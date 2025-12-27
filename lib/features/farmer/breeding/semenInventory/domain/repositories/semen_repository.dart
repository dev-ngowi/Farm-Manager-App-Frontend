import 'package:dartz/dartz.dart';
import 'package:farm_manager_app/core/error/failure.dart';
import 'package:farm_manager_app/features/farmer/breeding/semenInventory/domain/entities/dropdown_entity.dart';
import 'package:farm_manager_app/features/farmer/breeding/semenInventory/domain/entities/semen_entity.dart';

abstract class SemenRepository {
  // 1. Get List with Filters
  Future<Either<Failure, List<SemenEntity>>> getSemenInventory({
    bool? availableOnly,
    String? breedId,
  });

  // 2. Get Dropdown List (Maps the API response to a clean Entity for dropdowns)
  Future<Either<Failure, List<DropdownEntity>>> getAvailableSemen();

  // ⭐ NEW: Get dropdown data for Bulls and Breeds (for creation form)
  Future<Either<Failure, Map<String, List<DropdownEntity>>>> getSemenDropdownData();

  // 3. Get Details
  Future<Either<Failure, SemenEntity>> getSemenDetails(String id);

  // 4. Create
  Future<Either<Failure, SemenEntity>> createSemen(SemenEntity semen);

  // 5. Update
  Future<Either<Failure, SemenEntity>> updateSemen(String id, SemenEntity semen);

  // 6. Delete
  Future<Either<Failure, void>> deleteSemen(String id);
}