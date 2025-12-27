// lib/features/farmer/breeding/offspring/domain/entities/offspring_entity.dart

import 'package:equatable/equatable.dart';

class OffspringEntity extends Equatable {
  final dynamic id;
  final dynamic deliveryId;
  final String? temporaryTag;
  final String gender;
  final double birthWeightKg;
  final String birthCondition;
  final String colostrumIntake;
  final bool navelTreated;
  final String? notes;
  final dynamic livestockId;
  
  // Related delivery/parental data
  final String deliveryDate;
  final String deliveryType;
  final int calvingEaseScore;
  final String damTag;
  final String damName;
  final String damSpecies;
  final String? sireTag;
  final String? sireName;
  final String? registeredTag; // Tag if registered as Livestock

  const OffspringEntity({
    required this.id,
    required this.deliveryId,
    this.temporaryTag,
    required this.gender,
    required this.birthWeightKg,
    required this.birthCondition,
    required this.colostrumIntake,
    required this.navelTreated,
    this.notes,
    this.livestockId,
    required this.deliveryDate,
    required this.deliveryType,
    required this.calvingEaseScore,
    required this.damTag,
    required this.damName,
    required this.damSpecies,
    this.sireTag,
    this.sireName,
    this.registeredTag,
  });

  bool get isRegistered => livestockId != null;

  @override
  List<Object?> get props => [
        id,
        deliveryId,
        temporaryTag,
        gender,
        birthWeightKg,
        birthCondition,
        livestockId,
      ];
}

class OffspringDeliveryEntity extends Equatable {
  final dynamic id;
  final String label; // e.g., "Delivery - COW-101 (2025-09-10)"
  final String damTag;
  final String damName;
  final String deliveryDate;

  const OffspringDeliveryEntity({
    required this.id,
    required this.label,
    required this.damTag,
    required this.damName,
    required this.deliveryDate,
  });

  @override
  List<Object?> get props => [id, damTag];
}