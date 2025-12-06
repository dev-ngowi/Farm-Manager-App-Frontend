// lib/features/farmer/livestock/domain/entities/dropdown_data.dart

import 'package:equatable/equatable.dart';
import 'package:farm_manager_app/features/farmer/livestock/domain/entities/breed.dart';
import 'package:farm_manager_app/features/farmer/livestock/domain/entities/parent.dart';
import 'package:farm_manager_app/features/farmer/livestock/domain/entities/species.dart';

/// Holds all required dynamic data for filling livestock-related forms.
class DropdownData extends Equatable {
  final List<SpeciesEntity> species;
  final List<BreedEntity> breeds;
  final List<ParentEntity> sires; // Expected by constructor
  final List<ParentEntity> dams; // Expected by constructor

  const DropdownData({
    required this.species,
    required this.breeds,
    required this.sires,
    required this.dams,
  });

  @override
  List<Object> get props => [species, breeds, sires, dams];
}