import 'dart:convert';

import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_model.dart';

class StorageService extends GetxService {
  static const String _userKey = 'current_user';
  static const String _tokenKey = 'auth_token';

  late SharedPreferences _prefs;

  Future<StorageService> init() async {
    _prefs = await SharedPreferences.getInstance();
    return this;
  }

  Future<void> saveUser(UserModel user) async {
    await _prefs.setString(_userKey, jsonEncode(user.toJson()));
  }

  Future<UserModel?> getUser() async {
    final str = _prefs.getString(_userKey);
    if (str == null) return null;
    return UserModel.fromJson(jsonDecode(str) as Map<String, dynamic>);
  }

  Future<void> clearUser() async {
    await _prefs.remove(_userKey);
  }

  // Token 相关方法
  Future<void> saveToken(String token) async {
    await _prefs.setString(_tokenKey, token);
  }

  String? getToken() {
    return _prefs.getString(_tokenKey);
  }

  Future<void> removeToken() async {
    await _prefs.remove(_tokenKey);
  }

  bool get isLoggedIn => getToken() != null;
}