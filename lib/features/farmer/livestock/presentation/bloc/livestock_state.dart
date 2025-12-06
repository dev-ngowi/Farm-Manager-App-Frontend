// lib/features/farmer/livestock/presentation/bloc/livestock_state.dart

import 'package:equatable/equatable.dart';
import 'package:farm_manager_app/core/error/failure.dart'; // Import the Failure class
import 'package:farm_manager_app/features/farmer/livestock/domain/entities/livestock.dart';

abstract class LivestockState extends Equatable {
  const LivestockState();

  @override
  List<Object> get props => [];
}

// --- List States ---
class LivestockInitial extends LivestockState {}

class LivestockLoading extends LivestockState {}

class LivestockListLoaded extends LivestockState {
  final List<LivestockEntity> livestock;

  const LivestockListLoaded(this.livestock);

  @override
  List<Object> get props => [livestock];
}

// --- Detail States ---
class LivestockDetailLoaded extends LivestockState {
  final LivestockEntity animal;

  const LivestockDetailLoaded(this.animal);

  @override
  List<Object> get props => [animal];
}

// --- CRUD States ---
class LivestockError extends LivestockState {
  final Failure failure;

  const LivestockError(this.failure);

  String get message => FailureConverter.toMessage(failure);

  @override
  List<Object> get props => [failure];
}

class LivestockAdded extends LivestockState { 
  final LivestockEntity newAnimal;

  const LivestockAdded(this.newAnimal);

  @override
  List<Object> get props => [newAnimal];
}