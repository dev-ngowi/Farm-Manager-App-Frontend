import 'package:farm_manager_app/features/auth/data/domain/entities/user_entity.dart';
import 'package:farm_manager_app/features/auth/data/domain/usecases/login_usecase.dart';
import 'package:farm_manager_app/features/auth/data/domain/usecases/register_usecase.dart';
import 'package:farm_manager_app/features/auth/data/domain/usecases/assign_role_usecase.dart';
import 'package:farm_manager_app/features/auth/presentation/bloc/auth_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

part 'auth_event.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase loginUseCase;
  final RegisterUseCase registerUseCase;
  final AssignRoleUseCase assignRoleUseCase;
  final _storage = const FlutterSecureStorage();

  AuthBloc({
    required this.loginUseCase,
    required this.registerUseCase,
    required this.assignRoleUseCase,
  }) : super(AuthInitial()) {
    
    on<RegisterSubmitted>((event, emit) async {
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

      // FIX: Use await and handle the fold result synchronously
      await result.fold(
        (failure) async {
          emit(AuthError(failure.message));
        },
        (user) async {
          await _saveUserData(user);
          emit(RegistrationComplete()); // Use RegistrationComplete to match your UI
        },
      );
    });

    on<LoginSubmitted>((event, emit) async {
      emit(AuthLoading());
      
      final result = await loginUseCase(event.login, event.password);

      // FIX: Use await and handle the fold result synchronously
      await result.fold(
        (failure) async {
          emit(AuthError(failure.message));
        },
        (user) async {
          await _saveUserData(user);
          emit(AuthSuccess(user)); // Changed from LoginSuccess to AuthSuccess
        },
      );
    });

    on<AssignRoleSubmitted>((event, emit) async {
      emit(AuthLoading());
      
      final result = await assignRoleUseCase(role: event.role);

      // FIX: Use await and handle the fold result synchronously
      await result.fold(
        (failure) async {
          emit(AuthError(failure.message));
        },
        (updatedUser) async {
          await _saveUserData(updatedUser);
          emit(RoleAssigned(event.role));
        },
      );
    });

    on<LogoutRequested>((event, emit) async {
      await _storage.deleteAll();
      emit(AuthInitial());
    });
  }

  /// Helper function to persist essential user data in secure storage.
  Future<void> _saveUserData(UserEntity user) async {
    // Save token if available
    if (user.token != null) {
      await _storage.write(key: 'access_token', value: user.token);
    }
    
    // Save user ID
    await _storage.write(key: 'user_id', value: user.id.toString());
    
    // Save user name
    await _storage.write(
      key: 'user_name',
      value: '${user.firstname ?? ''} ${user.lastname ?? ''}'.trim(),
    );
    
    // Save user role
    if (user.role != null) {
      await _storage.write(key: 'user_role', value: user.role);
    }
  }
}