import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/vehicle_location.dart';
import '../../domain/repositories/map_repository.dart';
import '../datasources/map_remote_datasource.dart';
import '../models/vehicle_location_model.dart';

@LazySingleton(as: MapRepository)
class MapRepositoryImpl implements MapRepository {
  const MapRepositoryImpl(this.remoteDataSource);

  final MapRemoteDataSource remoteDataSource;

  @override
  Future<Either<Failure, List<VehicleLocation>>> getVehicleLocations() async {
    try {
      final locations = await remoteDataSource.getVehicleLocations();
      return Right(locations.cast<VehicleLocation>());
    } on ServerException {
      return const Left(ServerFailure());
    } on NetworkException {
      return const Left(NetworkFailure());
    } catch (_) {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, VehicleLocation>> getVehicleLocationById(
    String vehicleId,
  ) async {
    try {
      final location = await remoteDataSource.getVehicleLocationById(vehicleId);
      return Right(location as VehicleLocation);
    } on ServerException {
      return const Left(ServerFailure());
    } on NetworkException {
      return const Left(NetworkFailure());
    } catch (_) {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, Unit>> updateVehicleLocation(
    VehicleLocation location,
  ) async {
    try {
      final model = VehicleLocationModel.fromEntity(location);
      await remoteDataSource.updateVehicleLocation(model);
      return const Right(unit);
    } on ServerException {
      return const Left(ServerFailure());
    } on NetworkException {
      return const Left(NetworkFailure());
    } catch (_) {
      return const Left(ServerFailure());
    }
  }

  @override
  Stream<Either<Failure, VehicleLocation>> watchVehicleLocation(
    String vehicleId,
  ) {
    try {
      return remoteDataSource
          .watchVehicleLocation(vehicleId)
          .map(
            (location) =>
                Right<Failure, VehicleLocation>(location as VehicleLocation),
          )
          .handleError((error) {
            if (error is ServerException) {
              return const Left(ServerFailure());
            } else if (error is NetworkException) {
              return const Left(NetworkFailure());
            }
            return const Left(ServerFailure());
          });
    } catch (_) {
      return Stream.value(const Left(ServerFailure()));
    }
  }
}
