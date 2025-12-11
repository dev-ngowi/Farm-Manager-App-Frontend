// lib/features/farmer/insemination/domain/usecases/fetch_insemination_detail.dart

import 'package:dartz/dartz.dart';
import 'package:farm_manager_app/core/error/failure.dart';
import 'package:farm_manager_app/core/usecases/usercase.dart';
import 'package:farm_manager_app/features/farmer/breeding/Insemination/domain/entities/insemination_entity.dart';
import 'package:farm_manager_app/features/farmer/breeding/Insemination/domain/repositories/insemination_repository.dart';


class FetchInseminationDetail implements UseCase<InseminationEntity, IdParams> {
  final InseminationRepository repository;

  FetchInseminationDetail({required this.repository});

  @override
  Future<Either<Failure, InseminationEntity>> call(IdParams params) async {
    // The repository method already returns the correct Future<Either<...>> type.
    // We just need to return that result directly.
    try {
      final result = await repository.fetchInseminationDetail(params.id);
      return result; // ⭐ FIX: Return the Either result directly.
      
      // Note: The outer try-catch is still useful here to handle potential 
      // synchronous errors (like DI failures) before the async call is made,
      // but for the repository result, we just return it.
    } catch (e) {
      // This handles unexpected synchronous errors that bypass the repository's Either logic.
      return Left(FailureConverter.fromException(e));
    }
  }
}