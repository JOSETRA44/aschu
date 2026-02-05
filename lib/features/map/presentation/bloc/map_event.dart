part of 'map_bloc.dart';

abstract class MapEvent extends Equatable {
  const MapEvent();

  @override
  List<Object?> get props => [];
}

class InitializeMapEvent extends MapEvent {
  const InitializeMapEvent();
}

class UpdateLocationEvent extends MapEvent {
  const UpdateLocationEvent(this.location);

  final VehicleLocation location;

  @override
  List<Object?> get props => [location];
}

class LoadVehicleLocationsEvent extends MapEvent {
  const LoadVehicleLocationsEvent();
}

class WatchVehicleEvent extends MapEvent {
  const WatchVehicleEvent(this.vehicleId);

  final String vehicleId;

  @override
  List<Object?> get props => [vehicleId];
}
