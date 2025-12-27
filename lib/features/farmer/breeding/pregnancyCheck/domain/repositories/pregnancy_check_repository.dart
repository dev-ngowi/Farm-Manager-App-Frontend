// lib/features/farmer/breeding/pregnancy_check/domain/repositories/pregnancy_check_repository.dart

import 'package:dartz/dartz.dart';
import 'package:farm_manager_app/core/error/failure.dart';
import '../entities/pregnancy_check_entity.dart';

abstract class PregnancyCheckRepository {
  Future<Either<Failure, List<PregnancyCheckEntity>>> getPregnancyChecks({Map<String, dynamic>? filters});
  Future<Either<Failure, PregnancyCheckEntity>> getPregnancyCheckById(int id);
  Future<Either<Failure, PregnancyCheckEntity>> addPregnancyCheck(Map<String, dynamic> data);
  Future<Either<Failure, PregnancyCheckEntity>> updatePregnancyCheck(int id, Map<String, dynamic> data);
  Future<Either<Failure, void>> deletePregnancyCheck(int id);
  
  // Required by PregnancyCheckForm
  Future<Either<Failure, List<PregnancyCheckInseminationEntity>>> getAvailableInseminations();
  Future<Either<Failure, List<PregnancyCheckVetEntity>>> getAvailableVets();
}