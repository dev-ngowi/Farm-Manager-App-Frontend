// lib/features/farmer/breeding/presentation/bloc/delivery/delivery_bloc.dart

import 'package:farm_manager_app/features/farmer/breeding/delivery/domain/repositories/delivery_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'delivery_event.dart';
import 'delivery_state.dart';

class DeliveryBloc extends Bloc<DeliveryEvent, DeliveryState> {
  final DeliveryRepository repository;

  DeliveryBloc({required this.repository}) : super(DeliveryInitial()) {
    on<LoadDeliveryList>(_onLoadList);
    on<LoadDeliveryDetail>(_onLoadDetail);
    on<AddDelivery>(_onAddDelivery);
    on<UpdateDelivery>(_onUpdateDelivery);
    on<DeleteDelivery>(_onDeleteDelivery);
    on<LoadDeliveryDropdowns>(_onLoadDropdowns);
  }

  Future<void> _onLoadList(
    LoadDeliveryList event,
    Emitter<DeliveryState> emit,
  ) async {
    emit(DeliveryLoading());
    final result = await repository.getDeliveries(filters: event.filters);
    result.fold(
      (failure) => emit(DeliveryError(failure.message)),
      (deliveries) => emit(DeliveryListLoaded(deliveries)),
    );
  }

  Future<void> _onLoadDetail(
    LoadDeliveryDetail event,
    Emitter<DeliveryState> emit,
  ) async {
    emit(DeliveryLoading());
    final result = await repository.getDeliveryById(event.id);
    result.fold(
      (failure) => emit(DeliveryError(failure.message)),
      (delivery) => emit(DeliveryDetailLoaded(delivery)),
    );
  }

  Future<void> _onAddDelivery(
    AddDelivery event,
    Emitter<DeliveryState> emit,
  ) async {
    emit(DeliveryLoading());
    final result = await repository.addDelivery(event.data);
    result.fold(
      (failure) => emit(DeliveryError(failure.message)),
      (newDelivery) => emit(DeliveryAdded(newDelivery)),
    );
  }

  Future<void> _onUpdateDelivery(
    UpdateDelivery event,
    Emitter<DeliveryState> emit,
  ) async {
    emit(DeliveryLoading());
    final result = await repository.updateDelivery(event.id, event.data);
    result.fold(
      (failure) => emit(DeliveryError(failure.message)),
      (updatedDelivery) => emit(DeliveryUpdated(updatedDelivery)),
    );
  }

  Future<void> _onDeleteDelivery(
    DeleteDelivery event,
    Emitter<DeliveryState> emit,
  ) async {
    emit(DeliveryLoading());
    final result = await repository.deleteDelivery(event.id);
    result.fold(
      (failure) => emit(DeliveryError(failure.message)),
      (_) => emit(DeliveryDeleted()),
    );
  }

  Future<void> _onLoadDropdowns(
    LoadDeliveryDropdowns event,
    Emitter<DeliveryState> emit,
  ) async {
    emit(DeliveryDropdownsLoading());
    
    final result = await repository.getAvailableInseminations();

    result.fold(
      (failure) => emit(DeliveryError(failure.message)),
      (inseminations) => emit(DeliveryDropdownsLoaded(inseminations: inseminations)),
    );
  }
}