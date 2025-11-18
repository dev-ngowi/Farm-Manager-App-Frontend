// core/networking/interceptors/error_interceptor.dart

import 'package:dio/dio.dart';
import 'package:farm_manager_app/core/error/failure.dart';

class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    String message = 'Something went wrong. Please try again.';

    if (err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.sendTimeout) {
      message = 'Connection timeout. Please check your internet and try again.';
    } else if (err.type == DioExceptionType.badResponse) {
      message = 'Server error. Please try again later.';
    } else if (err.response == null && err.message!.contains('SocketException')) {
      message = 'No internet connection. Please connect and try again.';
    }

    final failure = ServerFailure(message);
    handler.next(err.copyWith(error: failure));
  }
}