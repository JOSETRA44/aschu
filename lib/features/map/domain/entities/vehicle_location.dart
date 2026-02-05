import 'package:equatable/equatable.dart';

/// Domain Entity: Vehicle Location
class VehicleLocation extends Equatable {
  const VehicleLocation({
    required this.vehicleId,
    required this.latitude,
    required this.longitude,
    required this.timestamp,
    this.heading,
    this.speed,
    this.driverName,
    this.vehicleType,
  });

  final String vehicleId;
  final double latitude;
  final double longitude;
  final DateTime timestamp;
  final double? heading;
  final double? speed;
  final String? driverName;
  final String? vehicleType;

  @override
  List<Object?> get props => [
    vehicleId,
    latitude,
    longitude,
    timestamp,
    heading,
    speed,
    driverName,
    vehicleType,
  ];

  VehicleLocation copyWith({
    String? vehicleId,
    double? latitude,
    double? longitude,
    DateTime? timestamp,
    double? heading,
    double? speed,
    String? driverName,
    String? vehicleType,
  }) {
    return VehicleLocation(
      vehicleId: vehicleId ?? this.vehicleId,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      timestamp: timestamp ?? this.timestamp,
      heading: heading ?? this.heading,
      speed: speed ?? this.speed,
      driverName: driverName ?? this.driverName,
      vehicleType: vehicleType ?? this.vehicleType,
    );
  }
}
