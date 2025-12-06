// lib/features/auth/data/models/location_model.dart

import 'package:farm_manager_app/features/auth/data/domain/entities/location_entity.dart';

/// Data model for parsing location data from API responses
/// Implements the new simplified LocationEntity structure
class LocationModel extends LocationEntity {
  const LocationModel({
    required super.locationId,
    required super.regionId,
    required super.districtId,
    required super.wardId,
    super.userLocationId,
    super.isPrimary = false,
    required super.regionName,
    required super.districtName,
    required super.wardName,
    super.streetName,
    super.latitude,
    super.longitude,
    super.addressDetails,
  }) : super();


  @override
  LocationEntity toEntity() {
    return LocationEntity(
      locationId: locationId,
      regionId: regionId,
      districtId: districtId,
      wardId: wardId,
      userLocationId: userLocationId,
      isPrimary: isPrimary,
      regionName: regionName,
      districtName: districtName,
      wardName: wardName,
      streetName: streetName,
      latitude: latitude,
      longitude: longitude,
      addressDetails: addressDetails,
    );
  }

  /// Parse location from API response
  factory LocationModel.fromJson(Map<String, dynamic> json) {
    try {
      // Determine response format and get the core location data map
      final hasNestedLocation = json.containsKey('location');
      final locationData = hasNestedLocation 
          ? json['location'] as Map<String, dynamic>
          : json;

      // Access deeply nested objects for names (e.g., location.region)
      final regionObject = locationData['region'] as Map<String, dynamic>?;
      final districtObject = locationData['district'] as Map<String, dynamic>?;
      final wardObject = locationData['ward'] as Map<String, dynamic>?;

      // -----------------------------------------------------------
      // 1. Parse IDs
      // -----------------------------------------------------------
      final locationId = _parseInt(
        locationData['id'] ?? 
        locationData['location_id'] ?? 
        json['location_id']
      );

      final regionId = _parseInt(locationData['region_id']);
      final districtId = _parseInt(locationData['district_id']);
      final wardId = _parseInt(locationData['ward_id']);

      // -----------------------------------------------------------
      // 2. Parse Display Names (Robust Check)
      // Checks 1. Nested Object -> 2. Flat LocationData -> 3. Fallback
      // -----------------------------------------------------------
      
      final regionName = (regionObject?['region_name']?.toString() ??
                          locationData['region_name']?.toString() ??
                          'Unknown Region');
                          
      final districtName = (districtObject?['district_name']?.toString() ??
                            locationData['district_name']?.toString() ??
                            'Unknown District');
                            
      final wardName = (wardObject?['ward_name']?.toString() ??
                        locationData['ward_name']?.toString() ??
                        'Unknown Ward');

      // -----------------------------------------------------------
      // 3. Parse Optional Fields
      // -----------------------------------------------------------
      final streetName = locationData['street_id'] == null ? null : locationData['street_name']?.toString();
      final latitude = _parseDouble(locationData['latitude']);
      final longitude = _parseDouble(locationData['longitude']);
      final addressDetails = locationData['address_details']?.toString();

      // Parse pivot table fields if available
      final userLocationId = hasNestedLocation 
          ? _parseNullableInt(json['id']) // UserLocation ID from pivot table
          : null;
      
      // Handle bool or int (0/1) for is_primary
      final isPrimary = (json['is_primary'] as bool?) ?? 
                       (json['is_primary'] == 1) ??
                       false;

      // Create and return the model
      return LocationModel(
        locationId: locationId,
        regionId: regionId,
        districtId: districtId,
        wardId: wardId,
        userLocationId: userLocationId,
        isPrimary: isPrimary,
        regionName: regionName,
        districtName: districtName,
        wardName: wardName,
        streetName: streetName,
        latitude: latitude,
        longitude: longitude,
        addressDetails: addressDetails,
      );

    } catch (e, stackTrace) {
      print('❌ Error parsing LocationModel: $e');
      print('   JSON keys: ${json.keys.toList()}');
      print('   Stack: $stackTrace');
      
      // Return a fallback model to prevent crashes
      return LocationModel(
        locationId: _parseInt(json['id'] ?? json['location_id'] ?? 0),
        regionId: 0,
        districtId: 0,
        wardId: 0,
        regionName: 'Unknown Region (Parse Error)', 
        districtName: 'Unknown District (Parse Error)',
        wardName: 'Unknown Ward (Parse Error)',
      );
    }
  }

  /// Parse multiple locations from API response list
  static List<LocationEntity> parseList(dynamic data) {
    try {
      if (data == null) return [];
      
      // Extract the list from response
      final List<dynamic>? items = data is Map<String, dynamic>
          ? data['data'] as List<dynamic>?
          : data as List<dynamic>?;
      
      if (items == null || items.isEmpty) {
        print('⚠️ No location data found in response');
        return [];
      }

      print('📊 Parsing ${items.length} location(s) from API response');
      
      final locations = items.map((item) {
        try {
          if (item is Map<String, dynamic>) {
            return LocationModel.fromJson(item);
          } else if (item is Map) {
            return LocationModel.fromJson(item.cast<String, dynamic>());
          } else {
            print('⚠️ Skipping invalid location item: $item');
            return null;
          }
        } catch (e) {
          print('⚠️ Failed to parse location item: $e');
          return null;
        }
      }).whereType<LocationModel>().toList();

      print('✅ Successfully parsed ${locations.length} location(s)');
      
      return locations;
      
    } catch (e, stackTrace) {
      print('❌ Error parsing location list: $e');
      print('   Stack: $stackTrace');
      return [];
    }
  }

  /// Helper method to safely parse int values
  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) {
      final parsed = int.tryParse(value);
      if (parsed != null) return parsed;
    }
    if (value is double) return value.toInt();
    return 0;
  }

  /// Helper method to safely parse nullable int values
  static int? _parseNullableInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) {
      final parsed = int.tryParse(value);
      if (parsed != null) return parsed;
    }
    if (value is double) return value.toInt();
    return null;
  }

  /// Helper method to safely parse double values
  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      final parsed = double.tryParse(value);
      if (parsed != null) return parsed;
    }
    return null;
  }

  /// Convert to JSON for API requests
  Map<String, dynamic> toJson() {
    return {
      'location_id': locationId,
      'region_id': regionId,
      'district_id': districtId,
      'ward_id': wardId,
      'is_primary': isPrimary,
      'region_name': regionName,
      'district_name': districtName,
      'ward_name': wardName,
      if (userLocationId != null) 'id': userLocationId,
      if (streetName != null) 'street_name': streetName,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (addressDetails != null) 'address_details': addressDetails,
    };
  }

  /// Convert to a simplified map for farmer registration
  Map<String, dynamic> toRegistrationJson() {
    return {
      'location_id': locationId,
      'region_id': regionId,
      'district_id': districtId,
      'ward_id': wardId,
    };
  }

  /// Create a LocationModel from a LocationEntity
  factory LocationModel.fromEntity(LocationEntity entity) {
    return LocationModel(
      locationId: entity.locationId,
      regionId: entity.regionId,
      districtId: entity.districtId,
      wardId: entity.wardId,
      userLocationId: entity.userLocationId,
      isPrimary: entity.isPrimary,
      regionName: entity.regionName,
      districtName: entity.districtName,
      wardName: entity.wardName,
      streetName: entity.streetName,
      latitude: entity.latitude,
      longitude: entity.longitude,
      addressDetails: entity.addressDetails,
    );
  }

  /// Get a display string for debugging
  @override
  String toString() {
    return 'LocationModel('
        'id: $locationId, '
        'display: "$displayName", '
        'primary: $isPrimary, '
        'coords: ${hasCoordinates ? coordinatesString : "none"}'
        ')';
  }

  /// Get a short string for logging
  String toShortString() {
    return '$locationId: $displayName${isPrimary ? " ★" : ""}';
  }
}