import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/driver_location.dart';
import '../entities/vehicle_location.dart';

abstract class MapRepository {
  // Vehicle Location methods
  Future<Either<Failure, List<VehicleLocation>>> getVehicleLocations();
  Future<Either<Failure, VehicleLocation>> getVehicleLocationById(
    String vehicleId,
  );
  Future<Either<Failure, Unit>> updateVehicleLocation(VehicleLocation location);
  Stream<Either<Failure, VehicleLocation>> watchVehicleLocation(
    String vehicleId,
  );

  // Driver Location methods (CRITICAL para Qawaqawa)
  Future<Either<Failure, List<DriverLocation>>> getDriverLocations();
  Future<Either<Failure, DriverLocation>> getDriverLocationById(String driverId);
  Future<Either<Failure, Unit>> updateDriverLocation(DriverLocation location);
  Stream<Either<Failure, DriverLocation>> watchDriverLocation(String driverId);
}

