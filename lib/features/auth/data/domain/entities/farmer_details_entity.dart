import 'package:equatable/equatable.dart';

// Represents the data structure for the farmer's profile details.
class FarmerDetailsEntity extends Equatable {
  final String farmName;
  final String farmPurpose;
  final double totalLandAcres;
  final int yearsExperience;
  final int locationId;

  const FarmerDetailsEntity({
    required this.farmName,
    required this.farmPurpose,
    required this.totalLandAcres,
    required this.yearsExperience,
    required this.locationId,
  });

  @override
  List<Object> get props => [
        farmName,
        farmPurpose,
        totalLandAcres,
        yearsExperience,
        locationId,
      ];
}