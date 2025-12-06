import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:farm_manager_app/core/networking/api_endpoints.dart';
import 'package:farm_manager_app/features/auth/data/models/user_model.dart';
import 'package:http_parser/http_parser.dart';

import '../../../../../core/error/failure.dart';
import '../../models/farmer_details_model.dart';

/// Abstract contract for farmer-related remote operations
abstract class FarmerRemoteDataSource {
  /// Submit farmer registration details
  Future<UserModel> submitFarmerDetails(
    FarmerDetailsModel details,
    String token, {
    String? profilePhotoBase64,
  });
  
  /// Fetch farmer profile
  Future<Map<String, dynamic>> getFarmerProfile(String token);
  
  /// Update farmer profile
  Future<Map<String, dynamic>> updateFarmerProfile(
    Map<String, dynamic> updates,
    String token, {
    String? profilePhotoBase64,
  });
}

class FarmerRemoteDataSourceImpl implements FarmerRemoteDataSource {
  final Dio dio;

  FarmerRemoteDataSourceImpl({required this.dio});

  // ========================================
  // SUBMIT FARMER DETAILS (REGISTRATION)
  // ========================================

  @override
  Future<UserModel> submitFarmerDetails(
    FarmerDetailsModel details,
    String token, {
    String? profilePhotoBase64,
  }) async {
    try {
      print('→ POST ${ApiEndpoints.farmerRegister}');
      print('📦 Farm: ${details.farmName}, Location: ${details.locationId}');

      // Prepare form data
      final formData = await _buildFormData(
        details: details,
        profilePhotoBase64: profilePhotoBase64,
      );

      // Make request
      final response = await dio.post(
        ApiEndpoints.farmerRegister,
        data: formData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
          // Allow 409 responses to be processed (not treated as error)
          validateStatus: (status) => status! < 500,
        ),
      );

      print('← ${response.statusCode} ${ApiEndpoints.farmerRegister}');

      // Handle different response codes
      return _handleRegistrationResponse(response, token);
      
    } on ServerException {
      rethrow;
    } on AuthException {
      rethrow;
    } on DioException catch (e) {
      print('ERROR → ${e.response?.statusCode} ${ApiEndpoints.farmerRegister}');
      throw _handleDioException(e, 'Failed to submit farmer details');
    } catch (e, stackTrace) {
      print('❌ Unexpected error: $e\n$stackTrace');
      throw const ServerException(
        message: 'An unexpected error occurred during details submission',
      );
    }
  }

  /// Build FormData for farmer registration
  Future<FormData> _buildFormData({
    required FarmerDetailsModel details,
    String? profilePhotoBase64,
  }) async {
    final formData = FormData.fromMap({
      'farm_name': details.farmName,
      'farm_purpose': details.farmPurpose,
      'total_land_acres': details.totalLandAcres.toString(),
      'years_experience': details.yearsExperience.toString(),
      'location_id': details.locationId.toString(),
    });

    // Add photo if provided
    if (profilePhotoBase64 != null && profilePhotoBase64.isNotEmpty) {
      try {
        final bytes = base64Decode(profilePhotoBase64);
        formData.files.add(
          MapEntry(
            'profile_photo',
            MultipartFile.fromBytes(
              bytes,
              filename: 'profile_${DateTime.now().millisecondsSinceEpoch}.jpg',
              contentType: MediaType('image', 'jpeg'),
            ),
          ),
        );
        print('📷 Photo attached to request (${bytes.length} bytes)');
      } catch (e) {
        print('⚠️ Failed to attach photo: $e');
        // Don't throw - photo is optional, continue without it
      }
    }

    return formData;
  }

  /// Handle different registration response codes
  Future<UserModel> _handleRegistrationResponse(
    Response response,
    String token,
  ) async {
    final statusCode = response.statusCode;
    final data = response.data;

    switch (statusCode) {
      case 201:
      case 200:
        return _handleSuccessResponse(data, token);

      case 409:
        return _handleConflictResponse(data, token);

      case 422:
        throw _handleValidationError(data);

      case 401:
      case 403:
        throw AuthException(_extractErrorMessage(data));

      case 404:
        throw ServerException(
          message: _extractErrorMessage(data),
          statusCode: 404,
        );

      default:
        throw ServerException(
          message: _extractErrorMessage(data),
          statusCode: statusCode,
        );
    }
  }

  /// Handle successful registration (201/200)
  Future<UserModel> _handleSuccessResponse(
    dynamic data,
    String token,
  ) async {
    print('✅ Farmer profile created successfully');

    // Try to extract user from response
    final userData = _extractUserData(data);

    if (userData != null) {
      // If user data is in response, use it
      print('   User data found in response');
      return UserModel.fromJson(userData);
    }

    // Otherwise, fetch current user from /me endpoint
    print('   Fetching updated user data from /me');
    return await _fetchCurrentUser(token);
  }

  /// Handle conflict response (409 - Profile already exists)
  Future<UserModel> _handleConflictResponse(
    dynamic data,
    String token,
  ) async {
    print('⚠️ 409 Conflict - Farmer profile already exists');

    // Backend returns user data in 409 response
    final userData = _extractUserData(data);

    if (userData != null) {
      print('✅ Extracted user data from 409 response');
      print('   hasCompletedDetails: ${userData['has_completed_details']}');
      
      // Ensure the flag is set
      userData['has_completed_details'] = true;
      
      return UserModel.fromJson(userData);
    }

    // If no user data in 409 response, fetch from /me
    print('   User data not in 409 response, fetching from /me');
    return await _fetchCurrentUser(token);
  }

  /// Handle validation errors (422)
  ValidationException _handleValidationError(dynamic data) {
    final message = _extractErrorMessage(data);
    final errors = _extractValidationErrors(data);

    print('❌ 422 Validation Error: $message');
    if (errors != null) {
      print('   Errors: $errors');
    }

    return ValidationException(
      message: message,
      errors: errors,
    );
  }

  // ========================================
  // GET FARMER PROFILE
  // ========================================

  @override
  Future<Map<String, dynamic>> getFarmerProfile(String token) async {
    try {
      print('→ GET ${ApiEndpoints.farmerProfile}');

      final response = await dio.get(
        ApiEndpoints.farmerProfile,
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      print('← ${response.statusCode} Profile fetched');

      if (response.statusCode == 200) {
        return _extractData(response.data);
      }

      throw ServerException(
        message: _extractErrorMessage(response.data),
        statusCode: response.statusCode,
      );
      
    } on DioException catch (e) {
      throw _handleDioException(e, 'Failed to fetch farmer profile');
    }
  }

  // ========================================
  // UPDATE FARMER PROFILE
  // ========================================

  @override
  Future<Map<String, dynamic>> updateFarmerProfile(
    Map<String, dynamic> updates,
    String token, {
    String? profilePhotoBase64,
  }) async {
    try {
      print('→ PUT ${ApiEndpoints.farmerProfile}');

      // Prepare form data if photo is included
      dynamic requestData = updates;
      
      if (profilePhotoBase64 != null && profilePhotoBase64.isNotEmpty) {
        final formData = FormData.fromMap(updates);
        
        try {
          final bytes = base64Decode(profilePhotoBase64);
          formData.files.add(
            MapEntry(
              'profile_photo',
              MultipartFile.fromBytes(
                bytes,
                filename: 'profile_${DateTime.now().millisecondsSinceEpoch}.jpg',
                contentType: MediaType('image', 'jpeg'),
              ),
            ),
          );
          requestData = formData;
          print('📷 Photo attached to update request');
        } catch (e) {
          print('⚠️ Failed to attach photo: $e');
        }
      }

      final response = await dio.put(
        ApiEndpoints.farmerProfile,
        data: requestData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        ),
      );

      print('← ${response.statusCode} Profile updated');

      if (response.statusCode == 200) {
        return _extractData(response.data);
      }

      throw ServerException(
        message: _extractErrorMessage(response.data),
        statusCode: response.statusCode,
      );
      
    } on DioException catch (e) {
      throw _handleDioException(e, 'Failed to update farmer profile');
    }
  }

  // ========================================
  // HELPER METHODS
  // ========================================

  /// Fetch current user data from /me endpoint
  Future<UserModel> _fetchCurrentUser(String token) async {
    try {
      print('→ GET /api/v1/me (fetching updated user)');

      final response = await dio.get(
        '/me',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      if (response.statusCode == 200) {
        final userData = _extractUserData(response.data);
        
        if (userData != null) {
          print('✅ User data fetched successfully');
          return UserModel.fromJson(userData);
        }
      }

      throw const ServerException(
        message: 'Failed to fetch updated user data',
      );
      
    } catch (e) {
      print('❌ Error fetching user from /me: $e');
      throw const ServerException(
        message: 'Profile created but unable to fetch updated data. Please refresh.',
      );
    }
  }

  /// Extract user data from various response structures
  /// Handles: {data: {user: {...}}}, {user: {...}}, {data: {...}}
  Map<String, dynamic>? _extractUserData(dynamic data) {
    if (data is! Map<String, dynamic>) return null;

    // Try data.user first (most specific)
    if (data['data'] is Map) {
      final dataMap = data['data'] as Map<String, dynamic>;
      if (dataMap['user'] is Map) {
        return dataMap['user'] as Map<String, dynamic>;
      }
      // If data exists but no user field, maybe data IS the user
      if (dataMap.containsKey('id') || dataMap.containsKey('email')) {
        return dataMap;
      }
    }

    // Try user field directly
    if (data['user'] is Map) {
      return data['user'] as Map<String, dynamic>;
    }

    // If top level has user fields, use it
    if (data.containsKey('id') || data.containsKey('email')) {
      return data;
    }

    return null;
  }

  /// Extract data field from response
  Map<String, dynamic> _extractData(dynamic responseData) {
    if (responseData is Map<String, dynamic>) {
      return responseData['data'] as Map<String, dynamic>? ?? responseData;
    }
    return {};
  }

  /// Handle DioException and convert to appropriate exception
  Exception _handleDioException(DioException e, String defaultMessage) {
    final statusCode = e.response?.statusCode;
    final data = e.response?.data;

    print('❌ DioException: $statusCode - ${_extractErrorMessage(data)}');

    // Handle specific status codes
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
        return ServerException(
          message: _extractErrorMessage(data),
          statusCode: 409,
        );

      default:
        return ServerException(
          message: _extractErrorMessage(data) != 'An error occurred'
              ? _extractErrorMessage(data)
              : defaultMessage,
          statusCode: statusCode,
        );
    }
  }

  /// Extract error message from response data
  String _extractErrorMessage(dynamic data) {
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
  Map<String, dynamic>? _extractValidationErrors(dynamic data) {
    if (data is Map<String, dynamic> && data['errors'] is Map) {
      return data['errors'] as Map<String, dynamic>;
    }
    return null;
  }
}