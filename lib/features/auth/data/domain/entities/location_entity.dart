// lib/features/auth/data/domain/entities/location_entity.dart

import 'package:equatable/equatable.dart';

class LocationEntity extends Equatable {
  final int id;
  final String region;
  final String district;
  final String ward;
  final String? street;
  final double latitude;
  final double longitude;
  final String? addressDetails;
  final bool isPrimary;

  const LocationEntity({
    required this.id,
    required this.region,
    required this.district,
    required this.ward,
    this.street,
    required this.latitude,
    required this.longitude,
    this.addressDetails,
    this.isPrimary = false,
  });

  @override
  List<Object?> get props => [
        id,
        region,
        district,
        ward,
        street,
        latitude,
        longitude,
        addressDetails,
        isPrimary,
      ];
}