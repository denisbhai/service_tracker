// lib/core/network/dio_client.dart

import 'package:dio/dio.dart';
import '../constants/app_constants.dart';
import '../errors/exceptions.dart';

class DioClient {
  late final Dio _dio;

  DioClient() {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.baseUrl,
        connectTimeout: const Duration(milliseconds: AppConstants.connectTimeout),
        receiveTimeout: const Duration(milliseconds: AppConstants.receiveTimeout),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _dio.interceptors.addAll([
      _LoggingInterceptor(),
      _ErrorInterceptor(),
    ]);
  }

  Dio get dio => _dio;
}

/// Logs request/response in debug mode — remove or gate behind kDebugMode in production.
class _LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // ignore: avoid_print
    print('[DIO] --> ${options.method} ${options.uri}');
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    // ignore: avoid_print
    print('[DIO] <-- ${response.statusCode} ${response.requestOptions.uri}');
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // ignore: avoid_print
    print('[DIO] ERROR ${err.type} ${err.message}');
    handler.next(err);
  }
}

/// Converts Dio errors → typed AppExceptions before they reach repositories.
class _ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        throw NetworkException(message: 'Request timed out. Check your connection.');

      case DioExceptionType.connectionError:
        throw const NetworkException(message: 'No internet connection.');

      case DioExceptionType.badResponse:
        final statusCode = err.response?.statusCode;
        if (statusCode == 404) {
          throw NotFoundException(message: 'Resource not found ($statusCode).');
        }
        if (statusCode != null && statusCode >= 500) {
          throw ServerException(
            message: 'Server error ($statusCode). Please try again.',
            statusCode: statusCode,
          );
        }
        throw ServerException(
          message: 'Request failed with status $statusCode.',
          statusCode: statusCode,
        );

      default:
        throw AppException(message: err.message ?? 'Unknown network error.');
    }
  }
}
