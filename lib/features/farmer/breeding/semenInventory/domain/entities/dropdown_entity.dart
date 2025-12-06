// lib/features/farmer/breeding/semenInventory/domain/entities/dropdown_entity.dart

import 'package:equatable/equatable.dart';

/// A simple entity representing a key-value pair suitable for use in
/// dropdown menus, selectors, or radio button lists in the UI layer.
class DropdownEntity extends Equatable {
  /// The unique identifier or value to be used when selecting the item (e.g., the ID).
  final String value;

  /// The human-readable label to display in the UI (e.g., 'Straw Code - Bull Name').
  final String label;

  /// ⭐ FIX: Add the 'type' field to distinguish between different dropdowns (bulls vs. breeds).
  final String type; 

  const DropdownEntity({
    required this.value,
    required this.label,
    required this.type, // Make 'type' required
  });

  @override
  List<Object?> get props => [value, label, type];
}