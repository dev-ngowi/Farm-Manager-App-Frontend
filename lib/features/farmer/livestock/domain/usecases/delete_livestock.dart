// lib/features/farmer/livestock/domain/usecases/delete_livestock.dart

import 'package:dartz/dartz.dart';
import 'package:farm_manager_app/core/error/failure.dart';
import 'package:farm_manager_app/core/usecases/usercase.dart'; // Typo in snippet: usercase -> usecase

import 'package:farm_manager_app/features/farmer/livestock/domain/repositories/livestock_repository.dart';

// No return type (void) for successful deletion, no params needed.
class DeleteLivestock implements UseCase<void, int> { 
  final LivestockRepository repository;

  DeleteLivestock(this.repository);

  @override
  // The input parameter is the animalId (int)
  Future<Either<Failure, void>> call(int animalId) { 
    return repository.deleteLivestock(animalId);
  }
}