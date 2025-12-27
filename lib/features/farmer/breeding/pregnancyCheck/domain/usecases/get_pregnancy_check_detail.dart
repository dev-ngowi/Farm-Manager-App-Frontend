
import 'package:dartz/dartz.dart';
import 'package:farm_manager_app/core/error/failure.dart';
import 'package:farm_manager_app/features/farmer/breeding/pregnancyCheck/domain/entities/pregnancy_check_entity.dart';
import 'package:farm_manager_app/features/farmer/breeding/pregnancyCheck/domain/repositories/pregnancy_check_repository.dart';

class GetPregnancyCheckDetail {
  final PregnancyCheckRepository repository;

  GetPregnancyCheckDetail(this.repository);

  Future<Either<Failure, PregnancyCheckEntity>> call(int id) async {
    return await repository.getPregnancyCheckById(id);
  }
}