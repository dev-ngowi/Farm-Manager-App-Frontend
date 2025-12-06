class BullEntity {
  final int animalId;
  final String tagNumber;
  final String name;
  final int? speciesId; 
  
  BullEntity({
    required this.animalId, 
    required this.tagNumber, 
    required this.name, 
    this.speciesId
  });


  String get displayName => '$tagNumber - $name';
}