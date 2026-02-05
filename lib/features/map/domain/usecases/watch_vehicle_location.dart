import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../entities/vehicle_location.dart';
import '../repositories/map_repository.dart';

@lazySingleton
class WatchVehicleLocation {
  const WatchVehicleLocation(this.repository);

  final MapRepository repository;

  Stream<Either<Failure, VehicleLocation>> call(String vehicleId) {
    return repository.watchVehicleLocation(vehicleId);
  }
}
