import 'package:dartz/dartz.dart';
import 'package:farm_manager_app/core/error/failure.dart';
import 'package:farm_manager_app/features/farmer/breeding/delivery/domain/repositories/delivery_repository.dart';

class DeleteDeliveryUseCase {
  final DeliveryRepository repository;

  DeleteDeliveryUseCase(this.repository);

  Future<Either<Failure, void>> call(int id) async {
    return await repository.deleteDelivery(id);
  }
}