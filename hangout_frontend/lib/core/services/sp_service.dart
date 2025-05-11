import 'package:shared_preferences/shared_preferences.dart';

class SpService {
  static const String _tokenKey = 'x-auth-token';
  static const String _userIdKey = 'user-id';

  Future<void> setToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(_tokenKey, token);
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  Future<void> setId(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(_userIdKey, userId);
  }

  Future<String?> getId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userIdKey);
  }
}
