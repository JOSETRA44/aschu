import '../models/vehicle_location_model.dart';

abstract class MapRemoteDataSource {
  Future<List<VehicleLocationModel>> getVehicleLocations();
  Future<VehicleLocationModel> getVehicleLocationById(String vehicleId);
  Future<void> updateVehicleLocation(VehicleLocationModel location);
  Stream<VehicleLocationModel> watchVehicleLocation(String vehicleId);
}
