import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  final _storage = const FlutterSecureStorage();

  Future<void> saveUserSession(Map<String, dynamic> userData) async {
    await _storage.write(key: 'user_id', value: userData['id']);
    await _storage.write(key: 'email', value: userData['email']);
    await _storage.write(key: 'name', value: userData['name']);
    await _storage.write(key: 'token', value: userData['token']);
  }

  Future<Map<String, String?>> getUserSession() async {
    return {
      'user_id': await _storage.read(key: 'user_id'),
      'email': await _storage.read(key: 'email'),
      'name': await _storage.read(key: 'name'),
      'token': await _storage.read(key: 'token'),
    };
  }

  Future<void> clearUserSession() async {
    await _storage.deleteAll();
  }

  // Guardar un dato
  Future<void> writeSecureData(String key, String value) async {
    await _storage.write(key: key, value: value);
  }

  // Leer un dato
  Future<String?> readSecureData(String key) async {
    return await _storage.read(key: key);
  }

  // Borrar un dato
  Future<void> deleteSecureData(String key) async {
    await _storage.delete(key: key);
  }

  // Borrar todo
  Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}
