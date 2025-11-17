import 'package:equatable/equatable.dart';
import 'package:farm_manager_app/features/auth/data/domain/entities/user_entity.dart';

class UserModel extends Equatable {
  final int id;
  final String firstname;
  final String lastname;
  final String username;
  final String? email;
  final String? phoneNumber;
  final String role;

  const UserModel({
    required this.id,
    required this.firstname,
    required this.lastname,
    required this.username,
    this.email,
    this.phoneNumber,
    required this.role,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      firstname: json['firstname'],
      lastname: json['lastname'],
      username: json['username'],
      email: json['email'],
      phoneNumber: json['phone_number'],
      role: json['role'],
    );
  }

  UserEntity toEntity() {
  return UserEntity(
    id: id ?? 0,
    firstname: firstname ?? '',
    lastname: lastname ?? '',
    email: email,
    phoneNumber: phoneNumber ?? '',
    username: username ?? '',
    role: role ?? 'farmer',
    token: '',
  );
}

// Optional: add copyWith
UserEntity copyWith({String? token}) => toEntity().copyWith(token: token);

  @override
  List<Object?> get props => [id, username, role];
}