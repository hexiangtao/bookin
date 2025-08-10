import 'package:get/get.dart';
import '../../shared/models/user_model.dart';
import '../../shared/services/storage_service.dart';

class UserController extends GetxController {
  final Rxn<UserModel> currentUser = Rxn<UserModel>();
  final RxBool isLoggedIn = false.obs;
  final RxBool loading = false.obs;

  final StorageService _storage = Get.find<StorageService>();

  @override
  void onInit() {
    super.onInit();
    _loadUserFromStorage();
  }

  Future<void> _loadUserFromStorage() async {
    final userData = await _storage.getUser();
    if (userData != null) {
      currentUser.value = userData;
      isLoggedIn.value = true;
    }
  }

  Future<bool> login(String phone, String password) async {
    loading.value = true;
    try {
      // TODO: 调用登录API
      await Future.delayed(const Duration(seconds: 1));
      
      // 模拟登录成功
      final user = UserModel(
        id: '1',
        name: '用户${phone.substring(7)}',
        phone: phone,
        avatar: 'https://via.placeholder.com/100',
      );
      
      await _storage.saveUser(user);
      currentUser.value = user;
      isLoggedIn.value = true;
      
      Get.snackbar('登录成功', '欢迎回来！');
      return true;
    } catch (e) {
      Get.snackbar('登录失败', e.toString());
      return false;
    } finally {
      loading.value = false;
    }
  }

  Future<void> logout() async {
    await _storage.clearUser();
    currentUser.value = null;
    isLoggedIn.value = false;
    Get.snackbar('已退出', '您已成功退出登录');
  }

  Future<void> updateProfile(UserModel updatedUser) async {
    loading.value = true;
    try {
      // TODO: 调用更新用户信息API
      await Future.delayed(const Duration(seconds: 1));
      
      await _storage.saveUser(updatedUser);
      currentUser.value = updatedUser;
      
      Get.snackbar('保存成功', '个人信息已更新');
    } catch (e) {
      Get.snackbar('保存失败', e.toString());
    } finally {
      loading.value = false;
    }
  }
}