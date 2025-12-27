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
  final String collectionDate; // Store as string, parse when converting to Entity
  final bool used;
  final double? costPerStraw;
  final double? doseMl;
  final int? motilityPercentage;
  final String? sourceSupplier;

  // Relationships
  final BullDto? bull; 
  final BreedDto? breed; 
  final List<InseminationDto>? inseminations;

  // Statistical fields
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
    this.timesUsed,
    this.successRate,
  });

  // FROM JSON - Updated to match the exact API format
  factory SemenModel.fromJson(Map<String, dynamic> json) {
    // Safe parsing helpers
    int? safeParseInt(dynamic value) {
      if (value == null) return null;
      if (value is String) return int.tryParse(value);
      if (value is int) return value;
      if (value is double) return value.toInt();
      return null;
    }

    double? safeParseDouble(dynamic value) {
      if (value == null) return null;
      if (value is String) return double.tryParse(value);
      if (value is num) return value.toDouble();
      return null;
    }

    // Parse the 'used' field - API returns boolean directly
    final bool isUsed = json['used'] == true || json['used'] == 1;

    // Parse collection_date - API returns ISO timestamp, extract just the date part
    String collectionDateStr = json['collection_date'] as String? ?? '';
    if (collectionDateStr.contains('T')) {
      // Extract date part from ISO timestamp (2025-12-15T00:00:00.000000Z -> 2025-12-15)
      collectionDateStr = collectionDateStr.split('T').first;
    }

    // Parse relationships
    final bullData = json['bull'];
    final breedData = json['breed'];
    final List<InseminationDto>? inseminationsList = (json['inseminations'] as List?)
        ?.map((i) => InseminationDto.fromJson(i as Map<String, dynamic>))
        .toList();
        
    final stats = json['stats'] as Map<String, dynamic>?;

    return SemenModel(
      id: safeParseInt(json['id']) ?? 0,
      strawCode: json['straw_code'] as String? ?? '',
      bullId: safeParseInt(json['bull_id']),
      bullTag: json['bull_tag'] as String?,
      bullName: json['bull_name'] as String? ?? '',
      breedId: safeParseInt(json['breed_id']) ?? 0,
      collectionDate: collectionDateStr,
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
      timesUsed: safeParseInt(stats?['times_used']),
      successRate: stats?['success_rate'] as String?,
    );
  }

  // TO JSON
  Map<String, dynamic> toJson() {
    return {
      'straw_code': strawCode,
      if (bullId != null) 'bull_id': bullId,
      if (bullTag != null) 'bull_tag': bullTag,
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
      collectionDate: entity.collectionDate.toIso8601String().split('T').first,
      used: entity.used,
      costPerStraw: entity.costPerStraw,
      doseMl: entity.doseMl,
      motilityPercentage: entity.motilityPercentage,
      sourceSupplier: entity.sourceSupplier,
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
      collectionDate: DateTime.parse(collectionDate),
      used: used,
      costPerStraw: costPerStraw ?? 0.0,
      doseMl: doseMl ?? 0.0,
      motilityPercentage: motilityPercentage,
      sourceSupplier: sourceSupplier,
      bull: bull?.toEntity(),
      breed: breed?.toEntity(),
      inseminations: inseminations?.map((i) => i.toEntity()).toList(),
      timesUsed: timesUsed ?? 0,
      successRate: successRate ?? '0%',
    );
  }
}