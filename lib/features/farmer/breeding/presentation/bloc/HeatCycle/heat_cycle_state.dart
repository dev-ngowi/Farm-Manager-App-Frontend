import 'package:equatable/equatable.dart';
import 'package:farm_manager_app/core/error/failure.dart';
import 'package:farm_manager_app/features/farmer/breeding/HeatCycle/domain/entities/heat_cycle_entity.dart';

abstract class HeatCycleState extends Equatable {
  const HeatCycleState();

  @override
  // Base class uses List<Object>
  List<Object> get props => []; 
}

/// Initial state, ready for an event
class HeatCycleInitial extends HeatCycleState {}

/// State when any long-running operation (fetch, create, update) is ongoing
class HeatCycleLoading extends HeatCycleState {}

/// State when the list of heat cycles has been successfully loaded
class HeatCycleListLoaded extends HeatCycleState {
  final List<HeatCycleEntity> cycles;

  const HeatCycleListLoaded({required this.cycles});

  @override
  List<Object> get props => [cycles];
}

/// State when a single heat cycle's details have been successfully loaded
class HeatCycleDetailsLoaded extends HeatCycleState {
  final HeatCycleEntity cycle;

  const HeatCycleDetailsLoaded({required this.cycle});

  @override
  List<Object> get props => [cycle];
}

/// State for successful creation or update operations
class HeatCycleSuccess extends HeatCycleState {
  final String message;
  final HeatCycleEntity? cycle; // Optionally return the updated/created entity

  const HeatCycleSuccess({required this.message, this.cycle});

  @override
  // We must return List<Object>. We use a list literal and the spread operator 
  // with 'if (condition)' to conditionally include the non-nullable properties.
  List<Object> get props => [
    message,
    if (cycle != null) cycle!,
  ];
}

/// State for any failure during operations
class HeatCycleError extends HeatCycleState {
  final String message;
  final Failure? failure;

  const HeatCycleError({required this.message, this.failure});

  @override
  // We must return List<Object>.
  List<Object> get props => [
    message,
    if (failure != null) failure!,
  ];
}