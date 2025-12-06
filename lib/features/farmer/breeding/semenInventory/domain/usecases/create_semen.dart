import 'package:dartz/dartz.dart';
import 'package:farm_manager_app/core/error/failure.dart';
import 'package:farm_manager_app/core/usecases/usercase.dart';
import 'package:farm_manager_app/features/farmer/breeding/semenInventory/domain/entities/semen_entity.dart';
import 'package:farm_manager_app/features/farmer/breeding/semenInventory/domain/repositories/semen_repository.dart';

class CreateSemen implements UseCase<SemenEntity, SemenEntity> {
  final SemenRepository repository;

  CreateSemen(this.repository);

  @override
  Future<Either<Failure, SemenEntity>> call(SemenEntity semen) async {
    return repository.createSemen(semen);
  }
}