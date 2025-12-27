// lib/features/farmer/breeding/delivery/data/models/delivery_model.dart

import 'package:farm_manager_app/features/farmer/breeding/delivery/domain/entities/delivery_entity.dart';

class DeliveryModel extends DeliveryEntity {
  const DeliveryModel({
    required super.id,
    required super.inseminationId,
    required super.actualDeliveryDate,
    required super.deliveryType,
    required super.calvingEaseScore,
    required super.totalBorn,
    required super.liveBorn,
    required super.stillborn,
    required super.damConditionAfter,
    required super.notes,
    required super.damName,
    required super.damTagNumber,
    required super.offspring,
  });

  factory DeliveryModel.fromJson(Map<String, dynamic> json) {
    // 1. Extract dam info from nested Insemination -> Dam
    // Backend: 'insemination' => ['dam' => ['name', 'tag_number']]
    String damName = 'Unknown';
    String damTagNumber = 'N/A';

    if (json['insemination'] != null && json['insemination']['dam'] != null) {
      final dam = json['insemination']['dam'] as Map<String, dynamic>;
      damName = dam['name'] ?? 'Unknown';
      damTagNumber = dam['tag_number'] ?? 'N/A';
    }

    // 2. Parse offspring list
    final offspringList = (json['offspring'] as List<dynamic>?)
            ?.map((o) => OffspringModel.fromJson(o as Map<String, dynamic>))
            .toList() ??
        [];

    return DeliveryModel(
      id: json['id'] ?? 0,
      inseminationId: json['insemination_id'] ?? 0,
      // Backend provides YYYY-MM-DD
      actualDeliveryDate: json['actual_delivery_date'] != null
          ? DateTime.parse(json['actual_delivery_date'])
          : DateTime.now(),
      deliveryType: json['delivery_type'] ?? 'Normal',
      calvingEaseScore: json['calving_ease_score'] ?? 1,
      totalBorn: json['total_born'] ?? 0,
      liveBorn: json['live_born'] ?? 0,
      stillborn: json['stillborn'] ?? 0,
      damConditionAfter: json['dam_condition_after'] ?? 'Good',
      notes: json['notes'] ?? '',
      damName: damName,
      damTagNumber: damTagNumber,
      offspring: offspringList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'insemination_id': inseminationId,
      'actual_delivery_date':
          "${actualDeliveryDate.year.toString().padLeft(4, '0')}-${actualDeliveryDate.month.toString().padLeft(2, '0')}-${actualDeliveryDate.day.toString().padLeft(2, '0')}",
      'delivery_type': deliveryType,
      'calving_ease_score': calvingEaseScore,
      'dam_condition_after': damConditionAfter,
      'notes': notes.isEmpty ? null : notes,
      'offspring':
          offspring.map((o) => (o as OffspringModel).toJson()).toList(),
    };
  }
}

class OffspringModel extends OffspringEntity {
  const OffspringModel({
    super.id,
    required super.gender,
    required super.birthCondition,
    required super.birthWeightKg,
    required super.colostrumIntake,
    required super.navelTreated,
    super.temporaryTag,
    super.notes,
  });

  factory OffspringModel.fromJson(Map<String, dynamic> json) {
    return OffspringModel(
      id: json['id'],
      gender: json['gender'] ?? '',
      birthCondition: json['birth_condition'] ?? 'Vigorous',
      birthWeightKg: _parseDouble(json['birth_weight_kg'], 0.0),
      colostrumIntake: json['colostrum_intake'] ?? 'Adequate',
      navelTreated: json['navel_treated'] == 1 || json['navel_treated'] == true,
      temporaryTag: json['temporary_tag'],
      notes: json['notes'],
    );
  }

  /// Helper method to safely parse double values from various formats
  static double _parseDouble(dynamic value, double defaultValue) {
    if (value == null) return defaultValue;

    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      return double.tryParse(value) ?? defaultValue;
    }

    return defaultValue;
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'gender': gender,
      'birth_condition': birthCondition,
      'birth_weight_kg': birthWeightKg,
      'colostrum_intake': colostrumIntake,
      'navel_treated': navelTreated,
      'temporary_tag': temporaryTag?.isEmpty == true ? null : temporaryTag,
      'notes': notes?.isEmpty == true ? null : notes,
    };
  }
}

class DeliveryInseminationModel extends DeliveryInseminationEntity {
  const DeliveryInseminationModel({
    required super.id,
    required super.damName,
    required super.damTagNumber,
    super.expectedDeliveryDate,
  });

  /// FIXED: Parses the actual API response format
  /// API returns: {"id": 1, "label": "00023 - Samira", "expected_date": "2025-12-25T00:00:00.000000Z"}
  factory DeliveryInseminationModel.fromJson(Map<String, dynamic> json) {
    // Parse the "label" field which contains "tagNumber - name"
    String damName = 'Unknown Dam';
    String damTagNumber = 'N/A';

    final label = json['label'] as String?;
    if (label != null && label.contains(' - ')) {
      final parts = label.split(' - ');
      if (parts.length >= 2) {
        damTagNumber = parts[0].trim();
        damName =
            parts.sublist(1).join(' - ').trim(); // Handle names with dashes
      }
    } else if (label != null) {
      // Fallback: if no dash separator, use entire label as name
      damName = label;
    }

    // Handle backward compatibility with old API format
    if (json.containsKey('dam_name')) {
      damName = json['dam_name'] ?? damName;
    }
    if (json.containsKey('dam_tag_number')) {
      damTagNumber = json['dam_tag_number'] ?? damTagNumber;
    }

    return DeliveryInseminationModel(
      id: json['id'] ?? 0,
      damName: damName,
      damTagNumber: damTagNumber,
      expectedDeliveryDate: json['expected_date'] != null
          ? DateTime.parse(json['expected_date'])
          : (json['expected_delivery_date'] != null
              ? DateTime.parse(json['expected_delivery_date'])
              : null),
    );
  }
}
