// lib/core/networking/interceptors/connectivity_interceptor.dart

import 'package:dio/dio.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

class ConnectivityInterceptor extends Interceptor {
  final InternetConnectionChecker _checker = InternetConnectionChecker.instance;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final bool isConnected = await _checker.hasConnection;

    if (!isConnected) {
      return handler.reject(
        DioException(
          requestOptions: options,
          message: 'No internet connection',
          type: DioExceptionType.connectionError,
        ),
      );
    }

    // Internet OK → continue
    handler.next(options);
  }
}