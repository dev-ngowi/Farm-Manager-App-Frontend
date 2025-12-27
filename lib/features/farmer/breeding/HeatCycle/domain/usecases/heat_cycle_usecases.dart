import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:farm_manager_app/core/error/failure.dart';
import 'package:farm_manager_app/features/farmer/breeding/HeatCycle/domain/entities/heat_cycle_entity.dart';
import 'package:farm_manager_app/features/farmer/breeding/HeatCycle/domain/repositories/heat_cycle_repository.dart';


/// Abstract base class for all use cases.
abstract class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}

/// Generic class for use cases that require no parameters.
class NoParams extends Equatable {
  @override
  List<Object?> get props => [];
}

// ------------------------------------------------------------------
// 1. GET HEAT CYCLES (LIST)
// ------------------------------------------------------------------

class GetHeatCycles implements UseCase<List<HeatCycleEntity>, GetHeatCyclesParams> {
  final HeatCycleRepository repository;

  GetHeatCycles(this.repository);

  @override
  Future<Either<Failure, List<HeatCycleEntity>>> call(GetHeatCyclesParams params) async {
    return await repository.getHeatCycles(token: params.token);
  }
}

class GetHeatCyclesParams extends Equatable {
  final String token;

  const GetHeatCyclesParams({required this.token});

  @override
  List<Object?> get props => [token];
}

// ------------------------------------------------------------------
// 2. GET HEAT CYCLE DETAILS
// ------------------------------------------------------------------

class GetHeatCycleDetails implements UseCase<HeatCycleEntity, GetHeatCycleDetailsParams> {
  final HeatCycleRepository repository;

  GetHeatCycleDetails(this.repository);

  @override
  Future<Either<Failure, HeatCycleEntity>> call(GetHeatCycleDetailsParams params) async {
    return await repository.getHeatCycleDetails(
      id: params.id,
      token: params.token,
    );
  }
}

class GetHeatCycleDetailsParams extends Equatable {
  final String id;
  final String token;

  const GetHeatCycleDetailsParams({required this.id, required this.token});

  @override
  List<Object?> get props => [id, token];
}

// ------------------------------------------------------------------
// 3. CREATE HEAT CYCLE
// ------------------------------------------------------------------

class CreateHeatCycle implements UseCase<HeatCycleEntity, CreateHeatCycleParams> {
  final HeatCycleRepository repository;

  CreateHeatCycle(this.repository);

  @override
  Future<Either<Failure, HeatCycleEntity>> call(CreateHeatCycleParams params) async {
    // Business logic: Ensure the DamEntity inside the HeatCycleEntity is fully populated
    // before sending it off (although the repo will only use the animalId/dam_id).
    
    return await repository.createHeatCycle(
      cycle: params.cycle,
      token: params.token,
    );
  }
}

class CreateHeatCycleParams extends Equatable {
  final HeatCycleEntity cycle; // The entity holds all the required fields (dam, date, intensity, notes)
  final String token;

  const CreateHeatCycleParams({required this.cycle, required this.token});

  @override
  List<Object?> get props => [cycle, token];
}

// ------------------------------------------------------------------
// 4. UPDATE HEAT CYCLE
// ------------------------------------------------------------------

class UpdateHeatCycle implements UseCase<HeatCycleEntity, UpdateHeatCycleParams> {
  final HeatCycleRepository repository;

  UpdateHeatCycle(this.repository);

  @override
  Future<Either<Failure, HeatCycleEntity>> call(UpdateHeatCycleParams params) async {
    // Business logic: Pass the updated entity to the repository. The data layer 
    // is responsible for figuring out which fields to send to the PUT endpoint.
    
    return await repository.updateHeatCycle(
      id: params.id,
      cycle: params.cycle,
      token: params.token,
    );
  }
}

class UpdateHeatCycleParams extends Equatable {
  final String id; // The ID of the cycle to update
  final HeatCycleEntity cycle; // The entity containing the new data
  final String token;

  const UpdateHeatCycleParams({required this.id, required this.cycle, required this.token});

  @override
  List<Object?> get props => [id, cycle, token];
}

// ------------------------------------------------------------------
// 5. DELETE HEAT CYCLE ⬅️ NEW USE CASE
// ------------------------------------------------------------------

/// Deletes a specific heat cycle record. Returns [Unit] on success.
class DeleteHeatCycle implements UseCase<Unit, DeleteHeatCycleParams> {
  final HeatCycleRepository repository;

  DeleteHeatCycle(this.repository);

  @override
  Future<Either<Failure, Unit>> call(DeleteHeatCycleParams params) async {
    return await repository.deleteHeatCycle(
      id: params.id,
      token: params.token,
    );
  }
}

class DeleteHeatCycleParams extends Equatable {
  final String id; // The ID of the cycle to delete
  final String token;

  const DeleteHeatCycleParams({required this.id, required this.token});

  @override
  List<Object?> get props => [id, token];
}