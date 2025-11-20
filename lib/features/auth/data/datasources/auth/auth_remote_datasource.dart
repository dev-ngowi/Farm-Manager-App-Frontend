import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../../../core/error/failure.dart';
import '../../models/login_response_model.dart';
import '../../models/user_model.dart';

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

    if (token == null || token.isEmpty) {
      throw ServerException('Unauthorised. Please login again.');
    }

    try {
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

      if (response.statusCode == 200 || response.statusCode == 201) {
        // 1. Ensure response data is a valid map before processing
        if (response.data == null || response.data is! Map<String, dynamic>) {
          print('AssignRole Error: Invalid response format or data is null: ${response.data}');
          throw ServerException('Invalid response format from assign-role API.');
        }

        final jsonResponse = response.data as Map<String, dynamic>;

        // 2. Safely access the user object, checking for both 'data' (expected) and 'user' (received) keys
        final userData = jsonResponse['data'] ?? jsonResponse['user']; 

        if (userData == null || userData is! Map<String, dynamic>) {
          print('AssignRole Error: Missing or invalid "data" or "user" field in response: ${jsonResponse}');
          // Use the server's own message if it explains why the role wasn't assigned (e.g., "Tayari umechagua...")
          final serverMessage = jsonResponse['message'] as String? ?? 'User data missing from role assignment response.';
          throw ServerException(serverMessage);
        }

        final userJson = userData as Map<String, dynamic>;

        // Ensure role is up-to-date in local storage
        await _storage.write(key: 'user_role', value: role);

        // Optional: update full name if returned
        if (userJson['full_name'] != null) {
          await _storage.write(key: 'user_name', value: userJson['full_name']);
        }

        return UserModel.fromJson(userJson);
      } else {
        // Handling non-successful status codes
        final errorMsg = response.data?['message'] ?? 'Failed to assign role';
        throw ServerException(errorMsg);
      }
    } on DioException catch (e) {
      String errorMessage = 'Failed to assign role. Please try again.';

      if (e.response != null) {
        final data = e.response?.data;
        if (data is Map<String, dynamic>) {
          errorMessage = data['message'] ??
              data['error'] ??
              (data['errors'] is Map
                  ? (data['errors'] as Map).values.first[0]
                  : 'Validation error');
        }
      }

      print('Dio Error during assignRole: $errorMessage');
      throw ServerException(errorMessage);
    } catch (e, s) {
      print('Unexpected error in assignRole: $e\n$s');
      throw ServerException('An unexpected error occurred. Please try again.');
    }
  }
}