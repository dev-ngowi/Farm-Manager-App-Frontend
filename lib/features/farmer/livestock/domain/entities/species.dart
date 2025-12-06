// lib/features/farmer/livestock/domain/entities/species.dart

import 'package:equatable/equatable.dart';

class SpeciesEntity extends Equatable {
  final int id;
  final String speciesName;

  const SpeciesEntity({
    required this.id,
    required this.speciesName,
  });

  @override
  List<Object?> get props => [id, speciesName];
}