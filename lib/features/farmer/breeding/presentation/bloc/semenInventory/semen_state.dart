import 'package:equatable/equatable.dart';
import 'package:farm_manager_app/features/farmer/breeding/semenInventory/domain/entities/dropdown_entity.dart';
import 'package:farm_manager_app/features/farmer/breeding/semenInventory/domain/entities/semen_entity.dart';

abstract class SemenState extends Equatable {
  const SemenState();

  @override
  List<Object> get props => [];
}

/// Initial, idle state.
class SemenInitial extends SemenState {}

/// State indicating that a network request or heavy operation is in progress.
class SemenLoading extends SemenState {}

/// State emitted upon successful retrieval of the main list of semen records.
class SemenLoadedList extends SemenState {
  final List<SemenEntity> semenList;

  const SemenLoadedList(this.semenList);

  @override
  List<Object> get props => [semenList];
}

/// State emitted upon successful retrieval of a single record's details.
class SemenLoadedDetails extends SemenState {
  final SemenEntity semen;

  const SemenLoadedDetails(this.semen);

  @override
  List<Object> get props => [semen];
}

/// State emitted upon successful retrieval of the available semen for selectors.
class SemenLoadedDropdowns extends SemenState {
  // Use named arguments (required)
  final List<DropdownEntity> bulls;
  final List<DropdownEntity> breeds;

  const SemenLoadedDropdowns({
    required this.bulls,
    required this.breeds,
  });

  @override
  List<Object> get props => [bulls, breeds];
}


/// State emitted after a successful CRUD operation (Create, Update, Delete).
class SemenActionSuccess extends SemenState {
  final String message;

  const SemenActionSuccess(this.message);

  @override
  List<Object> get props => [message];
}

/// State emitted when an error occurs during an operation.
class SemenError extends SemenState {
  final String message;
  final bool isValidationError;

  const SemenError(this.message, {this.isValidationError = false});

  @override
  List<Object> get props => [message, isValidationError];
}