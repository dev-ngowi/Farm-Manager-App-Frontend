import 'package:farm_manager_app/features/auth/data/domain/entities/user_entity.dart';
import 'package:farm_manager_app/features/auth/data/domain/usecases/auth/login_usecase.dart';
import 'package:farm_manager_app/features/auth/data/domain/usecases/auth/register_usecase.dart';
import 'package:farm_manager_app/features/auth/data/domain/usecases/auth/assign_role_usecase.dart';
import 'package:farm_manager_app/features/auth/presentation/bloc/auth/auth_state.dart';
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
    
    // ========== REGISTER EVENT ==========
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
      
      await result.fold(
        (failure) async {
          print('❌ Register Error: ${failure.message}');
          emit(AuthError(failure.message));
        },
        (user) async {
          print('✅ Register Success: ${user.firstname}');
          await _saveUserData(user);
          emit(RegistrationComplete());
        },
      );
    });

    // ========== LOGIN EVENT ==========
    on<LoginSubmitted>((event, emit) async {
      emit(AuthLoading());
      
      final result = await loginUseCase(event.login, event.password);
      
      await result.fold(
        (failure) async {
          print('❌ Login Error: ${failure.message}');
          emit(AuthError(failure.message));
        },
        (user) async {
          print('✅ Login Success: ${user.firstname}, Role: ${user.role}');
          await _saveUserData(user);
          emit(AuthSuccess(user));
        },
      );
    });

    // ========== ASSIGN ROLE EVENT ==========
    on<AssignRoleSubmitted>((event, emit) async {
      print('📌 AssignRole Started: ${event.role}');
      emit(AuthLoading());
      
      final result = await assignRoleUseCase(role: event.role);
      
      await result.fold(
        (failure) async {
          // 🔍 DEBUG: Print detailed error information
          print('❌ AssignRole Error: ${failure.message}');
          print('❌ Error Type: ${failure.runtimeType}');
          emit(AuthError(failure.message));
        },
        (updatedUser) async {
          // 🔍 DEBUG: Print success information
          print('✅ AssignRole Success!');
          print('✅ User ID: ${updatedUser.id}');
          print('✅ User Role: ${updatedUser.role}');
          print('✅ User Name: ${updatedUser.firstname} ${updatedUser.lastname}');
          
          await _saveUserData(updatedUser);
          
          // ✅ Emit ONLY RoleAssigned state (no AuthSuccess after)
          emit(RoleAssigned(
            role: updatedUser.role!,
            user: updatedUser,
            message: "Role assigned successfully.",
          ));
        },
      );
    });

    // ========== LOGOUT EVENT ==========
    on<LogoutRequested>((event, emit) async {
      await _storage.deleteAll();
      emit(AuthInitial());
    });
  }

  /// Helper function to persist essential user data in secure storage.
  Future<void> _saveUserData(UserEntity user) async {
    try {
      // Save token if available
      if (user.token != null && user.token!.isNotEmpty) {
        await _storage.write(key: 'access_token', value: user.token);
        print('💾 Token saved');
      }

      // Save user ID
      await _storage.write(key: 'user_id', value: user.id.toString());
      print('💾 User ID saved: ${user.id}');

      // Save user name
      final userName = '${user.firstname ?? ''} ${user.lastname ?? ''}'.trim();
      if (userName.isNotEmpty) {
        await _storage.write(key: 'user_name', value: userName);
        print('💾 User name saved: $userName');
      }

      // Save user role
      if (user.role != null && user.role!.isNotEmpty) {
        await _storage.write(key: 'user_role', value: user.role);
        print('💾 User role saved: ${user.role}');
      }
    } catch (e) {
      print('❌ Error saving user data: $e');
    }
  }
}