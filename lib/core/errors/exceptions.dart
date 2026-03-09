// lib/core/errors/exceptions.dart

/// Base exception class used in the data layer only.
/// These get mapped to [Failure] objects before reaching the domain/presentation layers.
class AppException implements Exception {
  final String message;
  final String? code;

  const AppException({required this.message, this.code});

  @override
  String toString() => 'AppException(message: $message, code: $code)';
}

class NetworkException extends AppException {
  const NetworkException({
    super.message = 'Network error',
    super.code,
  });
}

class ServerException extends AppException {
  final int? statusCode;

  const ServerException({
    super.message = 'Server error',
    this.statusCode,
    super.code,
  });
}

class NotFoundException extends AppException {
  const NotFoundException({
    super.message = 'Resource not found',
    super.code,
  });
}

class ParseException extends AppException {
  const ParseException({
    super.message = 'Failed to parse response',
    super.code,
  });
}
