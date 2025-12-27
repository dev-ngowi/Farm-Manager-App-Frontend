// lib/features/farmer/breeding/presentation/bloc/offspring/offspring_event.dart

import 'package:equatable/equatable.dart';

abstract class OffspringEvent extends Equatable {
  const OffspringEvent();

  @override
  List<Object?> get props => [];
}

class LoadOffspringList extends OffspringEvent {
  final Map<String, dynamic> filters;

  const LoadOffspringList({this.filters = const {}});

  @override
  List<Object?> get props => [filters];
}

class LoadOffspringDetail extends OffspringEvent {
  final dynamic id;

  const LoadOffspringDetail(this.id);

  @override
  List<Object?> get props => [id];
}

class LoadOffspringDropdowns extends OffspringEvent {
  const LoadOffspringDropdowns();
}

class AddOffspring extends OffspringEvent {
  final Map<String, dynamic> data;

  const AddOffspring(this.data);

  @override
  List<Object?> get props => [data];
}

class UpdateOffspring extends OffspringEvent {
  final dynamic id;
  final Map<String, dynamic> data;

  const UpdateOffspring(this.id, this.data);

  @override
  List<Object?> get props => [id, data];
}

class DeleteOffspring extends OffspringEvent {
  final dynamic id;

  const DeleteOffspring(this.id);

  @override
  List<Object?> get props => [id];
}

class RegisterOffspring extends OffspringEvent {
  final dynamic id;
  final Map<String, dynamic> data;

  const RegisterOffspring(this.id, this.data);

  @override
  List<Object?> get props => [id, data];
}