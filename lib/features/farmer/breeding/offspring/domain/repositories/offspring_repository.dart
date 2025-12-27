// lib/features/farmer/breeding/offspring/domain/repositories/offspring_repository.dart

import 'package:dartz/dartz.dart';
import 'package:farm_manager_app/core/error/failure.dart';
import '../entities/offspring_entity.dart';

abstract class OffspringRepository {
  Future<Either<Failure, List<OffspringEntity>>> getOffspringList({Map<String, dynamic>? filters});
  Future<Either<Failure, OffspringEntity>> getOffspringById(dynamic id);
  Future<Either<Failure, OffspringEntity>> addOffspring(Map<String, dynamic> data);
  Future<Either<Failure, OffspringEntity>> updateOffspring(dynamic id, Map<String, dynamic> data);
  Future<Either<Failure, void>> deleteOffspring(dynamic id);
  Future<Either<Failure, dynamic>> registerOffspring(dynamic id, Map<String, dynamic> data);
  
  Future<Either<Failure, List<OffspringDeliveryEntity>>> getAvailableDeliveries();
}