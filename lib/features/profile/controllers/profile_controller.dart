import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../core/models/user_model.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/user_service.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/config/app_config.dart';
import '../widgets/logout_confirm_dialog.dart';

class ProfileController extends GetxController {
  // 用户信息
  final Rx<UserModel?> userInfo = Rx<UserModel?>(null);
  
  // 加载状态
  final RxBool isLoading = false.obs;
  final RxBool isRefreshing = false.obs;
  
  // 布局配置
  final RxString layoutType = 'default'.obs;
  
  // 订单统计
  final RxMap<String, int> orderStats = <String, int>{}.obs;
  
  // 优惠券数量
  final RxInt couponCount = 0.obs;
  
  // 钱包余额
  final RxDouble walletBalance = 0.0.obs;
  
  // 用户头像主色调
  final Rx<Color?> avatarDominantColor = Rx<Color?>(null);
  
  final UserService _userService = UserService.instance;
  final AuthService _authService = AuthService.instance;
  
  @override
  void onInit() {
    super.onInit();
    _initializeProfile();
  }
  
  /// 初始化用户资料
  Future<void> _initializeProfile() async {
    await checkLoginAndRedirect();
    if (_authService.isAuthenticated) {
      await loadUserInfo();
    }
  }
  
  /// 检查登录状态并重定向
  Future<void> checkLoginAndRedirect() async {
    if (!_authService.isAuthenticated) {
      // 跳转到登录页面
      Get.toNamed('/login');
      return;
    }
    
    // 检查token是否过期
    if (_authService.isTokenExpired()) {
      // 尝试刷新token
      final refreshResult = await _authService.refreshToken();
      if (!refreshResult['success']) {
        // 刷新失败，跳转到登录页面
        Get.toNamed('/login');
        return;
      }
    }
  }
  
  /// 加载用户信息
  Future<void> loadUserInfo({bool refresh = false}) async {
    if (!_authService.isAuthenticated) {
      await checkLoginAndRedirect();
      return;
    }
    
    try {
      if (refresh) {
        isRefreshing.value = true;
      } else {
        isLoading.value = true;
      }
      
      // 获取用户信息
      final result = await _userService.getUserInfo(refresh: refresh);
      
      if (result['success'] == true && result['data'] != null) {
        final data = result['data'] as Map<String, dynamic>;
        
        // 更新用户信息
        if (data['userInfo'] != null) {
          userInfo.value = UserModel.fromJson(data['userInfo']);
          
          // 根据用户信息设置布局类型
          _updateLayoutType();
          
          // 提取头像主色调
          _extractAvatarDominantColor();
        }
        
        // 更新订单统计
        if (data['orderCount'] != null) {
          final orderCount = data['orderCount'] as Map<String, dynamic>;
          orderStats.value = orderCount.map((key, value) => MapEntry(key, value as int));
        }
        
        // 更新优惠券数量
        if (data['couponCount'] != null) {
          couponCount.value = data['couponCount'] as int;
        }
        
        // 更新钱包余额
        if (data['walletBalance'] != null) {
          walletBalance.value = (data['walletBalance'] as num).toDouble();
        }
        
        if (AppConfig.enableApiLog) {
          print('📱 Profile loaded: ${userInfo.value?.nickname}');
        }
      } else {
        _handleApiError(result['message'] ?? '获取用户信息失败');
      }
    } catch (e) {
      if (AppConfig.enableApiLog) {
        print('❌ Load user info error: $e');
      }
      _handleApiError('获取用户信息失败');
    } finally {
      isLoading.value = false;
      isRefreshing.value = false;
    }
  }
  
  /// 静默更新用户信息
  Future<void> silentUpdateUserInfo() async {
    if (!_authService.isAuthenticated) {
      return;
    }
    
    try {
      final result = await _userService.getUserInfo(refresh: true);
      
      if (result['success'] == true && result['data'] != null) {
        final data = result['data'] as Map<String, dynamic>;
        
        if (data['userInfo'] != null) {
          userInfo.value = UserModel.fromJson(data['userInfo']);
          _updateLayoutType();
          _extractAvatarDominantColor();
        }
        
        if (AppConfig.enableApiLog) {
          print('🔄 Profile silently updated: ${userInfo.value?.nickname}');
        }
      }
    } catch (e) {
      if (AppConfig.enableApiLog) {
        print('❌ Silent update user info error: $e');
      }
    }
  }
  
  /// 更新布局类型
  void _updateLayoutType() {
    final user = userInfo.value;
    if (user == null) {
      layoutType.value = 'default';
      return;
    }
    
    // 根据用户类型或其他条件设置布局
    // 这里可以根据实际业务逻辑调整
    if (user.userType == 'technician' || user.isTechnician == true) {
      layoutType.value = 'technician';
    } else {
      layoutType.value = 'default';
    }
    
    if (AppConfig.enableApiLog) {
      print('🎨 Layout type updated: ${layoutType.value}');
    }
  }
  
  /// 处理API错误
  void _handleApiError(String message) {
    Get.snackbar(
      '提示',
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.red.withOpacity(0.8),
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
    );
  }
  
  /// 处理导航
  void handleNavigation(String type, {Map<String, dynamic>? params}) {
    switch (type) {
      case 'orders':
        Get.toNamed('/orders', parameters: params?.map((key, value) => MapEntry(key, value.toString())) ?? {});
        break;
      case 'favorites':
        Get.toNamed('/favorites');
        break;
      case 'coupons':
        Get.toNamed('/coupons');
        break;
      case 'wallet':
        Get.toNamed('/user/wallet');
        break;
      case 'settings':
        Get.toNamed('/settings');
        break;
      case 'technician_center':
        Get.toNamed('/technician/center');
        break;
      case 'technician_recruitment':
        Get.toNamed('/technician/recruitment');
        break;
      case 'nearby_stores':
        Get.toNamed('/stores/nearby');
        break;
      case 'customer_service':
        _contactCustomerService();
        break;
      case 'about':
        Get.toNamed('/about');
        break;
      case 'feedback':
        Get.toNamed('/feedback');
        break;
      case 'invite_friends':
        Get.toNamed('/invite');
        break;
      case 'edit_profile':
        Get.toNamed('/user/edit');
        break;
      case 'membership':
        Get.toNamed('/membership');
        break;
      case 'settings':
        Get.toNamed('/settings');
        break;
      default:
        if (AppConfig.enableApiLog) {
          print('⚠️ Unknown navigation type: $type');
        }
        break;
    }
  }
  
  /// 联系客服
  void _contactCustomerService() {
    // 这里可以实现联系客服的逻辑
    // 比如打开客服聊天、拨打电话等
    Get.snackbar(
      '客服',
      '正在为您转接客服...',
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.blue.withOpacity(0.8),
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
    );
  }
  
  /// 退出登录
  Future<void> logout() async {
    try {
      // 显示确认对话框
      final confirmed = await Get.dialog<bool>(
        LogoutConfirmDialog(
          onConfirm: () => Get.back(result: true),
          onCancel: () => Get.back(result: false),
        ),
      );
      
      if (confirmed == true) {
        await _authService.logout();
        
        // 清空用户信息
        userInfo.value = null;
        orderStats.clear();
        couponCount.value = 0;
        walletBalance.value = 0.0;
        layoutType.value = 'default';
        
        // 跳转到登录页面
        Get.offAllNamed('/login');
        
        Get.snackbar(
          '提示',
          '已退出登录',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green.withOpacity(0.8),
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );
      }
    } catch (e) {
      if (AppConfig.enableApiLog) {
        print('❌ Logout error: $e');
      }
      _handleApiError('退出登录失败');
    }
  }
  
  /// 刷新页面
  Future<void> onRefresh() async {
    await loadUserInfo(refresh: true);
  }
  
  /// 设置用户头像背景色
  Color getUserAvatarBackground() {
    final user = userInfo.value;
    if (user?.avatar?.isNotEmpty == true) {
      return Colors.transparent;
    }
    
    // 根据用户名生成背景色
    final name = user?.nickname ?? user?.phone ?? 'U';
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
      Colors.teal,
      Colors.indigo,
      Colors.pink,
    ];
    
    final index = name.hashCode % colors.length;
    return colors[index.abs()];
  }
  
  /// 获取用户显示名称
  String getUserDisplayName() {
    final user = userInfo.value;
    if (user?.nickname?.isNotEmpty == true) {
      return user!.nickname!;
    }
    if (user?.phone?.isNotEmpty == true) {
      // 隐藏手机号中间4位
      final phone = user!.phone!;
      if (phone.length >= 11) {
        return '${phone.substring(0, 3)}****${phone.substring(7)}';
      }
      return phone;
    }
    return '用户';
  }
  
  /// 提取用户头像主色调
  Future<void> _extractAvatarDominantColor() async {
    final user = userInfo.value;
    if (user?.avatar?.isNotEmpty != true) {
      avatarDominantColor.value = null;
      return;
    }
    
    // 异步执行，避免阻塞UI
    Future.microtask(() async {
      try {
        final imageProvider = CachedNetworkImageProvider(user!.avatar!);
        PaletteGenerator? paletteGenerator;
        try {
          paletteGenerator = await PaletteGenerator.fromImageProvider(
            imageProvider,
            maximumColorCount: 16,
          ).timeout(
            const Duration(seconds: 5), // 减少超时时间
          );
        } on TimeoutException {
          if (AppConfig.enableApiLog) {
            print('⏰ Avatar color extraction timeout, using default');
          }
          paletteGenerator = null;
        }
      
        if (paletteGenerator != null) {
          // 优先选择柔和的颜色，调整亮度和饱和度
          Color? dominantColor = paletteGenerator.mutedColor?.color ?? 
                                paletteGenerator.lightMutedColor?.color ??
                                paletteGenerator.vibrantColor?.color ?? 
                                paletteGenerator.dominantColor?.color;
          
          // 如果提取到颜色，进行更精细的调整
          if (dominantColor != null) {
            final hsl = HSLColor.fromColor(dominantColor);
            // 确保颜色既不太暗也不太亮，饱和度适中
            final adjustedLightness = hsl.lightness < 0.3 
                ? 0.5  // 太暗的颜色调亮
                : hsl.lightness > 0.8 
                    ? 0.7  // 太亮的颜色调暗
                    : (hsl.lightness * 1.1).clamp(0.4, 0.8);  // 适中的颜色稍微调整
            
            final adjustedSaturation = (hsl.saturation * 0.7).clamp(0.3, 0.8);
            
            dominantColor = hsl.withSaturation(adjustedSaturation)
                              .withLightness(adjustedLightness)
                              .toColor();
          }
          
          avatarDominantColor.value = dominantColor;
          
          if (AppConfig.enableApiLog) {
            print('🎨 Avatar dominant color extracted: $dominantColor');
          }
        } else {
          avatarDominantColor.value = null;
        }
      } catch (e) {
        if (AppConfig.enableApiLog) {
          print('❌ Extract avatar color error: $e');
        }
        avatarDominantColor.value = null;
      }
    });
  }
}