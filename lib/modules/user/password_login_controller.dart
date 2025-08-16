import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../core/utils/toast_utils.dart';
import '../../core/utils/validators.dart';
import '../../core/services/auth_service.dart';
import '../../core/routes/app_routes.dart';

class PasswordLoginController extends GetxController {
  // 文本控制器
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  
  // 响应式变量
  final loading = false.obs;
  final showPassword = false.obs;
  final phoneValid = false.obs;
  final passwordValid = false.obs;
  final agreedToTerms = true.obs; // 默认勾选协议
  
  // 计算属性
  bool get canLogin => phoneValid.value && passwordValid.value && agreedToTerms.value && !loading.value;
  
  @override
  void onInit() {
    super.onInit();
    // 监听输入变化
    phoneController.addListener(validatePhone);
    passwordController.addListener(validatePassword);
  }
  
  @override
  void onClose() {
    phoneController.dispose();
    passwordController.dispose();
    super.onClose();
  }
  
  // 验证手机号
  void validatePhone() {
    phoneValid.value = Validators.isValidPhone(phoneController.text);
  }
  
  // 验证密码
  void validatePassword() {
    passwordValid.value = passwordController.text.length >= 6;
  }
  
  // 密码登录
  Future<void> loginWithPassword() async {
    if (!canLogin) return;
    
    loading.value = true;
    
    try {
      final phone = phoneController.text.trim();
      final password = passwordController.text.trim();
      
      // 调用认证服务进行密码登录
      final result = await AuthService.instance.loginWithPassword(
        phone: phone,
        password: password,
      );
      
      if (result['success']) {
        ToastUtils.showSuccess('登录成功');
        // 跳转到主页
        Get.offAllNamed(AppRoutes.home);
      } else {
        ToastUtils.showError(result['message'] ?? '登录失败，请检查手机号和密码');
      }
    } catch (e) {
      ToastUtils.showError('登录失败：${e.toString()}');
    } finally {
      loading.value = false;
    }
  }
  
  // 忘记密码
  void forgotPassword() {
    ToastUtils.showInfo('忘记密码功能开发中...');
  }
  
  // 返回验证码登录
  void backToSmsLogin() {
    Get.back();
  }
  
  // 切换密码显示状态
  void togglePasswordVisibility() {
    showPassword.toggle();
  }
}

// 密码登录绑定
class PasswordLoginBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PasswordLoginController>(() => PasswordLoginController());
  }
}