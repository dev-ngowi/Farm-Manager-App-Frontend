import 'package:equatable/equatable.dart';
import 'package:farm_manager_app/features/farmer/breeding/HeatCycle/domain/entities/heat_cycle_entity.dart';

abstract class HeatCycleEvent extends Equatable {
  const HeatCycleEvent();

  @override
  List<Object> get props => [];
}

/// Event to trigger fetching all heat cycles for the farmer
/// RENAMED: GetHeatCyclesEvent -> LoadHeatCycles to match BLoC handler
class LoadHeatCycles extends HeatCycleEvent {
  final String token; // ADDED: token parameter required by BLoC
  
  const LoadHeatCycles({required this.token});
  
  @override
  List<Object> get props => [token];
}

/// Event to fetch details for a single heat cycle
/// RENAMED: GetHeatCycleDetailsEvent -> LoadHeatCycleDetails to match BLoC handler
class LoadHeatCycleDetails extends HeatCycleEvent {
  final String id;
  final String token; // ADDED: token parameter required by BLoC
  
  const LoadHeatCycleDetails({required this.id, required this.token});
  
  @override
  List<Object> get props => [id, token];
}

/// Event to create a new heat cycle record
class CreateHeatCycleEvent extends HeatCycleEvent {
  final HeatCycleEntity cycle; // CHANGED: from Map<String, dynamic> to HeatCycleEntity
  final String token;
  
  const CreateHeatCycleEvent({required this.cycle, required this.token});

  @override
  List<Object> get props => [cycle, token];
}

/// Event to update an existing heat cycle record
class UpdateHeatCycleEvent extends HeatCycleEvent {
  final String id;
  final HeatCycleEntity cycle; // CHANGED: from Map<String, dynamic> to HeatCycleEntity
  final String token;
  
  const UpdateHeatCycleEvent({
    required this.id,
    required this.cycle,
    required this.token,
  });
  
  @override
  List<Object> get props => [id, cycle, token];
}