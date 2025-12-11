// lib/features/farmer/insemination/domain/usecases/fetch_insemination_list.dart

import 'package:dartz/dartz.dart';
import 'package:farm_manager_app/core/error/failure.dart';
import 'package:farm_manager_app/core/usecases/usercase.dart';
import 'package:farm_manager_app/features/farmer/breeding/Insemination/domain/entities/insemination_entity.dart';
import 'package:farm_manager_app/features/farmer/breeding/Insemination/domain/repositories/insemination_repository.dart';


class FetchInseminationListParams extends Params {
  final Map<String, dynamic>? filters;
  const FetchInseminationListParams({this.filters});

  @override
  List<Object?> get props => [filters];
}

class FetchInseminationList implements UseCase<List<InseminationEntity>, FetchInseminationListParams> {
  final InseminationRepository repository;

  FetchInseminationList({required this.repository});

  @override
  Future<Either<Failure, List<InseminationEntity>>> call(FetchInseminationListParams params) async {
    try {
      final result = await repository.fetchInseminationList(filters: params.filters);
      return result;
    } catch (e) {
      // ⭐ Convert repository exception to a Failure
      return Left(FailureConverter.fromException(e)); 
    }
  }
}