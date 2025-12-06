import 'package:farm_manager_app/features/farmer/livestock/domain/entities/breed.dart'; // Assuming BreedEntity is defined here

class BreedDto {
  final int id;
  final String breedName;
  // NOTE: Made speciesId non-nullable here to match BreedEntity, 
  // or handle the null case explicitly in toEntity(). 
  // Sticking with non-nullable for DTO to match required Entity field.
  final int speciesId; 
  final String? purpose; // Added to match the Entity

  BreedDto({
    required this.id,
    required this.breedName,
    required this.speciesId, // Updated to be required
    this.purpose, // Added purpose
   });

  factory BreedDto.fromJson(Map<String, dynamic> json) {
    // You might need to adjust 'species_id' handling if it can be null 
    // in the JSON but is required for the Entity.
    final speciesIdJson = json['species_id'];

    return BreedDto(
      id: json['id'] as int,
      breedName: json['breed_name'] as String,
      // Use null-aware operator '??' to provide a default or throw an error 
      // if speciesId is null in JSON and is required. Assuming it's non-null here.
      speciesId: speciesIdJson as int, 
      purpose: json['purpose'] as String?, // Assuming 'purpose' is in the JSON
    );
  }

  // Convert DTO to Entity
  BreedEntity toEntity() {
    return BreedEntity(
      id: id,
      breedName: breedName,
      speciesId: speciesId, // speciesId is now correctly required and non-nullable
      purpose: purpose,
    );
  }
}