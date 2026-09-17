import 'package:equatable/equatable.dart';

import 'exceptions.dart';

/// Domain-level error. Everything above the data layer speaks in [Failure]s.
///
/// [code] is a stable key the presentation layer can map to a localized
/// string, so error text never has to be hard-coded in a bloc.
sealed class Failure extends Equatable {
  const Failure({required this.code, this.message, this.statusCode});

  final String code;
  final String? message;
  final int? statusCode;

  @override
  List<Object?> get props => [code, message, statusCode];
}

class ServerFailure extends Failure {
  const ServerFailure({super.message, super.statusCode})
    : super(code: 'server_error');
}

class NetworkFailure extends Failure {
  const NetworkFailure({super.message}) : super(code: 'network_error');
}

class TimeoutFailure extends Failure {
  const TimeoutFailure({super.message}) : super(code: 'timeout_error');
}

class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure({super.message})
    : super(code: 'unauthorized_error', statusCode: 401);
}

class NotFoundFailure extends Failure {
  const NotFoundFailure({super.message})
    : super(code: 'not_found_error', statusCode: 404);
}

class CacheFailure extends Failure {
  const CacheFailure({super.message}) : super(code: 'cache_error');
}

class UnknownFailure extends Failure {
  const UnknownFailure({super.message}) : super(code: 'unknown_error');
}

extension AppExceptionToFailure on AppException {
  /// Single place where data-layer exceptions become domain failures.
  Failure toFailure() => switch (this) {
    NetworkException() => NetworkFailure(message: message),
    TimeoutException() => TimeoutFailure(message: message),
    UnauthorizedException() => UnauthorizedFailure(message: message),
    NotFoundException() => NotFoundFailure(message: message),
    CacheException() => CacheFailure(message: message),
    ParsingException() => UnknownFailure(message: message),
    ServerException() => ServerFailure(message: message, statusCode: statusCode),
  };
}
