import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _tokenKey = 'user_token';
  static const String _userInfoKey = 'user_info'; // Store user info as JSON string

  // Save user token
  static Future<void> setToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  // Get user token
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  // Remove user token
  static Future<void> removeToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  // Save user info (as JSON string)
  static Future<void> setUserInfo(String userInfoJson) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userInfoKey, userInfoJson);
  }

  // Get user info (as JSON string)
  static Future<String?> getUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userInfoKey);
  }

  // Remove user info
  static Future<void> removeUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userInfoKey);
  }

  // Clear all stored data (use with caution)
  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
