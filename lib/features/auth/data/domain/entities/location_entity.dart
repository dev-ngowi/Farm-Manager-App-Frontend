// lib/features/auth/data/domain/entities/location_entity.dart

import 'package:equatable/equatable.dart';

/// Domain entity representing a user's location for the farmer registration form
/// Simplified version optimized for dropdown selection in farmer details form
class LocationEntity extends Equatable {
  // ========================================
  // CORE IDENTIFIERS
  // ========================================
  
  /// The actual location ID (e.g., 13) ← THIS is what you send to backend
  /// Use this value when submitting farmer details (location_id)
  final int locationId;
  
  /// Region ID (e.g., 2)
  final int regionId;
  
  /// District ID (e.g., 8)
  final int districtId;
  
  /// Ward ID (e.g., 7)
  final int wardId;
  
  /// User Location ID from pivot table (optional, for reference only)
  final int? userLocationId;
  
  /// Whether this is the user's primary location
  final bool isPrimary;
  
  // ========================================
  // DISPLAY NAMES (for UI)
  // ========================================
  
  /// Region name (e.g., "Dar Es Salaam")
  final String regionName;
  
  /// District name (e.g., "Ilala Municipal")
  final String districtName;
  
  /// Ward name (e.g., "Ilala")
  final String wardName;
  
  /// Street name (optional)
  final String? streetName;
  
  // ========================================
  // COORDINATES (optional)
  // ========================================
  
  /// Latitude coordinate
  final double? latitude;
  
  /// Longitude coordinate
  final double? longitude;
  
  /// Additional address details
  final String? addressDetails;

  // ========================================
  // CONSTRUCTOR
  // ========================================

  const LocationEntity({
    required this.locationId,
    required this.regionId,
    required this.districtId,
    required this.wardId,
    this.userLocationId,
    this.isPrimary = false,
    required this.regionName,
    required this.districtName,
    required this.wardName,
    this.streetName,
    this.latitude,
    this.longitude,
    this.addressDetails,
  });

  // ========================================
  // FACTORY CONSTRUCTORS
  // ========================================

  /// Create a LocationEntity from minimal required data
  factory LocationEntity.minimal({
    required int locationId,
    required String wardName,
    required String districtName,
    required String regionName,
    int? regionId,
    int? districtId,
    int? wardId,
    bool isPrimary = false,
  }) {
    return LocationEntity(
      locationId: locationId,
      regionId: regionId ?? 0,
      districtId: districtId ?? 0,
      wardId: wardId ?? 0,
      isPrimary: isPrimary,
      regionName: regionName,
      districtName: districtName,
      wardName: wardName,
    );
  }

 factory LocationEntity.fromJson(Map<String, dynamic> json) {
  try {
    // Debug: Print raw JSON to see what backend is sending
    print('🔍 LocationEntity.fromJson - Raw JSON: $json');
    
    // Handle both nested and flat response structures
    final locationData = json['location'] as Map<String, dynamic>? ?? json;
    
    print('🔍 LocationEntity.fromJson - Location Data: $locationData');
    
    final locationId = _parseInt(locationData['id'] ?? locationData['location_id']);
    final regionName = (locationData['region_name'] ?? locationData['region'] ?? 'Unknown Region').toString();
    final districtName = (locationData['district_name'] ?? locationData['district'] ?? 'Unknown District').toString();
    final wardName = (locationData['ward_name'] ?? locationData['ward'] ?? 'Unknown Ward').toString();
    
    print('✅ Parsed: locationId=$locationId, region=$regionName, district=$districtName, ward=$wardName');
    
    return LocationEntity(
      locationId: locationId,
      regionId: _parseInt(locationData['region_id']),
      districtId: _parseInt(locationData['district_id']),
      wardId: _parseInt(locationData['ward_id']),
      userLocationId: _parseNullableInt(json['id']),
      isPrimary: (json['is_primary'] as bool?) ?? false,
      regionName: regionName,
      districtName: districtName,
      wardName: wardName,
      streetName: locationData['street_name']?.toString(),
      latitude: _parseDouble(locationData['latitude']),
      longitude: _parseDouble(locationData['longitude']),
      addressDetails: locationData['address_details']?.toString(),
    );
  } catch (e, stackTrace) {
    print('❌ LocationEntity.fromJson ERROR: $e');
    print('📍 Stack trace: $stackTrace');
    print('📦 Failed JSON: $json');
    
    // Return a fallback entity to prevent crashes
    return LocationEntity(
      locationId: (json['id'] ?? json['location_id'] ?? 0) as int,
      regionId: 0,
      districtId: 0,
      wardId: 0,
      isPrimary: false,
      regionName: 'Unknown',
      districtName: 'Unknown',
      wardName: 'Unknown',
    );
  }
}
  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    if (value is double) return value.toInt();
    return 0;
  }

  static int? _parseNullableInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    if (value is double) return value.toInt();
    return null;
  }

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  // ========================================
  // DISPLAY GETTERS
  // ========================================

  /// Full display name with all levels
  /// Example: "Ilala, Ilala Municipal, Dar Es Salaam"
  /// If street exists: "Main Street, Ilala, Ilala Municipal, Dar Es Salaam"
  String get displayName {
    final parts = <String>[];
    
    if (streetName != null && streetName!.isNotEmpty) {
      parts.add(streetName!);
    }
    
    parts.add(wardName);
    parts.add(districtName);
    parts.add(regionName);
    
    return parts.join(', ');
  }

  /// Short display name (ward and district only)
  /// Example: "Ilala, Ilala Municipal"
  String get shortDisplayName {
    return '$wardName, $districtName';
  }

  /// Display name with primary indicator
  /// Example: "Ilala, Ilala Municipal, Dar Es Salaam (Primary)"
  String get displayNameWithPrimary {
    return isPrimary ? '$displayName (Primary)' : displayName;
  }

  /// Simple display for dropdown (ward and district)
  String get dropdownDisplay {
    return '$wardName, $districtName, $regionName${isPrimary ? ' ★' : ''}';
  }

  /// Compact display for mobile
  String get compactDisplay {
    if (streetName != null && streetName!.isNotEmpty) {
      return '$streetName, $wardName';
    }
    return wardName;
  }

  // ========================================
  // UTILITY METHODS
  // ========================================

  /// Check if coordinates are available
  bool get hasCoordinates => latitude != null && longitude != null;

  /// Get coordinates as a formatted string
  String get coordinatesString {
    if (!hasCoordinates) return 'No coordinates';
    return '${latitude!.toStringAsFixed(6)}, ${longitude!.toStringAsFixed(6)}';
  }

  /// Create a copy with updated fields
  LocationEntity copyWith({
    int? locationId,
    int? regionId,
    int? districtId,
    int? wardId,
    int? userLocationId,
    bool? isPrimary,
    String? regionName,
    String? districtName,
    String? wardName,
    String? streetName,
    double? latitude,
    double? longitude,
    String? addressDetails,
  }) {
    return LocationEntity(
      locationId: locationId ?? this.locationId,
      regionId: regionId ?? this.regionId,
      districtId: districtId ?? this.districtId,
      wardId: wardId ?? this.wardId,
      userLocationId: userLocationId ?? this.userLocationId,
      isPrimary: isPrimary ?? this.isPrimary,
      regionName: regionName ?? this.regionName,
      districtName: districtName ?? this.districtName,
      wardName: wardName ?? this.wardName,
      streetName: streetName ?? this.streetName,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      addressDetails: addressDetails ?? this.addressDetails,
    );
  }

  /// Convert to a map for API requests
  Map<String, dynamic> toMap() {
    return {
      'location_id': locationId,
      'region_id': regionId,
      'district_id': districtId,
      'ward_id': wardId,
      'is_primary': isPrimary,
      'region_name': regionName,
      'district_name': districtName,
      'ward_name': wardName,
      if (streetName != null) 'street_name': streetName,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (addressDetails != null) 'address_details': addressDetails,
    };
  }

  /// Convert to a simplified map for farmer registration
  Map<String, dynamic> toFarmerRegistrationMap() {
    return {
      'location_id': locationId,
      'display_name': displayName,
    };
  }

  // ========================================
  // COMPARISON METHODS
  // ========================================

  /// Check if this location matches another by ID
  bool matchesId(int otherLocationId) {
    return locationId == otherLocationId;
  }

  /// Check if this location has same hierarchy as another
  bool hasSameHierarchy(LocationEntity other) {
    return regionId == other.regionId &&
           districtId == other.districtId &&
           wardId == other.wardId;
  }

  // ========================================
  // EQUATABLE
  // ========================================

  @override
  List<Object?> get props => [
        locationId,
        regionId,
        districtId,
        wardId,
        userLocationId,
        isPrimary,
        regionName,
        districtName,
        wardName,
        streetName,
        latitude,
        longitude,
        addressDetails,
      ];

  @override
  String toString() {
    return 'LocationEntity('
        'id: $locationId, '
        'display: "$displayName", '
        'primary: $isPrimary'
        ')';
  }

  // ========================================
  // STATIC UTILITY METHODS
  // ========================================

  /// Sort locations by primary status then alphabetically
  static List<LocationEntity> sortLocations(List<LocationEntity> locations) {
    final sorted = List<LocationEntity>.from(locations);
    sorted.sort((a, b) {
      // Primary locations first
      if (a.isPrimary && !b.isPrimary) return -1;
      if (!a.isPrimary && b.isPrimary) return 1;
      
      // Then by display name
      return a.displayName.compareTo(b.displayName);
    });
    return sorted;
  }

  /// Find primary location from list
  static LocationEntity? findPrimary(List<LocationEntity> locations) {
    try {
      return locations.firstWhere(
        (loc) => loc.isPrimary,
        orElse: () => locations.isNotEmpty ? locations.first : LocationEntity(
          locationId: 0,
          regionId: 0,
          districtId: 0,
          wardId: 0,
          regionName: 'No Location',
          districtName: '',
          wardName: '',
        ),
      );
    } catch (e) {
      return locations.isNotEmpty ? locations.first : null;
    }
  }

  /// Check if location ID exists in list
  static bool containsId(List<LocationEntity> locations, int locationId) {
    return locations.any((loc) => loc.locationId == locationId);
  }
}