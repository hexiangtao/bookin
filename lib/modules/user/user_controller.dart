import 'package:get/get.dart';
import '../../core/models/user_model.dart';
import '../../core/services/storage_service.dart';
import '../../core/services/auth_service.dart';

class UserController extends GetxController {
  final Rxn<UserModel> currentUser = Rxn<UserModel>();
  final RxBool isLoggedIn = false.obs;
  final RxBool loading = false.obs;

  StorageService? _storage;
  
  StorageService get storage {
    _storage ??= Get.find<StorageService>();
    return _storage!;
  }

  @override
  void onInit() {
    super.onInit();
    _loadUserFromStorage();
  }

  Future<void> _loadUserFromStorage() async {
    final userData = StorageService().getUserInfo();
    final isUserLoggedIn = await AuthService.instance.isLoggedIn();
    
    print('🔍 Loading user from storage - userData: ${userData != null}, isLoggedIn: $isUserLoggedIn');
    
    if (userData != null && isUserLoggedIn) {
      currentUser.value = userData;
      isLoggedIn.value = true;
      print('✅ User loaded successfully');
    } else {
      print('⚠️ User data or token invalid, but not auto-logging out to avoid conflicts');
      // 不自动登出，避免与登录流程冲突
      currentUser.value = null;
      isLoggedIn.value = false;
    }
  }

  /// 更新用户登录状态（由AuthService调用）
  Future<void> updateLoginStatus() async {
    await _loadUserFromStorage();
  }
  
  /// 设置当前用户信息
  void setCurrentUser(UserModel user) {
    currentUser.value = user;
    isLoggedIn.value = true;
  }

  Future<void> logout() async {
    try {
      // 调用AuthService的登出方法
      await AuthService.instance.logout();
      
      // 清除本地状态
      currentUser.value = null;
      isLoggedIn.value = false;
      
      // 跳转到登录页面
      Get.offAllNamed('/login');
    } catch (e) {
      print('Logout error: $e');
      // 即使出错也要清除本地状态
      currentUser.value = null;
      isLoggedIn.value = false;
    }
  }

  Future<void> updateProfile(UserModel updatedUser) async {
    loading.value = true;
    try {
      // TODO: 调用更新用户信息API
      await Future.delayed(const Duration(seconds: 1));
      
      await StorageService().saveUserInfo(updatedUser);
      currentUser.value = updatedUser;
      
      Get.snackbar('保存成功', '个人信息已更新');
    } catch (e) {
      Get.snackbar('保存失败', e.toString());
    } finally {
      loading.value = false;
    }
  }
}