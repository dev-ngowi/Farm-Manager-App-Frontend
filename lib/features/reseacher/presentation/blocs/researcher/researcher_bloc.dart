import 'package:farm_manager_app/core/error/failure.dart';
import 'package:farm_manager_app/features/reseacher/domain/entities/researcher_details_entity.dart';
import 'package:farm_manager_app/features/reseacher/domain/usecases/submit_researcher_details_usecase.dart';
import 'package:farm_manager_app/features/reseacher/presentation/blocs/researcher/researcher_event.dart';
import 'package:farm_manager_app/features/reseacher/presentation/blocs/researcher/researcher_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// # Researcher Bloc
class ResearcherBloc extends Bloc<ResearcherEvent, ResearcherState> {
  // 1. Inject the Use Case
  final SubmitResearcherDetailsUseCase submitResearcherDetailsUseCase;
  
  // NOTE: You need a mechanism to get the authenticated user's token. 
  // For simplicity here, we'll assume a method/dependency handles it.
  // In a real app, this might come from a shared preference or an Auth Bloc.
  // We'll use a placeholder variable for now.
  final String _userTokenPlaceholder = 'YOUR_AUTHENTICATION_TOKEN_HERE'; 

  ResearcherBloc({
    required this.submitResearcherDetailsUseCase,
  }) : super(ResearcherInitial()) {
    on<SubmitResearcherDetailsEvent>(_mapSubmitResearcherDetailsEventToState);
  }

  void _mapSubmitResearcherDetailsEventToState(
    SubmitResearcherDetailsEvent event,
    Emitter<ResearcherState> emit,
  ) async {
    // 1. Loading State
    emit(ResearcherLoading());

    try {
      // 2. Map Event data to Entity
      final detailsEntity = ResearcherDetailsEntity(
        affiliatedInstitution: event.affiliatedInstitution,
        department: event.department,
        researchPurpose: event.researchPurpose,
        researchFocusArea: event.researchFocusArea,
        academicTitle: event.academicTitle,
        orcidId: event.orcidId,
      );

      // 3. Prepare Use Case Parameters
      final params = SubmitResearcherDetailsParams(
        details: detailsEntity,
        token: _userTokenPlaceholder, // Replace with actual token retrieval
      );

      // 4. Call the Use Case
      final result = await submitResearcherDetailsUseCase(params);
      
      // 5. Handle the result (Either<Failure, UserEntity>)
      result.fold(
        // LEFT: Failure (Error)
        (failure) {
          // Use FailureConverter.toMessage for user-friendly errors
          final errorMessage = (failure is ValidationFailure)
              ? 'Validation Error: ${failure.getFieldError(failure.errors!.keys.first) ?? failure.message}'
              : failure.message;
          
          emit(ResearcherError(errorMessage));
        },
        
        // RIGHT: Success (UserEntity)
        (userEntity) {
          emit(ResearcherSuccess(
            message: 'Profile for ${event.affiliatedInstitution} saved successfully!',
            // The UserEntity should contain the updated hasCompletedDetails flag
            hasCompletedDetails: userEntity.hasCompletedDetails, 
          ));
        },
      );
    } catch (e) {
      // 6. Catch any unexpected sync errors
      emit(ResearcherError("An unexpected error occurred during profile submission."));
    }
  }
}