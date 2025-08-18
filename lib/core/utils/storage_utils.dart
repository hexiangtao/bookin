import 'package:get/get.dart';
import '../services/storage_service.dart';

class StorageUtils {
  static StorageService get _storage => Get.find<StorageService>();

  // ==================== 用户相关 ====================
  
  /// 保存用户登录状态
  static Future<void> saveLoginStatus(bool isLoggedIn) async {
    await _storage.box.write('is_logged_in', isLoggedIn);
  }

  /// 获取用户登录状态
  static bool getLoginStatus() {
    return _storage.isLoggedIn;
  }

  /// 保存用户信息
  static Future<void> saveUserInfo(Map<String, dynamic> userInfo) async {
    await _storage.box.write('user_info', userInfo);
  }

  /// 获取用户信息
  static Map<String, dynamic>? getUserInfo() {
    return _storage.box.read<Map<String, dynamic>>('user_info');
  }

  /// 清除用户数据
  static Future<void> clearUserData() async {
    await _storage.clearUserData();
  }

  // ==================== Token相关 ====================
  
  /// 保存访问令牌
  static Future<void> saveAccessToken(String token) async {
    await _storage.saveToken(token);
  }

  /// 获取访问令牌
  static String? getAccessToken() {
    return _storage.getToken();
  }

  /// 保存刷新令牌
  static Future<void> saveRefreshToken(String token) async {
    await _storage.box.write('refresh_token', token);
  }

  /// 获取刷新令牌
  static String? getRefreshToken() {
    return _storage.box.read<String>('refresh_token');
  }

  /// 清除所有Token
  static Future<void> clearTokens() async {
    await _storage.removeToken();
  }

  // ==================== 应用设置 ====================
  
  /// 保存应用设置
  static Future<void> saveAppSettings(Map<String, dynamic> settings) async {
    await _storage.saveAppSettings(settings);
  }

  /// 获取应用设置
  static Map<String, dynamic> getAppSettings() {
    return _storage.getAppSettings();
  }

  /// 保存单个设置项
  static Future<void> saveSetting(String key, dynamic value) async {
    await _storage.saveSetting(key, value);
  }

  /// 获取单个设置项
  static T? getSetting<T>(String key, {T? defaultValue}) {
    final settings = getAppSettings();
    return settings[key] as T? ?? defaultValue;
  }

  // ==================== 缓存相关 ====================
  
  /// 保存缓存数据
  static Future<void> saveCache(String key, dynamic data, {Duration? expiry}) async {
    await _storage.saveCache(key, data, expiry: expiry);
  }

  /// 获取缓存数据
  static T? getCache<T>(String key) {
    return _storage.getCache<T>(key);
  }

  /// 清除指定缓存
  static Future<void> clearCache(String key) async {
    await _storage.removeCache(key);
  }

  /// 清除所有缓存
  static Future<void> clearAllCache() async {
    await _storage.clearCache();
  }

  // ==================== 搜索历史 ====================
  
  /// 保存搜索历史（添加关键词）
  static Future<void> saveSearchHistory(String keyword) async {
    await _storage.saveSearchHistory(keyword);
  }

  /// 获取搜索历史
  static List<String> getSearchHistory() {
    return _storage.getSearchHistory();
  }

  /// 添加搜索记录
  static Future<void> addSearchRecord(String keyword) async {
    await _storage.saveSearchHistory(keyword);
  }

  /// 清除搜索历史
  static Future<void> clearSearchHistory() async {
    await _storage.clearSearchHistory();
  }

  // ==================== 收藏相关 ====================
  
  /// 保存收藏的技师列表
  static Future<void> saveFavoriteTechnicians(List<String> technicianIds) async {
    await _storage.saveFavoriteTechnicians(technicianIds);
  }

  /// 获取收藏的技师列表
  static List<String> getFavoriteTechnicians() {
    return _storage.getFavoriteTechnicians();
  }

  /// 添加收藏技师
  static Future<void> addFavoriteTechnician(String technicianId) async {
    await _storage.addFavoriteTechnician(technicianId);
  }

  /// 移除收藏技师
  static Future<void> removeFavoriteTechnician(String technicianId) async {
    await _storage.removeFavoriteTechnician(technicianId);
  }

  /// 检查是否收藏了某个技师
  static bool isFavoriteTechnician(String technicianId) {
    return _storage.isFavoriteTechnician(technicianId);
  }

  // ==================== 地址相关 ====================
  
  /// 保存最后使用的地址
  static Future<void> saveLastAddress(Map<String, dynamic> address) async {
    await _storage.saveLastAddress(address);
  }

  /// 获取最后使用的地址
  static Map<String, dynamic>? getLastAddress() {
    return _storage.getLastAddress();
  }

  // ==================== 通用方法 ====================
  
  /// 保存字符串值
  static Future<void> setString(String key, String value) async {
    await _storage.box.write(key, value);
  }

  static String? getString(String key) {
    return _storage.box.read<String>(key);
  }

  /// 检查键是否存在
  static bool hasKey(String key) {
    return _storage.box.hasData(key);
  }

  /// 删除指定键
  static Future<void> remove(String key) async {
    await _storage.box.remove(key);
  }

  /// 清除所有数据
  static Future<void> clearAll() async {
    await _storage.box.erase();
  }

  /// 获取所有键
  static Iterable<String> getAllKeys() {
    return _storage.box.getKeys().cast<String>();
  }
}