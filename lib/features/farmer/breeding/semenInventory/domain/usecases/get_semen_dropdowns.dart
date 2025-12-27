import 'package:dartz/dartz.dart';
import 'package:farm_manager_app/core/error/failure.dart';
import 'package:farm_manager_app/features/farmer/breeding/semenInventory/domain/entities/dropdown_entity.dart';
import 'package:farm_manager_app/features/farmer/breeding/semenInventory/domain/repositories/semen_repository.dart';

// NoParams class - use this if not defined in your core
class NoParams {}

/// Use case to fetch dropdown data (Bulls and Breeds) for the semen creation form
/// This calls the repository's getSemenDropdownData method which returns a Map
class GetSemenDropdowns {
  final SemenRepository repository;

  GetSemenDropdowns(this.repository);

  Future<Either<Failure, Map<String, List<DropdownEntity>>>> call(NoParams params) async {
    return repository.getSemenDropdownData();
  }
}