import 'package:dio/dio.dart';
import 'package:farm_manager_app/core/error/failure.dart';
import '../../../../core/error/exceptions.dart';
import '../models/login_response_model.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<LoginResponseModel> login(String login, String password);
  
  // ← THIS LINE WAS MISSING — THIS IS THE FIX
  Future<UserModel> register({
    required String firstname,
    required String lastname,
    required String phoneNumber,
    String? email,
    required String password,
    required String passwordConfirmation,
  });
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio dio;

  AuthRemoteDataSourceImpl(this.dio);

  @override
  Future<LoginResponseModel> login(String login, String password) async {
    final response = await dio.post('/login', data: {
      'login': login,
      'password': password,
    });
    return LoginResponseModel.fromJson(response.data);
  }

  @override
  Future<UserModel> register({
    required String firstname,
    required String lastname,
    required String phoneNumber,
    String? email,
    required String password,
    required String passwordConfirmation,
  }) async {
    try {
      final response = await dio.post('/register', data: {
        'firstname': firstname,
        'lastname': lastname,
        'phone_number': phoneNumber,
        'email': email,
        'password': password,
        'password_confirmation': passwordConfirmation,
      });

      final userJson = response.data['user'] ?? response.data['data'];
      return UserModel.fromJson(userJson);
    } on DioException catch (e) {
      throw ServerException(e.response?.data['message'] ?? 'Registration failed');
    } catch (e) {
      throw ServerException('Unexpected error');
    }
  }
}