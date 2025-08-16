import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'api_client.dart';
import 'api_endpoints.dart';
import 'network_exception.dart';
import 'storage_service.dart';
import '../config/app_config.dart';
import '../models/user_model.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();
  
  static AuthService get instance => _instance;
  
  /// 发送验证码
  /// [phone] 手机号
  /// [type] 验证码类型：login-登录，register-注册，reset-重置密码
  Future<Map<String, dynamic>> sendCode({
    required String phone,
    String type = 'login',
  }) async {
    try {
      final response = await ApiClient().post(
        ApiEndpoints.sendCode,
        data: {
          'phone': phone,
          'type': type,
        },
      );
      
      if (AppConfig.enableApiLog) {
        print('📱 Send code response: ${response.data}');
      }
      
      return {
        'success': response.data['code'] == "0",
        'message': response.data['msg'] ?? '',
        'data': response.data['data'],
      };
    } on DioException catch (e) {
      if (AppConfig.enableApiLog) {
        print('❌ Send code error: ${e.message}');
      }
      
      final error = NetworkException.fromDioException(e);
      return {
        'success': false,
        'message': error.message,
        'data': null,
      };
    } catch (e) {
      if (AppConfig.enableApiLog) {
        print('❌ Send code unexpected error: $e');
      }
      
      return {
        'success': false,
        'message': '发送验证码失败',
        'data': null,
      };
    }
  }
  
  /// 手机号验证码登录
  /// [phone] 手机号
  /// [code] 验证码
  /// [inviteCode] 邀请码（可选）
  Future<Map<String, dynamic>> loginWithCode({
    required String phone,
    required String code,
    String? inviteCode,
  }) async {
    try {
      final data = {
        'phone': phone,
        'code': code,
        'type': 'phone',
      };
      
      if (inviteCode != null && inviteCode.isNotEmpty) {
        data['invite_code'] = inviteCode;
      }
      
      final response = await ApiClient().post(
        ApiEndpoints.login,
        data: data,
      );
      
      if (AppConfig.enableApiLog) {
        print('📱 Login with code response: ${response.data}');
      }
      
      final result = {
        'success': response.data['code'] == "0",
        'message': response.data['msg'] ?? '',
        'data': response.data['data'],
      };
      
      // 登录成功后保存token和用户信息
      if (result['success'] && result['data'] != null) {
        await _saveLoginData(result['data']);
      }
      
      return result;
    } on DioException catch (e) {
      if (AppConfig.enableApiLog) {
        print('❌ Login with code error: ${e.message}');
      }
      
      final error = NetworkException.fromDioException(e);
      return {
        'success': false,
        'message': error.message,
        'data': null,
      };
    } catch (e) {
      if (AppConfig.enableApiLog) {
        print('❌ Login with code unexpected error: $e');
      }
      
      return {
        'success': false,
        'message': '登录失败',
        'data': null,
      };
    }
  }
  
  /// 密码登录
  /// [phone] 手机号
  /// [password] 密码
  Future<Map<String, dynamic>> loginWithPassword({
    required String phone,
    required String password,
  }) async {
    try {
      final response = await ApiClient().post(
        ApiEndpoints.passwordLogin,
        data: {
          'phone': phone,
          'password': password,
        },
      );
      
      if (AppConfig.enableApiLog) {
        print('🔐 Login with password response: ${response.data}');
      }
      
      final result = {
        'success': response.data['code'] == "0",
        'message': response.data['msg'] ?? '',
        'data': response.data['data'],
      };
      
      // 登录成功后保存token和用户信息
      if (result['success'] && result['data'] != null) {
        await _saveLoginData(result['data']);
      }
      
      return result;
    } on DioException catch (e) {
      if (AppConfig.enableApiLog) {
        print('❌ Login with password error: ${e.message}');
      }
      
      final error = NetworkException.fromDioException(e);
      return {
        'success': false,
        'message': error.message,
        'data': null,
      };
    } catch (e) {
      if (AppConfig.enableApiLog) {
        print('❌ Login with password unexpected error: $e');
      }
      
      return {
        'success': false,
        'message': '登录失败',
        'data': null,
      };
    }
  }
  
  /// 微信登录
  /// [code] 微信授权码
  /// [encryptedData] 加密数据（可选）
  /// [iv] 初始向量（可选）
  Future<Map<String, dynamic>> loginWithWechat({
    required String code,
    String? encryptedData,
    String? iv,
  }) async {
    try {
      final data = {
        'code': code,
        'type': 'wechat',
      };
      
      if (encryptedData != null) {
        data['encrypted_data'] = encryptedData;
      }
      
      if (iv != null) {
        data['iv'] = iv;
      }
      
      final response = await ApiClient().post(
        ApiEndpoints.wechatLogin,
        data: data,
      );
      
      if (AppConfig.enableApiLog) {
        print('💚 Wechat login response: ${response.data}');
      }
      
      final result = {
        'success': response.data['code'] == "0",
        'message': response.data['msg'] ?? '',
        'data': response.data['data'],
      };
      
      // 登录成功后保存token和用户信息
      if (result['success'] && result['data'] != null) {
        await _saveLoginData(result['data']);
      }
      
      return result;
    } on DioException catch (e) {
      if (AppConfig.enableApiLog) {
        print('❌ Wechat login error: ${e.message}');
      }
      
      final error = NetworkException.fromDioException(e);
      return {
        'success': false,
        'message': error.message,
        'data': null,
      };
    } catch (e) {
      if (AppConfig.enableApiLog) {
        print('❌ Wechat login unexpected error: $e');
      }
      
      return {
        'success': false,
        'message': '微信登录失败',
        'data': null,
      };
    }
  }
  
  /// 绑定手机号
  /// [phone] 手机号
  /// [code] 验证码
  /// [token] 临时token（微信登录后获取）
  Future<Map<String, dynamic>> bindPhone({
    required String phone,
    required String code,
    String? token,
  }) async {
    try {
      final data = {
        'phone': phone,
        'code': code,
      };
      
      if (token != null) {
        data['temp_token'] = token;
      }
      
      final response = await ApiClient().post(
        '/auth/bind-phone',
        data: data,
      );
      
      if (AppConfig.enableApiLog) {
        print('📱 Bind phone response: ${response.data}');
      }
      
      final result = {
        'success': response.data['code'] == "0",
        'message': response.data['msg'] ?? '',
        'data': response.data['data'],
      };
      
      // 绑定成功后保存token和用户信息
      if (result['success'] && result['data'] != null) {
        await _saveLoginData(result['data']);
      }
      
      return result;
    } on DioException catch (e) {
      if (AppConfig.enableApiLog) {
        print('❌ Bind phone error: ${e.message}');
      }
      
      final error = NetworkException.fromDioException(e);
      return {
        'success': false,
        'message': error.message,
        'data': null,
      };
    } catch (e) {
      if (AppConfig.enableApiLog) {
        print('❌ Bind phone unexpected error: $e');
      }
      
      return {
        'success': false,
        'message': '绑定手机号失败',
        'data': null,
      };
    }
  }
  
  /// 登出
  Future<Map<String, dynamic>> logout() async {
    try {
      // 清除本地存储的用户数据
      await StorageService().clearUserData();
      
      if (AppConfig.enableApiLog) {
        print('👋 User logged out');
      }
      
      return {
        'success': true,
        'message': '退出登录成功',
        'data': null,
      };
    } catch (e) {
      if (AppConfig.enableApiLog) {
        print('❌ Logout error: $e');
      }
      
      return {
        'success': false,
        'message': '退出登录失败',
        'data': null,
      };
    }
  }
  
  /// 刷新token
  Future<Map<String, dynamic>> refreshToken() async {
    try {
      final response = await ApiClient().post(
        ApiEndpoints.refreshToken,
      );
      
      if (AppConfig.enableApiLog) {
        print('🔄 Refresh token response: ${response.data}');
      }
      
      final result = {
          'success': response.data['code'] == "0",
          'message': response.data['msg'] ?? '',
          'data': response.data['data'],
        };
        
        // 刷新成功后保存新的token
      if (result['success'] && result['data'] != null) {
        final data = result['data'] as Map<String, dynamic>;
        final token = data['token'] as String?;
        if (token != null) {
          await StorageService().saveToken(token);
        }
      }
      
      return result;
    } on DioException catch (e) {
      if (AppConfig.enableApiLog) {
        print('❌ Refresh token error: ${e.message}');
      }
      
      final error = NetworkException.fromDioException(e);
      return {
        'success': false,
        'message': error.message,
        'data': null,
      };
    } catch (e) {
      if (AppConfig.enableApiLog) {
        print('❌ Refresh token unexpected error: $e');
      }
      
      return {
        'success': false,
        'message': '刷新token失败',
        'data': null,
      };
    }
  }
  
  /// 检查是否已登录
  Future<bool> isLoggedIn() async {
    final token = StorageService().getToken();
    return token != null && token.isNotEmpty;
  }
  
  /// 同步检查是否已认证
  bool get isAuthenticated {
    final token = StorageService().getToken();
    return token != null && token.isNotEmpty;
  }
  
  /// 检查token是否过期
  bool isTokenExpired() {
    // 这里可以根据实际需求实现token过期检查逻辑
    // 目前简单返回false，表示token未过期
    return false;
  }
  
  /// 获取当前用户信息
  Future<UserModel?> getCurrentUser() async {
    return StorageService().getUserInfo();
  }
  
  /// 保存登录数据
  Future<void> _saveLoginData(Map<String, dynamic> data) async {
    try {
      // 保存token
      final token = data['token'] as String?;
      if (token != null && token.isNotEmpty) {
        await StorageService().saveToken(token);
        if (AppConfig.enableApiLog) {
          print('💾 Token saved');
        }
      }
      
      // 保存用户信息 - 尝试从 userInfo 或 user 字段获取
      Map<String, dynamic>? userInfo = data['userInfo'] as Map<String, dynamic>?;
      userInfo ??= data['user'] as Map<String, dynamic>?;
      
      if (userInfo != null) {
        final user = UserModel.fromJson(userInfo);
        await StorageService().saveUserInfo(user);
        if (AppConfig.enableApiLog) {
          print('💾 User info saved: ${user.nickname ?? userInfo['phone']}');
        }
      } else {
        if (AppConfig.enableApiLog) {
          print('⚠️ No user info found in login response');
        }
      }
    } catch (e) {
      if (AppConfig.enableApiLog) {
        print('❌ Save login data error: $e');
      }
    }
  }
}