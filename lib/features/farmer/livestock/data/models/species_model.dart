// lib/features/farmer/livestock/data/models/species_model.dart

import 'package:farm_manager_app/features/farmer/livestock/domain/entities/species.dart';

class SpeciesModel extends SpeciesEntity {
  const SpeciesModel({
    required super.id,
    required super.speciesName,
  });

  factory SpeciesModel.fromJson(Map<String, dynamic> json) {
    // Helper to safely parse an integer, preventing 'Null is not a subtype of int'
    int safeParseInt(dynamic value) {
      if (value is int) return value;
      if (value is String) return int.tryParse(value) ?? 0;
      return 0; // Default to 0 if null or unexpected type
    }
    
    return SpeciesModel(
      // FIX 1: Safely parse ID, checking both 'id' (list response) and 'value' (dropdown response)
      id: safeParseInt(json['id'] ?? json['value']), 
      // FIX 2: Safely parse required string 'speciesName' checking both 'species_name' and 'label'
      speciesName: (json['species_name'] ?? json['label'] as String?) ?? 'N/A',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'species_name': speciesName,
    };
  }
}