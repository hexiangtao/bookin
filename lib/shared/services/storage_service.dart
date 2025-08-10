import 'dart:convert';

import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_model.dart';

class StorageService extends GetxService {
  static const String _userKey = 'current_user';

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
}