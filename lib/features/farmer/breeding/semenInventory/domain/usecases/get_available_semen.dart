import 'package:dartz/dartz.dart';
import 'package:farm_manager_app/core/error/failure.dart';

import 'package:farm_manager_app/core/usecases/usercase.dart' show UseCase; 
import 'package:farm_manager_app/features/farmer/breeding/semenInventory/domain/entities/dropdown_entity.dart';
import 'package:farm_manager_app/features/farmer/breeding/semenInventory/domain/repositories/semen_repository.dart';

// ✅ FIX: Define NoParams here IF you don't have a shared core/usecase file that exports it.
// If you do have a core file, you should remove this definition and import it instead.
// For now, let's keep it here for guaranteed use case functionality:
class NoParams {} 

class GetAvailableSemen implements UseCase<List<DropdownEntity>, NoParams> {
  final SemenRepository repository;

  GetAvailableSemen(this.repository);

  @override
  Future<Either<Failure, List<DropdownEntity>>> call(NoParams params) async {
    return repository.getAvailableSemen();
  }
}