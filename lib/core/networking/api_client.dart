import 'package:dio/dio.dart';
import 'package:farm_manager_app/core/config/env.dart';
import 'interceptors/auth_interceptor.dart';
import 'interceptors/logging_interceptor.dart';
import 'interceptors/error_interceptor.dart';

class ApiClient {
  static final Dio dio = Dio();

  static void init() {
    dio.options.baseUrl = Env.webBaseUrl; // Chrome uses localhost
    dio.options.connectTimeout = const Duration(seconds: 30);
    dio.options.receiveTimeout = const Duration(seconds: 30);

    dio.interceptors.addAll([
      AuthInterceptor(),
      LoggingInterceptor(),
      ErrorInterceptor(),
    ]);
  }
}