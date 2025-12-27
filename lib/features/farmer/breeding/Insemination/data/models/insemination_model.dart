// lib/features/farmer/insemination/data/models/insemination_model.dart

import 'package:farm_manager_app/features/farmer/breeding/Insemination/domain/entities/insemination_entity.dart';
import 'package:equatable/equatable.dart';

// --- Nested Model Classes for Relationships ---

class InseminationAnimalModel extends InseminationAnimalEntity with EquatableMixin {
  const InseminationAnimalModel({
    required super.id,
    required super.tagNumber,
    required super.name,
    required super.sex, // ✅ Added sex field
  });

  factory InseminationAnimalModel.fromJson(Map<String, dynamic> json) {
    // Robust integer parsing
    int safeParseInt(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      if (value is String) return int.tryParse(value) ?? 0;
      if (value is double) return value.toInt();
      return 0;
    }

    // ✅ FIXED: Check for both 'animal_id' (primary) and 'id' (fallback)
    final int id = safeParseInt(json['animal_id']) != 0 
        ? safeParseInt(json['animal_id']) 
        : safeParseInt(json['id']);

    return InseminationAnimalModel(
      id: id,
      tagNumber: json['tag_number']?.toString() ?? 'Unknown',
      name: json['name']?.toString() ?? 'Unnamed',
      sex: json['sex']?.toString() ?? 'Unknown', // ✅ Parse sex field
    );
  }

  @override
  List<Object?> get props => [id, tagNumber, name, sex];
}

class InseminationSemenModel extends InseminationSemenEntity with EquatableMixin {
  const InseminationSemenModel({
    required super.id,
    required super.strawCode,
    required super.bullName,
  });

  factory InseminationSemenModel.fromJson(Map<String, dynamic> json) {
    int? safeParseInt(dynamic value) {
      if (value == null) return null;
      if (value is String) return int.tryParse(value);
      if (value is int) return value;
      if (value is double) return value.toInt();
      return null;
    }

    // ✅ FIX: Handle both formats
    // Format 1: Direct format with id, straw_code, bull_name
    // Format 2: Dropdown format with value (id) and label (display text)
    
    int id;
    String strawCode;
    String bullName;

    if (json.containsKey('value') && json.containsKey('label')) {
      // Dropdown format: {"value": 1, "label": "12 - black legend (Boran)"}
      id = safeParseInt(json['value']) ?? 0;
      
      // Parse the label to extract straw_code and bull_name
      final String label = json['label'] as String? ?? '';
      final parts = label.split(' - ');
      
      if (parts.length >= 2) {
        strawCode = parts[0].trim();
        // Remove breed from bull_name if present
        final bullPart = parts[1].trim();
        final breedMatch = RegExp(r'\s*\([^)]+\)$').firstMatch(bullPart);
        bullName = breedMatch != null 
            ? bullPart.substring(0, breedMatch.start).trim()
            : bullPart;
      } else {
        strawCode = '';
        bullName = label;
      }
    } else {
      // Standard format: {"id": 1, "straw_code": "12", "bull_name": "black legend"}
      id = safeParseInt(json['id']) ?? 0;
      strawCode = json['straw_code'] as String? ?? '';
      bullName = json['bull_name'] as String? ?? '';
    }

    return InseminationSemenModel(
      id: id,
      strawCode: strawCode,
      bullName: bullName,
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
    int? safeParseInt(dynamic value) {
      if (value == null) return null;
      if (value is String) return int.tryParse(value);
      if (value is int) return value;
      if (value is double) return value.toInt();
      return null;
    }

    bool safeParseBool(dynamic value) {
      if (value == null) return false;
      if (value is bool) return value;
      if (value is int) return value == 1;
      if (value is String) return value.toLowerCase() == 'true' || value == '1';
      return false;
    }

    return InseminationModel(
      id: safeParseInt(json['id']) ?? 0,
      damId: safeParseInt(json['dam_id']) ?? 0,
      sireId: safeParseInt(json['sire_id']),
      semenId: safeParseInt(json['semen_id']),
      heatCycleId: safeParseInt(json['heat_cycle_id']) ?? 0,
      breedingMethod: json['breeding_method'] as String? ?? 'AI',
      inseminationDate: DateTime.parse(json['insemination_date'] as String),
      expectedDeliveryDate: DateTime.parse(json['expected_delivery_date'] as String),
      status: json['status'] as String? ?? 'Pending',
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
      isPregnant: safeParseBool(json['is_pregnant']),
      daysToDue: safeParseInt(json['days_to_due']) ?? 999,
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