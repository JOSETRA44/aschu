import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  const Failure([this.properties = const <dynamic>[]]);

  final List properties;

  @override
  List<Object> get props => [properties];
}

// General failures
class ServerFailure extends Failure {
  const ServerFailure([super.properties]);
}

class CacheFailure extends Failure {
  const CacheFailure([super.properties]);
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.properties]);
}

class LocationFailure extends Failure {
  const LocationFailure([super.properties]);
}

class PermissionFailure extends Failure {
  const PermissionFailure([super.properties]);
}
