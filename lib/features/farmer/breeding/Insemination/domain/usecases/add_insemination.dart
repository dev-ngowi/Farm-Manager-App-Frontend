// lib/features/farmer/insemination/domain/usecases/add_insemination.dart

import 'package:dartz/dartz.dart';
import 'package:farm_manager_app/core/error/failure.dart';
import 'package:farm_manager_app/core/usecases/usercase.dart';
import 'package:farm_manager_app/features/farmer/breeding/Insemination/domain/entities/insemination_entity.dart';
import 'package:farm_manager_app/features/farmer/breeding/Insemination/domain/repositories/insemination_repository.dart';

class AddInsemination implements UseCase<InseminationEntity, DataParams> {
  final InseminationRepository repository;

  AddInsemination({required this.repository});

  @override
  Future<Either<Failure, InseminationEntity>> call(DataParams params) async {
    try {
      final result = await repository.addInsemination(params.data);
      return result;
    } catch (e) {
      // ⭐ Convert repository exception to a Failure
      return Left(FailureConverter.fromException(e));
    }
  }
}