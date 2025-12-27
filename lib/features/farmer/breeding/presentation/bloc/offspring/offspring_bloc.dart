// lib/features/farmer/breeding/presentation/bloc/offspring/offspring_bloc.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:farm_manager_app/features/farmer/breeding/offspring/domain/repositories/offspring_repository.dart';
import 'package:farm_manager_app/features/farmer/breeding/presentation/bloc/offspring/offspring_event.dart';
import 'package:farm_manager_app/features/farmer/breeding/presentation/bloc/offspring/offspring_state.dart';

class OffspringBloc extends Bloc<OffspringEvent, OffspringState> {
  final OffspringRepository repository;

  OffspringBloc({required this.repository}) : super(OffspringInitial()) {
    on<LoadOffspringList>(_onLoadOffspringList);
    on<LoadOffspringDetail>(_onLoadOffspringDetail);
    on<LoadOffspringDropdowns>(_onLoadOffspringDropdowns);
    on<AddOffspring>(_onAddOffspring);
    on<UpdateOffspring>(_onUpdateOffspring);
    on<DeleteOffspring>(_onDeleteOffspring);
    on<RegisterOffspring>(_onRegisterOffspring);
  }

  Future<void> _onLoadOffspringList(
    LoadOffspringList event,
    Emitter<OffspringState> emit,
  ) async {
    emit(OffspringLoading());
    
    final result = await repository.getOffspringList(filters: event.filters);
    
    result.fold(
      (failure) => emit(OffspringError(failure.message)),
      (offspring) => emit(OffspringListLoaded(offspring)),
    );
  }

  Future<void> _onLoadOffspringDetail(
    LoadOffspringDetail event,
    Emitter<OffspringState> emit,
  ) async {
    emit(OffspringLoading());
    
    final result = await repository.getOffspringById(event.id);
    
    result.fold(
      (failure) => emit(OffspringError(failure.message)),
      (offspring) => emit(OffspringDetailLoaded(offspring)),
    );
  }

  Future<void> _onLoadOffspringDropdowns(
    LoadOffspringDropdowns event,
    Emitter<OffspringState> emit,
  ) async {
    final result = await repository.getAvailableDeliveries();
    
    result.fold(
      (failure) => emit(OffspringError(failure.message)),
      (deliveries) => emit(OffspringDropdownsLoaded(deliveries)),
    );
  }

  Future<void> _onAddOffspring(
    AddOffspring event,
    Emitter<OffspringState> emit,
  ) async {
    emit(OffspringLoading());
    
    final result = await repository.addOffspring(event.data);
    
    result.fold(
      (failure) => emit(OffspringError(failure.message)),
      (_) => emit(OffspringAdded()),
    );
  }

  Future<void> _onUpdateOffspring(
    UpdateOffspring event,
    Emitter<OffspringState> emit,
  ) async {
    emit(OffspringLoading());
    
    final result = await repository.updateOffspring(event.id, event.data);
    
    result.fold(
      (failure) => emit(OffspringError(failure.message)),
      (_) => emit(OffspringUpdated()),
    );
  }

  Future<void> _onDeleteOffspring(
    DeleteOffspring event,
    Emitter<OffspringState> emit,
  ) async {
    emit(OffspringLoading());
    
    final result = await repository.deleteOffspring(event.id);
    
    result.fold(
      (failure) => emit(OffspringError(failure.message)),
      (_) => emit(OffspringDeleted()),
    );
  }

  Future<void> _onRegisterOffspring(
    RegisterOffspring event,
    Emitter<OffspringState> emit,
  ) async {
    emit(OffspringLoading());
    
    final result = await repository.registerOffspring(event.id, event.data);
    
    result.fold(
      (failure) => emit(OffspringError(failure.message)),
      (_) => emit(OffspringRegistered()),
    );
  }
}