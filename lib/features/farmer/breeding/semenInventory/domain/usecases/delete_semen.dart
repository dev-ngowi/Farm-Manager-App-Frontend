import 'package:dartz/dartz.dart';
import 'package:farm_manager_app/core/error/failure.dart';
import 'package:farm_manager_app/core/usecases/usercase.dart';
import 'package:farm_manager_app/features/farmer/breeding/semenInventory/domain/repositories/semen_repository.dart';

class DeleteSemen implements UseCase<void, String> {
  final SemenRepository repository;

  DeleteSemen(this.repository);

  @override
  Future<Either<Failure, void>> call(String id) async {
    return repository.deleteSemen(id);
  }
}