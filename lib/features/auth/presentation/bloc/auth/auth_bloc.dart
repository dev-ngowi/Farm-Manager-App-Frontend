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
    on<AssignRoleSubmitted>(_onAssignRoleSubmitted);
    on<SubmitFarmerDetails>(_onSubmitFarmerDetails);
    on<LogoutRequested>(_onLogoutRequested);
    on<CheckAuthStatus>(_onCheckAuthStatus);
    on<UserLocationUpdated>(_onUserLocationUpdated);
    on<UserDetailsUpdated>(_onUserDetailsUpdated); 
  }

  // lib/features/auth/presentation/bloc/auth/auth_bloc.dart
  // FIXED VERSION - Properly handles UserDetailsUpdated event

  // ========================================
  // USER DETAILS UPDATED HANDLER (COMPLETE FIX)
  // ========================================
  Future<void> _onUserDetailsUpdated(
    UserDetailsUpdated event,
    Emitter<AuthState> emit,
  ) async {
    print('========================================');
    print('AuthBloc: UserDetailsUpdated received');
    print('========================================');

    final currentState = state;
    String? preservedToken;
    List<LocationEntity>? preservedLocations;
    bool? preservedHasLocation;
    int? preservedPrimaryLocationId;

    // Step 1: Try to get data from current AuthSuccess state
    if (currentState is AuthSuccess) {
      preservedToken = currentState.user.token;
      preservedLocations = currentState.user.locations;
      preservedHasLocation = currentState.user.hasLocation;
      preservedPrimaryLocationId = currentState.user.primaryLocationId;
      print('✅ Retrieved data from AuthSuccess state');
      print('   Token exists: ${preservedToken != null}');
      print('   Locations count: ${preservedLocations?.length ?? 0}');
      print('   Has Location: $preservedHasLocation');
      print('   Primary Location ID: $preservedPrimaryLocationId');
    } else {
      // Step 2: If not AuthSuccess, read from secure storage (CRITICAL FIX)
      print('⚠️  State is not AuthSuccess. Reading from secure storage...');

      try {
        preservedToken = await _storage.read(key: 'access_token');
        final hasLocationStr = await _storage.read(key: 'has_location');
        final primaryLocationIdStr =
            await _storage.read(key: 'primary_location_id');
        final locationsCountStr = await _storage.read(key: 'locations_count');

        preservedHasLocation = hasLocationStr == 'true';
        preservedPrimaryLocationId = primaryLocationIdStr != null
            ? int.tryParse(primaryLocationIdStr)
            : null;

        print('✅ Retrieved from secure storage:');
        print('   Token exists: ${preservedToken != null}');
        print('   Has Location: $preservedHasLocation');
        print('   Primary Location ID: $preservedPrimaryLocationId');
        print('   Locations count: ${locationsCountStr ?? '0'}');
      } catch (e) {
        print('❌ Error reading from storage: $e');
      }
    }

    // Step 3: Merge event data with preserved data
    print('');
    print('Merging user data...');
    print('   Event user:');
    print('      ID: ${event.user.id}');
    print('      Role: ${event.user.role}');
    print('      hasCompletedDetails: ${event.user.hasCompletedDetails}');
    print('      hasDetailsApproved: ${event.user.hasDetailsApproved}');
    print('      hasLocation: ${event.user.hasLocation}');
    print('      token: ${event.user.token != null ? "provided" : "null"}');
    print('   Preserved data:');
    print('      hasLocation: $preservedHasLocation');
    print('      primaryLocationId: $preservedPrimaryLocationId');
    print('      locations count: ${preservedLocations?.length ?? 0}');

    // 🎯 CRITICAL FIX: Determine which location data to use
    // Priority: preserved data > event data (because researcher/vet detail APIs don't return location)
    final bool finalHasLocation =
        preservedHasLocation ?? event.user.hasLocation ?? false;
    final int? finalPrimaryLocationId =
        preservedPrimaryLocationId ?? event.user.primaryLocationId;
    final List<LocationEntity>? finalLocations =
        preservedLocations ?? event.user.locations;

    print('');
    print('Final location decision:');
    print(
        '   hasLocation: $finalHasLocation (preserved: $preservedHasLocation, event: ${event.user.hasLocation})');
    print(
        '   primaryLocationId: $finalPrimaryLocationId (preserved: $preservedPrimaryLocationId, event: ${event.user.primaryLocationId})');
    print('   locations count: ${finalLocations?.length ?? 0}');

    final finalUser = event.user.copyWith(
      // 🎯 Token: Use preserved token if event doesn't have one
      token: event.user.token ?? preservedToken,

      // 🎯 CRITICAL: Always use preserved location data first
      // The researcher/vet details API responses don't include location info
      locations: finalLocations,
      hasLocation: finalHasLocation,
      primaryLocationId: finalPrimaryLocationId,

      // 🎯 CRITICAL: These MUST come from the API response (event.user)
      hasCompletedDetails: event.user.hasCompletedDetails,
      hasDetailsApproved: event.user.hasDetailsApproved,
    );

    // Step 4: Validate final user data
    print('');
    print('Final merged user:');
    print('   ID: ${finalUser.id}');
    print('   Role: ${finalUser.role}');
    print(
        '   Token exists: ${finalUser.token != null && finalUser.token!.isNotEmpty}');
    print('   Has Location: ${finalUser.hasLocation}');
    print('   Primary Location ID: ${finalUser.primaryLocationId}');
    print('   Locations count: ${finalUser.locations?.length ?? 0}');
    print('   Has Completed Details: ${finalUser.hasCompletedDetails}');
    print('   Has Details Approved: ${finalUser.hasDetailsApproved}');

    if (finalUser.token == null || finalUser.token!.isEmpty) {
      print('');
      print('❌ CRITICAL ERROR: Token is still missing after merge!');
      print('   Cannot save to secure storage or maintain auth state.');
      emit(const AuthError('Authentication error. Please log in again.'));
      return;
    }

    // Step 5: Save to secure storage
    print('');
    print('Saving user data to secure storage...');
    await _saveUserData(finalUser);
    print('✅ User data saved successfully');

    // Step 6: Emit AuthSuccess with updated user
    emit(AuthSuccess(
      finalUser,
      message: finalUser.hasCompletedDetails
          ? 'Profile updated successfully!'
          : 'User details synchronized.',
    ));

    print('');
    print('✅ AuthSuccess emitted with updated user details');
    print('   Router should now see:');
    print('   - Role: ${finalUser.role}');
    print('   - hasLocation: ${finalUser.hasLocation}');
    print('   - hasCompletedDetails: ${finalUser.hasCompletedDetails}');
    print('   - hasDetailsApproved: ${finalUser.hasDetailsApproved}');
    print('========================================');
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
        
        // ⭐ NEW: Handle ValidationFailure and show detailed errors
        if (failure is ValidationFailure) {
          print('Validation Error:');
          failure.errors?.forEach((key, value) => print('   - $key: $value'));

          final formattedErrors = _formatValidationErrors(failure.errors);

          final errorMessage = formattedErrors.isNotEmpty
              ? 'Please correct the following errors:\n$formattedErrors'
              : failure.message; 
              
          emit(AuthError(errorMessage));
          return;
        }

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
          final locationResult =
              await locationRepository.getUserLocations(user.token!);

          await locationResult.fold(
            (locationFailure) {
              print(
                  'Location Fetch Error (Post-Login): ${locationFailure.message}');
              // Continue with user data if location fetch fails
            },
            (locations) {
              print('Location Fetch Success: Found ${locations.length} locations.');
              final bool hasAnyLocation = locations.isNotEmpty;
              final LocationEntity? primaryLocation =
                  LocationEntity.findPrimary(locations);

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
  // REMOVED: FETCH USER LOCATIONS HANDLER (Kept for reference)
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
  // SUBMIT FARMER DETAILS HANDLER - WITH VALIDATION ERROR FIX
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

        // ⭐ FIX: Handle ValidationFailure to prioritize detailed errors
        if (failure is ValidationFailure) {
          print('Validation Error:');
          failure.errors?.forEach((key, value) => print('   - $key: $value'));

          final formattedErrors = _formatValidationErrors(failure.errors);

          // Use the formatted errors as the primary message
          final errorMessage = formattedErrors.isNotEmpty
              ? 'Please correct the following errors:\n$formattedErrors'
              : failure.message; // Fallback to the general message

          emit(AuthError(errorMessage));
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
      // 🎯 NEW: Save the hasDetailsApproved flag
      // Assumes UserEntity now contains hasDetailsApproved
      await _storage.write(
          key: 'has_details_approved',
          value: user.hasDetailsApproved.toString());

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

  /// Helper method to format a backend map of validation errors into a user-friendly string.
  /// Example: { "field1": ["error message 1"], "field2": ["error message 2"] }
  /// Output: "• error message 1\n• error message 2"
  String _formatValidationErrors(Map<String, dynamic>? errors) {
    if (errors == null || errors.isEmpty) return '';

    final errorMessages = <String>[];
    errors.forEach((field, messages) {
      if (messages is List && messages.isNotEmpty) {
        // Only use the first error message for a given field
        errorMessages.add('• ${messages.first}');
      } else if (messages is String) {
        errorMessages.add('• $messages');
      }
    });

    return errorMessages.join('\n');
  }
}