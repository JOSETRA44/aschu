import '../models/driver_location_model.dart';
import '../models/vehicle_location_model.dart';

abstract class MapRemoteDataSource {
  // Vehicle Location methods
  Future<List<VehicleLocationModel>> getVehicleLocations();
  Future<VehicleLocationModel> getVehicleLocationById(String vehicleId);
  Future<void> updateVehicleLocation(VehicleLocationModel location);
  Stream<VehicleLocationModel> watchVehicleLocation(String vehicleId);

  // Driver Location methods (CRITICAL para Qawaqawa)
  Future<List<DriverLocationModel>> getDriverLocations();
  Future<DriverLocationModel> getDriverLocationById(String driverId);
  Future<void> updateDriverLocation(DriverLocationModel location);
  Stream<DriverLocationModel> watchDriverLocation(String driverId);
}
