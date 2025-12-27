
import 'package:dartz/dartz.dart';
import 'package:farm_manager_app/core/error/failure.dart';
import 'package:farm_manager_app/features/farmer/breeding/pregnancyCheck/domain/repositories/pregnancy_check_repository.dart';

class DeletePregnancyCheckUseCase {
  final PregnancyCheckRepository repository;

  DeletePregnancyCheckUseCase(this.repository);

  Future<Either<Failure, void>> call(int id) async {
    return await repository.deletePregnancyCheck(id);
  }
}