import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../error/failure.dart';
import '../config/env.dart';
import 'interceptors/auth_interceptor.dart';
import 'interceptors/logging_interceptor.dart';
import 'interceptors/error_interceptor.dart';
import 'interceptors/connectivity_interceptor.dart';

class ApiClient {
  static final Dio dio = Dio();

  static void init() {
    dio.options.baseUrl = Env.webBaseUrl;
    dio.options.connectTimeout = const Duration(seconds: 30);
    dio.options.receiveTimeout = const Duration(seconds: 30);

    dio.interceptors.addAll([
      AuthInterceptor(),
      LoggingInterceptor(),
      ConnectivityInterceptor(),
      ErrorInterceptor(),
    ]);
  }

  static Future<Either<Failure, dynamic>> handleRequest(Future<Response> Function() request) async {
    try {
      final response = await request();
      return Right(response.data);
    } on DioException catch (e) {
      return Left(ServerFailure(e.message ?? 'Server error'));
    } catch (e) {
      return Left(ServerFailure('Unexpected error'));
    }
  }

  static Future<Either<Failure, dynamic>> get(String path, {Map<String, dynamic>? query}) async {
    return handleRequest(() => dio.get(path, queryParameters: query));
  }

  static Future<Either<Failure, dynamic>> post(String path, {dynamic data}) async {
    return handleRequest(() => dio.post(path, data: data));
  }
}