// lib/features/researcher/presentation/blocs/researcher/researcher_state.dart

import 'package:farm_manager_app/features/auth/data/domain/entities/user_entity.dart';

abstract class ResearcherState {}

class ResearcherInitial extends ResearcherState {}

class ResearcherLoading extends ResearcherState {}

class ResearcherSuccess extends ResearcherState {
  final String? message;
  final bool hasCompletedDetails;
  final UserEntity? updatedUser; // 🎯 NEW: Store the updated user entity
  
  ResearcherSuccess({
    this.message, 
    this.hasCompletedDetails = true,
    this.updatedUser, // 🎯 NEW
  });
}

class ResearcherError extends ResearcherState {
  final String message;
  ResearcherError(this.message);
}

class ResearcherApprovalStatus extends ResearcherState {
  final String approvalStatus;
  final String? declineReason;

  ResearcherApprovalStatus({
    required this.approvalStatus,
    this.declineReason,
  });
}