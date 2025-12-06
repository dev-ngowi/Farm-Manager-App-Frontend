
import 'package:farm_manager_app/features/farmer/livestock/domain/entities/livestock_summary.dart';

class LivestockSummaryModel extends LivestockSummary {
  const LivestockSummaryModel({
    required super.totalAnimals,
    required super.totalCows,
    required super.totalBulls,
    required super.totalCalves,
    required super.breedingReadyFemales,
    required super.averageWeightKg,
  });

  factory LivestockSummaryModel.fromJson(Map<String, dynamic> json) {
    return LivestockSummaryModel(
      totalAnimals: json['total_animals'] as int,
      totalCows: json['total_cows'] as int,
      totalBulls: json['total_bulls'] as int,
      totalCalves: json['total_calves'] as int,
      breedingReadyFemales: json['breeding_ready_females'] as int,
      // Ensure numerical fields are parsed correctly, even if API sends them as strings/ints
      averageWeightKg: (json['average_weight_kg'] as num).toDouble(),
    );
  }
}