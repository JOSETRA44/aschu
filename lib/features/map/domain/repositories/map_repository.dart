import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/vehicle_location.dart';

abstract class MapRepository {
  Future<Either<Failure, List<VehicleLocation>>> getVehicleLocations();
  Future<Either<Failure, VehicleLocation>> getVehicleLocationById(
    String vehicleId,
  );
  Future<Either<Failure, Unit>> updateVehicleLocation(VehicleLocation location);
  Stream<Either<Failure, VehicleLocation>> watchVehicleLocation(
    String vehicleId,
  );
}
