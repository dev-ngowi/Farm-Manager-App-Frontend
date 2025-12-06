import 'package:dartz/dartz.dart';
import 'package:farm_manager_app/core/error/failure.dart';
// 💡 IMPORTANT: Verify this import path. It is often 'usecase.dart'

import 'package:farm_manager_app/core/usecases/usercase.dart' show UseCase; 
import 'package:farm_manager_app/features/farmer/breeding/semenInventory/domain/entities/semen_entity.dart';
import 'package:farm_manager_app/features/farmer/breeding/semenInventory/domain/repositories/semen_repository.dart';

/// Fetches the entire semen inventory list from the repository.
/// 
/// It allows for optional filtering based on availability status or breed.
class GetAllSemen implements UseCase<List<SemenEntity>, SemenListParams> {
  final SemenRepository repository;

  GetAllSemen(this.repository);

  @override
  Future<Either<Failure, List<SemenEntity>>> call(SemenListParams params) async {
    // 💡 The Use Case simply calls the Repository, passing the parameters.
    return repository.getSemenInventory(
      availableOnly: params.availableOnly,
      breedId: params.breedId,
    );
  }
}

// --- Parameters Class ---
/// Defines the specific parameters required for filtering the semen list.
class SemenListParams {
  /// If true, only show semen straws that have an available quantity > 0.
  final bool? availableOnly;
  
  /// Filters the list by a specific breed ID.
  final String? breedId;

  SemenListParams({this.availableOnly, this.breedId});
}