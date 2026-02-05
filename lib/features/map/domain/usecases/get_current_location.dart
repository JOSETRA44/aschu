import 'package:dartz/dartz.dart';
import 'package:geolocator/geolocator.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/services/location_permission_service.dart';

/// GetCurrentLocationUseCase - Obtiene la ubicación actual del dispositivo
/// 
/// Arquitectura Clean:
/// - Domain Layer Use Case
/// - Maneja permisos y servicios de ubicación
/// - Retorna Either<Failure, Position> para error handling
/// 
/// Casos de Uso:
/// - Centrar mapa en ubicación del usuario
/// - Mostrar punto azul (myLocation)
/// - Actualizar posición del conductor
@injectable
class GetCurrentLocation {
  GetCurrentLocation(this._locationPermissionService);

  final LocationPermissionService _locationPermissionService;

  /// Obtiene la ubicación actual del dispositivo
  /// 
  /// Returns:
  /// - Right(Position): Ubicación obtenida exitosamente
  /// - Left(LocationServiceFailure): Servicios de ubicación deshabilitados
  /// - Left(PermissionFailure): Permisos denegados
  /// - Left(ServerFailure): Error al obtener ubicación
  Future<Either<Failure, Position>> call() async {
    try {
      // STEP 1: Verificar si los servicios de ubicación están habilitados
      final serviceEnabled = await _locationPermissionService.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return const Left(
          LocationFailure(['Los servicios de ubicación están deshabilitados']),
        );
      }

      // STEP 2: Verificar permisos
      final hasPermission = await _locationPermissionService.hasLocationPermission();
      if (!hasPermission) {
        return const Left(
          PermissionFailure(['Permisos de ubicación denegados']),
        );
      }

      // STEP 3: Obtener ubicación actual con timeout
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Timeout al obtener ubicación');
        },
      );

      return Right(position);
    } on PermissionDeniedException {
      return const Left(
        PermissionFailure(['Permisos de ubicación denegados por el usuario']),
      );
    } on LocationServiceDisabledException {
      return const Left(
        LocationFailure(['Los servicios de ubicación están deshabilitados']),
      );
    } catch (e) {
      return Left(
        ServerFailure(['Error al obtener ubicación: ${e.toString()}']),
      );
    }
  }
}
