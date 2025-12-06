import 'package:farm_manager_app/features/farmer/breeding/presentation/bloc/semenInventory/semen_event.dart';
import 'package:farm_manager_app/features/farmer/breeding/presentation/bloc/semenInventory/semen_state.dart';
import 'package:farm_manager_app/features/farmer/breeding/semenInventory/domain/usecases/create_semen.dart';
import 'package:farm_manager_app/features/farmer/breeding/semenInventory/domain/usecases/delete_semen.dart';
import 'package:farm_manager_app/features/farmer/breeding/semenInventory/domain/usecases/get_available_semen.dart';
import 'package:farm_manager_app/features/farmer/breeding/semenInventory/domain/usecases/get_semen_details.dart';
import 'package:farm_manager_app/features/farmer/breeding/semenInventory/domain/usecases/semen_usecases.dart';
import 'package:farm_manager_app/features/farmer/breeding/semenInventory/domain/usecases/update_semen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:farm_manager_app/core/error/failure.dart';
import 'package:farm_manager_app/features/farmer/breeding/semenInventory/domain/entities/dropdown_entity.dart'; // Import to use the type

class SemenInventoryBloc extends Bloc<SemenEvent, SemenState> {
  // Use Cases
  final GetAllSemen getAllSemen;
  final GetSemenDetails getSemenDetails;
  final CreateSemen createSemen;
  final UpdateSemen updateSemen;
  final DeleteSemen deleteSemen;
  final GetAvailableSemen getAvailableSemen;


  SemenInventoryBloc({
    required this.getAllSemen,
    required this.getSemenDetails,
    required this.createSemen,
    required this.updateSemen,
    required this.deleteSemen,
    required this.getAvailableSemen,
  }) : super(SemenInitial()) {
    on<SemenLoadInventory>(_onLoadInventory);
    on<SemenLoadDetails>(_onLoadDetails);
    on<SemenCreate>(_onCreateSemen);
    on<SemenUpdate>(_onUpdateSemen);
    on<SemenDelete>(_onDeleteSemen);
    on<SemenLoadDropdowns>(_onLoadDropdowns);
  }

  // Helper function to map Failure to Error State
  SemenError _mapFailureToState(Failure failure) {
    if (failure is ValidationFailure) {
      // ✅ FIX: Safely access values on potentially null errors map
      final errors = failure.errors?.values.expand((e) => e).join('\n') ?? 'Validation failed.';
      return SemenError(errors, isValidationError: true);
    }
    return SemenError(failure.message ?? 'An unexpected error occurred.');
  }

  // --- Handlers ---

  Future<void> _onLoadInventory(
    SemenLoadInventory event,
    Emitter<SemenState> emit,
  ) async {
    emit(SemenLoading());
    // ✅ FIX: SemenListParams is correctly imported from its Use Case file
    final params = SemenListParams( 
      availableOnly: event.availableOnly,
      breedId: event.breedId,
    );
    final result = await getAllSemen(params);

    emit(result.fold(
      (failure) => _mapFailureToState(failure),
      (list) => SemenLoadedList(list),
    ));
  }
  
  Future<void> _onLoadDetails(
    SemenLoadDetails event,
    Emitter<SemenState> emit,
    ) async {
    emit(SemenLoading());
    final result = await getSemenDetails(event.id);

    emit(result.fold(
      (failure) => _mapFailureToState(failure),
      (semen) => SemenLoadedDetails(semen),
    ));
  }

  Future<void> _onCreateSemen(
    SemenCreate event,
    Emitter<SemenState> emit,
  ) async {
    emit(SemenLoading());
    final result = await createSemen(event.semen);

    emit(result.fold(
      (failure) => _mapFailureToState(failure),
      (semen) => const SemenActionSuccess('Semen record created successfully.'),
    ));

    // Reload the list after success
    add(const SemenLoadInventory()); 
  }

  Future<void> _onUpdateSemen(
    SemenUpdate event,
    Emitter<SemenState> emit,
  ) async {
    emit(SemenLoading());
    // ✅ FIX: SemenUpdateParams is correctly imported from its Use Case file
    final params = SemenUpdateParams(id: event.id, semen: event.semen); 
    final result = await updateSemen(params);

    emit(result.fold(
      (failure) => _mapFailureToState(failure),
      (semen) => const SemenActionSuccess('Semen record updated successfully.'),
    ));

    // Reload details after update
    add(SemenLoadDetails(event.id)); 
  }

  Future<void> _onDeleteSemen(
    SemenDelete event,
    Emitter<SemenState> emit,
  ) async {
    emit(SemenLoading());
    final result = await deleteSemen(event.id);

    emit(result.fold(
      (failure) => _mapFailureToState(failure),
      (_) => const SemenActionSuccess('Semen record deleted successfully.'),
    ));

    // Reload the inventory list after deletion
    add(const SemenLoadInventory()); 
  }

  // ⭐ UPDATED HANDLER: Filter the list before emitting SemenLoadedDropdowns
  Future<void> _onLoadDropdowns(
    SemenLoadDropdowns event,
    Emitter<SemenState> emit,
  ) async {
    emit(SemenLoading());
    final result = await getAvailableSemen(NoParams()); 

    emit(result.fold(
      (failure) => _mapFailureToState(failure),
      (List<DropdownEntity> dropdowns) {
        // ⭐ Filter the single list into two separate lists for the state
        final bulls = dropdowns.where((d) => d.type == 'bull').toList();
        final breeds = dropdowns.where((d) => d.type == 'breed').toList();
        
        return SemenLoadedDropdowns(bulls: bulls, breeds: breeds);
      },
    ));
  }
}