// lib/features/farmer/breeding/delivery/domain/entities/delivery_entity.dart

import 'package:equatable/equatable.dart';

class DeliveryEntity extends Equatable {
  final dynamic id; // Changed to dynamic for consistency with Repository
  final dynamic inseminationId;
  final DateTime actualDeliveryDate;
  final String deliveryType;
  final int calvingEaseScore;
  final int totalBorn;
  final int liveBorn;
  final int stillborn;
  final String damConditionAfter;
  final String notes;
  final String damName;
  final String damTagNumber;
  final List<OffspringEntity> offspring;

  const DeliveryEntity({
    required this.id,
    required this.inseminationId,
    required this.actualDeliveryDate,
    required this.deliveryType,
    required this.calvingEaseScore,
    required this.totalBorn,
    required this.liveBorn,
    required this.stillborn,
    required this.damConditionAfter,
    required this.notes,
    required this.damName,
    required this.damTagNumber,
    required this.offspring,
  });

  @override
  List<Object?> get props => [
        id,
        inseminationId,
        actualDeliveryDate,
        deliveryType,
        offspring, // Added to ensure UI updates if offspring list changes
      ];
}

class OffspringEntity extends Equatable {
  final dynamic id;
  final String gender;
  final String birthCondition;
  final double birthWeightKg;
  final String colostrumIntake;
  final bool navelTreated;
  final String? temporaryTag;
  final String? notes;

  const OffspringEntity({
    this.id,
    required this.gender,
    required this.birthCondition,
    required this.birthWeightKg,
    required this.colostrumIntake,
    required this.navelTreated,
    this.temporaryTag,
    this.notes,
  });

  @override
  List<Object?> get props => [
        id,
        gender,
        birthCondition,
        birthWeightKg,
        temporaryTag,
      ];
}

class DeliveryInseminationEntity extends Equatable {
  final dynamic id;
  final String damName;
  final String damTagNumber;
  final DateTime? expectedDeliveryDate;

  const DeliveryInseminationEntity({
    required this.id,
    required this.damName,
    required this.damTagNumber,
    this.expectedDeliveryDate,
  });

  @override
  List<Object?> get props => [id, damTagNumber];
}