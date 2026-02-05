import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import '../../domain/entities/vehicle_location.dart';
import '../../domain/usecases/get_vehicle_locations.dart';
import '../../domain/usecases/watch_vehicle_location.dart';

part 'map_event.dart';
part 'map_state.dart';

@injectable
class MapBloc extends Bloc<MapEvent, MapState> {
  MapBloc(this._getVehicleLocations, this._watchVehicleLocation)
    : super(const MapInitial()) {
    on<InitializeMapEvent>(_onInitializeMap);
    on<LoadVehicleLocationsEvent>(_onLoadVehicleLocations);
    on<UpdateLocationEvent>(_onUpdateLocation);
    on<WatchVehicleEvent>(_onWatchVehicle);
  }

  final GetVehicleLocations _getVehicleLocations;
  final WatchVehicleLocation _watchVehicleLocation;

  StreamSubscription<dynamic>? _vehicleSubscription;

  Future<void> _onInitializeMap(
    InitializeMapEvent event,
    Emitter<MapState> emit,
  ) async {
    emit(const MapLoading());

    // Initialize with empty state for Challhuahuacho
    emit(const MapLoaded(vehicles: []));
  }

  Future<void> _onLoadVehicleLocations(
    LoadVehicleLocationsEvent event,
    Emitter<MapState> emit,
  ) async {
    emit(const MapLoading());

    final result = await _getVehicleLocations();

    result.fold(
      (failure) => emit(const MapError('Failed to load vehicle locations')),
      (vehicles) => emit(MapLoaded(vehicles: vehicles)),
    );
  }

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

  Future<void> _onWatchVehicle(
    WatchVehicleEvent event,
    Emitter<MapState> emit,
  ) async {
    await _vehicleSubscription?.cancel();

    _vehicleSubscription = _watchVehicleLocation(event.vehicleId).listen((
      result,
    ) {
      result.fold(
        (failure) => add(const LoadVehicleLocationsEvent()),
        (location) => add(UpdateLocationEvent(location)),
      );
    });
  }

  @override
  Future<void> close() {
    _vehicleSubscription?.cancel();
    return super.close();
  }
}
