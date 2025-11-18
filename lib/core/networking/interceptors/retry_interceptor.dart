// lib/core/networking/interceptors/retry_interceptor.dart

import 'package:dio/dio.dart';

class RetryInterceptor extends Interceptor {
  final Dio dio;
  RetryInterceptor({required this.dio});

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (_shouldRetry(err)) {
      try {
        final options = err.requestOptions;
        final response = await dio.fetch(options);
        handler.resolve(response);
      } catch (e) {
        handler.next(err);
      }
    } else {
      handler.next(err);
    }
  }

  bool _shouldRetry(DioException error) {
    return error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout ||
        (error.response?.statusCode != null &&
            error.response!.statusCode! >= 500);
  }
}