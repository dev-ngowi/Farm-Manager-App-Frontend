// lib/features/farmer/livestock/domain/entities/parent.dart

import 'package:equatable/equatable.dart';

class ParentEntity extends Equatable {
  final int animalId;
  final String tagNumber;
  final String sex; // ⭐ FIX: Added required 'sex' field for filtering
  final String? name;

  const ParentEntity({
    required this.animalId,
    required this.tagNumber,
    required this.sex, // ⭐ Added to constructor
    this.name,
  });

  @override
  List<Object?> get props => [animalId, tagNumber, sex, name];
}