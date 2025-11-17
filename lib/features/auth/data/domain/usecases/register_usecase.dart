// lib/features/auth/domain/usecases/register_usecase.dart
import 'package:dartz/dartz.dart';
import 'package:farm_manager_app/core/error/failure.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';

class RegisterUseCase {
  final AuthRepository repository;

  RegisterUseCase(this.repository);

  Future<Either<Failure, UserEntity>> call({
    required String firstname,
    required String lastname,
    required String phoneNumber,
    String? email,
    required String password,
    required String passwordConfirmation,
  }) {
    return repository.register(
      firstname: firstname,
      lastname: lastname,
      phoneNumber: phoneNumber,
      email: email,
      password: password,
      passwordConfirmation: passwordConfirmation,
    );
  }
}