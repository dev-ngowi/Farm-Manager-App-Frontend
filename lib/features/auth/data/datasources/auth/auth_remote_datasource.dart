// lib/features/auth/data/datasources/auth/auth_remote_datasource.dart (Implementation)

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../../../core/error/failure.dart';
import '../../models/login_response_model.dart';
import '../../models/user_model.dart';

/// Abstract contract for authentication remote operations
abstract class AuthRemoteDataSource {
  /// Login with email/phone and password
  Future<LoginResponseModel> login(String login, String password);
  
  /// Register a new user
  Future<UserModel> register({
    required String firstname,
    required String lastname,
    required String phoneNumber,
    String? email,
    required String password,
    required String passwordConfirmation,
    required String role,
  });
  
  /// Assign role to authenticated user
  Future<UserModel> assignRole({
    required String role,
    required String token,
  });

  /// Submit farmer specific details
  Future<UserModel> submitFarmerDetails({
    required String farmName,
    required String farmPurpose,
    required double totalLandAcres,
    required int yearsExperience,
    required int locationId,
    required String token,
    required String profilePhotoBase64,
  });
  
  // ⭐ NEW CONTRACT METHOD
  /// Submit veterinarian specific details
  Future<UserModel> submitVetDetails({
    required String clinicName,
    required String licenseNumber,
    required String specialization,
    required double consultationFee,
    required int yearsExperience,
    required int locationId,
    required String token,
    required String certificateBase64,
    required String licenseBase64,
    required List<String> clinicPhotosBase64,
  });
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio dio;
  final FlutterSecureStorage storage;

  AuthRemoteDataSourceImpl({
    required this.dio,
    FlutterSecureStorage? storage,
  }) : storage = storage ?? const FlutterSecureStorage();

  // ========================================
  // LOGIN
  // ========================================
  
  @override
  Future<LoginResponseModel> login(String login, String password) async {
    try {
      print('→ POST /api/v1/login');
      print('📦 Login: $login');

      final response = await dio.post(
        '/login',
        data: {
          'login': login,
          'password': password,
        },
      );

      print('← ${response.statusCode} Login successful');

      // Parse response
      final loginResponse = LoginResponseModel.fromJson(response.data);

      // Save credentials to secure storage
      await _saveAuthData(
        token: loginResponse.accessToken,
        role: loginResponse.user.role,
        userName: '${loginResponse.user.firstname} ${loginResponse.user.lastname}',
      );

      return loginResponse;
      
    } on DioException catch (e) {
      print('ERROR → ${e.response?.statusCode} /api/v1/login');
      throw _handleDioException(e, 'Login failed');
    } catch (e) {
      print('❌ Unexpected error during login: $e');
      throw const ServerException(message: 'Unexpected error during login');
    }
  }

  // ========================================
  // REGISTER
  // ========================================
  
  @override
  Future<UserModel> register({
    required String firstname,
    required String lastname,
    required String phoneNumber,
    String? email,
    required String password,
    required String passwordConfirmation,
    required String role,
  }) async {
    try {
      print('→ POST /api/v1/register');
      print('📦 User: $firstname $lastname, Role: $role');

      final response = await dio.post(
        '/register',
        data: {
          "firstname": firstname,
          "lastname": lastname,
          "phone_number": phoneNumber,
          "email": email,
          "password": password,
          "password_confirmation": passwordConfirmation,
          "role": role,
        },
      );

      print('← ${response.statusCode} Registration successful');

      // Validate response
      if (response.statusCode != 201) {
        throw ServerException(
          message: 'Registration failed with status: ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }

      // Extract data from response
      final data = response.data['data'];
      if (data == null) {
        throw const ServerException(
          message: 'Invalid response format: missing data field',
        );
      }

      final userJson = data['user'] as Map<String, dynamic>?;
      final token = data['access_token'] as String?;

      if (userJson == null || token == null) {
        throw const ServerException(
          message: 'Invalid response format: missing user or token',
        );
      }

      // Save credentials to secure storage
      await _saveAuthData(
        token: token,
        role: role,
        userName: '$firstname $lastname',
      );

      // Ensure role is in user model
      userJson['role'] = role;

      print('✅ User registered and credentials saved');
      return UserModel.fromJson(userJson);
      
    } on ServerException {
      rethrow;
    } on DioException catch (e) {
      print('ERROR → ${e.response?.statusCode} /api/v1/register');
      throw _handleDioException(e, 'Registration failed');
    } catch (e) {
      print('❌ Unexpected error during registration: $e');
      throw const ServerException(message: 'Unexpected error during registration');
    }
  }

  // ========================================
  // ASSIGN ROLE
  // ========================================
  
  @override
  Future<UserModel> assignRole({
    required String role,
    required String token, 
  }) async {
    try {
      print('🔄 Starting assignRole...');
      
      if (token.isEmpty) {
        print('❌ Token is empty');
        throw const AuthException('Unauthorized. Token missing.');
      }

      print('✅ Token received: ${token.substring(0, 20)}...');
      print('→ POST /api/v1/assign-role');
      print('📦 Role: $role');

      // 2. Make API request
      final response = await dio.post(
        '/assign-role',
        data: {'role': role},
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
            'Content-Type': 'application/json',
          },
        ),
      );

      print('← ${response.statusCode} Response received');

      // 3. Validate response status
      if (response.statusCode != 200 && response.statusCode != 201) {
        final errorMsg = _extractErrorMessage(response.data);
        print('❌ Invalid status code: ${response.statusCode}');
        throw ServerException(
          message: errorMsg,
          statusCode: response.statusCode,
        );
      }

      // 4. Validate response format
      if (response.data == null || response.data is! Map<String, dynamic>) {
        print('❌ Invalid response format');
        throw const ServerException(
          message: 'Invalid response format from assign-role API',
        );
      }

      final jsonResponse = response.data as Map<String, dynamic>;
      print('✅ Valid JSON response received');

      // 5. Extract user data (handle multiple possible response structures)
      Map<String, dynamic>? userJson;
      
      // Check for nested user in data field
      if (jsonResponse['data'] != null) {
        final data = jsonResponse['data'];
        if (data is Map<String, dynamic>) {
          if (data['user'] is Map<String, dynamic>) {
            userJson = data['user'] as Map<String, dynamic>;
            print('✅ Found user in data.user');
          } else {
            userJson = data;
            print('✅ Found user in data');
          }
        }
      } 
      // Check for direct user field
      else if (jsonResponse['user'] is Map<String, dynamic>) {
        userJson = jsonResponse['user'] as Map<String, dynamic>;
        print('✅ Found user in root.user');
      }
      // Check if the response itself is the user object
      else if (jsonResponse['id'] != null && jsonResponse['role'] != null) {
        userJson = jsonResponse;
        print('✅ Response is the user object');
      }

      // 6. Validate user data
      if (userJson == null) {
        print('❌ Could not find user data in response');
        
        final serverMessage = jsonResponse['message'] as String?;
        throw ServerException(
          message: serverMessage ?? 'User data missing from role assignment response',
        );
      }

      // 7. Ensure the role is present in user data
      if (userJson['role'] == null || userJson['role'].toString().isEmpty) {
        print('⚠️ Role missing in response, setting it to requested role');
        userJson['role'] = role;
      } else {
        print('✅ Role in response: ${userJson['role']}');
      }

      // 8. Update local storage with new role and name
      await storage.write(key: 'user_role', value: role);
      print('💾 Saved role to storage: $role');

      if (userJson['firstname'] != null && userJson['lastname'] != null) {
        final fullName = '${userJson['firstname']} ${userJson['lastname']}';
        await storage.write(key: 'user_name', value: fullName);
        print('💾 Saved full name: $fullName');
      }

      // 9. Parse and return user model
      print('✅ Creating UserModel from response');
      final userModel = UserModel.fromJson(userJson);
      
      print('✅ Role assigned successfully! User Role: ${userModel.role}');
      
      return userModel;
      
    } on AuthException {
      rethrow;
    } on ServerException {
      rethrow;
    } on DioException catch (e) {
      print('❌ DioException: ${e.response?.statusCode}');
      print('   Message: ${e.message}');
      throw _handleDioException(e, 'Failed to assign role');
    } catch (e, stackTrace) {
      print('❌ Unexpected error in assignRole: $e');
      print('   Stack trace: $stackTrace');
      throw const ServerException(
        message: 'An unexpected error occurred during role assignment',
      );
    }
  }

  // ========================================
  // SUBMIT FARMER DETAILS (Existing)
  // ========================================
  
  @override
  Future<UserModel> submitFarmerDetails({
    required String farmName,
    required String farmPurpose,
    required double totalLandAcres,
    required int yearsExperience,
    required int locationId,
    required String token,
    required String profilePhotoBase64,
  }) async {
    try {
      print('→ POST /api/v1/farmer/details');

      final response = await dio.post(
        '/farmer/details',
        data: {
          'farm_name': farmName,
          'farm_purpose': farmPurpose,
          'total_land_acres': totalLandAcres,
          'years_experience': yearsExperience,
          'location_id': locationId,
          'profile_photo_base64': profilePhotoBase64,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
            'Content-Type': 'application/json',
          },
        ),
      );

      print('← ${response.statusCode} Farmer details submitted successfully');
      
      // Response structure should contain the updated user model
      final userJson = response.data['data'] ?? response.data;
      if (userJson == null) {
        throw const ServerException(message: 'Invalid response format from farmer details API');
      }
      
      return UserModel.fromJson(userJson);
      
    } on DioException catch (e) {
      print('ERROR → ${e.response?.statusCode} /api/v1/farmer/details');
      throw _handleDioException(e, 'Farmer details submission failed');
    } catch (e) {
      print('❌ Unexpected error during farmer submission: $e');
      throw const ServerException(message: 'Unexpected error during farmer details submission');
    }
  }

  // ========================================
  // ⭐ NEW: SUBMIT VET DETAILS IMPLEMENTATION
  // ========================================

  @override
  Future<UserModel> submitVetDetails({
    required String clinicName,
    required String licenseNumber,
    required String specialization,
    required double consultationFee,
    required int yearsExperience,
    required int locationId,
    required String token,
    required String certificateBase64,
    required String licenseBase64,
    required List<String> clinicPhotosBase64,
  }) async {
    try {
      print('→ POST /api/v1/vet/details');
      print('📦 Clinic: $clinicName, Specialization: $specialization');

      final response = await dio.post(
        '/vet/details', // Assuming the endpoint is /vet/details
        data: {
          'clinic_name': clinicName,
          'license_number': licenseNumber,
          'specialization': specialization,
          'consultation_fee': consultationFee,
          'years_experience': yearsExperience,
          'location_id': locationId,
          'certificate_base64': certificateBase64,
          'license_base64': licenseBase64,
          'clinic_photos_base64': clinicPhotosBase64,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
            'Content-Type': 'application/json',
          },
        ),
      );

      print('← ${response.statusCode} Vet details submitted successfully');
      
      // Response structure should contain the updated user model
      final userJson = response.data['data'] ?? response.data;
      if (userJson == null) {
        throw const ServerException(message: 'Invalid response format from vet details API');
      }
      
      return UserModel.fromJson(userJson);
      
    } on DioException catch (e) {
      print('ERROR → ${e.response?.statusCode} /api/v1/vet/details');
      throw _handleDioException(e, 'Vet details submission failed');
    } catch (e) {
      print('❌ Unexpected error during vet submission: $e');
      throw const ServerException(message: 'Unexpected error during vet details submission');
    }
  }


  // ========================================
  // HELPER METHODS
  // ========================================

  /// Save authentication data to secure storage
  Future<void> _saveAuthData({
    required String token,
    String? role,
    String? userName,
  }) async {
    await storage.write(key: 'access_token', value: token);
    
    if (role != null && role.isNotEmpty) {
      await storage.write(key: 'user_role', value: role);
    }
    
    if (userName != null && userName.isNotEmpty) {
      await storage.write(key: 'user_name', value: userName);
    }
  }

  /// Handle DioException and convert to ServerException with proper message extraction
  ServerException _handleDioException(DioException e, String defaultMessage) {
    String errorMessage = defaultMessage;
    int? statusCode = e.response?.statusCode;

    // Check for explicit connection error (DioExceptionType.connectionError/unknown)
    if (e.type == DioExceptionType.connectionError) {
      return const ServerException(
        message: 'Connection failed. Check network or API URL.',
        statusCode: 0,
      );
    }

    if (e.response?.data != null) {
      errorMessage = _extractErrorMessage(e.response!.data);
    } else if (e.message != null) {
      errorMessage = e.message!;
    }

    print('❌ Error: $errorMessage (Status: $statusCode)');
    
    // The AuthBloc's logic relies on ServerException being thrown here, 
    // which the repository then converts to a domain-specific Failure.
    return ServerException(
      message: errorMessage,
      statusCode: statusCode,
      response: e.response?.data, // Include response data for validation/conflict handling
    );
  }

  /// Extract error message from response data
  String _extractErrorMessage(dynamic data) {
    if (data is! Map<String, dynamic>) {
      return 'An error occurred';
    }

    // Try to get message field first
    if (data['message'] != null) {
      return data['message'].toString();
    }

    // Try to get error field
    if (data['error'] != null) {
      return data['error'].toString();
    }

    // Try to extract first validation error
    if (data['errors'] is Map) {
      final errors = data['errors'] as Map;
      if (errors.isNotEmpty) {
        final firstError = errors.values.first;
        if (firstError is List && firstError.isNotEmpty) {
          return firstError.first.toString();
        }
        return firstError.toString();
      }
    }

    return 'An error occurred';
  }
}