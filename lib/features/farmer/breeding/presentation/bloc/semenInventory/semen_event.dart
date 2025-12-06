import 'package:equatable/equatable.dart';
import 'package:farm_manager_app/features/farmer/breeding/semenInventory/domain/entities/semen_entity.dart';

abstract class SemenEvent extends Equatable {
  const SemenEvent();

  @override
  List<Object> get props => [];
}

/// Fetches the main semen inventory list, optionally applying filters.
class SemenLoadInventory extends SemenEvent {
  final bool? availableOnly;
  final String? breedId;

  const SemenLoadInventory({this.availableOnly, this.breedId});

  @override
  List<Object> get props => [availableOnly ?? false, breedId ?? ''];
}

/// Fetches the details for a specific semen record by ID.
class SemenLoadDetails extends SemenEvent {
  final String id;

  const SemenLoadDetails(this.id);

  @override
  List<Object> get props => [id];
}

/// Triggers the creation of a new semen record.
class SemenCreate extends SemenEvent {
  final SemenEntity semen;

  const SemenCreate(this.semen);

  @override
  List<Object> get props => [semen];
}

/// Triggers the update of an existing semen record.
class SemenUpdate extends SemenEvent {
  final String id;
  final SemenEntity semen;

  const SemenUpdate({required this.id, required this.semen});

  @override
  List<Object> get props => [id, semen];
}

/// Triggers the deletion of a semen record.
class SemenDelete extends SemenEvent {
  final String id;

  const SemenDelete(this.id);

  @override
  List<Object> get props => [id];
}

/// Fetches the list of available semen (for use in dropdowns, e.g., in an Insemination form).
class SemenLoadDropdowns extends SemenEvent {
  const SemenLoadDropdowns();
}