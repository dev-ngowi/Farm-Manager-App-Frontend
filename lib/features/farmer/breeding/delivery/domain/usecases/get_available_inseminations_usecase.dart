import 'package:dartz/dartz.dart';
import 'package:farm_manager_app/core/error/failure.dart';
import 'package:farm_manager_app/features/farmer/breeding/delivery/domain/entities/delivery_entity.dart';
import 'package:farm_manager_app/features/farmer/breeding/delivery/domain/repositories/delivery_repository.dart';

class GetAvailableInseminationsUseCase {
  final DeliveryRepository repository;

  GetAvailableInseminationsUseCase(this.repository);

  Future<Either<Failure, List<DeliveryInseminationEntity>>> call() async {
    return await repository.getAvailableInseminations();
  }
}