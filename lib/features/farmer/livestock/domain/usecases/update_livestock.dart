// lib/features/farmer/livestock/domain/usecases/update_livestock.dart

import 'package:dartz/dartz.dart';
import 'package:farm_manager_app/core/error/failure.dart';
import 'package:farm_manager_app/core/usecases/usercase.dart'; // Typo in snippet: usercase -> usecase
import 'package:farm_manager_app/features/farmer/livestock/domain/entities/livestock.dart';
import 'package:farm_manager_app/features/farmer/livestock/domain/repositories/livestock_repository.dart';

class UpdateLivestock implements UseCase<LivestockEntity, UpdateLivestockParams> {
  final LivestockRepository repository;

  UpdateLivestock(this.repository);

  @override
  Future<Either<Failure, LivestockEntity>> call(UpdateLivestockParams params) {
    return repository.updateLivestock(
      animalId: params.animalId,
      animalData: params.animalData,
    );
  }
}

// Params class to encapsulate update request data
class UpdateLivestockParams {
  final int animalId;
  final Map<String, dynamic> animalData;

  const UpdateLivestockParams({
    required this.animalId,
    required this.animalData,
  });
}