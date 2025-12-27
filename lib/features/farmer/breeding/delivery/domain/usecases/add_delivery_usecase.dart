import 'package:dartz/dartz.dart';
import 'package:farm_manager_app/core/error/failure.dart';
import 'package:farm_manager_app/features/farmer/breeding/delivery/domain/entities/delivery_entity.dart';
import 'package:farm_manager_app/features/farmer/breeding/delivery/domain/repositories/delivery_repository.dart';

class AddDeliveryUseCase {
  final DeliveryRepository repository;

  AddDeliveryUseCase(this.repository);

  Future<Either<Failure, DeliveryEntity>> call(Map<String, dynamic> data) async {
    return await repository.addDelivery(data);
  }
}