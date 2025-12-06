// lib/features/auth/data/domain/entities/user_entity.dart

import 'package:equatable/equatable.dart';
import 'package:farm_manager_app/features/auth/data/domain/entities/location_entity.dart';

/// Domain entity representing a user in the system
/// Contains user profile info, authentication token, and associated locations
class UserEntity extends Equatable {
  // ========================================
  // BASIC USER FIELDS
  // ========================================
  
  /// Unique user ID
  final int id;
  
  /// User's first name
  final String firstname;
  
  /// User's last name
  final String lastname;
  
  /// User's email (optional - can be null)
  final String? email;
  
  /// User's phone number
  final String phoneNumber;
  
  /// Username for login
  final String username;
  
  /// User's role (e.g., "farmer", "admin", "vet")
  final String role;
  
  // ========================================
  // AUTHENTICATION
  // ========================================
  
  /// JWT authentication token (null if user fetched without login)
  final String? token;
  
  // ========================================
  // LOCATION FIELDS
  // ========================================
  
  /// Whether user has at least one location
  final bool hasLocation;
  
  /// ID of the user's primary location (can be null)
  final int? primaryLocationId;
  
  /// List of all user locations with full details
  /// This is populated from the /user-locations API endpoint
  final List<LocationEntity>? locations;
  
  // ========================================
  // PROFILE COMPLETION
  // ========================================
  
  /// Whether user has completed their role-specific details
  /// - For farmers: whether they've completed farm details
  /// - For vets: whether they've completed practice details
  final bool hasCompletedDetails;

  // ========================================
  // CONSTRUCTOR
  // ========================================

  const UserEntity({
    required this.id,
    required this.firstname,
    required this.lastname,
    this.email,
    required this.phoneNumber,
    required this.username,
    required this.role,
    this.token,
    required this.hasLocation,
    this.primaryLocationId,
    this.locations,
    this.hasCompletedDetails = false,
  });

  // ========================================
  // COMPUTED PROPERTIES
  // ========================================

  /// Full name (firstname + lastname)
  String get fullName => '$firstname $lastname';

  /// Display name (for UI - firstname only or full name)
  String get displayName => firstname;

  /// Check if user is authenticated (has token)
  bool get isAuthenticated => token != null && token!.isNotEmpty;

  /// Check if user has any locations
  bool get hasAnyLocations => 
      locations != null && locations!.isNotEmpty;

  /// Get primary location if it exists
  LocationEntity? get primaryLocation {
    if (locations == null || locations!.isEmpty) return null;
    
    try {
      return locations!.firstWhere(
        (loc) => loc.isPrimary,
        orElse: () => locations!.first,
      );
    } catch (e) {
      return null;
    }
  }

  /// Get the location ID that should be used (primary or first available)
  int? get defaultLocationId {
    final primary = primaryLocation;
    return primary?.locationId;
  }

  /// Check if user is a farmer
  bool get isFarmer => role.toLowerCase() == 'farmer';

  /// Check if user is a vet
  bool get isVet => role.toLowerCase() == 'vet';

  /// Check if user needs to complete their profile
  bool get needsProfileCompletion => !hasCompletedDetails;

  /// Check if user needs to add a location
  bool get needsLocation => !hasLocation || !hasAnyLocations;

  // ========================================
  // COPY WITH METHOD
  // ========================================

  UserEntity copyWith({
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
    return UserEntity(
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

  // ========================================
  // EQUATABLE
  // ========================================

  @override
  List<Object?> get props => [
        id,
        firstname,
        lastname,
        email,
        phoneNumber,
        username,
        role,
        token,
        hasLocation,
        primaryLocationId,
        locations,
        hasCompletedDetails,
      ];

  @override
  String toString() {
    return 'UserEntity('
        'id: $id, '
        'name: $fullName, '
        'role: $role, '
        'hasLocation: $hasLocation, '
        'locations: ${locations?.length ?? 0}, '
        'hasCompletedDetails: $hasCompletedDetails'
        ')';
  }
}