// lib/features/farmer/breeding/presentation/bloc/pregnancyCheck/pregnancy_check_event.dart

import 'package:equatable/equatable.dart';

abstract class PregnancyCheckEvent extends Equatable {
  const PregnancyCheckEvent();

  @override
  List<Object?> get props => [];
}

class LoadPregnancyCheckList extends PregnancyCheckEvent {
  final Map<String, dynamic>? filters;
  const LoadPregnancyCheckList({this.filters});

  @override
  List<Object?> get props => [filters];
}

class LoadPregnancyCheckDetail extends PregnancyCheckEvent {
  final int id;
  const LoadPregnancyCheckDetail(this.id);

  @override
  List<Object?> get props => [id];
}

class AddPregnancyCheck extends PregnancyCheckEvent {
  final Map<String, dynamic> data;
  const AddPregnancyCheck(this.data);

  @override
  List<Object?> get props => [data];
}

class UpdatePregnancyCheck extends PregnancyCheckEvent {
  final int id;
  final Map<String, dynamic> data;
  const UpdatePregnancyCheck(this.id, this.data);

  @override
  List<Object?> get props => [id, data];
}

class DeletePregnancyCheck extends PregnancyCheckEvent {
  final int id;
  const DeletePregnancyCheck(this.id);

  @override
  List<Object?> get props => [id];
}

// ⭐ NEW: Event to load dropdowns for form
class LoadPregnancyCheckDropdowns extends PregnancyCheckEvent {
  const LoadPregnancyCheckDropdowns();
}
