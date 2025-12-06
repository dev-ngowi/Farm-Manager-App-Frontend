import 'package:dartz/dartz.dart';
import 'package:farm_manager_app/core/error/failure.dart';
import 'package:farm_manager_app/features/farmer/livestock/domain/entities/livestock.dart';
import 'package:farm_manager_app/features/farmer/livestock/domain/repositories/livestock_repository.dart';
import 'package:farm_manager_app/core/usecases/usercase.dart';

class GetLivestockById implements UseCase<LivestockEntity, int> {
  final LivestockRepository repository;

  GetLivestockById(this.repository);

  @override
  Future<Either<Failure, LivestockEntity>> call(int animalId) {
    return repository.getLivestockById(animalId);
  }
}