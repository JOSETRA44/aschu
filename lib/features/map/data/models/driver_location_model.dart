import '../../domain/entities/driver_location.dart';

/// Model: DriverLocationModel
/// Extiende DriverLocation entity con métodos de serialización.
/// Maneja conversión desde/hacia Supabase JSON.
class DriverLocationModel extends DriverLocation {
  const DriverLocationModel({
    required super.driverId,
    required super.latitude,
    required super.longitude,
    required super.timestamp,
    super.accuracy,
    super.altitude,
    super.heading,
    super.speed,
    super.driverName,
    super.phoneNumber,
    super.isOnline,
    super.currentVehicleId,
  });

  /// Factory constructor desde JSON (Supabase response)
  factory DriverLocationModel.fromJson(Map<String, dynamic> json) {
    return DriverLocationModel(
      driverId: json['driver_id'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      timestamp: DateTime.parse(json['timestamp'] as String),
      accuracy: json['accuracy'] != null
          ? (json['accuracy'] as num).toDouble()
          : null,
      altitude: json['altitude'] != null
          ? (json['altitude'] as num).toDouble()
          : null,
      heading:
          json['heading'] != null ? (json['heading'] as num).toDouble() : null,
      speed: json['speed'] != null ? (json['speed'] as num).toDouble() : null,
      driverName: json['driver_name'] as String?,
      phoneNumber: json['phone_number'] as String?,
      isOnline: json['is_online'] as bool?,
      currentVehicleId: json['current_vehicle_id'] as String?,
    );
  }

  /// Convierte a JSON para Supabase insert/update
  Map<String, dynamic> toJson() {
    return {
      'driver_id': driverId,
      'latitude': latitude,
      'longitude': longitude,
      'timestamp': timestamp.toIso8601String(),
      if (accuracy != null) 'accuracy': accuracy,
      if (altitude != null) 'altitude': altitude,
      if (heading != null) 'heading': heading,
      if (speed != null) 'speed': speed,
      if (driverName != null) 'driver_name': driverName,
      if (phoneNumber != null) 'phone_number': phoneNumber,
      if (isOnline != null) 'is_online': isOnline,
      if (currentVehicleId != null) 'current_vehicle_id': currentVehicleId,
    };
  }

  /// Convierte Entity a Model (para actualizar)
  factory DriverLocationModel.fromEntity(DriverLocation entity) {
    return DriverLocationModel(
      driverId: entity.driverId,
      latitude: entity.latitude,
      longitude: entity.longitude,
      timestamp: entity.timestamp,
      accuracy: entity.accuracy,
      altitude: entity.altitude,
      heading: entity.heading,
      speed: entity.speed,
      driverName: entity.driverName,
      phoneNumber: entity.phoneNumber,
      isOnline: entity.isOnline,
      currentVehicleId: entity.currentVehicleId,
    );
  }
}
