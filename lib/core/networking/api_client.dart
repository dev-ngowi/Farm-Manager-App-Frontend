// lib/core/networking/api_client.dart

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../error/failure.dart'; // Import Failure and AppException
import '../config/env.dart';
// Assuming these interceptors exist or you will create them:
import 'interceptors/auth_interceptor.dart';
import 'interceptors/logging_interceptor.dart';
import 'interceptors/error_interceptor.dart';
import 'interceptors/connectivity_interceptor.dart';
// Assuming AppException and subclasses are here

/// A static class providing a centralized, robust API client 
/// with Dio initialization, interceptors, and functional error handling 
/// using dartz's Either<AppException, dynamic>.
class ApiClient {
  static final Dio dio = Dio();

  /// Initializes Dio with base configurations and adds interceptors.
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

  /// Generic request handler with comprehensive error handling.
  // ⭐ FIX: Changed return type to Either<AppException, dynamic>
  static Future<Either<AppException, dynamic>> handleRequest(
    Future<Response> Function() request,
  ) async {
    try {
      final response = await request();
      return Right(response.data);
      
    } on DioException catch (e) {
      // ⭐ FIX: Map DioException to AppException
      return Left(_handleDioException(e));
      
    } on AppException catch (e) {
      // Catch exceptions already thrown by interceptors (e.g., ConnectivityInterceptor)
      return Left(e);
      
    } catch (e) {
      // Catch any unexpected Dart errors and return ServerException
      return Left(ServerException(message: 'Unexpected error: ${e.toString()}'));
    }
  }

  /// Converts DioException to appropriate AppException subclass.
  // ⭐ FIX: Return type is AppException
  static AppException _handleDioException(DioException e) {
    // Case 1: Server responded (e.response is not null)
    if (e.response != null) {
      final statusCode = e.response!.statusCode;
      final data = e.response!.data;
      
      String message = 'Server error occurred';
      if (data is Map && data['message'] != null) {
        message = data['message'].toString();
      }
      
      // Extract validation errors if present
      Map<String, dynamic>? validationErrors;
      if (data is Map && data['errors'] != null) {
        if (data['errors'] is Map<String, dynamic>) {
            validationErrors = data['errors'] as Map<String, dynamic>;
        }
      }
      
      // Handle specific status codes
      switch (statusCode) {
        case 401:
        case 403:
          return AuthException(message.isNotEmpty ? message : 'Authentication failed. Please login again.');
        
        case 404:
          // Returns ServerException
          return ServerException(message: message.isNotEmpty ? message : 'Resource not found.', statusCode: statusCode, response: data);
        
        case 409:
          // Returns ServerException
          return ServerException(message: message.isNotEmpty ? message : 'Resource already exists.', statusCode: statusCode, response: data);

        
        case 422:
          // ⭐ CRITICAL FIX: Returns ValidationException
          return ValidationException(
            message: message.isNotEmpty ? message : 'Validation failed.',
            errors: validationErrors,
          );
        
        case 500:
        case 502:
        case 503:
          // Returns ServerException
          return ServerException(
            message: message.isNotEmpty ? message : 'Server is temporarily unavailable. Please try again later.',
            statusCode: statusCode,
            response: data,
          );
        
        default:
          return ServerException(message: message, statusCode: statusCode, response: data);
      }
    }
    
    // Case 2: No response from server - network/timeout issues (e.response is null)
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const NetworkException('Connection timeout. Please check your internet and try again.');
      
      case DioExceptionType.connectionError:
        return const NetworkException('No internet connection. Please check your network settings.');
      
      case DioExceptionType.badCertificate:
        return const NetworkException('Security certificate error. Please check your connection.');
      
      case DioExceptionType.cancel:
        return const ServerException(message: 'Request was cancelled.');
      
      case DioExceptionType.badResponse:
        return ServerException(message: e.message ?? 'A bad response was received.');
      
      case DioExceptionType.unknown:
      default:
        return ServerException(message: e.message ?? 'An unexpected network error occurred.');
    }
  }

  // ========================================
  // HTTP METHODS (Using the new return type)
  // ========================================

  /// GET request
  // ⭐ FIX: Return type is Either<AppException, dynamic>
  static Future<Either<AppException, dynamic>> get(
    String path, {
    Map<String, dynamic>? query,
    Map<String, dynamic>? headers, Map<String, dynamic>? queryParameters,
  }) async {
    return handleRequest(
      () => dio.get(
        path,
        queryParameters: query,
        options: headers != null ? Options(headers: headers) : null,
      ),
    );
  }

  /// POST request (for JSON data)
  // ⭐ FIX: Return type is Either<AppException, dynamic>
  static Future<Either<AppException, dynamic>> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? headers,
  }) async {
    return handleRequest(
      () => dio.post(
        path,
        data: data,
        options: headers != null ? Options(headers: headers) : null,
      ),
    );
  }

  /// POST with multipart/form-data (for file uploads)
  // ⭐ FIX: Return type is Either<AppException, dynamic>
  static Future<Either<AppException, dynamic>> postMultipart(
    String path, {
    required Map<String, dynamic> data,
    Map<String, dynamic>? headers,
    void Function(int sent, int total)? onSendProgress,
  }) async {
    return handleRequest(
      () => dio.post(
        path,
        data: FormData.fromMap(data),
        options: headers != null ? Options(headers: headers) : null,
        onSendProgress: onSendProgress,
      ),
    );
  }

  /// PUT request
  // ⭐ FIX: Return type is Either<AppException, dynamic>
  static Future<Either<AppException, dynamic>> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? headers,
  }) async {
    return handleRequest(
      () => dio.put(
        path,
        data: data,
        options: headers != null ? Options(headers: headers) : null,
      ),
    );
  }

  /// DELETE request
  // ⭐ FIX: Return type is Either<AppException, dynamic>
  static Future<Either<AppException, dynamic>> delete(
    String path, {
    Map<String, dynamic>? query,
    Map<String, dynamic>? headers,
  }) async {
    return handleRequest(
      () => dio.delete(
        path,
        queryParameters: query,
        options: headers != null ? Options(headers: headers) : null,
      ),
    );
  }

  /// PATCH request
  // ⭐ FIX: Return type is Either<AppException, dynamic>
  static Future<Either<AppException, dynamic>> patch(
    String path, {
    dynamic data,
    Map<String, dynamic>? query, // ⭐ ADDED query parameter
    Map<String, dynamic>? headers,
  }) async {
    return handleRequest(
      () => dio.patch(
        path,
        data: data,
        queryParameters: query, // ⭐ PASS query parameter to dio.patch
        options: headers != null ? Options(headers: headers) : null,
      ),
    );
  }
}