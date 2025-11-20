// lib/features/auth/data/models/location_model.dart

import 'package:farm_manager_app/features/auth/data/domain/entities/location_entity.dart';

class LocationModel extends LocationEntity {
  const LocationModel({
    required super.id,
    required super.region,
    required super.district,
    required super.ward,
    super.street,
    required super.latitude,
    required super.longitude,
    super.addressDetails,
    super.isPrimary,
  });

  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
      id: json['id'] as int,
      region: json['region'] as String,
      district: json['district'] as String,
      ward: json['ward'] as String,
      street: json['street'] as String?,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      addressDetails: json['address_details'] as String?,
      isPrimary: json['is_primary'] as bool? ?? false,
    );
  }

  LocationEntity toEntity() => this;
}