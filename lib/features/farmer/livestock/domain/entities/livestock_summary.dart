import 'package:equatable/equatable.dart';

/// Represents the high-level summary statistics for the livestock dashboard.
class LivestockSummary extends Equatable {
  final int totalAnimals;
  final int totalCows;
  final int totalBulls;
  final int totalCalves;
  final int breedingReadyFemales;
  final double averageWeightKg;

  const LivestockSummary({
    required this.totalAnimals,
    required this.totalCows,
    required this.totalBulls,
    required this.totalCalves,
    required this.breedingReadyFemales,
    required this.averageWeightKg,
  });

  @override
  List<Object> get props => [
        totalAnimals,
        totalCows,
        totalBulls,
        totalCalves,
        breedingReadyFemales,
        averageWeightKg,
      ];
}