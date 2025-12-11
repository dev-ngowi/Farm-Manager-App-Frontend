// Import dartz for Either
import 'package:farm_manager_app/core/error/failure.dart'; // Import Failure
// Import Entity
import 'package:farm_manager_app/features/farmer/breeding/Insemination/domain/repositories/insemination_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'insemination_event.dart';
import 'insemination_state.dart';

class InseminationBloc extends Bloc<InseminationEvent, InseminationState> {
  final InseminationRepository repository;

  InseminationBloc({required this.repository}) : super(InseminationInitial()) {
    on<LoadInseminationList>(_onLoadInseminationList);
    on<LoadInseminationDetail>(_onLoadInseminationDetail);
    on<AddInsemination>(_onAddInsemination);
    on<UpdateInsemination>(_onUpdateInsemination);
    on<DeleteInsemination>(_onDeleteInsemination);
  }

  // --- List Handler ---
  Future<void> _onLoadInseminationList(
    LoadInseminationList event,
    Emitter<InseminationState> emit,
  ) async {
    emit(InseminationLoading());
    final result = await repository.fetchInseminationList(filters: event.filters);
    
    // ⭐ FIX: Use .fold() to unwrap the Either
    result.fold(
      (failure) => emit(InseminationError(FailureConverter.toMessage(failure))),
      (records) => emit(InseminationListLoaded(records)),
    );
  }

  // --- Detail Handler ---
  Future<void> _onLoadInseminationDetail(
    LoadInseminationDetail event,
    Emitter<InseminationState> emit,
  ) async {
    emit(InseminationLoading());
    final result = await repository.fetchInseminationDetail(event.id);

    // ⭐ FIX: Use .fold() to unwrap the Either
    result.fold(
      (failure) => emit(InseminationError(FailureConverter.toMessage(failure))),
      (record) => emit(InseminationDetailLoaded(record)),
    );
  }

  // --- Add Handler (Fixes the reported error) ---
  Future<void> _onAddInsemination(
    AddInsemination event,
    Emitter<InseminationState> emit,
  ) async {
    // Note: You may want to emit a Loading/Submitting state here, but for now, 
    // we focus on the result handling.
    final newRecordResult = await repository.addInsemination(event.recordData);
    
    // ⭐ FIX: Use .fold() to unwrap the Either
    newRecordResult.fold(
      (failure) => emit(InseminationError(FailureConverter.toMessage(failure))),
      (newRecord) => emit(InseminationAdded(newRecord)), // newRecord is now InseminationEntity
    );
  }

  // --- Update Handler ---
  Future<void> _onUpdateInsemination(
    UpdateInsemination event,
    Emitter<InseminationState> emit,
  ) async {
    final updatedRecordResult = await repository.updateInsemination(event.id, event.updatedData);
    
    // ⭐ FIX: Use .fold() to unwrap the Either
    updatedRecordResult.fold(
      (failure) => emit(InseminationError(FailureConverter.toMessage(failure))),
      (updatedRecord) => emit(InseminationUpdated(updatedRecord)),
    );
  }

  // --- Delete Handler ---
  Future<void> _onDeleteInsemination(
    DeleteInsemination event,
    Emitter<InseminationState> emit,
  ) async {
    // You might want to emit InseminationLoading() for delete operations
    final deleteResult = await repository.deleteInsemination(event.id);
    
    // ⭐ FIX: Use .fold() to unwrap the Either (void is the Right side)
    deleteResult.fold(
      (failure) => emit(InseminationError(FailureConverter.toMessage(failure))),
      (_) => emit(InseminationDeleted()), // '_' represents the void (success) result
    );
  }
}