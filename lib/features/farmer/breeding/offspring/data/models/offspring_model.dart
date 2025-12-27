// lib/features/farmer/breeding/offspring/data/models/offspring_model.dart

import 'package:farm_manager_app/features/farmer/breeding/offspring/domain/entities/offspring_entity.dart';

class OffspringModel extends OffspringEntity {
  const OffspringModel({
    required super.id,
    required super.deliveryId,
    super.temporaryTag,
    required super.gender,
    required super.birthWeightKg,
    required super.birthCondition,
    required super.colostrumIntake,
    required super.navelTreated,
    super.notes,
    super.livestockId,
    required super.deliveryDate,
    required super.deliveryType,
    required super.calvingEaseScore,
    required super.damTag,
    required super.damName,
    required super.damSpecies,
    super.sireTag,
    super.sireName,
    super.registeredTag,
  });

  factory OffspringModel.fromJson(Map<String, dynamic> json) {
    // Helper to safely parse numeric values
    double parseDouble(dynamic value) {
      if (value == null) return 0.0;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0.0;
      return 0.0;
    }

    int parseInt(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      if (value is double) return value.toInt();
      if (value is String) return int.tryParse(value) ?? 0;
      return 0;
    }

    bool parseBool(dynamic value) {
      if (value == null) return false;
      if (value is bool) return value;
      if (value is int) return value == 1;
      if (value is String) return value.toLowerCase() == 'true' || value == '1';
      return false;
    }

    // Extract delivery data
    final delivery = json['delivery'] as Map<String, dynamic>?;
    final insemination = delivery?['insemination'] as Map<String, dynamic>?;
    final dam = insemination?['dam'] as Map<String, dynamic>?;
    final sire = insemination?['sire'] as Map<String, dynamic>?;
    final species = dam?['species'] as Map<String, dynamic>?;
    final livestock = json['livestock'] as Map<String, dynamic>?;

    return OffspringModel(
      id: json['id'],
      deliveryId: json['delivery_id'],
      temporaryTag: json['temporary_tag'] as String?,
      gender: json['gender'] as String? ?? 'Unknown',
      birthWeightKg: parseDouble(json['birth_weight_kg']),
      birthCondition: json['birth_condition'] as String? ?? 'Unknown',
      colostrumIntake: json['colostrum_intake'] as String? ?? 'None',
      navelTreated: parseBool(json['navel_treated']),
      notes: json['notes'] as String?,
      livestockId: json['livestock_id'],
      
      // Delivery context
      deliveryDate: delivery?['actual_delivery_date'] as String? ?? '',
      deliveryType: delivery?['delivery_type'] as String? ?? 'Unknown',
      calvingEaseScore: parseInt(delivery?['calving_ease_score']),
      
      // Dam information
      damTag: dam?['tag_number'] as String? ?? 'Unknown',
      damName: dam?['name'] as String? ?? 'Unknown',
      damSpecies: species?['name'] as String? ?? 'Unknown',
      
      // Sire information (optional)
      sireTag: sire?['tag_number'] as String?,
      sireName: sire?['name'] as String?,
      
      // Livestock registration
      registeredTag: livestock?['tag_number'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'delivery_id': deliveryId,
      'temporary_tag': temporaryTag,
      'gender': gender,
      'birth_weight_kg': birthWeightKg,
      'birth_condition': birthCondition,
      'colostrum_intake': colostrumIntake,
      'navel_treated': navelTreated ? 1 : 0,
      'notes': notes,
      'livestock_id': livestockId,
    };
  }
}

class OffspringDeliveryModel extends OffspringDeliveryEntity {
  const OffspringDeliveryModel({
    required super.id,
    required super.label,
    required super.damTag,
    required super.damName,
    required super.deliveryDate,
  });

  factory OffspringDeliveryModel.fromJson(Map<String, dynamic> json) {
    final insemination = json['insemination'] as Map<String, dynamic>?;
    final dam = insemination?['dam'] as Map<String, dynamic>?;
    final damTag = dam?['tag_number'] as String? ?? 'Unknown';
    final damName = dam?['name'] as String? ?? 'Unknown';
    final deliveryDate = json['actual_delivery_date'] as String? ?? '';

    return OffspringDeliveryModel(
      id: json['id'],
      label: 'Delivery - $damTag ($deliveryDate)',
      damTag: damTag,
      damName: damName,
      deliveryDate: deliveryDate,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'label': label,
      'dam_tag': damTag,
      'dam_name': damName,
      'delivery_date': deliveryDate,
    };
  }
}