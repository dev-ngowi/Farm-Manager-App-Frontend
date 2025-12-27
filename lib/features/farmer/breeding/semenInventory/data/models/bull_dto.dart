import 'package:farm_manager_app/features/farmer/breeding/semenInventory/domain/entities/bull_entity.dart';

class BullDto {
  final int animalId;
  final String tagNumber;
  final String name;

  BullDto({
    required this.animalId,
    required this.tagNumber,
    required this.name,
  });

  // FROM JSON - Updated to match API format
  factory BullDto.fromJson(Map<String, dynamic> json) {
    int? safeParseInt(dynamic value) {
      if (value == null) return null;
      if (value is String) return int.tryParse(value);
      if (value is int) return value;
      if (value is double) return value.toInt();
      return null;
    }

    return BullDto(
      animalId: safeParseInt(json['animal_id']) ?? 0,
      tagNumber: json['tag_number'] as String? ?? '',
      name: json['name'] as String? ?? '',
    );
  }

  // TO JSON
  Map<String, dynamic> toJson() {
    return {
      'animal_id': animalId,
      'tag_number': tagNumber,
      'name': name,
    };
  }

  // TO ENTITY
  BullEntity toEntity() {
    return BullEntity(
      animalId: animalId,
      tagNumber: tagNumber,
      name: name,
    );
  }

  // FROM ENTITY
  factory BullDto.fromEntity(BullEntity entity) {
    return BullDto(
      animalId: entity.animalId,
      tagNumber: entity.tagNumber,
      name: entity.name,
    );
  }
}