// lib/features/auth/presentation/bloc/auth/auth_state.dart

import 'package:equatable/equatable.dart';
import 'package:farm_manager_app/features/auth/data/domain/entities/user_entity.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthError extends AuthState {
  final String message;
  const AuthError(this.message);

  @override
  List<Object?> get props => [message];
}

class AuthSuccess extends AuthState {
  final UserEntity user;
  final String? message;

  const AuthSuccess(this.user, {this.message});

  @override
  List<Object?> get props => [user, message];
}

class AuthNavigateToLogin extends AuthState {
  final String message;

  const AuthNavigateToLogin(this.message);

  @override
  List<Object> get props => [message];
}