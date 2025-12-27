import 'package:dartz/dartz.dart';
import 'package:farm_manager_app/core/error/failure.dart';
import '../entities/delivery_entity.dart';

abstract class DeliveryRepository {
  Future<Either<Failure, List<DeliveryEntity>>> getDeliveries({Map<String, dynamic>? filters});
  Future<Either<Failure, DeliveryEntity>> getDeliveryById(dynamic id); // Changed to dynamic
  Future<Either<Failure, DeliveryEntity>> addDelivery(Map<String, dynamic> data);
  Future<Either<Failure, DeliveryEntity>> updateDelivery(dynamic id, Map<String, dynamic> data); // Changed to dynamic
  Future<Either<Failure, void>> deleteDelivery(dynamic id); // Changed to dynamic
  
  Future<Either<Failure, List<DeliveryInseminationEntity>>> getAvailableInseminations();
}