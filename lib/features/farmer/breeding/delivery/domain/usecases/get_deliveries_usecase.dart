
import 'package:dartz/dartz.dart';
import 'package:farm_manager_app/core/error/failure.dart';
import 'package:farm_manager_app/features/farmer/breeding/delivery/domain/entities/delivery_entity.dart';
import 'package:farm_manager_app/features/farmer/breeding/delivery/domain/repositories/delivery_repository.dart';

class GetDeliveriesUseCase {
  final DeliveryRepository repository;

  GetDeliveriesUseCase(this.repository);

  Future<Either<Failure, List<DeliveryEntity>>> call({Map<String, dynamic>? filters}) async {
    return await repository.getDeliveries(filters: filters);
  }
}