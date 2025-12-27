// heat_cycle_repository_impl.dart (in /data/repositories)

import 'package:dartz/dartz.dart';
import 'package:farm_manager_app/core/networking/network_info.dart';
import 'package:farm_manager_app/features/farmer/breeding/HeatCycle/data/datasources/heat_cycle_remote_data_source.dart';
import 'package:farm_manager_app/features/farmer/breeding/HeatCycle/data/models/heat_cycle_model.dart';
import 'package:farm_manager_app/features/farmer/breeding/HeatCycle/domain/entities/heat_cycle_entity.dart';
import 'package:farm_manager_app/features/farmer/breeding/HeatCycle/domain/repositories/heat_cycle_repository.dart';
import 'package:farm_manager_app/core/error/failure.dart'; 
// NOTE: Make sure you also import your exception classes (AuthException, ServerException, ValidationException)
// which are used in the catch blocks, although they are not shown in the provided imports.

class HeatCycleRepositoryImpl implements HeatCycleRepository {
  final HeatCycleRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  HeatCycleRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  // ========================================
  // GET HEAT CYCLES (LIST)
  // ========================================

  @override
  Future<Either<Failure, List<HeatCycleEntity>>> getHeatCycles({
    required String token,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure(
        'No internet connection. Please check your network.',
      ));
    }

    try {
      print('🔄 HeatCycleRepository: Fetching heat cycles list...');
      
      final List<HeatCycleModel> models = await remoteDataSource.getHeatCycles(token);
      
      print('✅ HeatCycleRepository: Fetched ${models.length} cycles.');
      
      final List<HeatCycleEntity> entities = models.map((model) => model as HeatCycleEntity).toList();
      
      return Right(entities);
      
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.statusCode));
    } on ValidationException catch (e) {
      return Left(ValidationFailure(e.message, errors: e.errors));
    } catch (e) {
      print('❌ HeatCycleRepository: Unexpected error fetching list: $e');
      return Left(ServerFailure('An unexpected error occurred while loading heat cycles: $e'));
    }
  }

  // ========================================
  // GET HEAT CYCLE DETAILS
  // ========================================

  @override
  Future<Either<Failure, HeatCycleEntity>> getHeatCycleDetails({
    required String id,
    required String token,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      print('🔄 HeatCycleRepository: Fetching details for cycle $id...');
      
      final HeatCycleModel model = await remoteDataSource.getHeatCycleDetails(id, token);
      
      print('✅ HeatCycleRepository: Details fetched successfully.');
      
      return Right(model as HeatCycleEntity);
      
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on ServerException catch (e) {
      if (e.statusCode == 404) {
        return Left(ServerFailure('Heat cycle with ID $id not found.', 404));
      }
      return Left(ServerFailure(e.message, e.statusCode));
    } catch (e) {
      return Left(ServerFailure('Failed to load heat cycle details: $e'));
    }
  }

  // ========================================
  // CREATE HEAT CYCLE
  // ========================================

  @override
  Future<Either<Failure, HeatCycleEntity>> createHeatCycle({
    required HeatCycleEntity cycle,
    required String token,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      print('🔄 HeatCycleRepository: Creating new heat cycle...');

      // FIXED: Convert Entity to Model with all required parameters
      final HeatCycleModel cycleModel = HeatCycleModel(
        id: cycle.id,
        damId: cycle.damId, // ADDED: missing damId parameter
        observedDate: cycle.observedDate,
        intensity: cycle.intensity,
        inseminated: cycle.inseminated,
        nextExpectedDate: cycle.nextExpectedDate,
        dam: cycle.dam,
        notes: cycle.notes,
      );

      final HeatCycleModel createdModel = await remoteDataSource.createHeatCycle(cycleModel, token);

      print('✅ HeatCycleRepository: Cycle created successfully with ID ${createdModel.id}');
      
      return Right(createdModel as HeatCycleEntity);
      
    } on ValidationException catch (e) {
      return Left(ValidationFailure(e.message, errors: e.errors));
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.statusCode));
    } catch (e) {
      return Left(ServerFailure('Failed to create heat cycle: $e'));
    }
  }

  // ========================================
  // UPDATE HEAT CYCLE
  // ========================================

  @override
  Future<Either<Failure, HeatCycleEntity>> updateHeatCycle({
    required String id,
    required HeatCycleEntity cycle,
    required String token,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      print('🔄 HeatCycleRepository: Updating heat cycle $id...');

      // FIXED: Convert Entity to Model with all required parameters
      final HeatCycleModel cycleModel = HeatCycleModel(
        id: cycle.id, 
        damId: cycle.damId, // ADDED: missing damId parameter
        observedDate: cycle.observedDate,
        intensity: cycle.intensity,
        inseminated: cycle.inseminated,
        nextExpectedDate: cycle.nextExpectedDate,
        dam: cycle.dam,
        notes: cycle.notes,
      );

      final HeatCycleModel updatedModel = await remoteDataSource.updateHeatCycle(id, cycleModel, token);

      print('✅ HeatCycleRepository: Cycle $id updated successfully.');
      
      return Right(updatedModel as HeatCycleEntity);
      
    } on ValidationException catch (e) {
      return Left(ValidationFailure(e.message, errors: e.errors));
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.statusCode));
    } catch (e) {
      return Left(ServerFailure('Failed to update heat cycle: $e'));
    }
  }

  // ========================================
  // DELETE HEAT CYCLE ⬅️ NEW METHOD
  // ========================================

  @override
  Future<Either<Failure, Unit>> deleteHeatCycle({
    required String id,
    required String token,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure(
        'No internet connection. Please check your network.',
      ));
    }

    try {
      print('🔄 HeatCycleRepository: Deleting heat cycle $id...');

      // Assuming remoteDataSource has a corresponding method
      await remoteDataSource.deleteHeatCycle(id, token);

      print('✅ HeatCycleRepository: Cycle $id deleted successfully.');
      
      // Use const Right(unit) to signify successful operation with no return value
      return const Right(unit); 
      
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.statusCode));
    } catch (e) {
      return Left(ServerFailure('Failed to delete heat cycle: $e'));
    }
  }
}