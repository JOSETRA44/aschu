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
  const MapLoaded({
    required this.vehicles,
    this.selectedVehicle,
    this.currentCameraPosition,
    this.hasLocationPermission = false,
    this.isLocationEnabled = false,
  });

  final List<VehicleLocation> vehicles;
  final VehicleLocation? selectedVehicle;
  final CameraPosition? currentCameraPosition;
  final bool hasLocationPermission;
  final bool isLocationEnabled;

  @override
  List<Object?> get props => [
        vehicles,
        selectedVehicle,
        currentCameraPosition,
        hasLocationPermission,
        isLocationEnabled,
      ];

  MapLoaded copyWith({
    List<VehicleLocation>? vehicles,
    VehicleLocation? selectedVehicle,
    CameraPosition? currentCameraPosition,
    bool? hasLocationPermission,
    bool? isLocationEnabled,
  }) {
    return MapLoaded(
      vehicles: vehicles ?? this.vehicles,
      selectedVehicle: selectedVehicle ?? this.selectedVehicle,
      currentCameraPosition:
          currentCameraPosition ?? this.currentCameraPosition,
      hasLocationPermission:
          hasLocationPermission ?? this.hasLocationPermission,
      isLocationEnabled: isLocationEnabled ?? this.isLocationEnabled,
    );
  }
}

class MapError extends MapState {
  const MapError(this.message, {this.isPermissionError = false});

  final String message;
  final bool isPermissionError;

  @override
  List<Object?> get props => [message, isPermissionError];
}

class MapWaitingPermission extends MapState {
  const MapWaitingPermission();
}
