// lib/features/farmer/livestock/data/models/breed_model.dart

import 'package:farm_manager_app/features/farmer/livestock/domain/entities/breed.dart';

class BreedModel extends BreedEntity {
  const BreedModel({
    required super.id,
    required super.breedName,
    required super.speciesId, 
    super.purpose,
  });

  factory BreedModel.fromJson(Map<String, dynamic> json) {
    // Helper to safely parse an integer, preventing 'Null is not a subtype of int'
    int safeParseInt(dynamic value) {
      if (value is int) return value;
      if (value is String) return int.tryParse(value) ?? 0;
      return 0; // Default to 0 if null or unexpected type
    }
    
    return BreedModel(
      // FIX 1: Safely parse ID, checking both 'id' (list response) and 'value' (dropdown response)
      id: safeParseInt(json['id'] ?? json['value']), 
      // FIX 2: Safely parse required string 'breedName' checking both 'breed_name' and 'label'
      breedName: (json['breed_name'] ?? json['label'] as String?) ?? 'N/A',
      // FIX 3: Safely parse 'species_id'
      speciesId: safeParseInt(json['species_id']), 
      // FIX 4: Safely cast nullable string 'purpose'
      purpose: json['purpose'] as String?, 
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id, // Using 'id' for consistency, but you can revert to 'value' if required by the API
      'breed_name': breedName,
      'species_id': speciesId,
      'purpose': purpose,
    };
  }
}