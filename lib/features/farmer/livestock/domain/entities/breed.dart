import 'package:equatable/equatable.dart';

class BreedEntity extends Equatable {
  final int id;
  final String breedName;
  final int speciesId; // Non-nullable, so DTO must provide a value
  final String? purpose; 

  const BreedEntity({
    required this.id,
    required this.breedName,
    required this.speciesId,
    this.purpose,
  });

  @override
  List<Object?> get props => [id, breedName, speciesId, purpose];
}