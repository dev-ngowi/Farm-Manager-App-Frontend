import 'package:equatable/equatable.dart';
import 'package:farm_manager_app/features/farmer/breeding/HeatCycle/domain/entities/heat_cycle_entity.dart';

abstract class HeatCycleEvent extends Equatable {
  const HeatCycleEvent();
  
  @override
  List<Object> get props => [];
}

/// Event to trigger fetching all heat cycles for the farmer
class LoadHeatCycles extends HeatCycleEvent {
  final String token;
  
  const LoadHeatCycles({required this.token});
  
  @override
  List<Object> get props => [token];
}

/// Event to fetch details for a single heat cycle
class LoadHeatCycleDetails extends HeatCycleEvent {
  final String id;
  final String token;
  
  const LoadHeatCycleDetails({required this.id, required this.token});
  
  @override
  List<Object> get props => [id, token];
}

/// Event to create a new heat cycle record
class CreateHeatCycleEvent extends HeatCycleEvent {
  final HeatCycleEntity cycle;
  final String token;
  
  const CreateHeatCycleEvent({required this.cycle, required this.token});
  
  @override
  List<Object> get props => [cycle, token];
}

/// Event to update an existing heat cycle record
class UpdateHeatCycleEvent extends HeatCycleEvent {
  final String id;
  final HeatCycleEntity cycle;
  final String token;
  
  const UpdateHeatCycleEvent({
    required this.id,
    required this.cycle,
    required this.token,
  });
  
  @override
  List<Object> get props => [id, cycle, token];
}

/// Event to delete a heat cycle record
class DeleteHeatCycleEvent extends HeatCycleEvent {
  final String id;
  final String token;
  
  const DeleteHeatCycleEvent(this.id, this.token);
  
  @override
  List<Object> get props => [id, token];
}