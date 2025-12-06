// lib/features/farmer/breeding/data/models/insemination_model.dart

import 'package:farm_manager_app/features/farmer/breeding/Insemination/domain/entities/insemination_entity.dart';
import 'package:farm_manager_app/features/farmer/breeding/Insemination/domain/usecases/insemination_usecases.dart';

// --- Nested Model Classes for Relationships ---

class InseminationAnimalModel extends InseminationAnimalEntity {
  const InseminationAnimalModel({
    required super.id,
    required super.tagNumber,
    required super.name,
  });

  factory InseminationAnimalModel.fromJson(Map<String, dynamic> json) {
    return InseminationAnimalModel(
      id: json['animal_id'] as int,
      tagNumber: json['tag_number'] as String,
      name: json['name'] as String,
    );
  }
}

class InseminationSemenModel extends InseminationSemenEntity {
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
}

// --- Main Insemination Model ---

class InseminationModel extends InseminationEntity {
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
      daysToDue: json['days_to_due'] as int? ?? 999, // Use a high default if null
    );
  }

  // Method to convert the Data Model back to the Domain Entity
  InseminationEntity toEntity() {
    return InseminationEntity(
      id: id,
      damId: damId,
      sireId: sireId,
      semenId: semenId,
      heatCycleId: heatCycleId,
      breedingMethod: breedingMethod,
      inseminationDate: inseminationDate,
      expectedDeliveryDate: expectedDeliveryDate,
      status: status,
      notes: notes,
      
      // Mapping Nested Models to Nested Entities
      dam: dam as InseminationAnimalEntity,
      sire: sire as InseminationAnimalEntity?,
      semen: semen as InseminationSemenEntity?,

      isPregnant: isPregnant,
      daysToDue: daysToDue,
    );
  }
  
  // Method to convert the entity to JSON for updating/creating (minimal fields)
  static Map<String, dynamic> toJson(CreateUpdateInseminationParams params) {
    return params.toJson();
  }
}