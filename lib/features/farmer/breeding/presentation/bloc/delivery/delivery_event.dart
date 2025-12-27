// lib/features/farmer/breeding/presentation/bloc/delivery/delivery_event.dart

import 'package:equatable/equatable.dart';

abstract class DeliveryEvent extends Equatable {
  const DeliveryEvent();

  @override
  List<Object?> get props => [];
}

class LoadDeliveryList extends DeliveryEvent {
  final Map<String, dynamic>? filters;
  const LoadDeliveryList({this.filters});

  @override
  List<Object?> get props => [filters];
}

class LoadDeliveryDetail extends DeliveryEvent {
  final dynamic id; // Changed from int to dynamic to match your implementation
  const LoadDeliveryDetail(this.id);

  @override
  List<Object?> get props => [id];
}

class AddDelivery extends DeliveryEvent {
  final Map<String, dynamic> data;
  const AddDelivery(this.data);

  @override
  List<Object?> get props => [data];
}

class UpdateDelivery extends DeliveryEvent {
  final dynamic id; // Changed from int to dynamic
  final Map<String, dynamic> data;
  const UpdateDelivery(this.id, this.data);

  @override
  List<Object?> get props => [id, data];
}

class DeleteDelivery extends DeliveryEvent {
  final dynamic id; // Changed from int to dynamic
  const DeleteDelivery(this.id);

  @override
  List<Object?> get props => [id];
}

class LoadDeliveryDropdowns extends DeliveryEvent {
  const LoadDeliveryDropdowns();
}