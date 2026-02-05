import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:permission_handler/permission_handler.dart';
import '../error/failures.dart';

/// Service para manejar permisos de ubicación con Android 14/15 (SDK 34-36)
/// 
/// Cumple con los nuevos requisitos de permisos granulares de Android 14+:
/// - Ubicación precisa (ACCESS_FINE_LOCATION)
/// - Ubicación aproximada (ACCESS_COARSE_LOCATION)
/// - Ubicación en segundo plano (ACCESS_BACKGROUND_LOCATION)
@lazySingleton
class LocationPermissionService {
  /// Verifica si los permisos básicos de ubicación están concedidos
  Future<bool> hasLocationPermission() async {
    final fineLocation = await Permission.location.isGranted;
    final coarseLocation = await Permission.locationWhenInUse.isGranted;
    
    return fineLocation || coarseLocation;
  }

  /// Verifica si se tiene acceso a ubicación precisa (GPS)
  Future<bool> hasPreciseLocationPermission() async {
    return await Permission.location.isGranted;
  }

  /// Verifica si se tiene acceso a ubicación aproximada (Network)
  Future<bool> hasApproximateLocationPermission() async {
    return await Permission.locationWhenInUse.isGranted;
  }

  /// Solicita permisos de ubicación con manejo para Android 14/15
  /// 
  /// Returns:
  /// - Right(true): Permisos concedidos
  /// - Right(false): Permisos denegados
  /// - Left(PermissionFailure): Error en la solicitud
  Future<Either<Failure, bool>> requestLocationPermission({
    bool requestPrecise = true,
  }) async {
    try {
      // Android 14+ permite elegir entre ubicación precisa y aproximada
      // El sistema muestra automáticamente el diálogo con ambas opciones
      
      PermissionStatus status;
      
      if (requestPrecise) {
        // Solicitar ubicación precisa (GPS)
        status = await Permission.location.request();
      } else {
        // Solicitar ubicación aproximada (Network)
        status = await Permission.locationWhenInUse.request();
      }

      return Right(_handlePermissionStatus(status));
    } catch (e) {
      return Left(PermissionFailure(['Error requesting location permission: $e']));
    }
  }

  /// Solicita permiso de ubicación en segundo plano (Android 10+)
  /// 
  /// IMPORTANTE: Solo llamar después de obtener permisos de primer plano
  /// Android requiere que primero se concedan permisos foreground
  Future<Either<Failure, bool>> requestBackgroundLocationPermission() async {
    try {
      // Verificar que primero se tengan permisos de primer plano
      final hasForeground = await hasLocationPermission();
      if (!hasForeground) {
        return const Left(
          PermissionFailure([
            'Foreground location permission required before requesting background'
          ]),
        );
      }

      // Solicitar permiso de segundo plano
      final status = await Permission.locationAlways.request();
      
      return Right(_handlePermissionStatus(status));
    } catch (e) {
      return Left(
        PermissionFailure([
          'Error requesting background location permission: $e'
        ]),
      );
    }
  }

  /// Verifica el estado actual de los permisos y sugiere acción
  /// 
  /// Returns:
  /// - granted: Permisos concedidos
  /// - denied: Permisos denegados (puede volver a solicitar)
  /// - permanentlyDenied: Usuario seleccionó "No volver a preguntar"
  /// - restricted: Restricciones del sistema (control parental, etc.)
  Future<LocationPermissionStatus> checkPermissionStatus() async {
    final status = await Permission.location.status;
    
    if (status.isGranted) {
      return LocationPermissionStatus.granted;
    } else if (status.isPermanentlyDenied) {
      return LocationPermissionStatus.permanentlyDenied;
    } else if (status.isRestricted) {
      return LocationPermissionStatus.restricted;
    } else {
      return LocationPermissionStatus.denied;
    }
  }

  /// Abre la configuración de la app para que el usuario cambie permisos manualmente
  /// 
  /// Usar cuando el permiso está permanentlyDenied
  Future<bool> openAppSettings() async {
    return await openAppSettings();
  }

  /// Maneja el estado del permiso y retorna bool
  bool _handlePermissionStatus(PermissionStatus status) {
    return status.isGranted || status.isLimited;
  }

  /// Verifica si los servicios de ubicación están habilitados en el dispositivo
  Future<bool> isLocationServiceEnabled() async {
    return await Permission.location.serviceStatus.isEnabled;
  }

  /// Solicita habilitar servicios de ubicación del dispositivo
  /// 
  /// Nota: En Android 14+, esto solo puede mostrar un diálogo informativo
  /// El usuario debe habilitar la ubicación manualmente desde configuración
  Future<Either<Failure, bool>> requestEnableLocationService() async {
    try {
      final isEnabled = await isLocationServiceEnabled();
      
      if (!isEnabled) {
        // En Android moderno, solo podemos guiar al usuario a configuración
        // No podemos activar la ubicación programáticamente por seguridad
        return const Left(
          PermissionFailure([
            'Location services are disabled. Please enable them in device settings.'
          ]),
        );
      }
      
      return const Right(true);
    } catch (e) {
      return Left(
        PermissionFailure(['Error checking location service: $e']),
      );
    }
  }

  /// Flujo completo de solicitud de permisos para la app
  /// 
  /// 1. Verifica servicios de ubicación
  /// 2. Solicita permisos de primer plano
  /// 3. Opcionalmente solicita permisos de segundo plano
  /// 
  /// Este es el método recomendado para usar en la inicialización de la app
  Future<Either<Failure, LocationPermissionResult>> requestFullLocationAccess({
    bool requestPrecise = true,
    bool requestBackground = false,
  }) async {
    // 1. Verificar servicios de ubicación
    final serviceEnabled = await isLocationServiceEnabled();
    if (!serviceEnabled) {
      return const Left(
        PermissionFailure([
          'Location services must be enabled to use this feature'
        ]),
      );
    }

    // 2. Solicitar permisos de primer plano
    final foregroundResult = await requestLocationPermission(
      requestPrecise: requestPrecise,
    );

    return foregroundResult.fold(
      (failure) => Left(failure),
      (foregroundGranted) async {
        if (!foregroundGranted) {
          return Right(
            LocationPermissionResult(
              foregroundGranted: false,
              backgroundGranted: false,
              isPrecise: false,
            ),
          );
        }

        // 3. Opcionalmente solicitar permisos de segundo plano
        bool backgroundGranted = false;
        if (requestBackground) {
          final backgroundResult = await requestBackgroundLocationPermission();
          backgroundGranted = backgroundResult.getOrElse(() => false);
        }

        return Right(
          LocationPermissionResult(
            foregroundGranted: true,
            backgroundGranted: backgroundGranted,
            isPrecise: await hasPreciseLocationPermission(),
          ),
        );
      },
    );
  }
}

/// Estados posibles de permisos de ubicación
enum LocationPermissionStatus {
  granted,
  denied,
  permanentlyDenied,
  restricted,
}

/// Resultado completo de la solicitud de permisos
class LocationPermissionResult {
  const LocationPermissionResult({
    required this.foregroundGranted,
    required this.backgroundGranted,
    required this.isPrecise,
  });

  final bool foregroundGranted;
  final bool backgroundGranted;
  final bool isPrecise;

  bool get isFullyGranted => foregroundGranted;
  bool get hasMinimumPermissions => foregroundGranted;
}
