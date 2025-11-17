// lib/features/auth/domain/entities/user_entity.dart
class UserEntity {
  final int id;
  final String firstname;
  final String lastname;
  final String? email;
  final String phoneNumber;
  final String username;
  final String role;
  final String token;

  UserEntity({
    required this.id,
    required this.firstname,
    required this.lastname,
    this.email,
    required this.phoneNumber,
    required this.username,
    required this.role,
    required this.token,
  });

  UserEntity toEntity() {
  return UserEntity(
    id: id,
    firstname: firstname,
    lastname: lastname,
    email: email,
    phoneNumber: phoneNumber,
    username: username,
    role: role,
    token: '', // token comes from login response
  );
}

// Also add copyWith if not exist
UserEntity copyWith({String? token}) {
  return UserEntity(
    id: id,
    firstname: firstname,
    lastname: lastname,
    email: email,
    phoneNumber: phoneNumber,
    username: username,
    role: role,
    token: token ?? '',
  );
}
}