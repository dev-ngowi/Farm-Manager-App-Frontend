import 'package:farm_manager_app/features/farmer/breeding/semenInventory/domain/entities/bull_entity.dart';

class BullDto {
  final int animalId;
  final String tagNumber;
  final String name;
  final int? speciesId; 
  
  BullDto({
    required this.animalId, 
    required this.tagNumber, 
    required this.name, 
    this.speciesId
  });
  
  factory BullDto.fromJson(Map<String, dynamic> json) {
    return BullDto(
      animalId: json['animal_id'] as int,
      tagNumber: json['tag_number'] as String,
      name: json['name'] as String,
      speciesId: json['species_id'] as int?,
    );
  }

  // NEW: Convert DTO to Entity
  BullEntity toEntity() {
    return BullEntity(
      animalId: animalId,
      tagNumber: tagNumber,
      name: name,
      speciesId: speciesId,
    );
  }
}