import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../../core/error/failure.dart';
import '../models/login_response_model.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<LoginResponseModel> login(String login, String password);
  Future<UserModel> register({
    required String firstname,
    required String lastname,
    required String phoneNumber,
    String? email,
    required String password,
    required String passwordConfirmation,
    required String role,
  });
  
  // NEW: Assign user role
  Future<UserModel> assignRole({required String role});
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio dio;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  AuthRemoteDataSourceImpl(this.dio);

  @override
  Future<LoginResponseModel> login(String login, String password) async {
    try {
      final response = await dio.post('/login', data: {
        'login': login,
        'password': password,
      });

      final loginResponse = LoginResponseModel.fromJson(response.data);

      // Save token and role immediately after successful login
      await _storage.write(key: 'access_token', value: loginResponse.accessToken);
      // NOTE: User model's role might be null if not set, so only save if it's not null/empty
      if (loginResponse.user.role?.isNotEmpty ?? false) {
        await _storage.write(key: 'user_role', value: loginResponse.user.role);
      }

      return loginResponse;
    } on DioException catch (e) {
      final message = e.response?.data['message'] ??
          e.response?.data['errors']?.toString() ??
          'Login failed. Please try again.';
      throw ServerException(message);
    } catch (e) {
      throw ServerException('Unexpected error during login');
    }
  }

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
      final response = await dio.post('/register', data: {
        "firstname": firstname,
        "lastname": lastname,
        "phone_number": phoneNumber,
        "email": email,
        "password": password,
        "password_confirmation": passwordConfirmation,
        "role": role, 
      });

      if (response.statusCode != 201) {
        throw ServerException('Registration failed with status: ${response.statusCode}');
      }

      final data = response.data['data'];
      final userJson = data['user'] as Map<String, dynamic>;
      final token = data['access_token'] as String;

      // Save token & role immediately
      await _storage.write(key: 'access_token', value: token);
      await _storage.write(key: 'user_role', value: role);
      await _storage.write(key: 'user_name', value: '$firstname $lastname');

      // Ensure role is attached to user model
      userJson['role'] = role;

      return UserModel.fromJson(userJson);
    } on DioException catch (e) {
      String message = 'Registration failed';

      if (e.response != null) {
        final errors = e.response?.data['errors'] ?? e.response?.data['message'];
        if (errors is Map) {
          // Attempt to extract the first error message from the validation array
          message = errors.values.first[0] ?? message;
        } else if (errors is String) {
          message = errors;
        }
      }

      throw ServerException(message);
    } catch (e) {
      throw ServerException('Unexpected error during registration');
    }
  }

  @override
  Future<UserModel> assignRole({required String role}) async {
    final token = await _storage.read(key: 'access_token');
    
    if (token == null) {
      throw ServerException('Authentication token missing. Please log in.');
    }

    try {
      // Endpoint used for assigning role post-login/registration
      final response = await dio.post(
        '/assign-role',
        data: {'role': role},
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        final userJson = response.data['user'] as Map<String, dynamic>;
        
        // Update the locally stored role after successful assignment
        await _storage.write(key: 'user_role', value: role);
        
        return UserModel.fromJson(userJson);
      } else {
        throw ServerException(response.data['message'] ?? 'Failed to assign role.');
      }
    } on DioException catch (e) {
      String message = 'Server Error Occurred during role assignment.';
      if (e.response != null) {
        message = e.response?.data['message'] ?? message;
      }
      throw ServerException(message);
    } catch (e) {
      throw ServerException('An unexpected error occurred during role assignment.');
    }
  }
}