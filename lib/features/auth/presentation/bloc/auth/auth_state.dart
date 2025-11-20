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

  // FIX: This getter is correct and will now work because primaryLocationId and locations are in UserEntity
  bool get hasLocation => user.primaryLocationId != null || (user.locations?.isNotEmpty ?? false);

  @override
  List<Object?> get props => [user, message];
}

class RegistrationComplete extends AuthState {
  final String? message;
  const RegistrationComplete({this.message});

  @override
  List<Object?> get props => [message];
}

class RoleAssigned extends AuthState {
  final String role;
  final UserEntity user; // Made non-final so we can update it later if needed
  final String? message;

  RoleAssigned({
    required this.role,
    required this.user,
    this.message,
  });

  @override
  List<Object?> get props => [role, user, message];
}