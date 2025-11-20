// lib/features/auth/data/domain/entities/user_entity.dart

import 'package:equatable/equatable.dart';
import 'package:farm_manager_app/features/auth/data/domain/entities/location_entity.dart'; // Import LocationEntity

class UserEntity extends Equatable {
  final int id;
  final String firstname;
  final String lastname;
  final String? email;
  final String phoneNumber;
  final String username;
  final String role;
  final String? token; // Token can be null if user is fetched without a new login
  final bool hasLocation;
  final int? primaryLocationId;
  final List<LocationEntity>? locations;
  

  const UserEntity({
    required this.id,
    required this.firstname,
    required this.lastname,
    this.email,
    required this.phoneNumber,
    required this.username,
    required this.role,
    this.token, // Changed to not be required in constructor
    this.primaryLocationId, 
    this.locations,
    required this.hasLocation,
  });

  // copyWith method
  UserEntity copyWith({
    int? id,
    String? firstname,
    String? lastname,
    String? email,
    String? phoneNumber,
    String? username,
    String? role,
    String? token,
    int? primaryLocationId, 
    List<LocationEntity>? locations, 
    bool? hasLocation, // 💡 FIX: Added 'hasLocation' to copyWith parameters
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
      primaryLocationId: primaryLocationId ?? this.primaryLocationId,
      locations: locations ?? this.locations, 
      hasLocation: hasLocation ?? this.hasLocation, // 💡 FIX: Used null-aware assignment
    );
  }

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
        primaryLocationId,
        locations,
        hasLocation,
      ];
}