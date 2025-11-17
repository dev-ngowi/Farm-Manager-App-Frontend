// lib/features/auth/presentation/bloc/auth_bloc.dart
import 'package:farm_manager_app/features/auth/data/domain/entities/user_entity.dart';
import 'package:farm_manager_app/features/auth/data/domain/usecases/login_usecase.dart';
import 'package:farm_manager_app/features/auth/data/domain/usecases/register_usecase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../../core/error/failure.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase loginUseCase;
  final RegisterUseCase registerUseCase;
  final _storage = const FlutterSecureStorage();

  AuthBloc({
    required this.loginUseCase,
    required this.registerUseCase,
  }) : super(AuthInitial()) {
    // HANDLE LOGIN
    on<LoginSubmitted>((event, emit) async {
      emit(AuthLoading());
      final result = await loginUseCase(event.login, event.password);
      result.fold(
        (failure) => emit(AuthError(failure.message)),
        (user) async {
          await _saveUserData(user);
          emit(AuthSuccess(user));
        },
      );
    });

    // HANDLE REGISTER
    on<RegisterSubmitted>((event, emit) async {
      emit(AuthLoading());
      final result = await registerUseCase(
        firstname: event.firstname,
        lastname: event.lastname,
        phoneNumber: event.phoneNumber,
        email: event.email,
        password: event.password,
        passwordConfirmation: event.passwordConfirmation,
      );

      result.fold(
        (failure) => emit(AuthError(failure.message)),
        (user) async {
          await _saveUserData(user);
          emit(AuthSuccess(user)); // This will trigger role selection page
        },
      );
    });
  }

  Future<void> _saveUserData(UserEntity user) async {
    await _storage.write(key: 'auth_token', value: user.token);
    await _storage.write(key: 'user_role', value: user.role);
    await _storage.write(key: 'user_id', value: user.id.toString());
    await _storage.write(key: 'user_name', value: '${user.firstname} ${user.lastname}');
  }
}