import 'package:farm_manager_app/features/farmer/livestock/domain/entities/breed.dart';

class BreedDto {
  final int id;
  final String breedName;
  final int? speciesId; // Optional because API might not always return it
  final String? purpose;

  BreedDto({
    required this.id,
    required this.breedName,
    this.speciesId,
    this.purpose,
  });

  // FROM JSON - Updated to match API format
  factory BreedDto.fromJson(Map<String, dynamic> json) {
    int? safeParseInt(dynamic value) {
      if (value == null) return null;
      if (value is String) return int.tryParse(value);
      if (value is int) return value;
      if (value is double) return value.toInt();
      return null;
    }

    return BreedDto(
      id: safeParseInt(json['id']) ?? 0,
      breedName: json['breed_name'] as String? ?? '',
      speciesId: safeParseInt(json['species_id']),
      purpose: json['purpose'] as String?,
    );
  }

  // TO JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'breed_name': breedName,
      if (speciesId != null) 'species_id': speciesId,
      if (purpose != null) 'purpose': purpose,
    };
  }

  // TO ENTITY
  BreedEntity toEntity() {
    return BreedEntity(
      id: id,
      breedName: breedName,
      // Use speciesId from DTO if available, otherwise default to 1 (cattle)
      // You may need to adjust this default based on your business logic
      speciesId: speciesId ?? 1, 
      purpose: purpose,
    );
  }

  // FROM ENTITY
  factory BreedDto.fromEntity(BreedEntity entity) {
    return BreedDto(
      id: entity.id,
      breedName: entity.breedName,
      speciesId: entity.speciesId,
      purpose: entity.purpose,
    );
  }
}