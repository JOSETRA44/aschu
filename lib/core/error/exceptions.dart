class ServerException implements Exception {
  const ServerException([this.message]);

  final String? message;
}

class CacheException implements Exception {
  const CacheException([this.message]);

  final String? message;
}

class NetworkException implements Exception {
  const NetworkException([this.message]);

  final String? message;
}

class LocationException implements Exception {
  const LocationException([this.message]);

  final String? message;
}

class PermissionException implements Exception {
  const PermissionException([this.message]);

  final String? message;
}
