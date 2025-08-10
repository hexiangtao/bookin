import 'package:flutter/material.dart';
import 'package:bookin/features/auth/data/api/user_api.dart';
import 'package:bookin/shared/services/storage_service.dart';
import 'dart:convert';

class UserProvider with ChangeNotifier {
  UserInfo? _userInfo;
  bool _isLoggedIn = false;

  UserInfo? get userInfo => _userInfo;
  bool get isLoggedIn => _isLoggedIn;

  UserProvider() {
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    final userInfoJson = await StorageService.getUserInfo();
    final token = await StorageService.getToken();
    if (userInfoJson != null && token != null && token.isNotEmpty) {
      _userInfo = UserInfo.fromJson(jsonDecode(userInfoJson));
      _isLoggedIn = true;
    } else {
      _userInfo = null;
      _isLoggedIn = false;
    }
    notifyListeners();
  }

  Future<void> login(BuildContext context, String phone, String code, {String? inviteCode}) async {
    try {
      final response = await UserApi().login(context, phone, code, inviteCode: inviteCode);
      if (response.success && response.data != null) {
        final token = response.data!['token'] as String;
        final userInfo = response.data!['userInfo'] as UserInfo;
        _userInfo = userInfo;
        _isLoggedIn = true;
        await StorageService.setUserInfo(jsonEncode(_userInfo!.toJson()));
      await StorageService.setToken(token);
        notifyListeners();
      } else {
        throw Exception(response.message);
      }
    } catch (e) {
      throw Exception('Login failed: ${e.toString()}');
    }
  }

  Future<void> loginWithPassword(BuildContext context, String phone, String password) async {
    try {
      final response = await UserApi().loginWithPassword(context, phone, password);
      if (response.success && response.data != null) {
        final token = response.data!['token'] as String;
        final userInfo = response.data!['userInfo'] as UserInfo;
        _userInfo = userInfo;
        _isLoggedIn = true;
        await StorageService.setUserInfo(jsonEncode(_userInfo!.toJson()));
      await StorageService.setToken(token);
        notifyListeners();
      } else {
        throw Exception(response.message);
      }
    } catch (e) {
      throw Exception('Password login failed: ${e.toString()}');
    }
  }

  Future<void> wechatLogin(BuildContext context, String code, {String? inviteCode}) async {
    try {
      final response = await UserApi().wechatLogin(context, code, inviteCode: inviteCode);
      if (response.success && response.data != null) {
        final token = response.data!['token'] as String;
        final userInfo = response.data!['userInfo'] as UserInfo;
        _userInfo = userInfo;
        _isLoggedIn = true;
        await StorageService.setUserInfo(jsonEncode(_userInfo!.toJson()));
        await StorageService.setToken(token);
        notifyListeners();
      } else {
        throw Exception(response.message);
      }
    } catch (e) {
      throw Exception('WeChat login failed: ${e.toString()}');
    }
  }

  Future<void> logout(BuildContext context) async {
    final UserApi userApi = UserApi();
    final response = await userApi.logout(context);
    if (response.success) {
      _userInfo = null;
      _isLoggedIn = false;
      await StorageService.removeToken();
      await StorageService.removeUserInfo();
      if (context.mounted) {
        notifyListeners();
      }
    } else {
      throw Exception(response.message);
    }
  }

  Future<void> fetchUserInfo(BuildContext context) async {
    final UserApi userApi = UserApi();
    final response = await userApi.getInfo(context);
    if (response.success && response.data != null) {
      _userInfo = response.data;
      _isLoggedIn = true;
      await StorageService.setUserInfo(jsonEncode(_userInfo!.toJson()));
      if (context.mounted) {
        notifyListeners();
      }
    } else {
      _userInfo = null;
      _isLoggedIn = false;
      await StorageService.removeToken(); // Clear token if fetching fails
      await StorageService.removeUserInfo();
      if (context.mounted) {
        notifyListeners();
      }
      // Check if it's an authorization error (token expired)
      if (response.message.contains('登录状态已过期') || response.message.contains('Unauthorized')) {
        // Don't throw exception for expired login, just clear the state
        print('Login status expired, cleared user data');
      } else {
        // For other errors, still throw the exception
        throw Exception(response.message);
      }
    }
  }

  Future<void> updateUserInfo(BuildContext context, UserInfo updatedInfo) async {
    final UserApi userApi = UserApi();
    final response = await userApi.updateInfo(context, updatedInfo);
    if (response.success && response.data != null) {
      _userInfo = response.data;
      await StorageService.setUserInfo(jsonEncode(_userInfo!.toJson()));
      if (context.mounted) {
        notifyListeners();
      }
    } else {
      throw Exception(response.message);
    }
  }
}
