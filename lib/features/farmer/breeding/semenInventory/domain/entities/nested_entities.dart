import 'package:equatable/equatable.dart';

// Used for the nested 'bull' relationship
class SemenAnimalEntity extends Equatable {
  final int animalId;
  final String tagNumber;
  final String name;

  const SemenAnimalEntity({
    required this.animalId,
    required this.tagNumber,
    required this.name,
  });

  @override
  List<Object?> get props => [animalId, tagNumber, name];
}

// Used for the nested 'breed' relationship (minimal)
class SemenBreedEntity extends Equatable {
  final int id;
  final String breedName;

  const SemenBreedEntity({
    required this.id,
    required this.breedName,
  });

  @override
  List<Object?> get props => [id, breedName];
}