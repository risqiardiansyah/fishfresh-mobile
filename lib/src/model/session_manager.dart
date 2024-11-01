import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SessionManager {
  final storage = const FlutterSecureStorage();

  Future<void> saveSession(String key, value) async {
    await storage.write(key: key, value: value);
  }

  Future getSession(String key) async {
    var data = await storage.read(key: key);

    return data;
  }

  Future<void> clearSession() async {
    await storage.delete(key: 'token');
    await storage.delete(key: 'user');
  }
}
