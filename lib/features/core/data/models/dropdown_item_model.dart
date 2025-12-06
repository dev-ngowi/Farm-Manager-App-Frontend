
import 'package:equatable/equatable.dart';

class DropdownItemModel extends Equatable {
  final dynamic value; // Typically int (ID) or String (Code)
  final String label;

  const DropdownItemModel({
    required this.value,
    required this.label,
  });

  @override
  List<Object?> get props => [value, label];
}