// lib/features/farmer/breeding/delivery/data/repositories/delivery_repository_impl.dart

import 'package:dartz/dartz.dart';
import 'package:farm_manager_app/core/error/failure.dart';
import 'package:farm_manager_app/features/farmer/breeding/delivery/data/datasources/delivery_remote_datasource.dart';
import 'package:farm_manager_app/features/farmer/breeding/delivery/data/models/delivery_model.dart';
import 'package:farm_manager_app/features/farmer/breeding/delivery/domain/entities/delivery_entity.dart';
import 'package:farm_manager_app/features/farmer/breeding/delivery/domain/repositories/delivery_repository.dart';

class DeliveryRepositoryImpl implements DeliveryRepository {
  final DeliveryRemoteDataSource remoteDataSource;

  DeliveryRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<DeliveryEntity>>> getDeliveries({
    Map<String, dynamic>? filters,
  }) async {
    try {
      final List<DeliveryModel> models = await remoteDataSource.getDeliveries(
        filters: filters,
      );
      return Right(models);
    } on AppException catch (e) {
      return Left(FailureConverter.fromException(e));
    } catch (e) {
      return Left(ServerFailure('An unexpected error occurred: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, DeliveryEntity>> getDeliveryById(dynamic id) async {
    try {
      final DeliveryModel model = await remoteDataSource.getDeliveryById(id);
      return Right(model);
    } on AppException catch (e) {
      return Left(FailureConverter.fromException(e));
    } catch (e) {
      return Left(ServerFailure('An unexpected error occurred: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, DeliveryEntity>> addDelivery(
    Map<String, dynamic> data,
  ) async {
    try {
      final DeliveryModel model = await remoteDataSource.addDelivery(data);
      return Right(model);
    } on AppException catch (e) {
      return Left(FailureConverter.fromException(e));
    } catch (e) {
      return Left(ServerFailure('An unexpected error occurred: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, DeliveryEntity>> updateDelivery(
    dynamic id,
    Map<String, dynamic> data,
  ) async {
    try {
      final DeliveryModel model = await remoteDataSource.updateDelivery(id, data);
      return Right(model);
    } on AppException catch (e) {
      return Left(FailureConverter.fromException(e));
    } catch (e) {
      return Left(ServerFailure('An unexpected error occurred: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteDelivery(dynamic id) async {
    try {
      await remoteDataSource.deleteDelivery(id);
      return const Right(null);
    } on AppException catch (e) {
      return Left(FailureConverter.fromException(e));
    } catch (e) {
      return Left(ServerFailure('An unexpected error occurred: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<DeliveryInseminationEntity>>> getAvailableInseminations() async {
    try {
      final List<DeliveryInseminationModel> models = 
          await remoteDataSource.getAvailableInseminations();
      return Right(models);
    } on AppException catch (e) {
      return Left(FailureConverter.fromException(e));
    } catch (e) {
      return Left(ServerFailure('An unexpected error occurred while fetching inseminations: ${e.toString()}'));
    }
  }
}