import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final int id;
  final String firstname;
  final String lastname;
  final String? email;
  final String phoneNumber;
  final String username;
  final String role;
  final String token;

  const UserEntity({
    required this.id,
    required this.firstname,
    required this.lastname,
    this.email,
    required this.phoneNumber,
    required this.username,
    required this.role,
    required this.token,
  });

  // copyWith method, necessary for immutability when updating fields (like the token)
  UserEntity copyWith({
    int? id,
    String? firstname,
    String? lastname,
    String? email,
    String? phoneNumber,
    String? username,
    String? role,
    String? token,
  }) {
    return UserEntity(
      id: id ?? this.id,
      firstname: firstname ?? this.firstname,
      lastname: lastname ?? this.lastname,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      username: username ?? this.username,
      role: role ?? this.role,
      token: token ?? this.token,
    );
  }

  @override
  List<Object?> get props => [
        id,
        firstname,
        lastname,
        email,
        phoneNumber,
        username,
        role,
        token,
      ];
}