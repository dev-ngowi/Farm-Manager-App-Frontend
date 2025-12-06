/// Base class for all failures in the application
/// Failures represent errors that have been handled and converted to a domain-friendly format
abstract class Failure {
  final String message;
  
  const Failure(this.message);
  
  @override
  String toString() => message;
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Failure && other.message == message;
  }
  
  @override
  int get hashCode => message.hashCode;
}

/// Base class for all exceptions in the application
/// Exceptions represent raw errors before they're converted to Failures
abstract class AppException implements Exception {
  final String message;
  
  const AppException(this.message);
  
  @override
  String toString() => message;
}

// ========================================
// EXCEPTIONS (Thrown by data layer)
// ========================================

/// Server-related exceptions
class ServerException extends AppException {
  final int? statusCode;
  final dynamic response;
  
  const ServerException({
    String message = 'Server Error',
    this.statusCode,
    this.response,
  }) : super(message);
  
  @override
  String toString() => 'ServerException: $message (Status: $statusCode)';
}

/// Network connectivity exceptions
class NetworkException extends AppException {
  const NetworkException([
    String message = 'No internet connection. Please check your network.',
  ]) : super(message);
}

/// Cache-related exceptions
class CacheException extends AppException {
  const CacheException([
    String message = 'Failed to access local storage',
  ]) : super(message);
}

/// Authentication/Authorization exceptions
class AuthException extends AppException {
  const AuthException([
    String message = 'Authentication failed',
  ]) : super(message);
}

/// Validation exceptions (from backend)
class ValidationException extends AppException {
  final Map<String, dynamic>? errors;
  
  const ValidationException({
    String message = 'Validation failed',
    this.errors,
  }) : super(message);
  
  @override
  String toString() {
    if (errors != null && errors!.isNotEmpty) {
      return 'ValidationException: $message\nErrors: $errors';
    }
    return 'ValidationException: $message';
  }
}

// ========================================
// FAILURES (Returned by repository)
// ========================================

/// General server failures
class ServerFailure extends Failure {
  final int? statusCode;
  
  const ServerFailure([
    String message = 'Server Error Occurred',
    this.statusCode,
  ]) : super(message);
  
  factory ServerFailure.fromException(ServerException exception) {
    return ServerFailure(
      exception.message,
      exception.statusCode,
    );
  }
}

/// Network connectivity failures
class NetworkFailure extends Failure {
  const NetworkFailure([
    String message = 'No internet connection. Please check your network settings.',
  ]) : super(message);
  
  factory NetworkFailure.fromException(NetworkException exception) {
    return NetworkFailure(exception.message);
  }
}

/// Cache/Local storage failures
class CacheFailure extends Failure {
  const CacheFailure([
    String message = 'Failed to access local data',
  ]) : super(message);
  
  factory CacheFailure.fromException(CacheException exception) {
    return CacheFailure(exception.message);
  }
}

/// Authentication/Authorization failures
class AuthFailure extends Failure {
  const AuthFailure([
    String message = 'Authentication failed. Please login again.',
  ]) : super(message);
  
  factory AuthFailure.fromException(AuthException exception) {
    return AuthFailure(exception.message);
  }
}

/// Validation failures (with field-specific errors)
class ValidationFailure extends Failure {
  final Map<String, dynamic>? errors;
  
  const ValidationFailure(
    String message, {
    this.errors,
  }) : super(message);
  
  factory ValidationFailure.fromException(ValidationException exception) {
    return ValidationFailure(
      exception.message,
      errors: exception.errors,
    );
  }
  
  /// Get error message for a specific field
  String? getFieldError(String fieldName) {
    if (errors == null) return null;
    
    final fieldError = errors![fieldName];
    if (fieldError is List && fieldError.isNotEmpty) {
      return fieldError.first.toString();
    }
    if (fieldError is String) {
      return fieldError;
    }
    return null;
  }
  
  /// Check if a specific field has an error
  bool hasFieldError(String fieldName) {
    return errors?.containsKey(fieldName) ?? false;
  }
}

/// Failure for unexpected errors not covered by specific exceptions
class UnknownFailure extends Failure {
  const UnknownFailure([
    String message = 'An unexpected error occurred.',
  ]) : super(message);
}


// ========================================
// FARMER-SPECIFIC FAILURES (Retained for completeness)
// ========================================

/// Farmer registration specific failures
class FarmerRegistrationFailure extends Failure {
  final int? statusCode;
  final Map<String, dynamic>? validationErrors;
  final bool profileAlreadyExists;
  
  const FarmerRegistrationFailure(
    String message, {
    this.statusCode,
    this.validationErrors,
    this.profileAlreadyExists = false,
  }) : super(message);
  
  factory FarmerRegistrationFailure.alreadyExists({
    String message = 'Farmer profile already exists.',
  }) {
    return FarmerRegistrationFailure(
      message,
      statusCode: 409,
      profileAlreadyExists: true,
    );
  }
  
  factory FarmerRegistrationFailure.validationError(
    String message,
    Map<String, dynamic> errors,
  ) {
    return FarmerRegistrationFailure(
      message,
      statusCode: 422,
      validationErrors: errors,
    );
  }
  
  factory FarmerRegistrationFailure.notFound({
    String message = 'Farmer profile not found. Please complete registration.',
  }) {
    return FarmerRegistrationFailure(
      message,
      statusCode: 404,
    );
  }
  
  String? getFieldError(String fieldName) {
    if (validationErrors == null) return null;
    
    final fieldError = validationErrors![fieldName];
    if (fieldError is List && fieldError.isNotEmpty) {
      return fieldError.first.toString();
    }
    if (fieldError is String) {
      return fieldError;
    }
    return null;
  }
}

/// Farmer profile update failures
class FarmerProfileUpdateFailure extends Failure {
  final int? statusCode;
  final Map<String, dynamic>? validationErrors;
  
  const FarmerProfileUpdateFailure(
    String message, {
    this.statusCode,
    this.validationErrors,
  }) : super(message);
  
  factory FarmerProfileUpdateFailure.notFound() {
    return const FarmerProfileUpdateFailure(
      'Farmer profile not found.',
      statusCode: 404,
    );
  }
  
  factory FarmerProfileUpdateFailure.validationError(
    String message,
    Map<String, dynamic> errors,
  ) {
    return FarmerProfileUpdateFailure(
      message,
      statusCode: 422,
      validationErrors: errors,
    );
  }
}

// ========================================
// ⭐ VET-SPECIFIC FAILURES (NEW)
// ========================================

/// Vet registration specific failures
class VetRegistrationFailure extends Failure {
  final int? statusCode;
  final Map<String, dynamic>? validationErrors;
  final bool profileAlreadyExists;
  
  const VetRegistrationFailure(
    String message, {
    this.statusCode,
    this.validationErrors,
    this.profileAlreadyExists = false,
  }) : super(message);
  
  factory VetRegistrationFailure.alreadyExists({
    String message = 'Vet profile already exists.',
  }) {
    return VetRegistrationFailure(
      message,
      statusCode: 409,
      profileAlreadyExists: true,
    );
  }
  
  factory VetRegistrationFailure.validationError(
    String message,
    Map<String, dynamic> errors,
  ) {
    return VetRegistrationFailure(
      message,
      statusCode: 422,
      validationErrors: errors,
    );
  }
  
  factory VetRegistrationFailure.notFound({
    String message = 'Vet profile not found. Please complete registration.',
  }) {
    return VetRegistrationFailure(
      message,
      statusCode: 404,
    );
  }
  
  String? getFieldError(String fieldName) {
    if (validationErrors == null) return null;
    
    final fieldError = validationErrors![fieldName];
    if (fieldError is List && fieldError.isNotEmpty) {
      return fieldError.first.toString();
    }
    if (fieldError is String) {
      return fieldError;
    }
    return null;
  }
}

// ========================================
// ⭐ RESEARCHER-SPECIFIC FAILURES (NEW)
// ========================================

/// Researcher profile specific failures
class ResearcherProfileFailure extends Failure {
  final int? statusCode;
  final Map<String, dynamic>? validationErrors;
  final bool profileAlreadyExists;
  
  const ResearcherProfileFailure(
    String message, {
    this.statusCode,
    this.validationErrors,
    this.profileAlreadyExists = false,
  }) : super(message);
  
  factory ResearcherProfileFailure.alreadyExists({
    String message = 'Researcher profile details already submitted.',
  }) {
    return ResearcherProfileFailure(
      message,
      statusCode: 409,
      profileAlreadyExists: true,
    );
  }
  
  factory ResearcherProfileFailure.validationError(
    String message,
    Map<String, dynamic> errors,
  ) {
    return ResearcherProfileFailure(
      message,
      statusCode: 422,
      validationErrors: errors,
    );
  }
  
  factory ResearcherProfileFailure.notFound({
    String message = 'Researcher profile not found. Please complete registration.',
  }) {
    return ResearcherProfileFailure(
      message,
      statusCode: 404,
    );
  }
  
  String? getFieldError(String fieldName) {
    if (validationErrors == null) return null;
    
    final fieldError = validationErrors![fieldName];
    if (fieldError is List && fieldError.isNotEmpty) {
      return fieldError.first.toString();
    }
    if (fieldError is String) {
      return fieldError;
    }
    return null;
  }
}

// ========================================
// UTILITY FUNCTIONS (UPDATED)
// ========================================

/// Helper class to convert exceptions to failures
class FailureConverter {
  FailureConverter._();
  
  /// Convert any exception to appropriate Failure
  static Failure fromException(dynamic exception) {
    if (exception is ServerException) {
      // Handle specific status codes
      switch (exception.statusCode) {
        case 401:
        case 403:
          return AuthFailure(exception.message);
        
        case 404:
          return ServerFailure('Resource not found', exception.statusCode);
        
        case 409:
          // ⭐ UPDATED 409 CONFLICT HANDLING
          final responseMap = exception.response is Map ? exception.response as Map : null;
          final role = responseMap?['role'] as String?;

          if (role == 'farmer') {
             return FarmerRegistrationFailure.alreadyExists(
                message: exception.message,
             );
          } else if (role == 'vet') {
             return VetRegistrationFailure.alreadyExists( // ⭐ Use new VetRegistrationFailure
                message: exception.message,
             );
          }
          // Default 409 if role is unknown or not provided
          return ServerFailure('Conflict: Resource already exists.', exception.statusCode);
        
        case 422:
          // Try to extract validation errors from response
          Map<String, dynamic>? errors;
          if (exception.response is Map) {
            final responseMap = exception.response as Map;
            // The API response for 422 errors usually looks like:
            // {'message': '...', 'errors': {'field_name': ['error message']}}
            errors = responseMap['errors'] as Map<String, dynamic>?;
          }
          
          return ValidationFailure(
            exception.message,
            errors: errors,
          );
        
        case 500:
        case 502:
        case 503:
          return const ServerFailure('Server is temporarily unavailable. Please try again later.');
        
        default:
          return ServerFailure(exception.message, exception.statusCode);
      }
    }
    
    if (exception is NetworkException) {
      return NetworkFailure.fromException(exception);
    }
    
    if (exception is CacheException) {
      return CacheFailure.fromException(exception);
    }
    
    if (exception is AuthException) {
      return AuthFailure.fromException(exception);
    }
    
    if (exception is ValidationException) {
      // This is the ideal conversion path when ApiClient returns ValidationException
      return ValidationFailure.fromException(exception);
    }
    
    // Unknown exception
    return UnknownFailure('An unexpected error occurred: ${exception.toString()}');
  }

  // ⭐ NEW STATIC METHOD: Convert Failure object to a user-facing string
  static String toMessage(Failure failure) {
    // Prioritize showing a specific error from a ValidationFailure if available
    if (failure is ValidationFailure) {
      // If there are specific field errors, try to show the first one for simplicity
      if (failure.errors != null && failure.errors!.isNotEmpty) {
        final firstKey = failure.errors!.keys.first;
        final firstError = failure.getFieldError(firstKey);
        // Use the first specific error if available
        if (firstError != null) return firstError;
      }
    }
    
    // For all other failures, or if validation errors are generic, use the message defined in the Failure
    return failure.message;
  }
}