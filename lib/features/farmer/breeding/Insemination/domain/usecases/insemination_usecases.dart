// lib/features/farmer/breeding/domain/usecases/insemination_usecases.dart

import 'package:equatable/equatable.dart';

class CreateUpdateInseminationParams extends Equatable {
  final int? id; // Required for Update, null for Create
  final int damId;
  final int? sireId; // Required if breedingMethod is 'Natural'
  final int? semenId; // Required if breedingMethod is 'AI'
  final String breedingMethod; // 'Natural' or 'AI'
  final int heatCycleId;
  final DateTime inseminationDate;
  final int? technicianId;
  final String? notes;
  
  // Only used for update, if the backend allows manual adjustment of expected date/status
  final DateTime? expectedDeliveryDate; 
  final String? status; 

  const CreateUpdateInseminationParams({
    this.id,
    required this.damId,
    this.sireId,
    this.semenId,
    required this.breedingMethod,
    required this.heatCycleId,
    required this.inseminationDate,
    this.technicianId,
    this.notes,
    this.expectedDeliveryDate,
    this.status,
  });

  // Convert to JSON map for API call
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> map = {
      'dam_id': damId,
      'breeding_method': breedingMethod,
      'heat_cycle_id': heatCycleId,
      'insemination_date': inseminationDate.toIso8601String().split('T').first,
      'notes': notes,
    };
    
    // Conditional fields based on breeding method
    if (breedingMethod == 'Natural') {
      map['sire_id'] = sireId;
    } else {
      map['semen_id'] = semenId;
    }

    // Optional fields
    if (technicianId != null) map['technician_id'] = technicianId;
    if (expectedDeliveryDate != null) map['expected_delivery_date'] = expectedDeliveryDate!.toIso8601String().split('T').first;
    if (status != null) map['status'] = status;

    return map;
  }

  @override
  List<Object?> get props => [
    id, damId, sireId, semenId, breedingMethod, heatCycleId,
    inseminationDate, technicianId, notes, expectedDeliveryDate, status
  ];
}