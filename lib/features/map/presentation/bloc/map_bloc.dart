import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/services/location_permission_service.dart';
import '../../domain/entities/vehicle_location.dart';
import '../../domain/usecases/get_vehicle_locations.dart';
import '../../domain/usecases/watch_vehicle_location.dart';

part 'map_event.dart';
part 'map_state.dart';

/// MapBloc optimizado para Flutter 3.27+ con Impeller
/// 
/// Maneja:
/// - Ciclo de vida del mapa y controlador
/// - Eventos de cámara y movimiento
/// - Permisos de ubicación (Android 14/15)
/// - Actualizaciones de vehículos en tiempo real
/// - Prevención de memory leaks
@injectable
class MapBloc extends Bloc<MapEvent, MapState> {
  MapBloc(
    this._getVehicleLocations,
    this._watchVehicleLocation,
    this._locationPermissionService,
  ) : super(const MapInitial()) {
    on<InitializeMapEvent>(_onInitializeMap);
    on<LoadVehicleLocationsEvent>(_onLoadVehicleLocations);
    on<UpdateLocationEvent>(_onUpdateLocation);
    on<WatchVehicleEvent>(_onWatchVehicle);
    on<CameraMovedEvent>(_onCameraMoved);
    on<CameraIdleEvent>(_onCameraIdle);
    on<MoveCameraEvent>(_onMoveCamera);
    on<FocusVehicleEvent>(_onFocusVehicle);
    on<RequestLocationPermissionEvent>(_onRequestPermission);
    on<DisposeMapEvent>(_onDispose);
  }

  final GetVehicleLocations _getVehicleLocations;
  final WatchVehicleLocation _watchVehicleLocation;
  final LocationPermissionService _locationPermissionService;

  // Subscripciones y controladores
  StreamSubscription<dynamic>? _vehicleSubscription;
  GoogleMapController? _mapController;
  
  // Cache de última posición de cámara para evitar updates innecesarios
  CameraPosition? _lastCameraPosition;

  /// Inicializa el mapa con verificación de permisos
  Future<void> _onInitializeMap(
    InitializeMapEvent event,
    Emitter<MapState> emit,
  ) async {
    emit(const MapLoading());

    try {
      // 1. Verificar permisos de ubicación
      final hasPermission = await _locationPermissionService.hasLocationPermission();

      if (!hasPermission) {
        emit(const MapWaitingPermission());
        return;
      }

      // 2. Verificar servicio de ubicación habilitado
      final serviceEnabled = await _locationPermissionService.isLocationServiceEnabled();
      
      if (!serviceEnabled) {
        emit(
          const MapError(
            'Los servicios de ubicación están deshabilitados. '
            'Por favor, habilítalos en la configuración del dispositivo.',
            isPermissionError: true,
          ),
        );
        return;
      }

      // 3. Inicializar con estado vacío para Challhuahuacho
      emit(
        MapLoaded(
          vehicles: const [],
          hasLocationPermission: true,
          currentCameraPosition: CameraPosition(
            target: const LatLng(-14.1197, -72.2458),
            zoom: 14.0,
          ),
        ),
      );
    } catch (e) {
      emit(MapError('Error al inicializar el mapa: ${e.toString()}'));
    }
  }

  /// Solicita permisos de ubicación
  Future<void> _onRequestPermission(
    RequestLocationPermissionEvent event,
    Emitter<MapState> emit,
  ) async {
    emit(const MapWaitingPermission());

    final result = await _locationPermissionService.requestFullLocationAccess(
      requestPrecise: true,
      requestBackground: false,
    );

    result.fold(
      (failure) {
        emit(
          const MapError(
            'No se pudieron obtener los permisos de ubicación. '
            'La aplicación requiere acceso a tu ubicación para funcionar.',
            isPermissionError: true,
          ),
        );
      },
      (permissionResult) {
        if (permissionResult.foregroundGranted) {
          // Re-inicializar el mapa ahora que tenemos permisos
          add(const InitializeMapEvent());
        } else {
          emit(
            const MapError(
              'Permisos de ubicación denegados. '
              'Por favor, habilítalos en la configuración de la aplicación.',
              isPermissionError: true,
            ),
          );
        }
      },
    );
  }

  /// Carga todas las ubicaciones de vehículos
  Future<void> _onLoadVehicleLocations(
    LoadVehicleLocationsEvent event,
    Emitter<MapState> emit,
  ) async {
    // Mantener estado actual mientras carga
    final currentState = state;
    if (currentState is MapLoaded) {
      emit(currentState.copyWith());
    } else {
      emit(const MapLoading());
    }

    final result = await _getVehicleLocations();

    result.fold(
      (failure) {
        if (currentState is MapLoaded) {
          // Mantener vehículos actuales en caso de error
          emit(currentState);
        } else {
          emit(const MapError('Error al cargar ubicaciones de vehículos'));
        }
      },
      (vehicles) {
        if (currentState is MapLoaded) {
          emit(
            currentState.copyWith(
              vehicles: vehicles,
            ),
          );
        } else {
          emit(
            MapLoaded(
              vehicles: vehicles,
              hasLocationPermission: true,
            ),
          );
        }
      },
    );
  }

  /// Actualiza la ubicación de un vehículo específico
  void _onUpdateLocation(UpdateLocationEvent event, Emitter<MapState> emit) {
    if (state is MapLoaded) {
      final currentState = state as MapLoaded;
      final updatedVehicles = List<VehicleLocation>.from(currentState.vehicles);

      final index = updatedVehicles.indexWhere(
        (v) => v.vehicleId == event.location.vehicleId,
      );

      if (index != -1) {
        updatedVehicles[index] = event.location;
      } else {
        updatedVehicles.add(event.location);
      }

      emit(currentState.copyWith(vehicles: updatedVehicles));
    }
  }

  /// Observa un vehículo específico en tiempo real
  Future<void> _onWatchVehicle(
    WatchVehicleEvent event,
    Emitter<MapState> emit,
  ) async {
    // Cancelar suscripción anterior
    await _vehicleSubscription?.cancel();

    _vehicleSubscription = _watchVehicleLocation(event.vehicleId).listen(
      (result) {
        result.fold(
          (failure) => add(const LoadVehicleLocationsEvent()),
          (location) => add(UpdateLocationEvent(location)),
        );
      },
    );
  }

  /// Maneja el evento cuando la cámara se mueve
  void _onCameraMoved(CameraMovedEvent event, Emitter<MapState> emit) {
    // Actualizar posición de cámara sin emitir nuevo estado
    // Esto previene rebuilds innecesarios durante el drag
    _lastCameraPosition = event.position;
  }

  /// Maneja el evento cuando la cámara termina de moverse
  void _onCameraIdle(CameraIdleEvent event, Emitter<MapState> emit) {
    if (state is MapLoaded) {
      final currentState = state as MapLoaded;
      
      // Solo emitir si la posición realmente cambió
      if (_lastCameraPosition != currentState.currentCameraPosition) {
        emit(
          currentState.copyWith(
            currentCameraPosition: event.position,
          ),
        );
      }
    }
  }

  /// Mueve la cámara a una posición específica
  void _onMoveCamera(MoveCameraEvent event, Emitter<MapState> emit) {
    if (_mapController != null) {
      final cameraUpdate = CameraUpdate.newLatLngZoom(
        event.target,
        event.zoom ?? 14.0,
      );
      
      _mapController!.animateCamera(cameraUpdate);
    }
  }

  /// Centra la cámara en un vehículo específico
  void _onFocusVehicle(FocusVehicleEvent event, Emitter<MapState> emit) {
    if (state is MapLoaded) {
      final currentState = state as MapLoaded;
      
      final vehicle = currentState.vehicles.firstWhere(
        (v) => v.vehicleId == event.vehicleId,
        orElse: () => throw Exception('Vehicle not found'),
      );

      // Mover cámara al vehículo
      add(
        MoveCameraEvent(
          target: LatLng(vehicle.latitude, vehicle.longitude),
          zoom: 16.0,
        ),
      );

      // Seleccionar vehículo
      emit(currentState.copyWith(selectedVehicle: vehicle));
    }
  }

  /// Limpia recursos al cerrar
  void _onDispose(DisposeMapEvent event, Emitter<MapState> emit) {
    _vehicleSubscription?.cancel();
    _mapController?.dispose();
    _mapController = null;
    _lastCameraPosition = null;
  }

  /// Establece el controlador del mapa (llamado desde el widget)
  void setMapController(GoogleMapController controller) {
    _mapController = controller;
  }

  @override
  Future<void> close() {
    _vehicleSubscription?.cancel();
    _mapController?.dispose();
    return super.close();
  }
}
