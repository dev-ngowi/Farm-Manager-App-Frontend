// lib/features/reseacher/data/models/approval_status_model.dart

import 'package:farm_manager_app/features/reseacher/domain/entities/approval_status_entity.dart';

class ApprovalStatusModel {
  // Use property names that directly match the JSON keys if possible,
  // or handle the mapping in the fromJson constructor.
  // The backend uses 'status' and 'decline_reason'.
  final String status; // 'pending', 'approved', 'declined'
  final String? reason;

  ApprovalStatusModel({
    required this.status,
    this.reason,
  });

  // ========================================
  // MANUAL FACTORY CONSTRUCTOR (FROM JSON)
  // This replaces the generated _$ApprovalStatusModelFromJson
  // ========================================
  factory ApprovalStatusModel.fromJson(Map<String, dynamic> json) {
    // Ensure 'status' is a required string.
    final status = json['status'];
    if (status is! String) {
        // You might throw an error or handle a default if the status is missing/wrong type
        throw const FormatException('Invalid or missing "status" field in approval status JSON.');
    }
    
    return ApprovalStatusModel(
      status: status,
      // Map 'decline_reason' and safely handle if it is null or missing.
      reason: json['decline_reason'] as String?,
    );
  }

  // ========================================
  // TO ENTITY METHOD
  // ========================================
  ApprovalStatusEntity toEntity() {
    return ApprovalStatusEntity(
      status: status,
      reason: reason,
    );
  }
}