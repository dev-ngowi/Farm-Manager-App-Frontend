// heat_cycle_model.dart

import 'package:farm_manager_app/features/farmer/breeding/HeatCycle/domain/entities/heat_cycle_entity.dart';

// ------------------------------------------------------------------
// Dam/Livestock Model (Must match LivestockEntity structure)
// ------------------------------------------------------------------

class DamModel extends LivestockEntity {
  const DamModel({
    required super.animalId,
    required super.tagNumber,
    required super.name,
    required super.species,
  });

  factory DamModel.fromJson(Map<String, dynamic> json) {
    return DamModel(
      animalId: json['animal_id']?.toString() ?? '', 
      tagNumber: json['tag_number'] as String, 
      name: json['name'] as String,
      species: json['species'] as String? ?? json['species_id']?.toString() ?? 'N/A', 
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'animal_id': animalId,
      'tag_number': tagNumber,
      'name': name,
      'species': species,
    };
  }
}

// ------------------------------------------------------------------
// Heat Cycle Model
// ------------------------------------------------------------------

class HeatCycleModel extends HeatCycleEntity {
  const HeatCycleModel({
    required super.id,
    required super.damId,
    required super.observedDate,
    required super.intensity,
    required super.inseminated,
    super.nextExpectedDate,
    required super.dam,
    super.notes,
  });

  // ========================================
  // FROM JSON - Parse API response (snake_case from backend)
  // ========================================
  factory HeatCycleModel.fromJson(Map<String, dynamic> json) {
    return HeatCycleModel(
      id: json['id']?.toString() ?? '',
      damId: json['dam_id']?.toString() ?? '',
      observedDate: DateTime.parse(json['observed_date'] as String),
      intensity: json['intensity'] as String,
      inseminated: json['inseminated'] == true || json['inseminated'] == 1,
      dam: DamModel.fromJson(json['dam'] as Map<String, dynamic>),
      nextExpectedDate: json['next_expected_date'] != null
          ? DateTime.parse(json['next_expected_date'] as String)
          : null,
      notes: json['notes'] as String?,
    );
  }

  // ========================================
  // TO JSON - Send to API (snake_case for backend)
  // ========================================
  @override
  Map<String, dynamic> toJson() {
    // For CREATE: Only send dam_id, observed_date, intensity, notes
    final Map<String, dynamic> data = {
      'dam_id': damId,
      'observed_date': _formatDate(observedDate),
      'intensity': intensity,
    };

    // Only include notes if not null or empty
    if (notes != null && notes!.trim().isNotEmpty) {
      data['notes'] = notes;
    }

    return data;
  }

  // ========================================
  // TO JSON FOR UPDATE - Only editable fields
  // ========================================
  Map<String, dynamic> toJsonForUpdate() {
    final Map<String, dynamic> data = {
      'observed_date': _formatDate(observedDate),
      'intensity': intensity,
    };

    // Always include notes field for updates (can be null to clear)
    data['notes'] = notes;

    return data;
  }

  // ========================================
  // HELPER METHODS
  // ========================================
  
  /// Format date to YYYY-MM-DD format expected by backend
  String _formatDate(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-'
           '${date.month.toString().padLeft(2, '0')}-'
           '${date.day.toString().padLeft(2, '0')}';
  }

  // ========================================
  // COPY WITH - For creating modified copies
  // ========================================
  HeatCycleModel copyWith({
    String? id,
    String? damId,
    DamModel? dam,
    DateTime? observedDate,
    String? intensity,
    bool? inseminated,
    DateTime? nextExpectedDate,
    String? notes,
  }) {
    return HeatCycleModel(
      id: id ?? this.id,
      damId: damId ?? this.damId,
      dam: dam ?? this.dam,
      observedDate: observedDate ?? this.observedDate,
      intensity: intensity ?? this.intensity,
      inseminated: inseminated ?? this.inseminated,
      nextExpectedDate: nextExpectedDate ?? this.nextExpectedDate,
      notes: notes ?? this.notes,
    );
  }

  // ========================================
  // FROM ENTITY - Convert entity to model
  // ========================================
  factory HeatCycleModel.fromEntity(HeatCycleEntity entity) {
    return HeatCycleModel(
      id: entity.id,
      damId: entity.damId,
      dam: entity.dam is DamModel 
          ? entity.dam as DamModel
          : DamModel(
              animalId: entity.dam.animalId,
              tagNumber: entity.dam.tagNumber,
              name: entity.dam.name,
              species: entity.dam.species,
            ),
      observedDate: entity.observedDate,
      intensity: entity.intensity,
      inseminated: entity.inseminated,
      nextExpectedDate: entity.nextExpectedDate,
      notes: entity.notes,
    );
  }

  // ========================================
  // TO ENTITY - Convert model to entity
  // ========================================
  HeatCycleEntity toEntity() {
    return HeatCycleEntity(
      id: id,
      damId: damId,
      dam: dam,
      observedDate: observedDate,
      intensity: intensity,
      inseminated: inseminated,
      nextExpectedDate: nextExpectedDate,
      notes: notes,
    );
  }

  @override
  List<Object?> get props => [
    id,
    damId,
    dam,
    observedDate,
    intensity,
    inseminated,
    nextExpectedDate,
    notes,
  ];
}