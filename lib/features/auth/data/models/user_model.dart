// lib/features/auth/data/models/user_model.dart

import 'package:equatable/equatable.dart';
import 'package:farm_manager_app/features/auth/data/domain/entities/user_entity.dart';
import 'package:farm_manager_app/features/auth/data/domain/entities/location_entity.dart';
import 'package:farm_manager_app/features/auth/data/models/location_model.dart'; // Ensure this model exists and is imported

class UserModel extends Equatable {
  final int id;
  final String firstname;
  final String lastname;
  final String username;
  final String? email;
  final String phoneNumber; // Made non-nullable based on UserEntity
  final String role;
  // NEW: Fields required by the updated UserEntity
  final String token;
  final bool hasLocation;
  final int? primaryLocationId;
  final List<LocationModel>? locations; // Use LocationModel internally

  const UserModel({
    required this.id,
    required this.firstname,
    required this.lastname,
    required this.username,
    this.email,
    required this.phoneNumber,
    required this.role,
    // NEW required fields
    required this.token,
    required this.hasLocation,
    this.primaryLocationId,
    this.locations,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    // FIX: Map raw locations data to a list of LocationModels
    final List<LocationModel>? locationsList = (json['locations'] as List<dynamic>?)
        ?.map((locationJson) => LocationModel.fromJson(locationJson as Map<String, dynamic>))
        .toList();
        
    // FIX: Use null-coalescing and safe casting for fields that might be null or missing
    return UserModel(
      id: json['id'] as int,
      firstname: json['firstname'] as String,
      lastname: json['lastname'] as String,
      username: json['username'] as String,
      email: json['email'] as String?,
      // Assuming 'phone_number' or 'phoneNumber' is the key in the API response
      phoneNumber: json['phone_number'] as String? ?? json['phoneNumber'] as String? ?? '', 
      role: json['role'] as String,
      // NEW required fields:
      token: json['token'] as String? ?? '', // Token is crucial, default to empty string if missing
      hasLocation: json['has_location'] as bool? ?? false, // Default to false
      primaryLocationId: json['primary_location_id'] as int?,
      locations: locationsList,
    );
  }

  // FIX: Update toEntity() to provide all required parameters
  UserEntity toEntity() {
    // Map LocationModel list to LocationEntity list
    final List<LocationEntity>? locationEntities = locations
        ?.map((model) => model.toEntity())
        .toList();
        
    return UserEntity(
      id: id,
      firstname: firstname,
      lastname: lastname,
      email: email,
      phoneNumber: phoneNumber,
      username: username,
      role: role,
      token: token, // Pass the token
      hasLocation: hasLocation, // Pass the boolean
      primaryLocationId: primaryLocationId,
      locations: locationEntities, // Pass the mapped entity list
    );
  }

  // Optional: add copyWith for UserModel (useful for updating just the token)
  UserModel copyWith({
    int? id,
    String? firstname,
    String? lastname,
    String? username,
    String? email,
    String? phoneNumber,
    String? role,
    String? token,
    bool? hasLocation,
    int? primaryLocationId,
    List<LocationModel>? locations,
  }) {
    return UserModel(
      id: id ?? this.id,
      firstname: firstname ?? this.firstname,
      lastname: lastname ?? this.lastname,
      username: username ?? this.username,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      role: role ?? this.role,
      token: token ?? this.token,
      hasLocation: hasLocation ?? this.hasLocation,
      primaryLocationId: primaryLocationId ?? this.primaryLocationId,
      locations: locations ?? this.locations,
    );
  }

  @override
  // Updated props list to include essential identity fields
  List<Object?> get props => [
    id, 
    username, 
    role, 
    token, 
    hasLocation, 
    primaryLocationId, 
    locations
  ];
}