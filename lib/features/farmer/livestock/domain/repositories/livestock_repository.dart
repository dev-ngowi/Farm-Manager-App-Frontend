// lib/features/farmer/livestock/domain/repositories/livestock_repository.dart

import 'package:dartz/dartz.dart';
import 'package:farm_manager_app/core/error/failure.dart';
import 'package:farm_manager_app/features/farmer/livestock/domain/entities/dropdown_data.dart';
import 'package:farm_manager_app/features/farmer/livestock/domain/entities/livestock.dart';
import 'package:farm_manager_app/features/farmer/livestock/domain/entities/livestock_summary.dart';

abstract class LivestockRepository {
  // Read Operations
  Future<Either<Failure, List<LivestockEntity>>> getAllLivestock({
    Map<String, dynamic>? filters,
  });
  Future<Either<Failure, LivestockEntity>> getLivestockById(int animalId);
  Future<Either<Failure, LivestockSummary>> getLivestockSummary();
  Future<Either<Failure, DropdownData>> getLivestockDropdowns();

  // Create Operation
  Future<Either<Failure, LivestockEntity>> addLivestock(
    Map<String, dynamic> animalData,
  );

  // ⭐ NEW: Update Operation
  Future<Either<Failure, LivestockEntity>> updateLivestock({
    required int animalId,
    required Map<String, dynamic> animalData,
  });

  // ⭐ NEW: Delete Operation
  Future<Either<Failure, void>> deleteLivestock(int animalId);
}