import 'package:equatable/equatable.dart';

/// Entity: DriverLocation
/// Representa la ubicación de un conductor en tiempo real.
/// Separado de VehicleLocation para cumplir Single Responsibility Principle.
/// 
/// Para Qawaqawa: Conductores comparten vehículos, ubicación del conductor != vehículo
class DriverLocation extends Equatable {
  const DriverLocation({
    required this.driverId,
    required this.latitude,
    required this.longitude,
    required this.timestamp,
    this.accuracy,
    this.altitude,
    this.heading,
    this.speed,
    this.driverName,
    this.phoneNumber,
    this.isOnline,
    this.currentVehicleId,
  });

  final String driverId;
  final double latitude;
  final double longitude;
  final DateTime timestamp;
  final double? accuracy; // Precisión en metros
  final double? altitude;
  final double? heading; // Dirección en grados (0-360)
  final double? speed; // Velocidad en m/s
  final String? driverName;
  final String? phoneNumber;
  final bool? isOnline;
  final String? currentVehicleId; // Si está asignado a un vehículo

  @override
  List<Object?> get props => [
        driverId,
        latitude,
        longitude,
        timestamp,
        accuracy,
        altitude,
        heading,
        speed,
        driverName,
        phoneNumber,
        isOnline,
        currentVehicleId,
      ];

  DriverLocation copyWith({
    String? driverId,
    double? latitude,
    double? longitude,
    DateTime? timestamp,
    double? accuracy,
    double? altitude,
    double? heading,
    double? speed,
    String? driverName,
    String? phoneNumber,
    bool? isOnline,
    String? currentVehicleId,
  }) {
    return DriverLocation(
      driverId: driverId ?? this.driverId,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      timestamp: timestamp ?? this.timestamp,
      accuracy: accuracy ?? this.accuracy,
      altitude: altitude ?? this.altitude,
      heading: heading ?? this.heading,
      speed: speed ?? this.speed,
      driverName: driverName ?? this.driverName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      isOnline: isOnline ?? this.isOnline,
      currentVehicleId: currentVehicleId ?? this.currentVehicleId,
    );
  }
}
