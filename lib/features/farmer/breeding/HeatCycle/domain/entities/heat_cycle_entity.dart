import 'package:equatable/equatable.dart';

// Placeholder for the Livestock/Dam entity structure
class LivestockEntity extends Equatable {
  final String animalId;
  final String tagNumber;
  final String name;
  final String species;

  const LivestockEntity({
    required this.animalId,
    required this.tagNumber,
    required this.name,
    required this.species,
  });

  @override
  List<Object> get props => [animalId, tagNumber, name, species];
}

class HeatCycleEntity extends Equatable {
  final String id;
  final String damId;
  final DateTime observedDate;
  final String intensity;
  final bool inseminated;
  final DateTime? nextExpectedDate;
  final LivestockEntity dam;
  final String? notes; // ⚠️ MUST BE HERE - this field is required

  const HeatCycleEntity({
    required this.id,
    required this.damId,
    required this.observedDate,
    required this.intensity,
    required this.inseminated,
    this.nextExpectedDate,
    required this.dam,
    this.notes, // ⚠️ MUST BE HERE - this parameter is required
  });

  // Helper logic moved from the mock class
  String get status {
    if (inseminated) return "Inseminated / Completed";
    
    final nextDate = nextExpectedDate;
    if (nextDate != null) {
      final now = DateTime.now();
      final isCurrent = observedDate.isBefore(now) && nextDate.isAfter(now);
      
      if (isCurrent) return "Active (Intensity: $intensity)";
      
      // If it's not inseminated and the expected date has passed, it's a Missed Cycle/Completed
      if (nextDate.isBefore(now)) return "Missed / Completed";
    }

    return "Unknown Status"; // Default catch-all
  }

  // Determine if it's an 'active' cycle for color coding
  bool get isActive {
    final nextDate = nextExpectedDate;
    return !inseminated && nextDate != null && nextDate.isAfter(DateTime.now());
  }

  @override
  List<Object?> get props => [
    id,
    damId,
    observedDate,
    intensity,
    inseminated,
    nextExpectedDate,
    dam,
    notes, // ⚠️ MUST BE HERE - this must be in props
  ];
}