part of 'map_bloc.dart';

abstract class MapEvent extends Equatable {
  const MapEvent();

  @override
  List<Object?> get props => [];
}

/// Inicializar el mapa con verificación de permisos
class InitializeMapEvent extends MapEvent {
  const InitializeMapEvent();
}

/// Actualizar ubicación de un vehículo
class UpdateLocationEvent extends MapEvent {
  const UpdateLocationEvent(this.location);

  final VehicleLocation location;

  @override
  List<Object?> get props => [location];
}

/// Cargar todas las ubicaciones de vehículos
class LoadVehicleLocationsEvent extends MapEvent {
  const LoadVehicleLocationsEvent();
}

/// Observar ubicación de un vehículo específico en tiempo real
class WatchVehicleEvent extends MapEvent {
  const WatchVehicleEvent(this.vehicleId);

  final String vehicleId;

  @override
  List<Object?> get props => [vehicleId];
}

/// Evento cuando la cámara del mapa se mueve
class CameraMovedEvent extends MapEvent {
  const CameraMovedEvent(this.position);

  final CameraPosition position;

  @override
  List<Object?> get props => [position];
}

/// Evento cuando la cámara del mapa termina de moverse
class CameraIdleEvent extends MapEvent {
  const CameraIdleEvent(this.position);

  final CameraPosition position;

  @override
  List<Object?> get props => [position];
}

/// Mover la cámara a una posición específica
class MoveCameraEvent extends MapEvent {
  const MoveCameraEvent({
    required this.target,
    this.zoom,
    this.bearing,
    this.tilt,
  });

  final LatLng target;
  final double? zoom;
  final double? bearing;
  final double? tilt;

  @override
  List<Object?> get props => [target, zoom, bearing, tilt];
}

/// Centrar cámara en un vehículo específico
class FocusVehicleEvent extends MapEvent {
  const FocusVehicleEvent(this.vehicleId);

  final String vehicleId;

  @override
  List<Object?> get props => [vehicleId];
}

/// Solicitar permisos de ubicación
class RequestLocationPermissionEvent extends MapEvent {
  const RequestLocationPermissionEvent();
}

/// Limpiar recursos del mapa
class DisposeMapEvent extends MapEvent {
  const DisposeMapEvent();
}
