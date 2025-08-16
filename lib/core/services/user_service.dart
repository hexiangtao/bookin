import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../models/user_model.dart';
import 'api_client.dart';
import 'api_endpoints.dart';
import 'network_exception.dart';
import '../config/app_config.dart';
import 'storage_service.dart';

class UserService {
  static final UserService _instance = UserService._internal();
  factory UserService() => _instance;
  UserService._internal();
  
  static UserService get instance => _instance;
  
  final ApiClient _apiClient = ApiClient();
  
  /// 获取用户信息
  /// [refresh] 是否强制刷新，false时优先使用缓存
  Future<Map<String, dynamic>> getUserInfo({bool refresh = false}) async {
    try {
      // 如果不强制刷新，且本地有用户信息，则直接返回
      if (!refresh) {
        final cachedUserInfo = StorageService().getUserInfo();
        if (cachedUserInfo != null) {
          if (AppConfig.enableApiLog) {
            print('📱 Using cached user info: ${cachedUserInfo.nickname}');
          }
          return {
            'success': true,
            'message': '获取用户信息成功',
            'data': {
              'userInfo': cachedUserInfo.toJson(),
              'orderCount': {'all': 0}, // 默认值，实际应从接口获取
              'couponCount': 0, // 默认值，实际应从接口获取
            },
          };
        }
      }
      
      // 调用获取用户信息API
      final response = await _apiClient.get(ApiEndpoints.userInfo);
      
      if (AppConfig.enableApiLog) {
        print('📱 Get user info response: ${response.data}');
      }
      
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        if ((data['code'] == 0 || data['code'] == '0' || data['success'] == true) && data['data'] != null) {
          // 更新本地用户信息缓存
          final userInfoData = data['data']['userInfo'] as Map<String, dynamic>?;
          if (userInfoData != null) {
            final user = UserModel.fromJson(userInfoData);
            await StorageService().saveUserInfo(user);
            if (AppConfig.enableApiLog) {
              print('💾 User info cached: ${user.nickname}');
            }
          }
          
          return {
            'success': true,
            'message': data['msg'] ?? '获取用户信息成功',
            'data': data['data'],
          };
        }
      }
      
      throw NetworkException(
        message: '获取用户信息失败',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      if (AppConfig.enableApiLog) {
        print('❌ Get user info error: ${e.message}');
      }
      
      final error = NetworkException.fromDioException(e);
      return {
        'success': false,
        'message': error.message,
        'data': null,
      };
    } catch (e) {
      if (AppConfig.enableApiLog) {
        print('❌ Get user info unexpected error: $e');
      }
      
      return {
        'success': false,
        'message': '获取用户信息失败',
        'data': null,
      };
    }
  }
  
  /// 更新用户信息
  /// [userInfo] 要更新的用户信息
  Future<Map<String, dynamic>> updateUserInfo(Map<String, dynamic> userInfo) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.updateUserInfo,
        data: userInfo,
      );
      
      if (AppConfig.enableApiLog) {
        print('📱 Update user info response: ${response.data}');
      }
      
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        if ((data['code'] == 0 || data['code'] == '0' || data['success'] == true)) {
          // 如果返回了更新后的用户信息，更新本地缓存
          if (data['data'] != null && data['data']['userInfo'] != null) {
            final userInfoData = data['data']['userInfo'] as Map<String, dynamic>;
            final user = UserModel.fromJson(userInfoData);
            await StorageService().saveUserInfo(user);
            if (AppConfig.enableApiLog) {
              print('💾 Updated user info cached: ${user.nickname}');
            }
          }
          
          return {
            'success': true,
            'message': data['msg'] ?? '更新用户信息成功',
            'data': data['data'],
          };
        }
      }
      
      throw NetworkException(
        message: '更新用户信息失败',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      if (AppConfig.enableApiLog) {
        print('❌ Update user info error: ${e.message}');
      }
      
      final error = NetworkException.fromDioException(e);
      return {
        'success': false,
        'message': error.message,
        'data': null,
      };
    } catch (e) {
      if (AppConfig.enableApiLog) {
        print('❌ Update user info unexpected error: $e');
      }
      
      return {
        'success': false,
        'message': '更新用户信息失败',
        'data': null,
      };
    }
  }
  
  /// 获取用户订单统计
  Future<Map<String, dynamic>> getUserOrderStats() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.userOrders);
      
      if (AppConfig.enableApiLog) {
        print('📱 Get user order stats response: ${response.data}');
      }
      
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        if ((data['code'] == 0 || data['code'] == '0' || data['success'] == true) && data['data'] != null) {
          return {
            'success': true,
            'message': data['msg'] ?? '获取订单统计成功',
            'data': data['data'],
          };
        }
      }
      
      throw NetworkException(
        message: '获取订单统计失败',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      if (AppConfig.enableApiLog) {
        print('❌ Get user order stats error: ${e.message}');
      }
      
      final error = NetworkException.fromDioException(e);
      return {
        'success': false,
        'message': error.message,
        'data': null,
      };
    } catch (e) {
      if (AppConfig.enableApiLog) {
        print('❌ Get user order stats unexpected error: $e');
      }
      
      return {
        'success': false,
        'message': '获取订单统计失败',
        'data': null,
      };
    }
  }
  
  /// 获取用户优惠券统计
  Future<Map<String, dynamic>> getUserCouponStats() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.userCoupons);
      
      if (AppConfig.enableApiLog) {
        print('📱 Get user coupon stats response: ${response.data}');
      }
      
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        if ((data['code'] == 0 || data['code'] == '0' || data['success'] == true) && data['data'] != null) {
          return {
            'success': true,
            'message': data['msg'] ?? '获取优惠券统计成功',
            'data': data['data'],
          };
        }
      }
      
      throw NetworkException(
        message: '获取优惠券统计失败',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      if (AppConfig.enableApiLog) {
        print('❌ Get user coupon stats error: ${e.message}');
      }
      
      final error = NetworkException.fromDioException(e);
      return {
        'success': false,
        'message': error.message,
        'data': null,
      };
    } catch (e) {
      if (AppConfig.enableApiLog) {
        print('❌ Get user coupon stats unexpected error: $e');
      }
      
      return {
        'success': false,
        'message': '获取优惠券统计失败',
        'data': null,
      };
    }
  }
}