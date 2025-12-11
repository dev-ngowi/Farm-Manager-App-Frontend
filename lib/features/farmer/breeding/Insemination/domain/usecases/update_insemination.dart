// lib/features/farmer/insemination/domain/usecases/update_insemination.dart

import 'package:dartz/dartz.dart';
import 'package:farm_manager_app/core/error/failure.dart';
import 'package:farm_manager_app/core/usecases/usercase.dart';
import 'package:farm_manager_app/features/farmer/breeding/Insemination/domain/entities/insemination_entity.dart';
import 'package:farm_manager_app/features/farmer/breeding/Insemination/domain/repositories/insemination_repository.dart';


class UpdateInseminationParams extends Params {
  final int id;
  final Map<String, dynamic> updatedData;

  const UpdateInseminationParams({required this.id, required this.updatedData});

  @override
  List<Object?> get props => [id, updatedData];
}

class UpdateInsemination implements UseCase<InseminationEntity, UpdateInseminationParams> {
  final InseminationRepository repository;

  UpdateInsemination({required this.repository});

  @override
  Future<Either<Failure, InseminationEntity>> call(UpdateInseminationParams params) async {
    try {
      final result = await repository.updateInsemination(params.id, params.updatedData);
      return result;
    } catch (e) {
      // ⭐ Convert repository exception to a Failure
      return Left(FailureConverter.fromException(e));
    }
  }
}