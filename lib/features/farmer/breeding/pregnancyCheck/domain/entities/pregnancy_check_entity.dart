// lib/features/farmer/breeding/pregnancy_check/domain/entities/pregnancy_check_entity.dart

import 'package:equatable/equatable.dart';

class PregnancyCheckEntity extends Equatable {
  final int id;
  final int inseminationId;
  final DateTime checkDate;
  final String method;
  final String result;
  final int? fetusCount;
  final DateTime? expectedDeliveryDate;
  final int? vetId;
  final String? vetName;
  final String notes;
  final String damName;
  final String damTagNumber;
  final PregnancyCheckInseminationEntity? insemination; // For relation
  final PregnancyCheckVetEntity? vet; // For relation

  const PregnancyCheckEntity({
    required this.id,
    required this.inseminationId,
    required this.checkDate,
    required this.method,
    required this.result,
    this.fetusCount,
    this.expectedDeliveryDate,
    this.vetId,
    this.vetName,
    required this.notes,
    required this.damName,
    required this.damTagNumber,
    this.insemination,
    this.vet,
  });

  @override
  List<Object?> get props => [id, inseminationId, result, checkDate];
}

// Supporting entity for the Insemination dropdown
class PregnancyCheckInseminationEntity extends Equatable {
  final int id;
  final String damName;
  final String damTagNumber;

  const PregnancyCheckInseminationEntity({
    required this.id, 
    required this.damName, 
    required this.damTagNumber,
  });

  @override
  List<Object?> get props => [id];
}

// Supporting entity for the Vet/Technician dropdown
class PregnancyCheckVetEntity extends Equatable {
  final int id;
  final String name;

  const PregnancyCheckVetEntity({required this.id, required this.name});

  @override
  List<Object?> get props => [id];
}