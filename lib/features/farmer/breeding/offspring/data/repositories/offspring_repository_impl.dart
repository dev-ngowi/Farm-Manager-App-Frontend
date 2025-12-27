// lib/features/farmer/breeding/offspring/data/repositories/offspring_repository_impl.dart

import 'package:dartz/dartz.dart';
import 'package:farm_manager_app/core/error/failure.dart';
import 'package:farm_manager_app/features/farmer/breeding/offspring/data/datasources/offspring_remote_datasource.dart';
import 'package:farm_manager_app/features/farmer/breeding/offspring/data/models/offspring_model.dart';
import 'package:farm_manager_app/features/farmer/breeding/offspring/domain/entities/offspring_entity.dart';
import 'package:farm_manager_app/features/farmer/breeding/offspring/domain/repositories/offspring_repository.dart';

class OffspringRepositoryImpl implements OffspringRepository {
  final OffspringRemoteDataSource remoteDataSource;

  OffspringRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<OffspringEntity>>> getOffspringList({
    Map<String, dynamic>? filters,
  }) async {
    try {
      final List<OffspringModel> models = await remoteDataSource.getOffspringList(
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
  Future<Either<Failure, OffspringEntity>> getOffspringById(dynamic id) async {
    try {
      final OffspringModel model = await remoteDataSource.getOffspringById(id);
      return Right(model);
    } on AppException catch (e) {
      return Left(FailureConverter.fromException(e));
    } catch (e) {
      return Left(ServerFailure('An unexpected error occurred: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, OffspringEntity>> addOffspring(
    Map<String, dynamic> data,
  ) async {
    try {
      final OffspringModel model = await remoteDataSource.addOffspring(data);
      return Right(model);
    } on AppException catch (e) {
      return Left(FailureConverter.fromException(e));
    } catch (e) {
      return Left(ServerFailure('An unexpected error occurred: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, OffspringEntity>> updateOffspring(
    dynamic id,
    Map<String, dynamic> data,
  ) async {
    try {
      final OffspringModel model = await remoteDataSource.updateOffspring(id, data);
      return Right(model);
    } on AppException catch (e) {
      return Left(FailureConverter.fromException(e));
    } catch (e) {
      return Left(ServerFailure('An unexpected error occurred: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteOffspring(dynamic id) async {
    try {
      await remoteDataSource.deleteOffspring(id);
      return const Right(null);
    } on AppException catch (e) {
      return Left(FailureConverter.fromException(e));
    } catch (e) {
      return Left(ServerFailure('An unexpected error occurred: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, dynamic>> registerOffspring(
    dynamic id,
    Map<String, dynamic> data,
  ) async {
    try {
      final result = await remoteDataSource.registerOffspring(id, data);
      return Right(result);
    } on AppException catch (e) {
      return Left(FailureConverter.fromException(e));
    } catch (e) {
      return Left(ServerFailure('An unexpected error occurred: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<OffspringDeliveryEntity>>> getAvailableDeliveries() async {
    try {
      final List<OffspringDeliveryModel> models = 
          await remoteDataSource.getAvailableDeliveries();
      return Right(models);
    } on AppException catch (e) {
      return Left(FailureConverter.fromException(e));
    } catch (e) {
      return Left(ServerFailure('An unexpected error occurred: ${e.toString()}'));
    }
  }
}