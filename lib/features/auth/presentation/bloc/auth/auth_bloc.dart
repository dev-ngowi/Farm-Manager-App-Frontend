// lib/features/auth/presentation/bloc/auth/auth_bloc.dart

import 'package:farm_manager_app/core/error/failure.dart';
import 'package:farm_manager_app/features/auth/data/domain/entities/location_entity.dart';
import 'package:farm_manager_app/features/auth/data/domain/entities/user_entity.dart';
import 'package:farm_manager_app/features/auth/data/domain/repositories/location_repository.dart';
import 'package:farm_manager_app/features/auth/data/domain/usecases/auth/login_usecase.dart';
import 'package:farm_manager_app/features/auth/data/domain/usecases/auth/register_usecase.dart';
import 'package:farm_manager_app/features/auth/data/domain/usecases/auth/assign_role_usecase.dart';
import 'package:farm_manager_app/features/auth/data/domain/usecases/farmer/submit_farmer_details_usecase.dart';
import 'package:farm_manager_app/features/auth/presentation/bloc/auth/auth_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

part 'auth_event.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase loginUseCase;
  final RegisterUseCase registerUseCase;
  final AssignRoleUseCase assignRoleUseCase;
  final RegisterFarmerUseCase registerFarmerUseCase;
  final LocationRepository locationRepository;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // Processing flags to prevent duplicate operations
  bool _isProcessingLogin = false;
  bool _isProcessingRegistration = false;
  bool _isProcessingFarmerDetails = false;

  AuthBloc({
    required this.loginUseCase,
    required this.registerUseCase,
    required this.assignRoleUseCase,
    required this.registerFarmerUseCase,
    required this.locationRepository,
  }) : super(AuthInitial()) {
    // Register event handlers
    on<RegisterSubmitted>(_onRegisterSubmitted);
    on<LoginSubmitted>(_onLoginSubmitted);
    // REMOVED: on<FetchUserLocations>(_onFetchUserLocations); // Not needed for immediate login refresh
    on<AssignRoleSubmitted>(_onAssignRoleSubmitted);
    on<SubmitFarmerDetails>(_onSubmitFarmerDetails);
    on<LogoutRequested>(_onLogoutRequested);
    on<CheckAuthStatus>(_onCheckAuthStatus);
    on<UserLocationUpdated>(_onUserLocationUpdated);
  }

  // ========================================
  // REGISTER EVENT HANDLER
  // ========================================

  Future<void> _onRegisterSubmitted(
    RegisterSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    if (_isProcessingRegistration) {
      print('Registration already in progress, ignoring duplicate event');
      return;
    }

    _isProcessingRegistration = true;
    emit(AuthLoading());

    final result = await registerUseCase(
      firstname: event.firstname,
      lastname: event.lastname,
      phoneNumber: event.phoneNumber,
      email: event.email,
      password: event.password,
      passwordConfirmation: event.passwordConfirmation,
      role: event.role,
    );

    await result.fold(
      (failure) async {
        print('Register Error: ${failure.message}');
        _isProcessingRegistration = false;
        emit(AuthError(failure.message));
      },
      (user) async {
        print('Register Success. Redirecting to Login.');
        _isProcessingRegistration = false;

        emit(const AuthNavigateToLogin(
          'Registration successful. Please log in to continue.',
        ));
      },
    );
  }

  // ========================================
  // LOGIN EVENT HANDLER - CRITICAL FIX
  // ========================================

  Future<void> _onLoginSubmitted(
    LoginSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    if (_isProcessingLogin) {
      print('Login already in progress, ignoring duplicate event');
      return;
    }

    _isProcessingLogin = true;
    emit(AuthLoading());

    final loginResult = await loginUseCase(event.login, event.password);

    await loginResult.fold(
      (failure) async {
        print('Login Error: ${failure.message}');
        _isProcessingLogin = false;
        emit(AuthError(failure.message));
      },
      (user) async {
        print('Login Success: ${user.firstname}, Role: ${user.role}');

        // --- CRITICAL FIX: Fetch locations synchronously after successful login ---
        UserEntity finalUser = user;
        
        if (user.token != null && user.token!.isNotEmpty) {
          print('Fetching locations before finalizing AuthSuccess...');
          
          // AWAIT the repository call to ensure data is fetched before proceeding
          final locationResult = await locationRepository.getUserLocations(user.token!);
          
          await locationResult.fold(
            (locationFailure) {
              print('Location Fetch Error (Post-Login): ${locationFailure.message}');
              // Continue with user data if location fetch fails
            },
            (locations) {
              print('Location Fetch Success: Found ${locations.length} locations.');
              final bool hasAnyLocation = locations.isNotEmpty;
              final LocationEntity? primaryLocation = LocationEntity.findPrimary(locations);
              
              // Update the user object with the fetched locations
              finalUser = user.copyWith(
                hasLocation: hasAnyLocation,
                primaryLocationId: primaryLocation?.locationId,
                locations: locations, // IMPORTANT: Locations are now populated
              );
            },
          );
        }
        
        // --- END CRITICAL FIX ---

        print('   HasDetails: ${finalUser.hasCompletedDetails}');
        print('   HasLocation: ${finalUser.hasLocation}');
        
        await _saveUserData(finalUser);
        _isProcessingLogin = false;

        // Emit the final AuthSuccess with the fully hydrated user object
        emit(AuthSuccess(
          finalUser,
          message: 'Login successful and profile data loaded!',
        ));
      },
    );
  }

  // ========================================
  // REMOVED: FETCH USER LOCATIONS HANDLER
  // This is now handled by _onLoginSubmitted, 
  // but keeping the function body for completeness if the event is triggered elsewhere.
  // ========================================

  Future<void> _onFetchUserLocations(
    FetchUserLocations event,
    Emitter<AuthState> emit,
  ) async {
    final currentState = state;

    if (currentState is! AuthSuccess) {
      print('Cannot fetch locations: User not authenticated');
      return;
    }

    print('Manually fetching user locations...');

    final result = await locationRepository.getUserLocations(event.token);

    await result.fold(
      (failure) async {
        print('Location Fetch Error: ${failure.message}');
        
        emit(AuthSuccess(currentState.user, message: 'Could not update locations.'));
      },
      (locations) async {
        print('Location Fetch Success: Found ${locations.length} locations.');

        final bool hasAnyLocation = locations.isNotEmpty;
        final LocationEntity? primaryLocation =
            LocationEntity.findPrimary(locations);

        final updatedUser = currentState.user.copyWith(
          hasLocation: hasAnyLocation,
          primaryLocationId: primaryLocation?.locationId,
          locations: locations,
        );

        await _saveUserData(updatedUser);

        emit(AuthSuccess(
          updatedUser,
          message: 'Locations refreshed successfully!',
        ));
      },
    );
  }

  // ========================================
  // ASSIGN ROLE EVENT HANDLER
  // ========================================

  Future<void> _onAssignRoleSubmitted(
    AssignRoleSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    print('AssignRole Started: ${event.role}');

    final currentState = state;
    if (currentState is! AuthSuccess) {
      print('Cannot assign role: User not authenticated');
      emit(const AuthError("Please log in to continue."));
      return;
    }

    final currentUser = currentState.user;
    final token = currentUser.token;

    if (token == null || token.isEmpty) {
      print('Cannot assign role: No token found');
      emit(const AuthError(
          "Authentication token missing. Please log in again."));
      return;
    }

    print('Token found');
    print('   Current role: ${currentUser.role}');
    print('   Requested role: ${event.role}');

    emit(AuthLoading());

    print('Calling assignRoleUseCase...');
    final result = await assignRoleUseCase(
      role: event.role,
      token: token,
    );

    await result.fold(
      (failure) async {
        print('AssignRole Failed: ${failure.message}');
        emit(AuthError(failure.message));
      },
      (updatedUser) async {
        print('AssignRole API Success!');
        print(
            '   API returned hasCompletedDetails: ${updatedUser.hasCompletedDetails}');

        final finalUser = updatedUser.copyWith(
          token: token,
          // Preserve locations if they were fetched before the role change
          locations: currentUser.locations,
          hasLocation: currentUser.hasLocation,
          primaryLocationId: currentUser.primaryLocationId,
          hasCompletedDetails: false, // Assuming details must be completed after role change
        );

        print('Saving user data to storage...');
        print('   Final hasCompletedDetails: ${finalUser.hasCompletedDetails}');
        await _saveUserData(finalUser);

        print('Emitting AuthSuccess state...');
        emit(AuthSuccess(
          finalUser,
          message: "Role assigned successfully.",
        ));

        print('Role assignment complete! Final role: ${finalUser.role}');
      },
    );
  }

  // ========================================
  // SUBMIT FARMER DETAILS HANDLER
  // ========================================

  Future<void> _onSubmitFarmerDetails(
    SubmitFarmerDetails event,
    Emitter<AuthState> emit,
  ) async {
    if (_isProcessingFarmerDetails) {
      print(
          'Farmer details submission already in progress, ignoring duplicate');
      return;
    }

    print('Farmer Details Submission Started...');

    final currentState = state;
    if (currentState is! AuthSuccess) {
      print('Cannot submit: User not authenticated');
      emit(const AuthError("Please log in to continue."));
      return;
    }

    final currentUser = currentState.user;

    if (currentUser.token == null || currentUser.token!.isEmpty) {
      print('Cannot submit: Token is missing');
      emit(const AuthError(
          "Authentication token missing. Please log in again."));
      return;
    }

    if (currentUser.hasCompletedDetails) {
      print('Details already completed locally. Skipping API call.');
      emit(AuthSuccess(
        currentUser,
        message: "Profile already completed.",
      ));
      return;
    }

    _isProcessingFarmerDetails = true;
    emit(AuthLoading());

    final result = await registerFarmerUseCase(
      farmName: event.farmName,
      farmPurpose: event.farmPurpose,
      totalLandAcres: event.totalLandAcres,
      yearsExperience: event.yearsExperience,
      locationId: event.locationId,
      token: event.token ?? currentUser.token!,
      profilePhotoBase64: event.profilePhotoBase64,
    );

    await result.fold(
      (failure) async {
        print('Farmer Details Submission Failed: ${failure.message}');
        _isProcessingFarmerDetails = false;

        if (failure is FarmerRegistrationFailure &&
            failure.profileAlreadyExists) {
          print('Profile already exists - updating local state');
          final updatedUser = currentUser.copyWith(hasCompletedDetails: true);
          await _saveUserData(updatedUser);
          emit(AuthSuccess(updatedUser,
              message: "Profile already exists. Redirecting to dashboard..."));
          return;
        }

        if (failure is ValidationFailure) {
          print('Validation Error:');
          failure.errors?.forEach((key, value) => print('   - $key: $value'));
          emit(AuthError(
              '${failure.message}\n${_formatValidationErrors(failure.errors)}'));
          return;
        }

        if (failure is AuthFailure) {
          emit(AuthError('${failure.message}\nPlease log in again.'));
          return;
        }

        emit(AuthError(failure.message));
      },
      (updatedUser) async {
        print('Farmer Details Submitted Successfully!');
        _isProcessingFarmerDetails = false;

        // Preserve locations from current state when updating user details
        final finalUser = updatedUser.copyWith(
          locations: currentUser.locations,
          hasLocation: currentUser.hasLocation,
          primaryLocationId: currentUser.primaryLocationId,
        );

        await _saveUserData(finalUser);

        emit(AuthSuccess(
          finalUser,
          message: "Farmer profile created successfully!",
        ));
      },
    );
  }

  // ========================================
  // USER LOCATION UPDATED HANDLER
  // ========================================

  Future<void> _onUserLocationUpdated(
    UserLocationUpdated event,
    Emitter<AuthState> emit,
  ) async {
    print('UserLocationUpdated Event Received');
    print('   Location ID: ${event.location.locationId}');
    print('   Display Name: ${event.location.displayName}');
    print('   Role: ${event.role}');

    if (state is! AuthSuccess) {
      print('Cannot update location: Not in AuthSuccess state');
      return;
    }

    final currentState = state as AuthSuccess;
    final currentUser = currentState.user;

    // Create a mutable copy of the locations list
    final updatedLocations =
        List<LocationEntity>.from(currentUser.locations ?? []);

    // Remove any existing location with the same ID (prevents duplicates)
    updatedLocations
        .removeWhere((loc) => loc.locationId == event.location.locationId);

    // Add the new location
    updatedLocations.add(event.location);

    // Update the user with full location data
    final updatedUser = currentUser.copyWith(
      hasLocation: true,
      primaryLocationId: event.location.locationId,
      locations: updatedLocations,
      role: event.role ?? currentUser.role,
      hasCompletedDetails: currentUser.hasCompletedDetails,
    );

    print('Updated user now has ${updatedLocations.length} location(s)');
    print('   Primary Location ID: ${updatedUser.primaryLocationId}');
    print('   hasLocation: ${updatedUser.hasLocation}');

    try {
      await _saveUserData(updatedUser);
      print('User data persisted successfully');

      emit(AuthSuccess(
        updatedUser,
        message: "Location saved successfully!",
      ));

      print(
          'AuthSuccess emitted - Farmer details form will now show the location');
    } catch (e) {
      print('Failed to persist user data: $e');
      emit(AuthSuccess(
        updatedUser,
        message: "Location saved, but failed to save locally.",
      ));
    }
  }

  // ========================================
  // LOGOUT EVENT HANDLER
  // ========================================

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    _isProcessingLogin = false;
    _isProcessingRegistration = false;
    _isProcessingFarmerDetails = false;

    await _storage.deleteAll();
    print('User logged out, storage cleared');

    emit(AuthInitial());
  }

  // ========================================
  // CHECK AUTH STATUS HANDLER
  // ========================================

  Future<void> _onCheckAuthStatus(
    CheckAuthStatus event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthInitial());
  }

  // ========================================
  // HELPER METHODS
  // ========================================

  Future<void> _saveUserData(UserEntity user) async {
    try {
      if (user.token != null && user.token!.isNotEmpty) {
        await _storage.write(key: 'access_token', value: user.token);
      }

      await _storage.write(key: 'user_id', value: user.id.toString());
      await _storage.write(key: 'user_role', value: user.role);
      await _storage.write(
          key: 'has_location', value: user.hasLocation.toString());
      await _storage.write(
          key: 'has_completed_details',
          value: user.hasCompletedDetails.toString());

      if (user.primaryLocationId != null) {
        await _storage.write(
            key: 'primary_location_id',
            value: user.primaryLocationId.toString());
      }

      if (user.locations != null) {
        await _storage.write(
            key: 'locations_count', value: user.locations!.length.toString());
      }

      print('User data saved to secure storage');
    } catch (e) {
      print('Error saving user data: $e');
    }
  }

  String _formatValidationErrors(Map<String, dynamic>? errors) {
    if (errors == null || errors.isEmpty) return '';

    final errorMessages = <String>[];
    errors.forEach((field, messages) {
      if (messages is List && messages.isNotEmpty) {
        errorMessages.add('• ${messages.first}');
      } else if (messages is String) {
        errorMessages.add('• $messages');
      }
    });

    return errorMessages.join('\n');
  }
}