import 'package:equatable/equatable.dart';

class BullEntity extends Equatable {
  final int animalId;
  final String tagNumber;
  final String name;

  const BullEntity({
    required this.animalId,
    required this.tagNumber,
    required this.name,
  });

  @override
  List<Object?> get props => [animalId, tagNumber, name];
}