import 'package:dartz/dartz.dart';
import 'package:farm_manager_app/core/error/failure.dart';
import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<Either<Failure, UserEntity>> login(String login, String password);
  
  Future<Either<Failure, UserEntity>> register({
    required String firstname,
    required String lastname,
    required String phoneNumber,
    String? email,
    required String password,
    required String passwordConfirmation,
    required String role,
  });

  // NEW: Assign user role method signature
  Future<Either<Failure, UserEntity>> assignRole({
    required String role,
  });
}