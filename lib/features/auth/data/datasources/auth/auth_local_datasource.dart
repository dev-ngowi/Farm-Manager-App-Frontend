import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../models/user_model.dart';

abstract class AuthLocalDataSource {
  Future<void> cacheToken(String token);
  Future<void> cacheUser(UserModel user);
  Future<String?> getToken();
  Future<UserModel?> getUser();
  Future<void> clear();

}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final FlutterSecureStorage storage;

  AuthLocalDataSourceImpl(this.storage);

  static const _tokenKey = 'auth_token';
  static const _userKey = 'cached_user';

  @override
  Future<void> cacheToken(String token) => storage.write(key: _tokenKey, value: token);

  @override
  Future<void> cacheUser(UserModel user) =>
      storage.write(key: _userKey, value: user.toString());

  @override
  Future<String?> getToken() => storage.read(key: _tokenKey);

  @override
  Future<UserModel?> getUser() async {
    final json = await storage.read(key: _userKey);
    if (json == null) return null;
    return null; // We'll improve later with Hive
  }

  @override
  Future<void> clear() => storage.deleteAll();
}