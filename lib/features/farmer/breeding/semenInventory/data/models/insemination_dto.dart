import 'package:farm_manager_app/features/farmer/breeding/Insemination/domain/entities/insemination_entity.dart';

// 1. DTO for the Animal link (Dam/Sire)
// Renamed from DamDto to a more generic name for reuse
class InseminationAnimalDto {
  // NOTE: animalId in the DTO corresponds to 'id' in the Entity constructor
  final int animalId; 
  final String tagNumber;
  final String name;

  InseminationAnimalDto({
    required this.animalId, 
    required this.tagNumber, 
    required this.name,
  });

  factory InseminationAnimalDto.fromJson(Map<String, dynamic> json) {
    return InseminationAnimalDto(
      // The Entity expects 'id', but the JSON field is 'animal_id'
      animalId: json['id'] as int, // Assuming 'id' is used in the relation
      // If the backend returns 'animal_id' for the related object's ID:
      // animalId: json['animal_id'] as int, 
      tagNumber: json['tag_number'] as String,
      name: json['name'] as String,
    );
  }

  // Convert DTO to Entity
  InseminationAnimalEntity toEntity() {
    // The Entity constructor takes 'id', which we map from the DTO's 'animalId'
    return InseminationAnimalEntity(
      id: animalId, 
      tagNumber: tagNumber,
      name: name, sex: 'Unknown',
    );
  }
}

// 2. DTO for the Semen link
class InseminationSemenDto {
  final int id;
  final String strawCode;
  final String bullName;

  InseminationSemenDto({
    required this.id, 
    required this.strawCode, 
    required this.bullName,
  });

  factory InseminationSemenDto.fromJson(Map<String, dynamic> json) {
    return InseminationSemenDto(
      id: json['id'] as int,
      strawCode: json['straw_code'] as String,
      bullName: json['bull_name'] as String,
    );
  }

  // Convert DTO to Entity
  InseminationSemenEntity toEntity() {
    return InseminationSemenEntity(
      id: id,
      strawCode: strawCode,
      bullName: bullName,
    );
  }
}


// 3. DTO for the Insemination record itself
class InseminationDto {
  final int id;
  final int damId;
  final int? sireId; // NEW
  final int? semenId; // NEW
  final int heatCycleId; // NEW
  final String breedingMethod; // NEW
  final String inseminationDate; 
  final String expectedDeliveryDate; // NEW
  final String status;
  final String? notes; // NEW
  final bool isPregnant; // NEW
  final int daysToDue; // NEW
  
  final InseminationAnimalDto dam; // Made non-nullable to match Entity
  final InseminationAnimalDto? sire; // NEW: Nested sire object
  final InseminationSemenDto? semen; // NEW: Nested semen object

  InseminationDto({
    required this.id, 
    required this.damId, 
    this.sireId,
    this.semenId,
    required this.heatCycleId,
    required this.breedingMethod,
    required this.inseminationDate, 
    required this.expectedDeliveryDate,
    required this.status, 
    this.notes,
    required this.isPregnant,
    required this.daysToDue,
    required this.dam, // Updated to required
    this.sire,
    this.semen,
  });
  
  factory InseminationDto.fromJson(Map<String, dynamic> json) {
    // Helper function for mapping animal data
    InseminationAnimalDto mapAnimalDto(Map<String, dynamic> data) {
      // NOTE: The backend Entity's fromJson suggests the related animal JSON 
      // structure only has 'id', 'tag_number', 'name'. We use that here.
      return InseminationAnimalDto.fromJson(data);
    }

    return InseminationDto(
      id: json['id'] as int,
      damId: json['dam_id'] as int,
      sireId: json['sire_id'] as int?,
      semenId: json['semen_id'] as int?,
      heatCycleId: json['heat_cycle_id'] as int,
      breedingMethod: json['breeding_method'] as String,
      inseminationDate: json['insemination_date'] as String,
      expectedDeliveryDate: json['expected_delivery_date'] as String,
      status: json['status'] as String,
      notes: json['notes'] as String?,
      
      // Custom calculated fields
      isPregnant: json['is_pregnant'] as bool? ?? false,
      daysToDue: json['days_to_due'] as int? ?? 999,
      
      // Nested Relationships
      dam: mapAnimalDto(json['dam'] as Map<String, dynamic>), // Entity requires 'dam' to be non-null
      sire: json['sire'] != null ? mapAnimalDto(json['sire'] as Map<String, dynamic>) : null,
      semen: json['semen'] != null ? InseminationSemenDto.fromJson(json['semen'] as Map<String, dynamic>) : null,
    );
  }

  // Convert DTO to Entity
  InseminationEntity toEntity() {
    return InseminationEntity(
      id: id,
      damId: damId,
      sireId: sireId,
      semenId: semenId,
      heatCycleId: heatCycleId,
      breedingMethod: breedingMethod,
      // DTO fields are usually Strings, Entity requires DateTime
      inseminationDate: DateTime.parse(inseminationDate), 
      expectedDeliveryDate: DateTime.parse(expectedDeliveryDate),
      status: status,
      notes: notes,
      
      // Relationships
      dam: dam.toEntity(), // Non-nullable
      sire: sire?.toEntity(),
      semen: semen?.toEntity(),

      // Custom fields
      isPregnant: isPregnant,
      daysToDue: daysToDue,
    );
  }
}