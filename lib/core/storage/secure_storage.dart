import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStore {
  SecureStore._();
  static final instance = SecureStore._();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<void> setToken(String token) =>
      _storage.write(key: 'token', value: token);
  Future<String?> getToken() => _storage.read(key: 'token');
  Future<void> clearToken() => _storage.delete(key: 'token');
}
