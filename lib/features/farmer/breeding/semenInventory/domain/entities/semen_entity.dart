import 'package:equatable/equatable.dart'; // ⭐ ADDED: Best practice for Domain Entities
// Core Domain Entities (Must be defined separately, similar to DTOs)
import 'package:farm_manager_app/features/farmer/breeding/Insemination/domain/entities/insemination_entity.dart';
import 'package:farm_manager_app/features/farmer/breeding/semenInventory/domain/entities/bull_entity.dart';
import 'package:farm_manager_app/features/farmer/livestock/domain/entities/breed.dart';

class SemenEntity extends Equatable { // ⭐ ADDED Equatable
  final int id;
  final String strawCode;
  final int? bullId;
  final String? bullTag;
  final String bullName;
  final int breedId;
  // ⭐ UPDATED: Use DateTime in Domain layer for consistency and calculations
  final DateTime collectionDate; 
  final bool used;
  // ⭐ ENFORCED: Non-nullable in Entity, as domain logic shouldn't rely on null for these values
  final double costPerStraw; 
  final double doseMl;
  final int? motilityPercentage;
  final String? sourceSupplier;

  // Domain Relationships
  final BullEntity? bull; 
  final BreedEntity? breed; 
  final List<InseminationEntity>? inseminations;

  // ⭐ ADDED: Calculated stats (mapped from API response in SemenModel)
  final int timesUsed;
  final String successRate;


  const SemenEntity({ // ⭐ ADDED const
    required this.id,
    required this.strawCode,
    this.bullId,
    this.bullTag,
    required this.bullName,
    required this.breedId,
    required this.collectionDate,
    required this.used,
    required this.costPerStraw,
    required this.doseMl,
    this.motilityPercentage,
    this.sourceSupplier,
    this.bull,
    this.breed,
    this.inseminations,
    // ⭐ ADDED: These are required, use default values if not provided by Model
    this.timesUsed = 0, 
    this.successRate = '0%', 
  });

  @override
  List<Object?> get props => [
    id, strawCode, bullId, bullTag, bullName, breedId, collectionDate, used, 
    costPerStraw, doseMl, motilityPercentage, sourceSupplier, bull, breed, 
    inseminations, timesUsed, successRate
  ];


  // --- Helper to convert entity for use cases (e.g., creating a new record) ---
  Map<String, dynamic> toRequestJson() {
    return {
      'straw_code': strawCode,
      'bull_id': bullId,
      'bull_tag': bullTag,
      'bull_name': bullName,
      'breed_id': breedId,
      // ⭐ UPDATED: Convert DateTime to the required date string format for the API
      'collection_date': collectionDate.toIso8601String().split('T').first, 
      'dose_ml': doseMl,
      'motility_percentage': motilityPercentage,
      'cost_per_straw': costPerStraw,
      'source_supplier': sourceSupplier,
    };
  }
}