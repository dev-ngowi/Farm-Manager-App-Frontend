
import 'package:dartz/dartz.dart';
import 'package:farm_manager_app/core/error/failure.dart';
import 'package:farm_manager_app/core/usecases/usercase.dart';
import 'package:farm_manager_app/features/farmer/breeding/Insemination/domain/repositories/insemination_repository.dart';


class DeleteInsemination implements UseCase<void, IdParams> {
  final InseminationRepository repository;

  DeleteInsemination({required this.repository});

  @override
  Future<Either<Failure, void>> call(IdParams params) async {
    try {
      await repository.deleteInsemination(params.id);
      return const Right(null);
    } catch (e) {
      // ⭐ Convert repository exception to a Failure
      return Left(FailureConverter.fromException(e));
    }
  }
}