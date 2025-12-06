import 'package:dio/dio.dart';
import 'package:farm_manager_app/core/error/failure.dart'; // Import your exception classes

/// Utility class to handle DioExceptions and map them to appropriate AppExceptions
class NetworkExceptionHandler {
  NetworkExceptionHandler._();

  /// Handles DioException and converts it to a concrete AppException.
  static AppException handleDioException(DioException e, String defaultMessage) {
    final statusCode = e.response?.statusCode;
    final data = e.response?.data;

    print('❌ DioException: $statusCode - ${_extractErrorMessage(data)}');

    // Handle network exceptions (no connectivity, timeouts)
    if (e.type == DioExceptionType.connectionTimeout || 
        e.type == DioExceptionType.receiveTimeout || 
        e.type == DioExceptionType.sendTimeout ||
        e.type == DioExceptionType.badCertificate) {
      return const NetworkException('Connection error. Please try again.');
    }
    
    if (e.type == DioExceptionType.connectionError) {
      return const NetworkException();
    }
    
    // Handle specific HTTP status codes (Bad Response)
    switch (statusCode) {
      case 401:
      case 403:
        return AuthException(_extractErrorMessage(data));

      case 422:
        return ValidationException(
          message: _extractErrorMessage(data),
          errors: _extractValidationErrors(data),
        );
        
      case 409:
        // Pass 409 details to be converted later by FailureConverter
        return ServerException(
          message: _extractErrorMessage(data),
          statusCode: 409,
          response: data, // Crucial for FailureConverter to check the 'role'
        );

      default:
        // Use default message if API message is generic
        final apiMessage = _extractErrorMessage(data);
        return ServerException(
          message: apiMessage != 'An error occurred' ? apiMessage : defaultMessage,
          statusCode: statusCode,
        );
    }
  }

  /// Handles non-2xx responses that were intentionally NOT thrown by Dio.
  /// (Your current code doesn't use this, but it's good practice for 409/410 handling).
  static AppException handleResponse(Response response, String defaultMessage) {
    return ServerException(
      message: _extractErrorMessage(response.data) != 'An error occurred'
          ? _extractErrorMessage(response.data)
          : defaultMessage,
      statusCode: response.statusCode,
      response: response.data,
    );
  }

  /// Extracts error message from response data
  static String _extractErrorMessage(dynamic data) {
    if (data is! Map<String, dynamic>) {
      return 'An error occurred';
    }

    // Try message field
    if (data['message'] != null) {
      return data['message'].toString();
    }

    // Try error field
    if (data['error'] != null) {
      return data['error'].toString();
    }
    
    // Try first validation error
    final errors = _extractValidationErrors(data);
    if (errors != null && errors.isNotEmpty) {
      final firstError = errors.values.first;
      if (firstError is List && firstError.isNotEmpty) {
        return firstError.first.toString();
      }
      return firstError.toString();
    }

    return 'An error occurred';
  }

  /// Extract validation errors from response
  static Map<String, dynamic>? _extractValidationErrors(dynamic data) {
    if (data is Map<String, dynamic> && data['errors'] is Map) {
      return data['errors'] as Map<String, dynamic>;
    }
    return null;
  }
}