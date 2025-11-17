import 'user_model.dart';

class LoginResponseModel {
  final String accessToken;
  final UserModel user;

  LoginResponseModel({required this.accessToken, required this.user});

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
    return LoginResponseModel(
      accessToken: json['data']['access_token'],
      user: UserModel.fromJson(json['data']['user']),
    );
  }
}