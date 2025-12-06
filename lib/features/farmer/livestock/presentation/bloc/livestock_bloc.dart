// lib/features/farmer/livestock/presentation/bloc/livestock_bloc.dart

import 'package:farm_manager_app/features/farmer/livestock/domain/usecases/add_livestock.dart';
import 'package:farm_manager_app/features/farmer/livestock/domain/usecases/get_all_livestock.dart';
import 'package:farm_manager_app/features/farmer/livestock/domain/usecases/get_livestock_by_id.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'livestock_event.dart';
import 'livestock_state.dart';

class LivestockBloc extends Bloc<LivestockEvent, LivestockState> {
  final GetAllLivestock getAllLivestock;
  final GetLivestockById getLivestockById;
  final AddLivestock addLivestock;

  LivestockBloc({
    required this.getAllLivestock,
    required this.getLivestockById,
    required this.addLivestock,
  }) : super(LivestockInitial()) {
    on<LoadLivestockList>(_onLoadLivestockList);
    on<LoadLivestockDetail>(_onLoadLivestockDetail);
    on<AddNewLivestock>(_onAddNewLivestock);
    // Add handlers for Update/Delete events later
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
    emit(LivestockLoading());
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
    // Note: We don't want to show loading on the list page, but we do need it
    // on the form page. This bloc instance might be used on the form page.
    emit(LivestockLoading());
    final result = await addLivestock(event.animalData);

    emit(result.fold(
      (failure) => LivestockError(failure),
      // This state should trigger a success message and then navigation back
      (newAnimal) => LivestockAdded(newAnimal),
    ));
  }
}