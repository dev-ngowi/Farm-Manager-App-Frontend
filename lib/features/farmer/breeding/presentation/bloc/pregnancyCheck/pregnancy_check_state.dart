
import 'package:equatable/equatable.dart';
import 'package:farm_manager_app/features/farmer/breeding/pregnancyCheck/domain/entities/pregnancy_check_entity.dart';

abstract class PregnancyCheckState extends Equatable {
  const PregnancyCheckState();
  
  @override
  List<Object?> get props => [];
}

class PregnancyCheckInitial extends PregnancyCheckState {}

class PregnancyCheckLoading extends PregnancyCheckState {}

class PregnancyCheckListLoaded extends PregnancyCheckState {
  final List<PregnancyCheckEntity> checks;
  const PregnancyCheckListLoaded(this.checks);

  @override
  List<Object?> get props => [checks];
}

class PregnancyCheckDetailLoaded extends PregnancyCheckState {
  final PregnancyCheckEntity check;
  const PregnancyCheckDetailLoaded(this.check);

  @override
  List<Object?> get props => [check];
}

class PregnancyCheckAdded extends PregnancyCheckState {
  final PregnancyCheckEntity newCheck;
  const PregnancyCheckAdded(this.newCheck);

  @override
  List<Object?> get props => [newCheck];
}

class PregnancyCheckUpdated extends PregnancyCheckState {
  final PregnancyCheckEntity check;
  const PregnancyCheckUpdated(this.check);

  @override
  List<Object?> get props => [check];
}

class PregnancyCheckDeleted extends PregnancyCheckState {}

class PregnancyCheckError extends PregnancyCheckState {
  final String message;
  const PregnancyCheckError(this.message);

  @override
  List<Object?> get props => [message];
}

// ⭐ NEW: States for dropdown loading
class PregnancyCheckDropdownsLoading extends PregnancyCheckState {}

class PregnancyCheckDropdownsLoaded extends PregnancyCheckState {
  final List<PregnancyCheckInseminationEntity> inseminations;
  final List<PregnancyCheckVetEntity> vets;

  const PregnancyCheckDropdownsLoaded({
    required this.inseminations,
    required this.vets,
  });

  @override
  List<Object?> get props => [inseminations, vets];
}