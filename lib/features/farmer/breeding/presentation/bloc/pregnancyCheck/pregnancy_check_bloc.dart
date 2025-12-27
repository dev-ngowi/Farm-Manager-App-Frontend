
import 'package:farm_manager_app/features/farmer/breeding/pregnancyCheck/domain/repositories/pregnancy_check_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'pregnancy_check_event.dart';
import 'pregnancy_check_state.dart';

class PregnancyCheckBloc extends Bloc<PregnancyCheckEvent, PregnancyCheckState> {
  final PregnancyCheckRepository repository;

  PregnancyCheckBloc({required this.repository}) : super(PregnancyCheckInitial()) {
    on<LoadPregnancyCheckList>(_onLoadList);
    on<LoadPregnancyCheckDetail>(_onLoadDetail);
    on<AddPregnancyCheck>(_onAddCheck);
    on<UpdatePregnancyCheck>(_onUpdateCheck);
    on<DeletePregnancyCheck>(_onDeleteCheck);
    on<LoadPregnancyCheckDropdowns>(_onLoadDropdowns);
  }

  Future<void> _onLoadList(
    LoadPregnancyCheckList event,
    Emitter<PregnancyCheckState> emit,
  ) async {
    emit(PregnancyCheckLoading());
    final result = await repository.getPregnancyChecks(filters: event.filters);
    result.fold(
      (failure) => emit(PregnancyCheckError(failure.message)),
      (checks) => emit(PregnancyCheckListLoaded(checks)),
    );
  }

  Future<void> _onLoadDetail(
    LoadPregnancyCheckDetail event,
    Emitter<PregnancyCheckState> emit,
  ) async {
    emit(PregnancyCheckLoading());
    final result = await repository.getPregnancyCheckById(event.id);
    result.fold(
      (failure) => emit(PregnancyCheckError(failure.message)),
      (check) => emit(PregnancyCheckDetailLoaded(check)),
    );
  }

  Future<void> _onAddCheck(
    AddPregnancyCheck event,
    Emitter<PregnancyCheckState> emit,
  ) async {
    emit(PregnancyCheckLoading());
    final result = await repository.addPregnancyCheck(event.data);
    result.fold(
      (failure) => emit(PregnancyCheckError(failure.message)),
      (newCheck) => emit(PregnancyCheckAdded(newCheck)),
    );
  }

  Future<void> _onUpdateCheck(
    UpdatePregnancyCheck event,
    Emitter<PregnancyCheckState> emit,
  ) async {
    emit(PregnancyCheckLoading());
    final result = await repository.updatePregnancyCheck(event.id, event.data);
    result.fold(
      (failure) => emit(PregnancyCheckError(failure.message)),
      (updatedCheck) => emit(PregnancyCheckUpdated(updatedCheck)),
    );
  }

  Future<void> _onDeleteCheck(
    DeletePregnancyCheck event,
    Emitter<PregnancyCheckState> emit,
  ) async {
    emit(PregnancyCheckLoading());
    final result = await repository.deletePregnancyCheck(event.id);
    result.fold(
      (failure) => emit(PregnancyCheckError(failure.message)),
      (_) => emit(PregnancyCheckDeleted()),
    );
  }

  Future<void> _onLoadDropdowns(
    LoadPregnancyCheckDropdowns event,
    Emitter<PregnancyCheckState> emit,
  ) async {
    emit(PregnancyCheckDropdownsLoading());
    
    // Fetch both inseminations and vets in parallel
    final inseminationsResult = await repository.getAvailableInseminations();
    final vetsResult = await repository.getAvailableVets();

    // Check if both succeeded
    if (inseminationsResult.isLeft() || vetsResult.isLeft()) {
      // Extract error message from whichever failed
      final errorMessage = inseminationsResult.fold(
        (failure) => failure.message,
        (_) => vetsResult.fold(
          (failure) => failure.message,
          (_) => 'Unknown error loading dropdowns',
        ),
      );
      emit(PregnancyCheckError(errorMessage));
      return;
    }

    // Both succeeded, extract the data
    final inseminations = inseminationsResult.getOrElse(() => []);
    final vets = vetsResult.getOrElse(() => []);

    emit(PregnancyCheckDropdownsLoaded(
      inseminations: inseminations,
      vets: vets,
    ));
  }
}