part of 'auth_bloc.dart';

// --- Base Event ---
abstract class AuthEvent extends Equatable {
  const AuthEvent();
  
  @override
  List<Object> get props => [];
}

// --- Registration Events ---
class RegisterSubmitted extends AuthEvent {
  final String firstname;
  final String lastname;
  final String phoneNumber;
  final String? email;
  final String password;
  final String passwordConfirmation;
  final String role; // Role is required for the new register flow

  const RegisterSubmitted({
    required this.firstname,
    required this.lastname,
    required this.phoneNumber,
    this.email,
    required this.password,
    required this.passwordConfirmation,
    required this.role,
  });

  @override
  List<Object> get props => [
    firstname,
    lastname,
    phoneNumber,
    password,
    passwordConfirmation,
    role
  ];
}

// --- Login Events ---
class LoginSubmitted extends AuthEvent {
  final String login;
  final String password;

  // Changed to named parameters to match how it's being called
  const LoginSubmitted({
    required this.login,
    required this.password,
  });

  @override
  List<Object> get props => [login, password];
}

// --- NEW Role Assignment Event ---
class AssignRoleSubmitted extends AuthEvent {
  final String role;

  const AssignRoleSubmitted({required this.role});

  @override
  List<Object> get props => [role];
}

// --- Logout Events ---
class LogoutRequested extends AuthEvent {}