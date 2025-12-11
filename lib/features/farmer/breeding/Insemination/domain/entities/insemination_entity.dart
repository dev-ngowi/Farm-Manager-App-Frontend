// lib/features/farmer/insemination/domain/entities/insemination_entity.dart

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

  // Relationships
  final InseminationAnimalEntity dam;
  final InseminationAnimalEntity? sire;
  final InseminationSemenEntity? semen;

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

  // Method to create a new entity instance with updated fields (useful for updates)
  InseminationEntity copyWith({
    int? id,
    int? damId,
    int? sireId,
    int? semenId,
    int? heatCycleId,
    String? breedingMethod,
    DateTime? inseminationDate,
    DateTime? expectedDeliveryDate,
    String? status,
    String? notes,
    InseminationAnimalEntity? dam,
    InseminationAnimalEntity? sire,
    InseminationSemenEntity? semen,
    bool? isPregnant,
    int? daysToDue,
  }) {
    return InseminationEntity(
      id: id ?? this.id,
      damId: damId ?? this.damId,
      sireId: sireId ?? this.sireId,
      semenId: semenId ?? this.semenId,
      heatCycleId: heatCycleId ?? this.heatCycleId,
      breedingMethod: breedingMethod ?? this.breedingMethod,
      inseminationDate: inseminationDate ?? this.inseminationDate,
      expectedDeliveryDate: expectedDeliveryDate ?? this.expectedDeliveryDate,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      dam: dam ?? this.dam,
      sire: sire ?? this.sire,
      semen: semen ?? this.semen,
      isPregnant: isPregnant ?? this.isPregnant,
      daysToDue: daysToDue ?? this.daysToDue,
    );
  }

  @override
  List<Object?> get props => [
    id, damId, sireId, semenId, heatCycleId, breedingMethod,
    inseminationDate, expectedDeliveryDate, status, notes,
    dam, sire, semen, isPregnant, daysToDue
  ];
}