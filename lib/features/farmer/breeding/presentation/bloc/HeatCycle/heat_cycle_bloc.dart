import 'package:bloc/bloc.dart';
import 'package:farm_manager_app/core/error/failure.dart';
import 'package:farm_manager_app/features/farmer/breeding/HeatCycle/domain/usecases/heat_cycle_usecases.dart';
import 'package:farm_manager_app/features/farmer/breeding/presentation/bloc/HeatCycle/heat_cycle_event.dart';
import 'package:farm_manager_app/features/farmer/breeding/presentation/bloc/HeatCycle/heat_cycle_state.dart';

// Mapping use cases to a concise name for the BLoC
const String SERVER_FAILURE_MESSAGE = 'A server error occurred. Please try again.';
const String NETWORK_FAILURE_MESSAGE = 'No internet connection.';
const String VALIDATION_FAILURE_MESSAGE = 'Input validation failed.';

class HeatCycleBloc extends Bloc<HeatCycleEvent, HeatCycleState> {
  final GetHeatCycles getHeatCycles;
  final GetHeatCycleDetails getHeatCycleDetails;
  final CreateHeatCycle createHeatCycle;
  final UpdateHeatCycle updateHeatCycle;
  final DeleteHeatCycle deleteHeatCycle;


  HeatCycleBloc({
    required this.getHeatCycles,
    required this.getHeatCycleDetails,
    required this.createHeatCycle,
    required this.updateHeatCycle,
    required this.deleteHeatCycle,
  }) : super(HeatCycleInitial()) {
    on<LoadHeatCycles>(_onLoadHeatCycles);
    on<LoadHeatCycleDetails>(_onLoadHeatCycleDetails);
    on<CreateHeatCycleEvent>(_onCreateHeatCycle);
    on<UpdateHeatCycleEvent>(_onUpdateHeatCycle);
    on<DeleteHeatCycleEvent>(_onDeleteHeatCycle);
  }

  // Helper to map failure types to user-friendly messages
  String _mapFailureToMessage(Failure failure) {
    if (failure is ServerFailure) {
      return failure.message ?? SERVER_FAILURE_MESSAGE;
    } else if (failure is NetworkFailure) {
      return NETWORK_FAILURE_MESSAGE;
    } else if (failure is ValidationFailure) {
      // For validation, we typically show the specific error message from the API
      return failure.message ?? VALIDATION_FAILURE_MESSAGE;
    } else if (failure is AuthFailure) {
      return failure.message ?? 'Authentication error.';
    }
    return 'An unexpected error occurred.';
  }

  // ========================================
  // EVENT HANDLERS
  // ========================================

  Future<void> _onLoadHeatCycles(
    LoadHeatCycles event,
    Emitter<HeatCycleState> emit,
  ) async {
    emit(HeatCycleLoading());
    final failureOrCycles = await getHeatCycles(
      GetHeatCyclesParams(token: event.token),
    );

    failureOrCycles.fold(
      (failure) => emit(HeatCycleError(
        message: _mapFailureToMessage(failure),
        failure: failure,
      )),
      (cycles) => emit(HeatCycleListLoaded(cycles: cycles)),
    );
  }

  Future<void> _onLoadHeatCycleDetails(
    LoadHeatCycleDetails event,
    Emitter<HeatCycleState> emit,
  ) async {
    emit(HeatCycleLoading());
    final failureOrCycle = await getHeatCycleDetails(
      GetHeatCycleDetailsParams(id: event.id, token: event.token),
    );

    failureOrCycle.fold(
      (failure) => emit(HeatCycleError(
        message: _mapFailureToMessage(failure),
        failure: failure,
      )),
      (cycle) => emit(HeatCycleDetailsLoaded(cycle: cycle)),
    );
  }

  Future<void> _onCreateHeatCycle(
    CreateHeatCycleEvent event,
    Emitter<HeatCycleState> emit,
  ) async {
    // Optionally emit the previous state or just Loading
    emit(HeatCycleLoading());
    final failureOrCycle = await createHeatCycle(
      CreateHeatCycleParams(cycle: event.cycle, token: event.token),
    );

    failureOrCycle.fold(
      (failure) => emit(HeatCycleError(
        message: _mapFailureToMessage(failure),
        failure: failure,
      )),
      (cycle) => emit(HeatCycleSuccess(
        message: 'Heat cycle recorded successfully!',
        cycle: cycle,
      )),
    );
  }

  Future<void> _onUpdateHeatCycle(
    UpdateHeatCycleEvent event,
    Emitter<HeatCycleState> emit,
  ) async {
    // Optionally emit the previous state or just Loading
    emit(HeatCycleLoading());
    final failureOrCycle = await updateHeatCycle(
      UpdateHeatCycleParams(
        id: event.id,
        cycle: event.cycle,
        token: event.token,
      ),
    );

    failureOrCycle.fold(
      (failure) => emit(HeatCycleError(
        message: _mapFailureToMessage(failure),
        failure: failure,
      )),
      (cycle) => emit(HeatCycleSuccess(
        message: 'Heat cycle updated successfully!',
        cycle: cycle,
      )),
    );
  }

  Future<void> _onDeleteHeatCycle(
    DeleteHeatCycleEvent event,
    Emitter<HeatCycleState> emit,
  ) async {
    // For delete, we emit the previous state or a loading state
    emit(HeatCycleLoading());

    // ⚠️ Assumes a Use Case named DeleteHeatCycle with params DeleteHeatCycleParams
    final failureOrSuccess = await deleteHeatCycle(
      DeleteHeatCycleParams(id: event.id, token: event.token),
    );

    failureOrSuccess.fold(
      (failure) => emit(HeatCycleError(
        message: _mapFailureToMessage(failure),
        failure: failure,
      )),
      // On success, we emit a success message without a specific entity
      (_) => emit(HeatCycleSuccess(
        message: 'Heat cycle successfully deleted!',
      )),
    );
  }

}