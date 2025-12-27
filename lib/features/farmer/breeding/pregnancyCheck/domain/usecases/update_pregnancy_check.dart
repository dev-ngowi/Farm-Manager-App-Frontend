// lib/features/farmer/breeding/pregnancy_check/domain/usecases/update_pregnancy_check.dart

import 'package:dartz/dartz.dart';
import 'package:farm_manager_app/core/error/failure.dart';
import 'package:farm_manager_app/features/farmer/breeding/pregnancyCheck/domain/entities/pregnancy_check_entity.dart';
import 'package:farm_manager_app/features/farmer/breeding/pregnancyCheck/domain/repositories/pregnancy_check_repository.dart';

class UpdatePregnancyCheckUseCase {
  final PregnancyCheckRepository repository;

  UpdatePregnancyCheckUseCase(this.repository);

  Future<Either<Failure, PregnancyCheckEntity>> call(int id, Map<String, dynamic> data) async {
    return await repository.updatePregnancyCheck(id, data);
  }
}