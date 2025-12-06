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