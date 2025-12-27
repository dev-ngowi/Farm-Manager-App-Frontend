// lib/features/farmer/breeding/pregnancy_check/data/repositories/pregnancy_check_repository_impl.dart

import 'package:dartz/dartz.dart';
import 'package:farm_manager_app/core/error/failure.dart';
import 'package:farm_manager_app/features/farmer/breeding/pregnancyCheck/data/datasources/pregnancy_check_remote_datasource.dart';
import 'package:farm_manager_app/features/farmer/breeding/pregnancyCheck/data/models/pregnancy_check_model.dart';
import 'package:farm_manager_app/features/farmer/breeding/pregnancyCheck/domain/entities/pregnancy_check_entity.dart';
import 'package:farm_manager_app/features/farmer/breeding/pregnancyCheck/domain/repositories/pregnancy_check_repository.dart';

class PregnancyCheckRepositoryImpl implements PregnancyCheckRepository {
  final PregnancyCheckRemoteDataSource remoteDataSource;

  PregnancyCheckRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<PregnancyCheckEntity>>> getPregnancyChecks({
    Map<String, dynamic>? filters,
  }) async {
    try {
      final List<PregnancyCheckModel> models = await remoteDataSource.getPregnancyChecks(
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
  Future<Either<Failure, PregnancyCheckEntity>> getPregnancyCheckById(int id) async {
    try {
      final PregnancyCheckModel model = await remoteDataSource.getPregnancyCheckById(id);
      return Right(model);
    } on AppException catch (e) {
      return Left(FailureConverter.fromException(e));
    } catch (e) {
      return Left(ServerFailure('An unexpected error occurred: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, PregnancyCheckEntity>> addPregnancyCheck(
    Map<String, dynamic> data,
  ) async {
    try {
      final PregnancyCheckModel model = await remoteDataSource.addPregnancyCheck(data);
      return Right(model);
    } on AppException catch (e) {
      return Left(FailureConverter.fromException(e));
    } catch (e) {
      return Left(ServerFailure('An unexpected error occurred: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, PregnancyCheckEntity>> updatePregnancyCheck(
    int id,
    Map<String, dynamic> data,
  ) async {
    try {
      final PregnancyCheckModel model = await remoteDataSource.updatePregnancyCheck(id, data);
      return Right(model);
    } on AppException catch (e) {
      return Left(FailureConverter.fromException(e));
    } catch (e) {
      return Left(ServerFailure('An unexpected error occurred: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> deletePregnancyCheck(int id) async {
    try {
      await remoteDataSource.deletePregnancyCheck(id);
      return const Right(null);
    } on AppException catch (e) {
      return Left(FailureConverter.fromException(e));
    } catch (e) {
      return Left(ServerFailure('An unexpected error occurred: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<PregnancyCheckInseminationEntity>>> getAvailableInseminations() async {
    try {
      final List<PregnancyCheckInseminationModel> models = 
          await remoteDataSource.getAvailableInseminations();
      return Right(models);
    } on AppException catch (e) {
      return Left(FailureConverter.fromException(e));
    } catch (e) {
      return Left(ServerFailure('An unexpected error occurred while fetching inseminations: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<PregnancyCheckVetEntity>>> getAvailableVets() async {
    try {
      final List<PregnancyCheckVetModel> models = await remoteDataSource.getAvailableVets();
      return Right(models);
    } on AppException catch (e) {
      return Left(FailureConverter.fromException(e));
    } catch (e) {
      return Left(ServerFailure('An unexpected error occurred while fetching vets: ${e.toString()}'));
    }
  }
}