// heat_cycle_repository.dart (in /domain/repositories)

import 'package:dartz/dartz.dart';
import 'package:farm_manager_app/core/error/failure.dart';
import 'package:farm_manager_app/features/farmer/breeding/HeatCycle/domain/entities/heat_cycle_entity.dart';


abstract class HeatCycleRepository {
  /// Fetches a list of all recorded heat cycles.
  /// Returns a list of HeatCycleEntity or a Failure.
  Future<Either<Failure, List<HeatCycleEntity>>> getHeatCycles({
    required String token,
  });

  /// Fetches the detailed information for a single heat cycle by ID.
  /// Returns a single HeatCycleEntity or a Failure.
  Future<Either<Failure, HeatCycleEntity>> getHeatCycleDetails({
    required String id,
    required String token,
  });

  /// Creates a new heat cycle record.
  /// It takes a HeatCycleEntity (from the presentation layer) and maps it
  /// to a model for the API request.
  /// Returns the newly created HeatCycleEntity (with server-generated ID/dates) or a Failure.
  Future<Either<Failure, HeatCycleEntity>> createHeatCycle({
    required HeatCycleEntity cycle,
    required String token,
  });

  /// Updates an existing heat cycle record.
  /// It takes the ID and the updated HeatCycleEntity.
  /// Returns the updated HeatCycleEntity or a Failure.
  Future<Either<Failure, HeatCycleEntity>> updateHeatCycle({
    required String id,
    required HeatCycleEntity cycle,
    required String token,
  });

 
}