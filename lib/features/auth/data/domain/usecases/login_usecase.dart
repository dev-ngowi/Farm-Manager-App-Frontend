import 'package:dartz/dartz.dart';
import 'package:farm_manager_app/core/error/failure.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class LoginUseCase {
  final AuthRepository repository;

  LoginUseCase(this.repository);

  Future<Either<Failure, UserEntity>> call(String login, String password) {
    return repository.login(login, password);
  }
}