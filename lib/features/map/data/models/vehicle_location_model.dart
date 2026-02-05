import '../../domain/entities/vehicle_location.dart';

/// Data Model: Vehicle Location
class VehicleLocationModel extends VehicleLocation {
  const VehicleLocationModel({
    required super.vehicleId,
    required super.latitude,
    required super.longitude,
    required super.timestamp,
    super.heading,
    super.speed,
    super.driverName,
    super.vehicleType,
  });

  factory VehicleLocationModel.fromJson(Map<String, dynamic> json) {
    return VehicleLocationModel(
      vehicleId: json['vehicle_id'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      timestamp: DateTime.parse(json['timestamp'] as String),
      heading: json['heading'] != null
          ? (json['heading'] as num).toDouble()
          : null,
      speed: json['speed'] != null ? (json['speed'] as num).toDouble() : null,
      driverName: json['driver_name'] as String?,
      vehicleType: json['vehicle_type'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'vehicle_id': vehicleId,
      'latitude': latitude,
      'longitude': longitude,
      'timestamp': timestamp.toIso8601String(),
      if (heading != null) 'heading': heading,
      if (speed != null) 'speed': speed,
      if (driverName != null) 'driver_name': driverName,
      if (vehicleType != null) 'vehicle_type': vehicleType,
    };
  }

  factory VehicleLocationModel.fromEntity(VehicleLocation entity) {
    return VehicleLocationModel(
      vehicleId: entity.vehicleId,
      latitude: entity.latitude,
      longitude: entity.longitude,
      timestamp: entity.timestamp,
      heading: entity.heading,
      speed: entity.speed,
      driverName: entity.driverName,
      vehicleType: entity.vehicleType,
    );
  }
}
