import 'dart:convert';
import 'package:get_storage/get_storage.dart';
import 'package:flutter/foundation.dart';
import '../config/app_config.dart';
import '../models/user_model.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  late GetStorage _box;
  GetStorage get box => _box;

  /// 初始化存储服务
  Future<void> init() async {
    await GetStorage.init();
    _box = GetStorage();
    
    if (AppConfig.enableApiLog) {
      print('📦 Storage Service initialized');
    }
  }

  // ==================== 用户相关 ====================
  
  /// 保存用户Token
  Future<void> saveToken(String token) async {
    await _box.write(AppConfig.keyUserToken, token);
    if (AppConfig.enableApiLog) {
      print('🔐 Token saved');
    }
  }
  
  /// 获取用户Token
  String? getToken() {
    return _box.read<String>(AppConfig.keyUserToken);
  }
  
  /// 删除用户Token
  Future<void> removeToken() async {
    await _box.remove(AppConfig.keyUserToken);
    if (AppConfig.enableApiLog) {
      print('🔐 Token removed');
    }
  }
  
  /// 检查是否已登录
  bool get isLoggedIn {
    final token = getToken();
    return token != null && token.isNotEmpty;
  }
  
  /// 保存用户信息
  Future<void> saveUserInfo(UserModel user) async {
    await _box.write(AppConfig.keyUserInfo, user.toJson());
    if (AppConfig.enableApiLog) {
      print('👤 User info saved: ${user.nickname}');
    }
  }
  
  /// 获取用户信息
  UserModel? getUserInfo() {
    final data = _box.read<Map<String, dynamic>>(AppConfig.keyUserInfo);
    if (data != null) {
      try {
        return UserModel.fromJson(data);
      } catch (e) {
        if (AppConfig.enableApiLog) {
          print('❌ Failed to parse user info: $e');
        }
        return null;
      }
    }
    return null;
  }
  
  /// 删除用户信息
  Future<void> removeUserInfo() async {
    await _box.remove(AppConfig.keyUserInfo);
    if (AppConfig.enableApiLog) {
      print('👤 User info removed');
    }
  }
  
  /// 清除所有用户数据
  Future<void> clearUserData() async {
    await removeToken();
    await removeUserInfo();
    if (AppConfig.enableApiLog) {
      print('🧹 All user data cleared');
    }
  }

  // ==================== 应用设置 ====================
  
  /// 保存应用设置
  Future<void> saveAppSettings(Map<String, dynamic> settings) async {
    await _box.write(AppConfig.keyAppSettings, settings);
    if (AppConfig.enableApiLog) {
      print('⚙️ App settings saved');
    }
  }
  
  /// 获取应用设置
  Map<String, dynamic> getAppSettings() {
    return _box.read<Map<String, dynamic>>(AppConfig.keyAppSettings) ?? {};
  }
  
  /// 保存单个设置项
  Future<void> saveSetting(String key, dynamic value) async {
    final settings = getAppSettings();
    settings[key] = value;
    await saveAppSettings(settings);
  }
  
  /// 获取单个设置项
  T? getSetting<T>(String key, [T? defaultValue]) {
    final settings = getAppSettings();
    return settings[key] as T? ?? defaultValue;
  }

  // ==================== 权限相关 ====================
  
  /// 保存位置权限状态
  Future<void> saveLocationPermission(bool granted) async {
    await _box.write(AppConfig.keyLocationPermission, granted);
  }
  
  /// 获取位置权限状态
  bool getLocationPermission() {
    return _box.read<bool>(AppConfig.keyLocationPermission) ?? false;
  }
  
  /// 保存通知权限状态
  Future<void> saveNotificationPermission(bool granted) async {
    await _box.write(AppConfig.keyNotificationPermission, granted);
  }
  
  /// 获取通知权限状态
  bool getNotificationPermission() {
    return _box.read<bool>(AppConfig.keyNotificationPermission) ?? false;
  }

  // ==================== 缓存相关 ====================
  
  /// 保存缓存数据（带过期时间）
  Future<void> saveCache(String key, dynamic data, {Duration? expiry}) async {
    final cacheData = {
      'data': data,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'expiry': expiry?.inMilliseconds,
    };
    await _box.write('cache_$key', cacheData);
  }
  
  /// 获取缓存数据
  T? getCache<T>(String key) {
    final cacheData = _box.read<Map<String, dynamic>>('cache_$key');
    if (cacheData == null) return null;
    
    final timestamp = cacheData['timestamp'] as int?;
    final expiry = cacheData['expiry'] as int?;
    
    if (timestamp != null && expiry != null) {
      final now = DateTime.now().millisecondsSinceEpoch;
      if (now - timestamp > expiry) {
        // 缓存已过期，删除并返回null
        removeCache(key);
        return null;
      }
    }
    
    return cacheData['data'] as T?;
  }
  
  /// 删除缓存数据
  Future<void> removeCache(String key) async {
    await _box.remove('cache_$key');
  }
  
  /// 清除所有缓存
  Future<void> clearCache() async {
    final keys = _box.getKeys().where((key) => key.toString().startsWith('cache_'));
    for (final key in keys) {
      await _box.remove(key);
    }
    if (AppConfig.enableApiLog) {
      print('🧹 All cache cleared');
    }
  }

  // ==================== 搜索历史 ====================
  
  /// 保存搜索历史
  Future<void> saveSearchHistory(String keyword) async {
    if (keyword.trim().isEmpty) return;
    
    List<String> history = getSearchHistory();
    
    // 移除重复项
    history.remove(keyword);
    
    // 添加到开头
    history.insert(0, keyword);
    
    // 限制历史记录数量
    if (history.length > 20) {
      history = history.take(20).toList();
    }
    
    await _box.write('search_history', history);
  }
  
  /// 获取搜索历史
  List<String> getSearchHistory() {
    final history = _box.read<List>('search_history');
    return history?.cast<String>() ?? [];
  }
  
  /// 清除搜索历史
  Future<void> clearSearchHistory() async {
    await _box.remove('search_history');
  }

  // ==================== 收藏相关 ====================
  
  /// 保存收藏的技师ID列表
  Future<void> saveFavoriteTechnicians(List<String> technicianIds) async {
    await _box.write('favorite_technicians', technicianIds);
  }
  
  /// 获取收藏的技师ID列表
  List<String> getFavoriteTechnicians() {
    final favorites = _box.read<List>('favorite_technicians');
    return favorites?.cast<String>() ?? [];
  }
  
  /// 添加收藏技师
  Future<void> addFavoriteTechnician(String technicianId) async {
    final favorites = getFavoriteTechnicians();
    if (!favorites.contains(technicianId)) {
      favorites.add(technicianId);
      await saveFavoriteTechnicians(favorites);
    }
  }
  
  /// 移除收藏技师
  Future<void> removeFavoriteTechnician(String technicianId) async {
    final favorites = getFavoriteTechnicians();
    favorites.remove(technicianId);
    await saveFavoriteTechnicians(favorites);
  }
  
  /// 检查是否收藏了某个技师
  bool isFavoriteTechnician(String technicianId) {
    return getFavoriteTechnicians().contains(technicianId);
  }

  // ==================== 地址相关 ====================
  
  /// 保存最后使用的地址
  Future<void> saveLastAddress(Map<String, dynamic> address) async {
    await _box.write('last_address', address);
  }
  
  /// 获取最后使用的地址
  Map<String, dynamic>? getLastAddress() {
    return _box.read<Map<String, dynamic>>('last_address');
  }

  // ==================== 通用方法 ====================
  
  /// 保存任意数据
  Future<void> save(String key, dynamic value) async {
    await _box.write(key, value);
  }
  
  /// 读取任意数据
  T? read<T>(String key) {
    return _box.read<T>(key);
  }
  
  /// 删除数据
  Future<void> remove(String key) async {
    await _box.remove(key);
  }
  
  /// 检查是否存在某个键
  bool hasKey(String key) {
    return _box.hasData(key);
  }
  
  /// 获取所有键
  Iterable<dynamic> getKeys() {
    return _box.getKeys();
  }
  
  /// 清除所有数据
  Future<void> clearAll() async {
    await _box.erase();
    if (AppConfig.enableApiLog) {
      print('🧹 All storage data cleared');
    }
  }
  
  /// 获取存储大小（估算）
  int getStorageSize() {
    try {
      final keys = _box.getKeys();
      int totalSize = 0;
      
      for (final key in keys) {
        final value = _box.read(key);
        if (value != null) {
          final jsonString = jsonEncode(value);
          totalSize += jsonString.length;
        }
      }
      
      return totalSize;
    } catch (e) {
      if (AppConfig.enableApiLog) {
        print('❌ Failed to calculate storage size: $e');
      }
      return 0;
    }
  }
  
  /// 打印存储信息（仅调试模式）
  void printStorageInfo() {
    if (!AppConfig.enableApiLog) return;
    
    final keys = _box.getKeys();
    final size = getStorageSize();
    
    print('=== Storage Information ===');
    print('Total Keys: ${keys.length}');
    print('Estimated Size: ${(size / 1024).toStringAsFixed(2)} KB');
    print('Is Logged In: $isLoggedIn');
    print('==========================');
  }
}