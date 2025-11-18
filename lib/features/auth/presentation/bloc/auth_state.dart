import 'package:equatable/equatable.dart';
import 'package:farm_manager_app/features/auth/data/domain/entities/user_entity.dart';

abstract class AuthState extends Equatable {
  const AuthState();
  
  @override
  List<Object> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthError extends AuthState {
  final String message;
  
  const AuthError(this.message);
  
  @override
  List<Object> get props => [message];
}

// Used for successful login - contains user data
class AuthSuccess extends AuthState {
  final UserEntity user;
  
  const AuthSuccess(this.user);
  
  @override
  List<Object> get props => [user];
}

// Used for successful registration - no user data needed, just navigate to login
class RegistrationComplete extends AuthState {}

// Used when a role is successfully assigned
class RoleAssigned extends AuthState {
  final String role;
  
  const RoleAssigned(this.role);
  
  @override
  List<Object> get props => [role];
}