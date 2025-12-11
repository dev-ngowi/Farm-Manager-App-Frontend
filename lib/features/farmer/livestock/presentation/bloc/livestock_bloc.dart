// lib/features/farmer/livestock/presentation/bloc/livestock_bloc.dart

import 'package:farm_manager_app/features/farmer/livestock/domain/usecases/add_livestock.dart';
import 'package:farm_manager_app/features/farmer/livestock/domain/usecases/get_all_livestock.dart';
import 'package:farm_manager_app/features/farmer/livestock/domain/usecases/get_livestock_by_id.dart';
// ⭐ FIX: Alias UseCases to avoid conflict with Events
import 'package:farm_manager_app/features/farmer/livestock/domain/usecases/update_livestock.dart' as usecase;
import 'package:farm_manager_app/features/farmer/livestock/domain/usecases/delete_livestock.dart' as usecase;

import 'package:flutter_bloc/flutter_bloc.dart';
// ⭐ FIX: Removed 'hide' clause so UpdateLivestock and DeleteLivestock events are available
import 'livestock_event.dart'; 
import 'livestock_state.dart';

class LivestockBloc extends Bloc<LivestockEvent, LivestockState> {
  final GetAllLivestock getAllLivestock;
  final GetLivestockById getLivestockById;
  final AddLivestock addLivestock;
  // ⭐ FIX: Use aliased types for UseCases
  final usecase.UpdateLivestock updateLivestock; 
  final usecase.DeleteLivestock deleteLivestock; 

  LivestockBloc({
    required this.getAllLivestock,
    required this.getLivestockById,
    required this.addLivestock,
    required this.updateLivestock,
    required this.deleteLivestock,
  }) : super(LivestockInitial()) {
    on<LoadLivestockList>(_onLoadLivestockList);
    on<LoadLivestockDetail>(_onLoadLivestockDetail);
    on<AddNewLivestock>(_onAddNewLivestock);
    on<UpdateLivestock>(_onUpdateLivestock); 
    on<DeleteLivestock>(_onDeleteLivestock); 
  }

  Future<void> _onLoadLivestockList(
    LoadLivestockList event,
    Emitter<LivestockState> emit,
  ) async {
    emit(LivestockLoading());
    final result = await getAllLivestock(LivestockParams(filters: event.filters));
    
    emit(result.fold(
      (failure) => LivestockError(failure), 
      (livestock) => LivestockListLoaded(livestock),
    ));
  }

  Future<void> _onLoadLivestockDetail(
    LoadLivestockDetail event,
    Emitter<LivestockState> emit,
  ) async {
    // Note: When updating, the form will also trigger a loading state
    // We only want to load details when specifically asked for.
    if (state is! LivestockUpdated) {
        emit(LivestockLoading());
    }
    
    final result = await getLivestockById(event.animalId);

    emit(result.fold(
      (failure) => LivestockError(failure),
      (animal) => LivestockDetailLoaded(animal),
    ));
  }

  Future<void> _onAddNewLivestock(
    AddNewLivestock event,
    Emitter<LivestockState> emit,
  ) async {
    emit(LivestockLoading());
    final result = await addLivestock(event.animalData);

    emit(result.fold(
      (failure) => LivestockError(failure),
      (newAnimal) => LivestockAdded(newAnimal),
    ));
  }

  // ⭐ New Handler for Update
  Future<void> _onUpdateLivestock(
    UpdateLivestock event,
    Emitter<LivestockState> emit,
  ) async {
    emit(LivestockLoading()); // Indicates that the update operation is in progress
    // ⭐ FIX: Use aliased parameter object for the UseCase call
    final result = await updateLivestock(usecase.UpdateLivestockParams(
      animalId: event.animalId,
      animalData: event.animalData,
    ));

    emit(result.fold(
      (failure) => LivestockError(failure),
      (animal) {
        // Broadcast success and return the updated animal
        return LivestockUpdated(animal);
      },
    ));
  }
  
  // ⭐ New Handler for Delete
  Future<void> _onDeleteLivestock(
    DeleteLivestock event,
    Emitter<LivestockState> emit,
  ) async {
    emit(LivestockLoading()); // Indicates that the delete operation is in progress
    final result = await deleteLivestock(event.animalId);

    emit(result.fold(
      (failure) => LivestockError(failure),
      (_) {
        // Broadcast success
        return const LivestockDeleted();
      },
    ));
  }
}