// lib/features/farmer/livestock/data/models/parent_model.dart

import 'package:farm_manager_app/features/farmer/livestock/domain/entities/parent.dart';

class ParentModel extends ParentEntity {
  const ParentModel({
    required super.animalId,
    required super.tagNumber,
    required super.sex, 
    super.name,
  });

  factory ParentModel.fromJson(Map<String, dynamic> json) {
    // Helper to safely parse an integer
    int safeParseInt(dynamic value) {
      if (value is int) return value;
      if (value is String) return int.tryParse(value) ?? 0;
      return 0;
    }

    return ParentModel(
      // FIX 1: Safely parse required 'animalId'
      animalId: safeParseInt(json['animal_id']), 
      // FIX 2: Safely parse required 'tagNumber'
      tagNumber: (json['tag_number'] as String?) ?? 'N/A Tag',
      // FIX 3: Safely parse required 'sex'
      sex: (json['sex'] as String?) ?? 'Unknown', 
      // FIX 4: Safely parse optional 'name'
      name: json['name'] as String?,
    );
  }
  // ... (add toJson method if necessary)
}