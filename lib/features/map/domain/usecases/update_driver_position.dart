import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../entities/driver_location.dart';
import '../repositories/map_repository.dart';

/// UseCase: UpdateDriverPosition
/// Actualiza la posición del conductor en tiempo real.
/// Usa Dartz Either<Failure, Success> para manejo robusto de errores.
/// 
/// CRITICAL para Qawaqawa: Maneja desconexión en cerros con retry logic.
@lazySingleton
class UpdateDriverPosition {
  const UpdateDriverPosition(this.repository);

  final MapRepository repository;

  /// Ejecuta la actualización de posición del conductor.
  /// 
  /// Returns:
  /// - Right(unit): Éxito
  /// - Left(NetworkFailure): Sin conexión (cerros)
  /// - Left(ServerFailure): Error del servidor
  /// - Left(CacheFailure): Error guardando localmente
  Future<Either<Failure, Unit>> call(UpdateDriverPositionParams params) async {
    return await repository.updateDriverLocation(params.location);
  }
}

/// Parámetros para UpdateDriverPosition UseCase
class UpdateDriverPositionParams extends Equatable {
  const UpdateDriverPositionParams({required this.location});

  final DriverLocation location;

  @override
  List<Object> get props => [location];
}
