import 'package:dartz/dartz.dart';
import 'package:farm_manager_app/core/error/failure.dart';
import 'package:farm_manager_app/features/farmer/livestock/domain/entities/livestock.dart';
import 'package:farm_manager_app/features/farmer/livestock/domain/repositories/livestock_repository.dart';
import 'package:farm_manager_app/core/usecases/usercase.dart';

class GetAllLivestock implements UseCase<List<LivestockEntity>, LivestockParams> {
  final LivestockRepository repository;

  GetAllLivestock(this.repository);

  @override
  Future<Either<Failure, List<LivestockEntity>>> call(LivestockParams params) {
    // The use case can now take optional filters from the list page
    return repository.getAllLivestock(filters: params.filters);
  }
}

// Params class to encapsulate optional filter parameters
class LivestockParams {
  final Map<String, dynamic>? filters;

  const LivestockParams({this.filters});
}