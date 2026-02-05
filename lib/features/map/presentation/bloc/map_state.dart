part of 'map_bloc.dart';

abstract class MapState extends Equatable {
  const MapState();

  @override
  List<Object?> get props => [];
}

class MapInitial extends MapState {
  const MapInitial();
}

class MapLoading extends MapState {
  const MapLoading();
}

class MapLoaded extends MapState {
  const MapLoaded({required this.vehicles, this.selectedVehicle});

  final List<VehicleLocation> vehicles;
  final VehicleLocation? selectedVehicle;

  @override
  List<Object?> get props => [vehicles, selectedVehicle];

  MapLoaded copyWith({
    List<VehicleLocation>? vehicles,
    VehicleLocation? selectedVehicle,
  }) {
    return MapLoaded(
      vehicles: vehicles ?? this.vehicles,
      selectedVehicle: selectedVehicle ?? this.selectedVehicle,
    );
  }
}

class MapError extends MapState {
  const MapError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
