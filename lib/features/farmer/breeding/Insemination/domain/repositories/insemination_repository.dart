// lib/features/farmer/insemination/domain/repositories/insemination_repository.dart

import 'package:dartz/dartz.dart';
import 'package:farm_manager_app/core/error/failure.dart';
import 'package:farm_manager_app/features/farmer/breeding/Insemination/domain/entities/insemination_entity.dart';

abstract class InseminationRepository {
  /// Fetches a list of all insemination records, optionally filtered.
  Future<Either<Failure, List<InseminationEntity>>> fetchInseminationList({
    Map<String, dynamic>? filters,
  });

  /// Fetches the detailed information for a single insemination record by ID.
  Future<Either<Failure, InseminationEntity>> fetchInseminationDetail(int id);

  /// Adds a new insemination record.
  Future<Either<Failure, InseminationEntity>> addInsemination(
      Map<String, dynamic> recordData);

  /// Updates an existing insemination record.
  Future<Either<Failure, InseminationEntity>> updateInsemination(
    int id,
    Map<String, dynamic> updatedData,
  );

  /// Deletes an insemination record by ID.
  Future<Either<Failure, void>> deleteInsemination(int id);

  /// Fetches animals available for breeding (dams & sires)
  Future<Either<Failure, List<InseminationAnimalEntity>>> getAvailableAnimals();

  /// Fetches available semen straws for AI
  Future<Either<Failure, List<InseminationSemenEntity>>> getAvailableSemen();
}