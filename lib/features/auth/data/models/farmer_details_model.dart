/// Request model for farmer registration
/// This matches what your Laravel backend expects
class FarmerDetailsModel {
  final String farmName;
  final String farmPurpose;
  final double totalLandAcres;
  final int yearsExperience;
  final int locationId;

  const FarmerDetailsModel({
    required this.farmName,
    required this.farmPurpose,
    required this.totalLandAcres,
    required this.yearsExperience,
    required this.locationId,
  });

  /// Convert to JSON for API request
  Map<String, dynamic> toJson() {
    return {
      'farm_name': farmName,
      'farm_purpose': farmPurpose,
      'total_land_acres': totalLandAcres,
      'years_experience': yearsExperience,
      'location_id': locationId,
    };
  }

  /// Create from form data
  factory FarmerDetailsModel.fromForm({
    required String farmName,
    required String farmPurpose,
    required double totalLandAcres,
    required int yearsExperience,
    required int locationId,
  }) {
    return FarmerDetailsModel(
      farmName: farmName,
      farmPurpose: farmPurpose,
      totalLandAcres: totalLandAcres,
      yearsExperience: yearsExperience,
      locationId: locationId,
    );
  }

  /// For debugging
  @override
  String toString() {
    return 'FarmerDetailsModel(farmName: $farmName, purpose: $farmPurpose, '
        'acres: $totalLandAcres, experience: $yearsExperience, locationId: $locationId)';
  }
}