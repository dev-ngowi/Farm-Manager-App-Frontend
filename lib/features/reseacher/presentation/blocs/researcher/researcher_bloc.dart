// lib/features/researcher/presentation/blocs/researcher/researcher_bloc.dart
// FIX: Don't get AuthBloc from GetIt, pass the token from the UI

import 'package:farm_manager_app/core/error/failure.dart';
import 'package:farm_manager_app/features/reseacher/domain/entities/researcher_details_entity.dart';
import 'package:farm_manager_app/features/reseacher/domain/usecases/get_researcher_approval_status_usecase.dart'; 
import 'package:farm_manager_app/features/reseacher/domain/usecases/submit_researcher_details_usecase.dart';
import 'package:farm_manager_app/features/reseacher/presentation/blocs/researcher/researcher_event.dart';
import 'package:farm_manager_app/features/reseacher/presentation/blocs/researcher/researcher_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// # Researcher Bloc
class ResearcherBloc extends Bloc<ResearcherEvent, ResearcherState> {
  final SubmitResearcherDetailsUseCase submitResearcherDetailsUseCase;
  final GetResearcherApprovalStatusUseCase getResearcherApprovalStatusUseCase;

  ResearcherBloc({
    required this.submitResearcherDetailsUseCase,
    required this.getResearcherApprovalStatusUseCase, 
  }) : super(ResearcherInitial()) {
    on<SubmitResearcherDetailsEvent>(_mapSubmitResearcherDetailsEventToState);
    on<CheckApprovalStatusEvent>(_mapCheckApprovalStatusEventToState);
  }

  // ========================================
  // SUBMIT RESEARCHER DETAILS - FIXED
  // ========================================
 void _mapSubmitResearcherDetailsEventToState(
    SubmitResearcherDetailsEvent event,
    Emitter<ResearcherState> emit,
  ) async {
    print('========================================');
    print('ResearcherBloc: Submit Details Started');
    print('========================================');
    
    emit(ResearcherLoading());
    
    // Get token from event
    final userToken = event.token;
    
    if (userToken == null || userToken.isEmpty) {
      print('❌ ERROR: Token is null or empty!');
      emit(ResearcherError('Authentication token missing. Please log in again.'));
      return;
    }
    
    print('✅ Token received from event');
    print('   Token (first 20 chars): ${userToken.substring(0, 20)}...');
    
    try {
      final detailsEntity = ResearcherDetailsEntity(
        affiliatedInstitution: event.affiliatedInstitution,
        department: event.department,
        researchPurpose: event.researchPurpose,
        researchFocusArea: event.researchFocusArea,
        academicTitle: event.academicTitle,
        orcidId: event.orcidId,
      );

      print('');
      print('Submitting researcher details:');
      print('   Institution: ${event.affiliatedInstitution}');
      print('   Department: ${event.department}');
      print('   Purpose: ${event.researchPurpose}');

      final params = SubmitResearcherDetailsParams(
        details: detailsEntity,
        token: userToken,
      );

      final result = await submitResearcherDetailsUseCase(params);
      
      result.fold(
        (failure) {
          print('');
          print('❌ Submission failed');
          
          final errorMessage = (failure is ValidationFailure)
              ? 'Validation Error: ${failure.getFieldError(failure.errors!.keys.first) ?? failure.message}'
              : failure.message;
          
          print('   Error: $errorMessage');
          
          if (failure is ValidationFailure && failure.errors != null) {
            print('   Validation errors:');
            failure.errors!.forEach((key, value) {
              print('      $key: $value');
            });
          }
          
          emit(ResearcherError(errorMessage));
        },
        
        (userEntity) {
          print('');
          print('✅ Submission successful!');
          print('   🔍 DIAGNOSTIC: API Response Details');
          print('   =====================================');
          print('   ID: ${userEntity.id}');
          print('   Firstname: ${userEntity.firstname}');
          print('   Lastname: ${userEntity.lastname}');
          print('   Email: ${userEntity.email}');
          print('   Phone: ${userEntity.phoneNumber}');
          print('   Role: ${userEntity.role}');
          print('   Token included: ${userEntity.token != null}');
          print('   Token length: ${userEntity.token?.length ?? 0}');
          print('   hasCompletedDetails: ${userEntity.hasCompletedDetails}');
          print('   hasDetailsApproved: ${userEntity.hasDetailsApproved}');
          print('   hasLocation: ${userEntity.hasLocation}');
          print('   primaryLocationId: ${userEntity.primaryLocationId}');
          print('   locations: ${userEntity.locations?.length ?? 0} items');
          
          if (userEntity.locations != null && userEntity.locations!.isNotEmpty) {
            print('   Location details:');
            for (var loc in userEntity.locations!) {
              print('      - ID: ${loc.locationId}, Name: ${loc.displayName}');
            }
          }
          print('   =====================================');
          
          // 🚨 WARNING CHECK: Verify role is correct
          if (userEntity.role.toLowerCase() != 'researcher') {
            print('');
            print('⚠️  WARNING: API returned wrong role!');
            print('   Expected: researcher');
            print('   Got: ${userEntity.role}');
            print('   This will cause router redirect issues!');
          }
          
          emit(ResearcherSuccess(
            message: 'Profile saved successfully! Waiting for approval.',
            hasCompletedDetails: userEntity.hasCompletedDetails,
            updatedUser: userEntity,
          ));
          
          print('✅ ResearcherSuccess emitted');
          print('========================================');
        },
      );
    } catch (e, stackTrace) {
      print('');
      print('❌ Exception during submission');
      print('   Error: $e');
      print('   Stack trace: $stackTrace');
      emit(ResearcherError("An unexpected error occurred during profile submission."));
    }
  }

  // ========================================
  // CHECK APPROVAL STATUS
  // ========================================
  void _mapCheckApprovalStatusEventToState(
    CheckApprovalStatusEvent event,
    Emitter<ResearcherState> emit,
  ) async {
    emit(ResearcherLoading()); 
    
    // 🎯 FIX: Token should be passed from the event
    final userToken = event.token;
    
    if (userToken == null || userToken.isEmpty) {
      emit(ResearcherError('Authentication token missing.'));
      return;
    }
    
    final params = GetResearcherApprovalStatusParams(token: userToken);

    final result = await getResearcherApprovalStatusUseCase(params);

    result.fold(
      (failure) {
        emit(ResearcherError("Failed to fetch approval status: ${failure.message}"));
      },
      (statusEntity) {
        emit(ResearcherApprovalStatus(
          approvalStatus: statusEntity.status,
          declineReason: statusEntity.reason,
        ));
      },
    );
  }
}