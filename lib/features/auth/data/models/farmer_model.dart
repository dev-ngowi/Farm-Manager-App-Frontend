/// Farmer profile data from API response
class FarmerModel {
  final int id;
  final int userId;
  final String farmName;
  final String farmPurpose;
  final double totalLandAcres;
  final int yearsExperience;
  final int locationId;
  final String? profilePhoto;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const FarmerModel({
    required this.id,
    required this.userId,
    required this.farmName,
    required this.farmPurpose,
    required this.totalLandAcres,
    required this.yearsExperience,
    required this.locationId,
    this.profilePhoto,
    this.createdAt,
    this.updatedAt,
  });

  /// Parse from API response JSON
  factory FarmerModel.fromJson(Map<String, dynamic> json) {
    return FarmerModel(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      farmName: json['farm_name'] as String,
      farmPurpose: json['farm_purpose'] as String,
      totalLandAcres: (json['total_land_acres'] as num).toDouble(),
      yearsExperience: json['years_experience'] as int,
      locationId: json['location_id'] as int,
      profilePhoto: json['profile_photo'] as String?,
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : null,
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at']) 
          : null,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'farm_name': farmName,
      'farm_purpose': farmPurpose,
      'total_land_acres': totalLandAcres,
      'years_experience': yearsExperience,
      'location_id': locationId,
      'profile_photo': profilePhoto,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'FarmerModel(id: $id, farmName: $farmName, userId: $userId)';
  }
}