// lib/features/farmer/livestock/data/models/dropdown_model.dart (UPDATED)

// The repository should handle the entity conversion.
class DropdownModel {
  // Use properties that match the top-level keys inside the "data" map of the API response
  final List<dynamic> species;
  final List<dynamic> breeds;
  final List<dynamic> parents;

  const DropdownModel({
    required this.species,
    required this.breeds,
    required this.parents,
  });

  factory DropdownModel.fromJson(Map<String, dynamic> json) {
    return DropdownModel(
      // ⭐ FIX: Use null-aware operator (??) to default to an empty list if null
      species: json['species'] as List? ?? [],
      breeds: json['breeds'] as List? ?? [],
      parents: json['parents'] as List? ?? [],
    );
  }
}