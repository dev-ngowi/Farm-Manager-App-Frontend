// lib/features/farmer/breeding/presentation/bloc/delivery/delivery_state.dart

import 'package:equatable/equatable.dart';
import 'package:farm_manager_app/features/farmer/breeding/delivery/domain/entities/delivery_entity.dart';

abstract class DeliveryState extends Equatable {
  const DeliveryState();

  @override
  List<Object?> get props => [];
}

class DeliveryInitial extends DeliveryState {}

class DeliveryLoading extends DeliveryState {}

class DeliveryDropdownsLoading extends DeliveryState {}

class DeliveryListLoaded extends DeliveryState {
  final List<DeliveryEntity> deliveries;

  const DeliveryListLoaded(this.deliveries);

  @override
  List<Object?> get props => [deliveries];
}

class DeliveryDetailLoaded extends DeliveryState {
  final DeliveryEntity delivery;

  const DeliveryDetailLoaded(this.delivery);

  @override
  List<Object?> get props => [delivery];
}

class DeliveryAdded extends DeliveryState {
  final DeliveryEntity delivery;
  final DateTime timestamp; // Ensures state changes are detected for listeners

  DeliveryAdded(this.delivery) : timestamp = DateTime.now();

  @override
  List<Object?> get props => [delivery, timestamp];
}

class DeliveryUpdated extends DeliveryState {
  final DeliveryEntity delivery;
  final DateTime timestamp;

  DeliveryUpdated(this.delivery) : timestamp = DateTime.now();

  @override
  List<Object?> get props => [delivery, timestamp];
}

class DeliveryDeleted extends DeliveryState {
  final DateTime timestamp;

  DeliveryDeleted() : timestamp = DateTime.now();

  @override
  List<Object?> get props => [timestamp];
}

class DeliveryDropdownsLoaded extends DeliveryState {
  // CORRECTED: Use DeliveryInseminationEntity to match Repository/Bloc
  final List<DeliveryInseminationEntity> inseminations;

  const DeliveryDropdownsLoaded({
    required this.inseminations,
  });

  @override
  List<Object?> get props => [inseminations];
}

class DeliveryError extends DeliveryState {
  final String message;

  const DeliveryError(this.message);

  @override
  List<Object?> get props => [message];
}