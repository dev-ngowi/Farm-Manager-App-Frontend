// Import dartz for Either
import 'package:farm_manager_app/core/error/failure.dart';
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

    result.fold(
      (failure) => emit(InseminationError(FailureConverter.toMessage(failure))),
      (record) => emit(InseminationDetailLoaded(record)),
    );
  }

  // --- Add Handler ---
  Future<void> _onAddInsemination(
    AddInsemination event,
    Emitter<InseminationState> emit,
  ) async {
    // ✅ Emit loading state for form submission
    emit(InseminationSubmitting());
    
    final newRecordResult = await repository.addInsemination(event.recordData);
    
    newRecordResult.fold(
      (failure) => emit(InseminationError(FailureConverter.toMessage(failure))),
      (newRecord) => emit(InseminationAdded(newRecord)),
    );
  }

  // --- Update Handler ---
  Future<void> _onUpdateInsemination(
    UpdateInsemination event,
    Emitter<InseminationState> emit,
  ) async {
    // ✅ Emit loading state for form submission
    emit(InseminationSubmitting());
    
    final updatedRecordResult = await repository.updateInsemination(event.id, event.updatedData);
    
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
    // ✅ Emit loading state for delete operation
    emit(InseminationLoading());
    
    final deleteResult = await repository.deleteInsemination(event.id);
    
    deleteResult.fold(
      (failure) => emit(InseminationError(FailureConverter.toMessage(failure))),
      (_) => emit(InseminationDeleted()),
    );
  }
}