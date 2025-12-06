import 'package:dartz/dartz.dart';
import 'package:farm_manager_app/core/error/failure.dart';
import 'package:farm_manager_app/core/usecases/usercase.dart';
import 'package:farm_manager_app/features/farmer/breeding/semenInventory/domain/entities/semen_entity.dart';
import 'package:farm_manager_app/features/farmer/breeding/semenInventory/domain/repositories/semen_repository.dart';

class UpdateSemen implements UseCase<SemenEntity, SemenUpdateParams> {
  final SemenRepository repository;

  UpdateSemen(this.repository);

  @override
  Future<Either<Failure, SemenEntity>> call(SemenUpdateParams params) async {
    return repository.updateSemen(params.id, params.semen);
  }
}

class SemenUpdateParams {
  final String id;
  final SemenEntity semen;

  SemenUpdateParams({required this.id, required this.semen});
}