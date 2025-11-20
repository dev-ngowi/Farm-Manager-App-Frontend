// lib/features/auth/domain/usecases/assign_role_usecase.dart

import 'package:dartz/dartz.dart';
import 'package:farm_manager_app/core/error/failure.dart';
import 'package:farm_manager_app/features/auth/data/domain/entities/user_entity.dart';
import 'package:farm_manager_app/features/auth/data/domain/repositories/auth_repository.dart';

class AssignRoleUseCase {
  final AuthRepository repository;

  AssignRoleUseCase(this.repository);

  Future<Either<Failure, UserEntity>> call({required String role}) async {
    try {
      return await repository.assignRole(role: role);
    } catch (e) {
      return Left(ServerFailure('Failed to assign role: ${e.toString()}'));
    }
  }
}