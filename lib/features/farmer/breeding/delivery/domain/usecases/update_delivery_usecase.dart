import 'package:dartz/dartz.dart';
import 'package:farm_manager_app/core/error/failure.dart';
import 'package:farm_manager_app/features/farmer/breeding/delivery/domain/entities/delivery_entity.dart';
import 'package:farm_manager_app/features/farmer/breeding/delivery/domain/repositories/delivery_repository.dart';

class UpdateDeliveryUseCase {
  final DeliveryRepository repository;

  UpdateDeliveryUseCase(this.repository);

  Future<Either<Failure, DeliveryEntity>> call(int id, Map<String, dynamic> data) async {
    return await repository.updateDelivery(id, data);
  }
}