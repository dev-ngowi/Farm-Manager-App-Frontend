// lib/features/farmer/livestock/data/repositories/livestock_repository_impl.dart

import 'package:dartz/dartz.dart';
import 'package:farm_manager_app/core/error/failure.dart';
// Import AppException for error handling
import 'package:farm_manager_app/features/farmer/livestock/data/datasources/livestock_remote_datasource.dart';
import 'package:farm_manager_app/features/farmer/livestock/domain/entities/dropdown_data.dart';
import 'package:farm_manager_app/features/farmer/livestock/domain/entities/livestock.dart';
import 'package:farm_manager_app/features/farmer/livestock/domain/entities/livestock_summary.dart';
import 'package:farm_manager_app/features/farmer/livestock/domain/repositories/livestock_repository.dart';

// Assuming these models are defined and handle the 'value'/'label' mapping:
import 'package:farm_manager_app/features/farmer/livestock/data/models/species_model.dart';
import 'package:farm_manager_app/features/farmer/livestock/data/models/breed_model.dart';
import 'package:farm_manager_app/features/farmer/livestock/data/models/dropdown_model.dart'; 
import 'package:farm_manager_app/features/farmer/livestock/data/models/parent_model.dart'; 


class LivestockRepositoryImpl implements LivestockRepository {
  final LivestockRemoteDataSource remoteDataSource;

  LivestockRepositoryImpl({required this.remoteDataSource});

  // -----------------------------------------------------------------
  // 1. Implementation of LivestockRepository required methods 
  // -----------------------------------------------------------------

  @override
  Future<Either<Failure, List<LivestockEntity>>> getAllLivestock({
    Map<String, dynamic>? filters,
  }) async {
    try {
      final result = await remoteDataSource.getAllLivestock(filters: filters);
      return Right(result);
    } on AppException catch (e) {
      return Left(FailureConverter.fromException(e));
    } catch (e) {
      return Left(ServerFailure('An unexpected error occurred: ${e.toString()}'));
    }
  }
  
  @override
  Future<Either<Failure, LivestockEntity>> getLivestockById(int animalId) async {
    try {
      final result = await remoteDataSource.getLivestockById(animalId);
      return Right(result);
    } on AppException catch (e) {
      return Left(FailureConverter.fromException(e));
    } catch (e) {
      return Left(ServerFailure('An unexpected error occurred: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, LivestockEntity>> addLivestock(Map<String, dynamic> animalData) async {
    try {
      final result = await remoteDataSource.addLivestock(animalData);
      return Right(result);
    } on AppException catch (e) {
      // Catches ValidationException and converts to ValidationFailure
      return Left(FailureConverter.fromException(e));
    } catch (e) {
      return Left(ServerFailure('An unexpected error occurred: ${e.toString()}'));
    }
  }
  
  @override
  Future<Either<Failure, LivestockSummary>> getLivestockSummary() async {
    try {
      final result = await remoteDataSource.getLivestockSummary();
      return Right(result);
    } on AppException catch (e) {
      return Left(FailureConverter.fromException(e));
    } catch (e) {
      return Left(ServerFailure('An unexpected error occurred: ${e.toString()}'));
    }
  }

 // ⭐ NEW: Update Livestock Implementation
  @override
  Future<Either<Failure, LivestockEntity>> updateLivestock({
    required int animalId,
    required Map<String, dynamic> animalData,
  }) async {
    try {
      final result = await remoteDataSource.updateLivestock(
        animalId: animalId,
        animalData: animalData,
      );
      return Right(result);
    } on AppException catch (e) {
      return Left(FailureConverter.fromException(e));
    } catch (e) {
      return Left(ServerFailure('An unexpected error occurred during update: ${e.toString()}'));
    }
  }

  // ⭐ NEW: Delete Livestock Implementation
  @override
  Future<Either<Failure, void>> deleteLivestock(int animalId) async {
    try {
      await remoteDataSource.deleteLivestock(animalId);
      return const Right(null); // Return Right(null) for a successful void operation
    } on AppException catch (e) {
      return Left(FailureConverter.fromException(e));
    } catch (e) {
      return Left(ServerFailure('An unexpected error occurred during deletion: ${e.toString()}'));
    }
  }

  // -----------------------------------------------------------------
  // 2. DROPDOWN OPERATION (Retained for completeness)
  // -----------------------------------------------------------------

  @override
  Future<Either<Failure, DropdownData>> getLivestockDropdowns() async {
    try {
      final DropdownModel resultModel = await remoteDataSource.getLivestockDropdowns();
      
      // Placeholder mapping logic
      final speciesList = resultModel.species
          .map((item) => SpeciesModel.fromJson(item as Map<String, dynamic>))
          .toList();

      final breedList = resultModel.breeds
          .map((item) => BreedModel.fromJson(item as Map<String, dynamic>))
          .toList();

      final allParents = resultModel.parents
          .map((item) => ParentModel.fromJson(item as Map<String, dynamic>))
          .toList();

      final siresList = allParents.where((p) => p.sex == 'Male').toList();
      final damsList = allParents.where((p) => p.sex == 'Female').toList();


      final dropdownData = DropdownData(
        species: speciesList,
        breeds: breedList,
        sires: siresList, 
        dams: damsList,
      );

      return Right(dropdownData);
    } on AppException catch (e) {
      return Left(FailureConverter.fromException(e));
    } catch (e) {
      return Left(ServerFailure('An unexpected error occurred during dropdown fetch: ${e.toString()}'));
    }
  }
}