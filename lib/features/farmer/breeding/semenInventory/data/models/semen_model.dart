import 'package:farm_manager_app/features/farmer/breeding/semenInventory/data/models/breed_dto.dart';
import 'package:farm_manager_app/features/farmer/breeding/semenInventory/data/models/bull_dto.dart';
import 'package:farm_manager_app/features/farmer/breeding/semenInventory/data/models/insemination_dto.dart';
import 'package:farm_manager_app/features/farmer/breeding/semenInventory/domain/entities/semen_entity.dart';

class SemenModel {
  final int id;
  final String strawCode;
  final int? bullId;
  final String? bullTag;
  final String bullName;
  final int breedId;
  final String collectionDate; // String in Model, convert to DateTime for Entity
  final bool used;
  final double? costPerStraw;
  final double? doseMl;
  final int? motilityPercentage;
  final String? sourceSupplier;

  // Relationships
  final BullDto? bull; 
  final BreedDto? breed; 
  final List<InseminationDto>? inseminations;

  // ⭐ ADDED: Statistical fields (These typically come from the /show endpoint)
  final int? timesUsed;
  final String? successRate;

  SemenModel({
    required this.id,
    required this.strawCode,
    this.bullId,
    this.bullTag,
    required this.bullName,
    required this.breedId,
    required this.collectionDate,
    required this.used,
    this.costPerStraw,
    this.doseMl,
    this.motilityPercentage,
    this.sourceSupplier,
    this.bull,
    this.breed,
    this.inseminations,
    // ⭐ ADDED to constructor
    this.timesUsed,
    this.successRate,
  });

  // FROM JSON
  factory SemenModel.fromJson(Map<String, dynamic> json) {
    int? safeParseInt(dynamic value) {
      if (value == null) return null;
      if (value is String) return int.tryParse(value);
      if (value is int) return value;
      return null;
    }

    double? safeParseDouble(dynamic value) {
      if (value == null) return null;
      if (value is String) return double.tryParse(value);
      if (value is num) return value.toDouble();
      return null;
    }

    final bool isUsed = (json['used'] is int) 
        ? (json['used'] == 1) 
        : (json['used'] as bool? ?? false); 

    // The 'inseminations' list and 'stats' objects only appear on the /show endpoint
    final List<InseminationDto>? inseminationsList = (json['inseminations'] as List?)
        ?.map((i) => InseminationDto.fromJson(i as Map<String, dynamic>))
        .toList();
        
    final stats = json['stats'] as Map<String, dynamic>?; // Stats object from /show endpoint

    final bullData = json['bull'];
    final breedData = json['breed'];

    return SemenModel(
      id: safeParseInt(json['id']) ?? 0, 
      strawCode: json['straw_code'] as String,
      bullId: safeParseInt(json['bull_id']),
      bullTag: json['bull_tag'] as String?,
      bullName: json['bull_name'] as String,
      breedId: safeParseInt(json['breed_id']) ?? 0, 
      collectionDate: json['collection_date'] as String,
      used: isUsed,
      costPerStraw: safeParseDouble(json['cost_per_straw']),
      doseMl: safeParseDouble(json['dose_ml']),
      motilityPercentage: safeParseInt(json['motility_percentage']),
      sourceSupplier: json['source_supplier'] as String?,
      bull: (bullData is Map<String, dynamic>) 
          ? BullDto.fromJson(bullData) 
          : null,
      breed: (breedData is Map<String, dynamic>) 
          ? BreedDto.fromJson(breedData) 
          : null,
      inseminations: inseminationsList,
      // ⭐ MAPPING STATS (Handles null if stats object is missing, e.g., on /index)
      timesUsed: stats?['times_used'] as int?,
      successRate: stats?['success_rate'] as String?,
    );
  }

  // TO JSON
  Map<String, dynamic> toJson() {
    return {
      'straw_code': strawCode,
      'bull_id': bullId,
      'bull_tag': bullTag,
      'bull_name': bullName,
      'breed_id': breedId,
      'collection_date': collectionDate,
      if (doseMl != null) 'dose_ml': doseMl,
      if (motilityPercentage != null) 'motility_percentage': motilityPercentage,
      if (costPerStraw != null) 'cost_per_straw': costPerStraw,
      if (sourceSupplier != null) 'source_supplier': sourceSupplier,
    };
  }

  // FROM ENTITY
  factory SemenModel.fromEntity(SemenEntity entity) {
    return SemenModel(
      id: entity.id,
      strawCode: entity.strawCode,
      bullId: entity.bullId,
      bullTag: entity.bullTag,
      bullName: entity.bullName,
      breedId: entity.breedId,
      // ⭐ UPDATED: Convert DateTime from Entity back to String for the Model
      collectionDate: entity.collectionDate.toIso8601String().split('T').first,
      used: entity.used,
      costPerStraw: entity.costPerStraw,
      doseMl: entity.doseMl,
      motilityPercentage: entity.motilityPercentage,
      sourceSupplier: entity.sourceSupplier,
      // Relationships are not mapped from Entity to Model, as the Model is typically 
      // used for creation/update requests or simple data mapping.
      bull: null,
      breed: null,
      inseminations: null,
      timesUsed: entity.timesUsed,
      successRate: entity.successRate,
    );
  }

  // TO ENTITY
  SemenEntity toEntity() {
    return SemenEntity(
      id: id,
      strawCode: strawCode,
      bullId: bullId,
      bullTag: bullTag,
      bullName: bullName,
      breedId: breedId,
      // ⭐ UPDATED: Convert String from Model to DateTime for the Entity
      collectionDate: DateTime.parse(collectionDate),
      used: used,
      // ⭐ ENFORCED: Use null-coalescing to ensure Entity receives non-nullable values
      costPerStraw: costPerStraw ?? 0.0, 
      doseMl: doseMl ?? 0.0,
      motilityPercentage: motilityPercentage,
      sourceSupplier: sourceSupplier,
      bull: bull?.toEntity(),
      breed: breed?.toEntity(),
      inseminations: inseminations?.map((i) => i.toEntity()).toList(),
      // ⭐ MAPPING STATS
      timesUsed: timesUsed ?? 0,
      successRate: successRate ?? '0%',
    );
  }
}