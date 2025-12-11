// lib/features/farmer/insemination/data/models/insemination_model.dart

import 'package:farm_manager_app/features/farmer/breeding/Insemination/domain/entities/insemination_entity.dart';
import 'package:equatable/equatable.dart';

// --- Nested Model Classes for Relationships ---

class InseminationAnimalModel extends InseminationAnimalEntity with EquatableMixin {
  const InseminationAnimalModel({
    required super.id,
    required super.tagNumber,
    required super.name,
  });

  factory InseminationAnimalModel.fromJson(Map<String, dynamic> json) {
    return InseminationAnimalModel(
      // ⭐ Adjusted to use snake_case keys common in API responses
      id: json['animal_id'] as int? ?? json['id'] as int, 
      tagNumber: json['tag_number'] as String,
      name: json['name'] as String,
    );
  }

  @override
  List<Object?> get props => [id, tagNumber, name];
}

class InseminationSemenModel extends InseminationSemenEntity with EquatableMixin {
  const InseminationSemenModel({
    required super.id,
    required super.strawCode,
    required super.bullName,
  });

  factory InseminationSemenModel.fromJson(Map<String, dynamic> json) {
    return InseminationSemenModel(
      id: json['id'] as int,
      strawCode: json['straw_code'] as String,
      bullName: json['bull_name'] as String,
    );
  }

  @override
  List<Object?> get props => [id, strawCode, bullName];
}

// --- Main Insemination Model ---

class InseminationModel extends InseminationEntity with EquatableMixin {
  const InseminationModel({
    required super.id,
    required super.damId,
    super.sireId,
    super.semenId,
    required super.heatCycleId,
    required super.breedingMethod,
    required super.inseminationDate,
    required super.expectedDeliveryDate,
    required super.status,
    super.notes,
    required super.dam,
    super.sire,
    super.semen,
    required super.isPregnant,
    required super.daysToDue,
  });

  factory InseminationModel.fromJson(Map<String, dynamic> json) {
    return InseminationModel(
      id: json['id'] as int,
      damId: json['dam_id'] as int,
      sireId: json['sire_id'] as int?,
      semenId: json['semen_id'] as int?,
      heatCycleId: json['heat_cycle_id'] as int,
      breedingMethod: json['breeding_method'] as String,
      inseminationDate: DateTime.parse(json['insemination_date'] as String),
      expectedDeliveryDate: DateTime.parse(json['expected_delivery_date'] as String),
      status: json['status'] as String,
      notes: json['notes'] as String?,
      
      // Relationship Mapping to Nested Models
      dam: InseminationAnimalModel.fromJson(json['dam'] as Map<String, dynamic>),
      sire: json['sire'] != null 
          ? InseminationAnimalModel.fromJson(json['sire'] as Map<String, dynamic>) 
          : null,
      semen: json['semen'] != null 
          ? InseminationSemenModel.fromJson(json['semen'] as Map<String, dynamic>) 
          : null,
      
      // Custom calculated fields from backend
      isPregnant: json['is_pregnant'] as bool? ?? false,
      daysToDue: json['days_to_due'] as int? ?? 999,
    );
  }

  // Method to convert the Data Model back to the Domain Entity (often implicit via implementation)
  InseminationEntity toEntity() {
    return this; // Since InseminationModel implements InseminationEntity
  }
  
  @override
  List<Object?> get props => [
    id, damId, sireId, semenId, heatCycleId, breedingMethod,
    inseminationDate, expectedDeliveryDate, status, notes,
    dam, sire, semen, isPregnant, daysToDue
  ];
}