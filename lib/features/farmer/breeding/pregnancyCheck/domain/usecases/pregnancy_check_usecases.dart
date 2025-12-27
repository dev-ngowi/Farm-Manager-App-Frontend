// lib/features/farmer/breeding/pregnancy_check/domain/usecases/pregnancy_check_usecases.dart

import 'package:dartz/dartz.dart';
import 'package:farm_manager_app/core/error/failure.dart';
import 'package:farm_manager_app/features/farmer/breeding/pregnancyCheck/domain/entities/pregnancy_check_entity.dart';
import 'package:farm_manager_app/features/farmer/breeding/pregnancyCheck/domain/repositories/pregnancy_check_repository.dart';

/// Fetch all pregnancy checks (optionally filtered)
class GetPregnancyChecks {
  final PregnancyCheckRepository repository;

  GetPregnancyChecks(this.repository);

  Future<Either<Failure, List<PregnancyCheckEntity>>> call({
    Map<String, dynamic>? filters,
  }) async {
    return await repository.getPregnancyChecks(filters: filters);
  }
}

/// Fetch single pregnancy check details by ID
class GetPregnancyCheckById {
  final PregnancyCheckRepository repository;

  GetPregnancyCheckById(this.repository);

  Future<Either<Failure, PregnancyCheckEntity>> call(int id) async {
    return await repository.getPregnancyCheckById(id);
  }
}

/// Add a new pregnancy check record
class AddPregnancyCheck {
  final PregnancyCheckRepository repository;

  AddPregnancyCheck(this.repository);

  Future<Either<Failure, PregnancyCheckEntity>> call(
    Map<String, dynamic> data,
  ) async {
    return await repository.addPregnancyCheck(data);
  }
}

/// Update an existing pregnancy check
class UpdatePregnancyCheck {
  final PregnancyCheckRepository repository;

  UpdatePregnancyCheck(this.repository);

  Future<Either<Failure, PregnancyCheckEntity>> call(
    int id,
    Map<String, dynamic> data,
  ) async {
    return await repository.updatePregnancyCheck(id, data);
  }
}

/// Delete a pregnancy check record
class DeletePregnancyCheck {
  final PregnancyCheckRepository repository;

  DeletePregnancyCheck(this.repository);

  Future<Either<Failure, void>> call(int id) async {
    return await repository.deletePregnancyCheck(id);
  }
}

/// Get available inseminations for dropdown
class GetAvailableInseminations {
  final PregnancyCheckRepository repository;

  GetAvailableInseminations(this.repository);

  Future<Either<Failure, List<PregnancyCheckInseminationEntity>>> call() async {
    return await repository.getAvailableInseminations();
  }
}

/// Get available vets for dropdown
class GetAvailableVets {
  final PregnancyCheckRepository repository;

  GetAvailableVets(this.repository);

  Future<Either<Failure, List<PregnancyCheckVetEntity>>> call() async {
    return await repository.getAvailableVets();
  }
}