import 'package:equatable/equatable.dart';
import 'breed.dart';
import 'species.dart';
import 'parent.dart';

class LivestockEntity extends Equatable {
  final int animalId;
  final int speciesId;
  final int breedId;
  final String tagNumber;
  final String? name;
  final String sex; // 'Male' or 'Female'
  final DateTime dateOfBirth;
  final double weightAtBirthKg;
  final String status; // 'Active', 'Sold', 'Dead', 'Stolen'
  final String? notes;

  // ⭐ PURCHASE DETAILS (Corrected to camelCase)
  final DateTime? purchaseDate;
  final double? purchaseCost;
  final String? source;

  // Relations
  final SpeciesEntity? species;
  final BreedEntity? breed;
  final ParentEntity? sire;
  final ParentEntity? dam;

  // Controller 'show' and 'index' additional fields (used for list/detail screens)
  final int? milkYieldsCount;
  final int? offspringAsDamCount;
  final int? offspringAsSireCount;
  final int? incomeCount;
  final int? expensesCount;

  const LivestockEntity({
    required this.animalId,
    required this.speciesId,
    required this.breedId,
    required this.tagNumber,
    this.name,
    required this.sex,
    required this.dateOfBirth,
    required this.weightAtBirthKg,
    required this.status,
    this.notes,
    // Purchase fields
    this.purchaseDate,
    this.purchaseCost,
    this.source,
    // Relations
    this.species,
    this.breed,
    this.sire,
    this.dam,
    // Count fields
    this.milkYieldsCount,
    this.offspringAsDamCount,
    this.offspringAsSireCount,
    this.incomeCount,
    this.expensesCount,
  });

  @override
  List<Object?> get props => [
        animalId,
        speciesId,
        breedId,
        tagNumber,
        name,
        sex,
        dateOfBirth,
        weightAtBirthKg,
        status,
        notes,
        purchaseDate,
        purchaseCost,
        source,
        species,
        breed,
        sire,
        dam,
        milkYieldsCount,
        offspringAsDamCount,
        offspringAsSireCount,
        incomeCount,
        expensesCount,
      ];
}