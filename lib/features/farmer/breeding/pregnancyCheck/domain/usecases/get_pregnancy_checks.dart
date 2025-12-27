// lib/features/farmer/breeding/pregnancy_check/domain/usecases/get_pregnancy_checks.dart

import 'package:dartz/dartz.dart';
import 'package:farm_manager_app/core/error/failure.dart';
import 'package:farm_manager_app/features/farmer/breeding/pregnancyCheck/domain/entities/pregnancy_check_entity.dart';
import 'package:farm_manager_app/features/farmer/breeding/pregnancyCheck/domain/repositories/pregnancy_check_repository.dart';

class GetPregnancyChecks {
  final PregnancyCheckRepository repository;

  GetPregnancyChecks(this.repository);

  Future<Either<Failure, List<PregnancyCheckEntity>>> call({Map<String, dynamic>? filters}) async {
    return await repository.getPregnancyChecks(filters: filters);
  }
}