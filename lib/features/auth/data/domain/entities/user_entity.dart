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
  // PROFILE/APPROVAL FIELDS
  // ========================================
  
  /// Whether the user has completed their profile details form
  final bool hasCompletedDetails;
  /// 🎯 NEW: Whether the user's submitted details have been approved by an admin/vet
  final bool hasDetailsApproved; 
  
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
    this.hasLocation = false,
    this.primaryLocationId,
    this.locations,
    this.hasCompletedDetails = false,
    this.hasDetailsApproved = false, // 🎯 NEW DEFAULT VALUE
  });

  // ========================================
  // GETTERS
  // ========================================

  String get fullName => '$firstname $lastname';

  // ========================================
  // COPYWITH METHOD (Updated)
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
    bool? hasDetailsApproved, // 🎯 NEW COPYWITH PARAMETER
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
      hasDetailsApproved: hasDetailsApproved ?? this.hasDetailsApproved, // 🎯 NEW
    );
  }

  // ========================================
  // EQUATABLE (Updated)
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
        hasDetailsApproved, // 🎯 NEW PROP
      ];

  @override
  String toString() {
    return 'UserEntity('
        'id: $id, '
        'name: $fullName, '
        'role: $role, '
        'hasLocation: $hasLocation, '
        'locations: ${locations?.length ?? 0}, '
        'hasCompletedDetails: $hasCompletedDetails, '
        'hasDetailsApproved: $hasDetailsApproved)'; // 🎯 NEW TOSTRING
  }
}