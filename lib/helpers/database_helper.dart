import 'package:shared_preferences/shared_preferences.dart';

class DatabaseHelper {
  static const String _keyUsername = 'username';
  static const String _keyPassword = 'password';

  static Future<void> saveUserData(String username, String password) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUsername, username);
    await prefs.setString(_keyPassword, password);
  }

  static Future<Map<String, String?>> getUserData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? username = prefs.getString(_keyUsername);
    final String? password = prefs.getString(_keyPassword);
    return {
      'username': username,
      'password': password,
    };
  }

  static Future<void> clearUserData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyUsername);
    await prefs.remove(_keyPassword);
  }
}
