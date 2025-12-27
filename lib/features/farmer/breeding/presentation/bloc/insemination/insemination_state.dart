import 'package:farm_manager_app/features/farmer/breeding/Insemination/domain/entities/insemination_entity.dart';

abstract class InseminationState {
  const InseminationState();
}

// Common States
class InseminationInitial extends InseminationState {}

class InseminationLoading extends InseminationState {}

// ✅ NEW: Separate state for form submission
class InseminationSubmitting extends InseminationState {}

class InseminationError extends InseminationState {
  final String message;
  const InseminationError(this.message);
}

// List States
class InseminationListLoaded extends InseminationState {
  final List<InseminationEntity> records;
  const InseminationListLoaded(this.records);
}

// Detail State
class InseminationDetailLoaded extends InseminationState {
  final InseminationEntity record;
  const InseminationDetailLoaded(this.record);
}

// CRUD Action States (for use with BlocListener)
class InseminationAdded extends InseminationState {
  final InseminationEntity newRecord;
  const InseminationAdded(this.newRecord);
}

class InseminationUpdated extends InseminationState {
  final InseminationEntity record;
  const InseminationUpdated(this.record);
}

class InseminationDeleted extends InseminationState {}