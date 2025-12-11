// lib/features/farmer/breeding/Insemination/data/repositories/insemination_repository_impl.dart

import 'package:dartz/dartz.dart';
import 'package:farm_manager_app/core/error/failure.dart';
import 'package:farm_manager_app/features/farmer/breeding/Insemination/data/datasources/insemination_remote_datasource.dart';
import 'package:farm_manager_app/features/farmer/breeding/Insemination/data/models/insemination_model.dart';
import 'package:farm_manager_app/features/farmer/breeding/Insemination/domain/entities/insemination_entity.dart';
import 'package:farm_manager_app/features/farmer/breeding/Insemination/domain/repositories/insemination_repository.dart';

class InseminationRepositoryImpl implements InseminationRepository {
  final InseminationRemoteDataSource remoteDataSource;

  InseminationRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<InseminationEntity>>> fetchInseminationList({
    Map<String, dynamic>? filters,
  }) async {
    try {
      final List<InseminationModel> resultModels = await remoteDataSource.fetchInseminationList(
        filters: filters,
      );
      return Right(resultModels);
    } on AppException catch (e) {
      return Left(FailureConverter.fromException(e));
    } catch (e) {
      return Left(ServerFailure('An unexpected error occurred during list fetch: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, InseminationEntity>> fetchInseminationDetail(int id) async {
    try {
      final InseminationModel resultModel = await remoteDataSource.fetchInseminationDetail(id);
      return Right(resultModel);
    } on AppException catch (e) {
      return Left(FailureConverter.fromException(e));
    } catch (e) {
      return Left(ServerFailure('An unexpected error occurred during detail fetch: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, InseminationEntity>> addInsemination(
    Map<String, dynamic> recordData,
  ) async {
    try {
      final InseminationModel resultModel = await remoteDataSource.addInsemination(recordData);
      return Right(resultModel);
    } on AppException catch (e) {
      return Left(FailureConverter.fromException(e));
    } catch (e) {
      return Left(ServerFailure('An unexpected error occurred during record submission: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, InseminationEntity>> updateInsemination(
    int id,
    Map<String, dynamic> updatedData,
  ) async {
    try {
      final InseminationModel resultModel = await remoteDataSource.updateInsemination(
        id,
        updatedData,
      );
      return Right(resultModel);
    } on AppException catch (e) {
      return Left(FailureConverter.fromException(e));
    } catch (e) {
      return Left(ServerFailure('An unexpected error occurred during record update: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteInsemination(int id) async {
    try {
      await remoteDataSource.deleteInsemination(id);
      return const Right(null);
    } on AppException catch (e) {
      return Left(FailureConverter.fromException(e));
    } catch (e) {
      return Left(ServerFailure('An unexpected error occurred during record deletion: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<InseminationAnimalEntity>>> getAvailableAnimals() async {
    try {
      final List<InseminationAnimalModel> resultModels = await remoteDataSource.getAvailableAnimals();
      return Right(resultModels);
    } on AppException catch (e) {
      return Left(FailureConverter.fromException(e));
    } catch (e) {
      return Left(ServerFailure('An unexpected error occurred while fetching animals: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<InseminationSemenEntity>>> getAvailableSemen() async {
    try {
      final List<InseminationSemenModel> resultModels = await remoteDataSource.getAvailableSemen();
      return Right(resultModels);
    } on AppException catch (e) {
      return Left(FailureConverter.fromException(e));
    } catch (e) {
      return Left(ServerFailure('An unexpected error occurred while fetching semen: ${e.toString()}'));
    }
  }
}