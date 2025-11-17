// lib/features/auth/presentation/bloc/auth_event.dart
part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

class LoginSubmitted extends AuthEvent {
  final String login;
  final String password;

  const LoginSubmitted({required this.login, required this.password});

  @override
  List<Object> get props => [login, password];
}

class RegisterSubmitted extends AuthEvent {
  final String firstname;
  final String lastname;
  final String phoneNumber;
  final String? email;
  final String password;
  final String passwordConfirmation;

  const RegisterSubmitted({
    required this.firstname,
    required this.lastname,
    required this.phoneNumber,
    this.email,
    required this.password,
    required this.passwordConfirmation,
  });

  @override
  List<Object> get props => [firstname, lastname, phoneNumber, email ?? '', password];
}