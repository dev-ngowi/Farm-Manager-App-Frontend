import 'package:dartz/dartz.dart';
import 'package:farm_manager_app/core/error/failure.dart';
import 'package:farm_manager_app/core/usecases/usercase.dart';
import 'package:farm_manager_app/features/farmer/breeding/semenInventory/domain/entities/semen_entity.dart';
import 'package:farm_manager_app/features/farmer/breeding/semenInventory/domain/repositories/semen_repository.dart';

class GetSemenDetails implements UseCase<SemenEntity, String> {
  final SemenRepository repository;

  GetSemenDetails(this.repository);

  @override
  Future<Either<Failure, SemenEntity>> call(String id) async {
    return repository.getSemenDetails(id);
  }
}