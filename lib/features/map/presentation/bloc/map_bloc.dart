import 'dart:async';
import 'package:flutter/foundation.dart'; // Para debugPrint
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/services/location_permission_service.dart';
import '../../domain/entities/vehicle_location.dart';
import '../../domain/usecases/get_current_location.dart';
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
    this._getCurrentLocation,
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
    on<CheckPermissionsEvent>(_onCheckPermissions);
    on<CenterOnUserLocationEvent>(_onCenterOnUserLocation);
    on<DisposeMapEvent>(_onDispose);
  }

  final GetVehicleLocations _getVehicleLocations;
  final WatchVehicleLocation _watchVehicleLocation;
  final LocationPermissionService _locationPermissionService;
  final GetCurrentLocation _getCurrentLocation;

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
      // CRITICAL FIX: Hacer la verificación de permisos NON-BLOCKING
      // Problema: El chequeo síncrono bloquea el hilo principal (Davey! duration=1457ms)
      // Solución: Permitir que el mapa intente cargar en paralelo con permisos
      
      // STEP 1: Check location permissions asíncronamente (sin await bloqueante)
      _locationPermissionService.hasLocationPermission().then((hasPermission) {
        if (!hasPermission && !isClosed) {
          add(const RequestLocationPermissionEvent());
        }
      }).catchError((e) {
        debugPrint('⚠️ Permission check failed (non-blocking): $e');
      });

      // STEP 2: Continuar con inicialización del mapa SIN ESPERAR permisos
      // El mapa puede cargar en gris, pero no crashea la app

      // STEP 3: Cargar mapa INMEDIATAMENTE (sin bloquear por servicios de ubicación)
      // Verificamos servicios en paralelo, pero no bloqueamos la carga del mapa
      _locationPermissionService.isLocationServiceEnabled().then((serviceEnabled) {
        if (!serviceEnabled && !isClosed) {
          debugPrint('⚠️ Location services disabled, but map can still load');
          // No emitir error, solo advertencia
        }
      }).catchError((e) {
        debugPrint('⚠️ Location service check failed (non-blocking): $e');
      });

      // STEP 4: Inicializar con estado vacío para Challhuahuacho
      // Esto permite que el mapa se dibuje INMEDIATAMENTE
      emit(
        const MapLoaded(
          vehicles: [],
          hasLocationPermission: false, // Se actualizará cuando permisos estén listos
          isLocationEnabled: false, // Se actualizará con CheckPermissionsEvent
          currentCameraPosition: CameraPosition(
            target: LatLng(-14.1197, -72.2458),
            zoom: 14.0,
          ),
        ),
      );

      // STEP 5: Verificar permisos automáticamente después de inicializar
      // Esto detectará si ya se otorgaron permisos previamente
      add(const CheckPermissionsEvent());
      
      // STEP 6: Cargar ubicaciones de vehículos en paralelo (no bloqueante)
      add(const LoadVehicleLocationsEvent());
    } catch (e) {
      emit(MapError('Error al inicializar el mapa: ${e.toString()}'));
    }
  }

  /// Solicita permisos de ubicación usando Geolocator directamente
  Future<void> _onRequestPermission(
    RequestLocationPermissionEvent event,
    Emitter<MapState> emit,
  ) async {
    debugPrint('📍 RequestLocationPermission event received');
    
    try {
      // Verificar si los servicios de ubicación están habilitados
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      debugPrint('📡 Location services enabled: $serviceEnabled');
      
      if (!serviceEnabled) {
        debugPrint('❌ GPS disabled - showing error');
        emit(
          const MapError(
            'Los servicios de ubicación están deshabilitados.\n'
            'Por favor, activa el GPS en la configuración de tu dispositivo.',
            isPermissionError: true,
          ),
        );
        return;
      }

      // Verificar estado actual de permisos
      LocationPermission permission = await Geolocator.checkPermission();
      debugPrint('🔐 Current permission: $permission');

      if (permission == LocationPermission.denied) {
        debugPrint('🔔 Requesting permission...');
        permission = await Geolocator.requestPermission();
        debugPrint('📝 Permission after request: $permission');
      }

      if (permission == LocationPermission.deniedForever) {
        debugPrint('🚫 Permission denied forever');
        emit(
          const MapError(
            'Los permisos de ubicación fueron denegados permanentemente.\n'
            'Por favor, habilítalos manualmente en Configuración > Aplicaciones > Aschu > Permisos.',
            isPermissionError: true,
          ),
        );
        return;
      }

      if (permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always) {
        debugPrint('✅ Permission granted!');
        
        // Volver a cargar el mapa con permisos
        add(const InitializeMapEvent());
      } else {
        debugPrint('❌ Permission denied');
        emit(
          const MapError(
            'Permisos de ubicación denegados.\n'
            'La aplicación necesita acceso a tu ubicación para funcionar correctamente.',
            isPermissionError: true,
          ),
        );
      }
    } catch (e) {
      debugPrint('⚠️ Error requesting permission: $e');
      emit(
        MapError(
          'Error al solicitar permisos: ${e.toString()}',
          isPermissionError: true,
        ),
      );
    }
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

  /// Verifica permisos de ubicación (self-healing para app resume)
  Future<void> _onCheckPermissions(
    CheckPermissionsEvent event,
    Emitter<MapState> emit,
  ) async {
    debugPrint('🔍 CheckPermissions event received');
    
    if (state is! MapLoaded) {
      debugPrint('⚠️ State is not MapLoaded, skipping check');
      return;
    }

    final currentState = state as MapLoaded;

    try {
      // USAR GEOLOCATOR DIRECTAMENTE para verificación precisa
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      debugPrint('📍 Location services enabled: $serviceEnabled');
      
      // Verificar permisos con Geolocator
      final permission = await Geolocator.checkPermission();
      debugPrint('🔐 Permission status: $permission');
      
      final hasPermission = permission == LocationPermission.always ||
          permission == LocationPermission.whileInUse;
      
      debugPrint('✅ Has permission: $hasPermission');
      debugPrint('🎯 Location enabled: ${serviceEnabled && hasPermission}');

      // Actualizar estado con nueva info de permisos y servicios
      emit(
        currentState.copyWith(
          hasLocationPermission: hasPermission,
          isLocationEnabled: serviceEnabled && hasPermission,
        ),
      );

      debugPrint('🔄 State updated - isLocationEnabled: ${serviceEnabled && hasPermission}');

      // Si ahora tenemos permisos, centrar automáticamente
      if (hasPermission && serviceEnabled) {
        debugPrint('🎉 Permisos OK! Centrando cámara...');
        add(const CenterOnUserLocationEvent());
      } else {
        if (!serviceEnabled) debugPrint('❌ GPS deshabilitado');
        if (!hasPermission) debugPrint('❌ Sin permisos de ubicación');
      }
    } catch (e) {
      debugPrint('⚠️ CheckPermissions failed: $e');
      // No emitir error, mantener estado actual
    }
  }

  /// Centra la cámara en la ubicación actual del usuario
  Future<void> _onCenterOnUserLocation(
    CenterOnUserLocationEvent event,
    Emitter<MapState> emit,
  ) async {
    debugPrint('📍 CenterOnUserLocation event received');
    
    if (state is! MapLoaded) {
      debugPrint('⚠️ State is not MapLoaded');
      return;
    }
    
    if (_mapController == null) {
      debugPrint('⚠️ Map controller is null');
      return;
    }

    final currentState = state as MapLoaded;
    debugPrint('🎯 Current location enabled: ${currentState.isLocationEnabled}');

    try {
      debugPrint('📡 Getting current location...');
      // Usar el use case para obtener ubicación
      final result = await _getCurrentLocation();

      result.fold(
        (failure) {
          debugPrint('❌ No se pudo obtener ubicación: $failure');
          // No mostramos error al usuario, solo log
        },
        (position) async {
          debugPrint('✅ Ubicación obtenida: ${position.latitude}, ${position.longitude}');
          
          // Animar cámara a ubicación del usuario
          final target = LatLng(position.latitude, position.longitude);
          final cameraUpdate = CameraUpdate.newLatLngZoom(target, 16.0);
          
          debugPrint('🎥 Animando cámara...');
          await _mapController!.animateCamera(cameraUpdate);

          // Actualizar estado con nueva posición de cámara
          emit(
            currentState.copyWith(
              currentCameraPosition: CameraPosition(
                target: target,
                zoom: 16.0,
              ),
              isLocationEnabled: true,
            ),
          );

          debugPrint('🎉 Cámara centrada en ubicación del usuario!');
        },
      );
    } catch (e) {
      debugPrint('⚠️ Error al centrar en ubicación: $e');
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
