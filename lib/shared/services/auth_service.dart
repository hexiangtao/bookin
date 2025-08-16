import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/services/api_service.dart';

class AuthService extends GetxService {
  static AuthService get to => Get.find();
  
  final ApiService _apiService = Get.find<ApiService>();
  
  final RxBool _isLoggedIn = false.obs;
  final RxString _token = ''.obs;
  final RxMap<String, dynamic> _userInfo = <String, dynamic>{}.obs;
  
  bool get isLoggedIn => _isLoggedIn.value;
  String get token => _token.value;
  Map<String, dynamic> get userInfo => _userInfo;
  
  @override
  void onInit() {
    super.onInit();
    _loadAuthData();
  }
  
  Future<void> _loadAuthData() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    final userInfoJson = prefs.getString('user_info');
    
    if (token != null && token.isNotEmpty) {
      _token.value = token;
      _isLoggedIn.value = true;
      
      if (userInfoJson != null) {
        // 这里应该解析JSON，简化处理
        _userInfo.value = {'token': token};
      }
    }
  }
  
  Future<bool> login(String phone, String code) async {
    try {
      final response = await _apiService.post('/auth/login', data: {
        'phone': phone,
        'code': code,
      });
      
      if (response['success'] == true) {
        final token = response['data']['token'];
        final userInfo = response['data']['user'];
        
        await _saveAuthData(token, userInfo);
        return true;
      }
      return false;
    } catch (e) {
      print('Login error: $e');
      return false;
    }
  }
  
  Future<bool> loginWithPassword(String phone, String password) async {
    try {
      final response = await _apiService.post('/auth/login-password', data: {
        'phone': phone,
        'password': password,
      });
      
      if (response['success'] == true) {
        final token = response['data']['token'];
        final userInfo = response['data']['user'];
        
        await _saveAuthData(token, userInfo);
        return true;
      }
      return false;
    } catch (e) {
      print('Password login error: $e');
      return false;
    }
  }
  
  Future<bool> sendVerificationCode(String phone) async {
    try {
      final response = await _apiService.post('/auth/send-code', data: {
        'phone': phone,
      });
      
      return response['success'] == true;
    } catch (e) {
      print('Send code error: $e');
      return false;
    }
  }
  
  Future<void> _saveAuthData(String token, Map<String, dynamic> userInfo) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
    await prefs.setString('user_info', userInfo.toString());
    
    _token.value = token;
    _userInfo.value = userInfo;
    _isLoggedIn.value = true;
  }
  
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('user_info');
    
    _token.value = '';
    _userInfo.clear();
    _isLoggedIn.value = false;
  }
  
  String getAuthHeader() {
    return 'Bearer ${_token.value}';
  }
}