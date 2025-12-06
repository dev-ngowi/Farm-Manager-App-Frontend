// lib/features/auth/data/models/user_model.dart

import 'package:farm_manager_app/features/auth/data/domain/entities/location_entity.dart';
import 'package:farm_manager_app/features/auth/data/domain/entities/user_entity.dart';
import 'package:farm_manager_app/features/auth/data/models/location_model.dart';

/// Data model for parsing user data from API responses
/// Extends UserEntity to maintain domain separation while allowing easy conversion
class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.firstname,
    required super.lastname,
    super.email,
    required super.phoneNumber,
    required super.username,
    required super.role,
    super.token,
    super.hasLocation = false,
    super.primaryLocationId,
    super.locations,
    super.hasCompletedDetails = false,
  });

  /// Parse user from various API response structures
  factory UserModel.fromJson(Map<String, dynamic> json) {
    print('👤 Parsing UserModel from JSON...');
    
    try {
      // ========================================
      // 1. EXTRACT USER OBJECT
      // ========================================
      
      Map<String, dynamic> userMap = json;
      
      // Check for nested user object
      if (json['user'] is Map<String, dynamic>) {
        userMap = json['user'] as Map<String, dynamic>;
        print('   Found user in json["user"]');
      } else if (json['data'] is Map<String, dynamic>) {
        final dataMap = json['data'] as Map<String, dynamic>;
        if (dataMap['user'] is Map<String, dynamic>) {
          userMap = dataMap['user'] as Map<String, dynamic>;
          print('   Found user in json["data"]["user"]');
        }
      }
      
      // ⭐ CRITICAL FIX: Ensure 'id' is treated as nullable during extraction 
      //                 to allow a controlled failure point.
      final int? userId = userMap['id'] as int?; 
      
      if (userId == null) {
          // If the ID is missing, it means the API returned an incomplete object.
          // We must throw a clear error or retrieve the ID from another source.
          // Since we cannot rely on the backend, we throw here.
          throw const FormatException('Required field "id" (user ID) is missing or null in the API response.');
      }
      
      print('   User ID: $userId');
      
      // ========================================
      // 2. PARSE LOCATIONS
      // ========================================
      
      List<LocationEntity> locations = [];
      
      // Try multiple location sources
      final rawLocations = 
          json['data'] ??           // /user-locations response
          json['locations'] ??      // Direct locations array
          userMap['locations'];     // User object with locations
      
      if (rawLocations is List && rawLocations.isNotEmpty) {
        print('   Found ${rawLocations.length} location(s) to parse');
        
        try {
          locations = rawLocations
              .map((item) {
                if (item is! Map<String, dynamic>) {
                  print('   ⚠️ Skipping invalid location item: $item');
                  return null;
                }
                return LocationModel.fromJson(item).toEntity();
              })
              .whereType<LocationEntity>() // Filter out null values
              .toList();
          
          print('   ✅ Successfully parsed ${locations.length} location(s)');
          
          // Log each location for debugging
          for (var loc in locations) {
            print('      → ${loc.displayName} (ID: ${loc.locationId}, Primary: ${loc.isPrimary})');
          }
        } catch (e, stackTrace) {
          print('   ❌ Error parsing locations: $e');
          print('   Stack: $stackTrace');
          // Continue with empty locations list
          locations = [];
        }
      } else {
        print('   No locations found in response');
      }
      
      // ========================================
      // 3. DETERMINE PRIMARY LOCATION
      // ========================================
      
      int? primaryLocationId;
      
      if (locations.isNotEmpty) {
        try {
          final primaryLoc = locations.firstWhere(
            (loc) => loc.isPrimary,
            orElse: () => locations.first,
          );
          primaryLocationId = primaryLoc.locationId;
          print('   Primary location ID: $primaryLocationId');
        } catch (e) {
          print('   ⚠️ Could not determine primary location: $e');
        }
      }
      
      // ========================================
      // 4. EXTRACT TOKEN
      // ========================================
      
      final token = userMap['token'] as String? ?? 
                   json['access_token'] as String? ?? 
                   json['token'] as String?;
      
      if (token != null) {
        print('   ✅ Token found');
      }
      
      // ========================================
      // 5. CREATE USER MODEL
      // ========================================
      
      final user = UserModel(
        // Use the validated userId
        id: userId, 
        
        // Provide defensive fallbacks for required String fields
        firstname: userMap['firstname'] as String? ?? 
                  userMap['first_name'] as String? ?? 
                  'N/A', // ⭐️ FIX: Changed default from '' to 'N/A' for clarity/safety
        lastname: userMap['lastname'] as String? ?? 
                 userMap['last_name'] as String? ?? 
                 'N/A', // ⭐️ FIX: Changed default from '' to 'N/A'
        
        email: userMap['email'] as String?,
        
        phoneNumber: userMap['phone_number'] as String? ?? 
                    userMap['phoneNumber'] as String? ?? 
                    'N/A', // ⭐️ FIX: Changed default from '' to 'N/A'
                    
        username: userMap['username'] as String? ?? 
                 userMap['email'] as String? ?? 
                 'user$userId',
                 
        role: userMap['role'] as String? ?? 
             userMap['user_type'] as String? ?? 
             'farmer',
             
        token: token,
        hasLocation: locations.isNotEmpty,
        primaryLocationId: primaryLocationId,
        locations: locations.isNotEmpty ? locations : null,
        
        hasCompletedDetails: userMap['has_completed_details'] == true || 
                           userMap['has_completed_details'] == 1 ||
                           userMap['hasCompletedDetails'] == true,
      );
      
      print('✅ UserModel parsed successfully');
      print('   Name: ${user.fullName}');
      print('   Role: ${user.role}');
      print('   Locations: ${user.locations?.length ?? 0}');
      print('   Has completed details: ${user.hasCompletedDetails}');
      
      return user;
      
    } catch (e, stackTrace) {
      print('❌ Error parsing UserModel: $e');
      print('   JSON: $json');
      print('   Stack: $stackTrace');
      rethrow;
    }
  }

  /// Convert to JSON for API requests
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstname': firstname,
      'lastname': lastname,
      'email': email,
      'phone_number': phoneNumber,
      'username': username,
      'role': role,
      'token': token,
      'has_completed_details': hasCompletedDetails,
      'has_location': hasLocation,
      'primary_location_id': primaryLocationId,
      'locations': locations?.map((loc) {
        if (loc is LocationModel) {
          return loc.toJson();
        }
        // If it's a LocationEntity, convert to LocationModel first
        return LocationModel.fromEntity(loc).toJson();
      }).toList(),
    };
  }

  /// Convert model to entity
  @override
  UserEntity toEntity() => this;

  /// Create a UserModel from a UserEntity
  factory UserModel.fromEntity(UserEntity entity) {
    return UserModel(
      id: entity.id,
      firstname: entity.firstname,
      lastname: entity.lastname,
      email: entity.email,
      phoneNumber: entity.phoneNumber,
      username: entity.username,
      role: entity.role,
      token: entity.token,
      hasLocation: entity.hasLocation,
      primaryLocationId: entity.primaryLocationId,
      locations: entity.locations,
      hasCompletedDetails: entity.hasCompletedDetails,
    );
  }

  /// Create a copy with updated fields
  UserModel copyWithModel({
    int? id,
    String? firstname,
    String? lastname,
    String? email,
    String? phoneNumber,
    String? username,
    String? role,
    String? token,
    bool? hasLocation,
    int? primaryLocationId,
    List<LocationEntity>? locations,
    bool? hasCompletedDetails,
  }) {
    return UserModel(
      id: id ?? this.id,
      firstname: firstname ?? this.firstname,
      lastname: lastname ?? this.lastname,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      username: username ?? this.username,
      role: role ?? this.role,
      token: token ?? this.token,
      hasLocation: hasLocation ?? this.hasLocation,
      primaryLocationId: primaryLocationId ?? this.primaryLocationId,
      locations: locations ?? this.locations,
      hasCompletedDetails: hasCompletedDetails ?? this.hasCompletedDetails,
    );
  }

  @override
  String toString() {
    return 'UserModel('
        'id: $id, '
        'name: $fullName, '
        'role: $role, '
        'locations: ${locations?.length ?? 0}, '
        'hasCompletedDetails: $hasCompletedDetails'
        ')';
  }
}