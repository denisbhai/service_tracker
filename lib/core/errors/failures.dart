// lib/core/errors/failures.dart

import 'package:equatable/equatable.dart';

/// Base failure class — all domain/data errors map to one of these.
/// This prevents raw exceptions from leaking into the UI layer.
abstract class Failure extends Equatable {
  final String message;
  final String? code;

  const Failure({required this.message, this.code});

  @override
  List<Object?> get props => [message, code];
}

/// Network-related failures (timeout, no connectivity, DNS)
class NetworkFailure extends Failure {
  const NetworkFailure({
    super.message = 'No internet connection. Please check your network.',
    super.code,
  });
}

/// Server returned a non-2xx response
class ServerFailure extends Failure {
  const ServerFailure({
    super.message = 'Server error. Please try again later.',
    super.code,
  });
}

/// Server returned 404
class NotFoundFailure extends Failure {
  const NotFoundFailure({
    super.message = 'The requested resource was not found.',
    super.code,
  });
}

/// JSON parsing or unexpected response shape
class ParseFailure extends Failure {
  const ParseFailure({
    super.message = 'Failed to parse server response.',
    super.code,
  });
}

/// Unexpected/unknown error
class UnexpectedFailure extends Failure {
  const UnexpectedFailure({
    super.message = 'An unexpected error occurred.',
    super.code,
  });
}

/// Local validation failure (form level)
class ValidationFailure extends Failure {
  const ValidationFailure({required super.message, super.code});
}
