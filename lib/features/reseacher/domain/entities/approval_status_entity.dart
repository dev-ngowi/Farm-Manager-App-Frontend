// lib/features/reseacher/domain/entities/approval_status_entity.dart
import 'package:equatable/equatable.dart';

class ApprovalStatusEntity extends Equatable {
  final String status; // e.g., 'pending', 'approved', 'declined'
  final String? reason; // Optional reason if status is 'declined'

  const ApprovalStatusEntity({
    required this.status,
    this.reason,
  });

  @override
  List<Object?> get props => [status, reason];
}