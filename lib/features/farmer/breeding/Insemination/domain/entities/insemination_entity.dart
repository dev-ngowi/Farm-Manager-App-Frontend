// lib/features/farmer/breeding/domain/entities/insemination_entity.dart

import 'package:equatable/equatable.dart';

// --- Nested Entities for Relationships (Minimal Data) ---

class InseminationAnimalEntity extends Equatable {
  final int id; // animal_id
  final String tagNumber;
  final String name;

  const InseminationAnimalEntity({
    required this.id,
    required this.tagNumber,
    required this.name,
  });

  @override
  List<Object?> get props => [id, tagNumber, name];
}

class InseminationSemenEntity extends Equatable {
  final int id;
  final String strawCode;
  final String bullName;

  const InseminationSemenEntity({
    required this.id,
    required this.strawCode,
    required this.bullName,
  });

  @override
  List<Object?> get props => [id, strawCode, bullName];
}

// --- Main Insemination Entity ---

class InseminationEntity extends Equatable {
  final int id;
  final int damId;
  final int? sireId;
  final int? semenId;
  final int heatCycleId;
  final String breedingMethod; // 'Natural' or 'AI'
  final DateTime inseminationDate;
  final DateTime expectedDeliveryDate;
  final String status; // 'Pending', 'Confirmed Pregnant', 'Not Pregnant', etc.
  final String? notes;

  // Relationships (from 'with' clause in backend index)
  final InseminationAnimalEntity dam;
  final InseminationAnimalEntity? sire;
  final InseminationSemenEntity? semen;
  // Note: 'delivery' and 'pregnancyChecks' should be included for a full detail entity.

  // Custom calculated fields from backend
  final bool isPregnant; // Calculated via accessor in backend model
  final int daysToDue; // Calculated via accessor in backend model

  const InseminationEntity({
    required this.id,
    required this.damId,
    this.sireId,
    this.semenId,
    required this.heatCycleId,
    required this.breedingMethod,
    required this.inseminationDate,
    required this.expectedDeliveryDate,
    required this.status,
    this.notes,
    required this.dam,
    this.sire,
    this.semen,
    required this.isPregnant,
    required this.daysToDue,
  });

  @override
  List<Object?> get props => [
    id, damId, sireId, semenId, heatCycleId, breedingMethod,
    inseminationDate, expectedDeliveryDate, status, notes,
    dam, sire, semen, isPregnant, daysToDue
  ];

  // A factory for converting from JSON map (assuming a Data Transfer Object converts API response to this)
  factory InseminationEntity.fromJson(Map<String, dynamic> json) {
    // Helper to map minimal animal data
    InseminationAnimalEntity mapAnimal(Map<String, dynamic> data) => InseminationAnimalEntity(
      id: data['animal_id'] as int,
      tagNumber: data['tag_number'] as String,
      name: data['name'] as String,
    );
    
    return InseminationEntity(
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
      
      // Relationships
      dam: mapAnimal(json['dam'] as Map<String, dynamic>),
      sire: json['sire'] != null ? mapAnimal(json['sire'] as Map<String, dynamic>) : null,
      semen: json['semen'] != null 
          ? InseminationSemenEntity(
              id: json['semen']['id'] as int,
              strawCode: json['semen']['straw_code'] as String,
              bullName: json['semen']['bull_name'] as String,
            ) 
          : null,
      
      // Custom accessors from backend (Laravel model accessors)
      isPregnant: json['is_pregnant'] ?? false,
      daysToDue: json['days_to_due'] ?? 999,
    );
  }
}