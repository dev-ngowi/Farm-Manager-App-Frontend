// lib/features/farmer/livestock/data/models/livestock_model.dart

import 'package:farm_manager_app/features/farmer/livestock/data/models/breed_model.dart';
import 'package:farm_manager_app/features/farmer/livestock/data/models/parent_model.dart';
import 'package:farm_manager_app/features/farmer/livestock/data/models/species_model.dart';
import 'package:farm_manager_app/features/farmer/livestock/domain/entities/livestock.dart';

class LivestockModel extends LivestockEntity {
  const LivestockModel({
    required super.animalId,
    required super.speciesId,
    required super.breedId,
    required super.tagNumber,
    super.name,
    required super.sex,
    required super.dateOfBirth,
    required super.weightAtBirthKg,
    required super.status,
    super.notes,
    // Purchase fields
    super.purchaseDate,
    super.purchaseCost,
    super.source,
    // Relations
    super.species,
    super.breed,
    super.sire,
    super.dam,
    // Count fields
    super.milkYieldsCount,
    super.offspringAsDamCount,
    super.offspringAsSireCount,
    super.incomeCount,
    super.expensesCount,
  });

  factory LivestockModel.fromJson(Map<String, dynamic> json) {
    // Helper to safely parse related models (ADJUSTED FOR EMPTY LISTS)
    ParentModel? parseParent(dynamic data) {
      // FIX: If data is an empty list (e.g., sire: []), return null instead of crashing ParentModel.fromJson.
      if (data == null || (data is List && data.isEmpty)) return null;
      // Also ensure it is a Map before parsing
      if (data is! Map<String, dynamic>) return null;
      return ParentModel.fromJson(data);
    }

    // Helper to safely parse related models (unchanged for map data)
    SpeciesModel? parseSpecies(dynamic data) {
      if (data == null) return null;
      return SpeciesModel.fromJson(data as Map<String, dynamic>);
    }
    
    BreedModel? parseBreed(dynamic data) {
      if (data == null) return null;
      return BreedModel.fromJson(data as Map<String, dynamic>);
    }

    // NEW HELPER: Safely convert JSON value (which can be String, num, or null) to double.
    double? safeParseDouble(dynamic value) {
      if (value == null) return null;
      if (value is num) return value.toDouble();
      // Handles '12.00' type 'String' is not a subtype of type 'num' error
      if (value is String) return double.tryParse(value); 
      return null;
    }

    // NEW HELPER: Safely convert JSON value (which can be String, num, or null) to int.
    int? safeParseInt(dynamic value) {
      if (value == null) return null;
      if (value is int) return value;
      if (value is String) return int.tryParse(value);
      if (value is double) return value.round(); // Handle doubles sent as counts
      return null;
    }
    
    return LivestockModel(
      // IDs - Safely parsed and forcibly unwrapped (assuming they are always present and non-zero)
      animalId: safeParseInt(json['animal_id'])!,
      speciesId: safeParseInt(json['species_id'])!,
      breedId: safeParseInt(json['breed_id'])!,
      
      // FIX 4: Safely handle required string fields, replacing null with a default. 
      // Prevents 'null is not a subtype of type 'String'' error in list view
      tagNumber: (json['tag_number'] as String?) ?? 'N/A',
      sex: (json['sex'] as String?) ?? 'Unknown',
      status: (json['status'] as String?) ?? 'Unknown',

      name: json['name'] as String?,
      dateOfBirth: DateTime.parse(json['date_of_birth'] as String),
      
      // FIX 5: Use safeParseDouble for weight
      weightAtBirthKg: safeParseDouble(json['weight_at_birth_kg']) ?? 0.0,
      
      notes: json['notes'] as String?,
      
      // Purchase Fields
      purchaseDate: json['purchase_date'] != null 
          ? DateTime.parse(json['purchase_date'] as String) 
          : null,
      
      purchaseCost: safeParseDouble(json['purchase_cost']),
      
      source: json['source'] as String?,

      // Relations
      species: parseSpecies(json['species']),
      breed: parseBreed(json['breed']),
      sire: parseParent(json['sire']), 
      dam: parseParent(json['dam']),   

      // Count fields
      milkYieldsCount: safeParseInt(json['milk_yields_count']),
      offspringAsDamCount: safeParseInt(json['offspring_as_dam_count']),
      offspringAsSireCount: safeParseInt(json['offspring_as_sire_count']),
      incomeCount: safeParseInt(json['income_count']),
      expensesCount: safeParseInt(json['expenses_count']),
    );
  }

  /// Converts form data into a snake_case JSON payload suitable for the API POST/PATCH request.
  static Map<String, dynamic> toStoreJson({
    required int speciesId,
    required int? breedId, // ⭐ FIX: Changed to nullable int?
    required String tagNumber,
    String? name,
    required String sex,
    required DateTime dateOfBirth,
    required double weightAtBirthKg,
    required String status,
    String? notes, 
    DateTime? purchaseDate,
    double? purchaseCost,
    String? source,
    int? sireId, // ⭐ Should also be nullable
    int? damId, // ⭐ Should also be nullable
  }) {
    return {
      'species_id': speciesId,
      'breed_id': breedId,
      'tag_number': tagNumber,
      'name': name,
      'sex': sex,
      // Ensure date is sent as YYYY-MM-DD string to satisfy Laravel 'date' rule
      'date_of_birth': dateOfBirth.toIso8601String().split('T').first, 
      'weight_at_birth_kg': weightAtBirthKg,
      'status': status,
      // Include the notes field
      'notes': notes, 
      'purchase_date': purchaseDate?.toIso8601String().split('T').first,
      'purchase_cost': purchaseCost,
      'source': source,
      'sire_id': sireId, 
      'dam_id': damId, 
    }..removeWhere((key, value) => value == null && key != 'notes'); // Clean up nulls except for notes
  }
  
  // Assuming you also have a toUpdateJson that calls a common serialization method, 
  // ensure it also uses nullable types for breedId, sireId, and damId.
  // The structure below assumes you call the above method (or a new internal toApiJson):

  static Map<String, dynamic> toUpdateJson({
    required int speciesId,
    required int? breedId, // ⭐ FIX: Changed to nullable int?
    required String tagNumber,
    String? name,
    required String sex,
    required DateTime dateOfBirth,
    required double weightAtBirthKg,
    required String status,
    String? notes, 
    DateTime? purchaseDate,
    double? purchaseCost,
    String? source,
    int? sireId, // ⭐ Should also be nullable
    int? damId, // ⭐ Should also be nullable
  }) {
    // For simplicity, we call toStoreJson which is now corrected.
    return toStoreJson(
      speciesId: speciesId,
      breedId: breedId,
      tagNumber: tagNumber,
      name: name,
      sex: sex,
      dateOfBirth: dateOfBirth,
      weightAtBirthKg: weightAtBirthKg,
      status: status,
      notes: notes,
      purchaseDate: purchaseDate,
      purchaseCost: purchaseCost,
      source: source,
      sireId: sireId,
      damId: damId,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'animal_id': animalId,
      'species_id': speciesId,
      'breed_id': breedId,
      'tag_number': tagNumber,
      'name': name,
      'sex': sex,
      'date_of_birth': dateOfBirth.toIso8601String().split('T').first,
      'weight_at_birth_kg': weightAtBirthKg,
      'status': status,
      'notes': notes,
      'purchase_date': purchaseDate?.toIso8601String().split('T').first,
      'purchase_cost': purchaseCost,
      'source': source,
    };
  }
}