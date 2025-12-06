import 'package:dartz/dartz.dart';
import 'package:farm_manager_app/core/error/failure.dart';
import 'package:farm_manager_app/features/farmer/livestock/domain/entities/livestock.dart';
import 'package:farm_manager_app/features/farmer/livestock/domain/repositories/livestock_repository.dart';
import 'package:farm_manager_app/core/usecases/usercase.dart';

class AddLivestock implements UseCase<LivestockEntity, Map<String, dynamic>> {
  final LivestockRepository repository;

  AddLivestock(this.repository);

  @override
  Future<Either<Failure, LivestockEntity>> call(Map<String, dynamic> animalData) {
    // animalData should be the payload created by LivestockModel.toStoreJson
    return repository.addLivestock(animalData);
  }
}