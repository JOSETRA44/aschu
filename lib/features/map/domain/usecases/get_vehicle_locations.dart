import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../entities/vehicle_location.dart';
import '../repositories/map_repository.dart';

@lazySingleton
class GetVehicleLocations {
  const GetVehicleLocations(this.repository);

  final MapRepository repository;

  Future<Either<Failure, List<VehicleLocation>>> call() async {
    return await repository.getVehicleLocations();
  }
}
