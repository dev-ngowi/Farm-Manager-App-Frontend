// lib/features/farmer/breeding/offspring/domain/usecases/offspring_usecases.dart

import 'package:dartz/dartz.dart';
import 'package:farm_manager_app/core/error/failure.dart';
import '../entities/offspring_entity.dart';
import '../repositories/offspring_repository.dart';

// ========================================
// GET OFFSPRING LIST
// ========================================
class GetOffspringListUseCase {
  final OffspringRepository repository;

  GetOffspringListUseCase(this.repository);

  Future<Either<Failure, List<OffspringEntity>>> call({
    Map<String, dynamic>? filters,
  }) {
    return repository.getOffspringList(filters: filters);
  }
}

// ========================================
// GET OFFSPRING BY ID
// ========================================
class GetOffspringByIdUseCase {
  final OffspringRepository repository;

  GetOffspringByIdUseCase(this.repository);

  Future<Either<Failure, OffspringEntity>> call(dynamic id) {
    return repository.getOffspringById(id);
  }
}

// ========================================
// ADD OFFSPRING
// ========================================
class AddOffspringUseCase {
  final OffspringRepository repository;

  AddOffspringUseCase(this.repository);

  Future<Either<Failure, OffspringEntity>> call(Map<String, dynamic> data) {
    return repository.addOffspring(data);
  }
}

// ========================================
// UPDATE OFFSPRING
// ========================================
class UpdateOffspringUseCase {
  final OffspringRepository repository;

  UpdateOffspringUseCase(this.repository);

  Future<Either<Failure, OffspringEntity>> call(
    dynamic id,
    Map<String, dynamic> data,
  ) {
    return repository.updateOffspring(id, data);
  }
}

// ========================================
// DELETE OFFSPRING
// ========================================
class DeleteOffspringUseCase {
  final OffspringRepository repository;

  DeleteOffspringUseCase(this.repository);

  Future<Either<Failure, void>> call(dynamic id) {
    return repository.deleteOffspring(id);
  }
}

// ========================================
// REGISTER OFFSPRING AS LIVESTOCK
// ========================================
class RegisterOffspringUseCase {
  final OffspringRepository repository;

  RegisterOffspringUseCase(this.repository);

  Future<Either<Failure, dynamic>> call(
    dynamic id,
    Map<String, dynamic> data,
  ) {
    return repository.registerOffspring(id, data);
  }
}

// ========================================
// GET AVAILABLE DELIVERIES (FOR DROPDOWN)
// ========================================
class GetAvailableDeliveriesUseCase {
  final OffspringRepository repository;

  GetAvailableDeliveriesUseCase(this.repository);

  Future<Either<Failure, List<OffspringDeliveryEntity>>> call() {
    return repository.getAvailableDeliveries();
  }
}