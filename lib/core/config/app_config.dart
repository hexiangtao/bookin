import 'package:flutter/foundation.dart';

class AppConfig {
  static const String appName = 'Bookin';
  static const String appVersion = '1.0.0';
  
  // API配置 - 与H5项目保持一致
  static const String prodApiBaseUrl = 'https://m.meijiandaojia.com/api';
  static const String devApiBaseUrl = 'https://m.meijiandaojia.com/api';
  static const String localApiBaseUrl = 'https://m.meijiandaojia.com/api';
  
  // 当前环境的API地址
  static String get apiBaseUrl {
    if (kDebugMode) {
      // 开发环境，可以根据需要切换
      return devApiBaseUrl;
      // return localApiBaseUrl; // 本地开发时使用
    }
    return prodApiBaseUrl;
  }
  
  // 网络配置
  static const int connectTimeout = 30000;
  static const int receiveTimeout = 30000;
  static const int sendTimeout = 30000;
  
  // 分页配置
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;
  
  // 缓存配置
  static const int cacheMaxAge = 300; // 5分钟
  static const int cacheMaxStale = 86400; // 24小时
  
  // 图片配置
  static const int imageQuality = 85;
  static const int maxImageSize = 1024 * 1024; // 1MB
  
  // 地图配置
  static const String mapApiKey = 'your_map_api_key';
  static const double defaultLatitude = 39.9042;
  static const double defaultLongitude = 116.4074;
  
  // 支付配置
  static const String wechatAppId = 'your_wechat_app_id';
  static const String alipayAppId = 'your_alipay_app_id';
  
  // 第三方服务配置
  static const String umengAppKey = 'your_umeng_app_key';
  static const String buglyAppId = 'your_bugly_app_id';
  
  // 功能开关
  static const bool enableAnalytics = true;
  static const bool enableCrashReport = true;
  static const bool enablePush = true;
  static const bool enableLocation = true;
  
  // 调试配置
  static const bool enableApiLog = kDebugMode;
  static const bool enablePerformanceMonitor = kDebugMode;
  static const bool enableMemoryMonitor = kDebugMode;
  
  // 业务配置
  static const int maxBookingDays = 30; // 最多可预约30天后的服务
  static const int minBookingHours = 2; // 最少提前2小时预约
  static const double maxServiceRadius = 50.0; // 最大服务半径50公里
  
  // UI配置
  static const double defaultBorderRadius = 8.0;
  static const double defaultPadding = 16.0;
  static const double defaultMargin = 16.0;
  
  // 颜色配置
  static const int primaryColorValue = 0xFF6C5CE7;
  static const int accentColorValue = 0xFFFF5777;
  static const int successColorValue = 0xFF00B894;
  static const int warningColorValue = 0xFFFFB347;
  static const int errorColorValue = 0xFFE17055;
  
  // 字体配置
  static const String fontFamily = 'PingFang SC';
  static const double baseFontSize = 14.0;
  
  // 动画配置
  static const int defaultAnimationDuration = 300;
  static const int fastAnimationDuration = 150;
  static const int slowAnimationDuration = 500;
  
  // 存储键名
  static const String keyUserToken = 'user_token';
  static const String keyUserInfo = 'user_info';
  static const String keyAppSettings = 'app_settings';
  static const String keyLocationPermission = 'location_permission';
  static const String keyNotificationPermission = 'notification_permission';
  
  // 环境判断
  static bool get isProduction => !kDebugMode;
  static bool get isDevelopment => kDebugMode;
  
  // 平台判断
  static bool get isAndroid => defaultTargetPlatform == TargetPlatform.android;
  static bool get isIOS => defaultTargetPlatform == TargetPlatform.iOS;
  static bool get isWeb => kIsWeb;
  
  // 获取完整的API URL
  static String getApiUrl(String endpoint) {
    return '$apiBaseUrl$endpoint';
  }
  
  // 获取图片URL（添加参数）
  static String getImageUrl(String imageUrl, {int? width, int? height, int? quality}) {
    if (imageUrl.isEmpty) return '';
    
    // 如果是完整URL，直接返回
    if (imageUrl.startsWith('http')) {
      return imageUrl;
    }
    
    // 如果是相对路径，拼接基础URL
    var url = '$apiBaseUrl$imageUrl';
    
    // 添加图片处理参数
    final params = <String>[];
    if (width != null) params.add('w=$width');
    if (height != null) params.add('h=$height');
    if (quality != null) params.add('q=$quality');
    
    if (params.isNotEmpty) {
      url += '?${params.join('&')}';
    }
    
    return url;
  }
  
  // 打印配置信息（仅调试模式）
  static void printConfig() {
    if (!kDebugMode) return;
    
    print('=== App Configuration ===');
    print('App Name: $appName');
    print('App Version: $appVersion');
    print('Environment: ${isDevelopment ? "Development" : "Production"}');
    print('API Base URL: $apiBaseUrl');
    print('Platform: ${defaultTargetPlatform.name}');
    print('Debug Mode: $kDebugMode');
    print('Web Mode: $kIsWeb');
    print('========================');
  }
}