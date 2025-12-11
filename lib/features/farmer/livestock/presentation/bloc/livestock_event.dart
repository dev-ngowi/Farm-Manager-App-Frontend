import 'package:equatable/equatable.dart';

abstract class LivestockEvent extends Equatable {
  const LivestockEvent();

  @override
  List<Object> get props => [];
}

// --- List Events ---
class LoadLivestockList extends LivestockEvent {
  final Map<String, dynamic>? filters;

  const LoadLivestockList({this.filters});

  @override
  List<Object> get props => [filters ?? {}];
}

// --- Detail Events ---
class LoadLivestockDetail extends LivestockEvent {
  final int animalId;

  const LoadLivestockDetail(this.animalId);

  @override
  List<Object> get props => [animalId];
}

// --- Add/CRUD Events ---
class AddNewLivestock extends LivestockEvent {
  final Map<String, dynamic> animalData;

  const AddNewLivestock(this.animalData);

  @override
  List<Object> get props => [animalData];
}

class UpdateLivestock extends LivestockEvent {
  final int animalId;
  final Map<String, dynamic> animalData;

  const UpdateLivestock({required this.animalId, required this.animalData});

  @override
  List<Object> get props => [animalId, animalData];
}

// ⭐ NEW: Delete Event (useful for a delete button on detail page)
class DeleteLivestock extends LivestockEvent {
  final int animalId;

  const DeleteLivestock(this.animalId);

  @override
  List<Object> get props => [animalId];
}