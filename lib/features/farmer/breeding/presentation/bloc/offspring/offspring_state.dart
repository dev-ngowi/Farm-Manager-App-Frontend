// lib/features/farmer/breeding/presentation/bloc/offspring/offspring_state.dart

import 'package:equatable/equatable.dart';
import 'package:farm_manager_app/features/farmer/breeding/offspring/domain/entities/offspring_entity.dart';

abstract class OffspringState extends Equatable {
  const OffspringState();

  @override
  List<Object?> get props => [];
}

class OffspringInitial extends OffspringState {}

class OffspringLoading extends OffspringState {}

class OffspringListLoaded extends OffspringState {
  final List<OffspringEntity> offspringList;

  const OffspringListLoaded(this.offspringList);

  @override
  List<Object?> get props => [offspringList];
}

class OffspringDetailLoaded extends OffspringState {
  final OffspringEntity offspring;

  const OffspringDetailLoaded(this.offspring);

  @override
  List<Object?> get props => [offspring];
}

class OffspringDropdownsLoaded extends OffspringState {
  final List<OffspringDeliveryEntity> deliveries;

  const OffspringDropdownsLoaded(this.deliveries);

  @override
  List<Object?> get props => [deliveries];
}

class OffspringAdded extends OffspringState {}

class OffspringUpdated extends OffspringState {}

class OffspringDeleted extends OffspringState {}

class OffspringRegistered extends OffspringState {}

class OffspringError extends OffspringState {
  final String message;

  const OffspringError(this.message);

  @override
  List<Object?> get props => [message];
}