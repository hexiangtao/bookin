import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/storage_service.dart';
import '../../core/utils/validators.dart';
import '../../core/utils/toast_utils.dart';
import 'user_controller.dart';
import '../../core/routes/app_routes.dart';

enum LoginType { phone, wechat }

class LoginController extends GetxController {
  // 表单控制器
  final phoneController = TextEditingController();
  final codeController = TextEditingController();
  final passwordPhoneController = TextEditingController();
  final passwordController = TextEditingController();
  
  // 响应式状态
  final loginType = LoginType.phone.obs;
  final loading = false.obs;
  final agreedToTerms = true.obs; // 默认勾选协议
  final showPassword = false.obs;
  
  // 验证码相关
  final canSendCode = false.obs; // 默认不可点击
  final codeButtonText = '获取验证码'.obs;
  Timer? _codeTimer;
  int _countdown = 60;
  
  // 表单验证
  final phoneValid = false.obs;
  final codeValid = false.obs;
  final passwordPhoneValid = false.obs;
  final passwordValid = false.obs;
  
  // 计算属性
  bool get canLogin => phoneValid.value && codeValid.value && agreedToTerms.value;
  bool get canPasswordLogin => passwordPhoneValid.value && passwordValid.value && agreedToTerms.value;
  
  @override
  void onInit() {
    super.onInit();
    _setupListeners();
  }
  
  @override
  void onClose() {
    phoneController.dispose();
    codeController.dispose();
    passwordPhoneController.dispose();
    passwordController.dispose();
    _codeTimer?.cancel();
    super.onClose();
  }
  
  // 设置监听器
  void _setupListeners() {
    phoneController.addListener(validatePhone);
    codeController.addListener(validateCode);
    passwordPhoneController.addListener(validatePasswordPhone);
    passwordController.addListener(validatePassword);
  }
  
  // 设置登录类型
  void setLoginType(LoginType type) {
    loginType.value = type;
  }
  
  // 验证手机号
  void validatePhone() {
    phoneValid.value = Validators.isValidPhone(phoneController.text);
    // 手机号有效时才能发送验证码
    canSendCode.value = phoneValid.value;
  }
  
  // 验证验证码
  void validateCode() {
    codeValid.value = codeController.text.length == 4;
  }
  
  // 验证密码登录手机号
  void validatePasswordPhone() {
    passwordPhoneValid.value = Validators.isValidPhone(passwordPhoneController.text);
  }
  
  // 验证密码
  void validatePassword() {
    passwordValid.value = passwordController.text.length >= 4;
  }
  
  // 发送验证码
  Future<void> sendCode() async {
    if (!phoneValid.value) {
      ToastUtils.showError('请输入正确的手机号');
      return;
    }
    
    try {
      loading.value = true;
      
      final result = await AuthService.instance.sendCode(
        phone: phoneController.text,
        type: 'login',
      );
      
      if (result['success']) {
        _startCountdown();
      } else {
        ToastUtils.showError(result['message'] ?? '发送失败');
      }
    } catch (e) {
      ToastUtils.showError('发送验证码失败');
    } finally {
      loading.value = false;
    }
  }
  
  // 开始倒计时
  void _startCountdown() {
    canSendCode.value = false;
    _countdown = 60;
    codeButtonText.value = '${_countdown}s';
    
    _codeTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _countdown--;
      if (_countdown <= 0) {
        timer.cancel();
        // 倒计时结束后，只有手机号有效时才能重新发送
        canSendCode.value = phoneValid.value;
        codeButtonText.value = '获取验证码';
      } else {
        codeButtonText.value = '${_countdown}s';
      }
    });
  }
  
  // 手机号验证码登录
  Future<void> loginWithPhone() async {
    if (!canLogin) {
      if (!agreedToTerms.value) {
        ToastUtils.showError('请先同意用户协议和隐私政策');
      }
      return;
    }
    
    try {
      loading.value = true;
      
      final result = await AuthService.instance.loginWithCode(
        phone: phoneController.text,
        code: codeController.text,
      );
      
      if (result['success']) {
        await _handleLoginSuccess();
      } else {
        ToastUtils.showError(result['message'] ?? '登录失败');
      }
    } catch (e) {
      ToastUtils.showError('登录失败，请重试');
    } finally {
      loading.value = false;
    }
  }
  
  // 密码登录
  Future<void> loginWithPassword() async {
    if (!canPasswordLogin) {
      if (!agreedToTerms.value) {
        ToastUtils.showError('请先同意用户协议和隐私政策');
      }
      return;
    }
    
    try {
      loading.value = true;
      
      final result = await AuthService.instance.loginWithPassword(
        phone: passwordPhoneController.text,
        password: passwordController.text,
      );
      
      if (result['success']) {
        await _handleLoginSuccess();
        Get.back(); // 关闭密码登录弹窗
      } else {
        ToastUtils.showError(result['message'] ?? '登录失败');
      }
    } catch (e) {
      ToastUtils.showError('登录失败，请重试');
    } finally {
      loading.value = false;
    }
  }
  
  // 微信登录
  Future<void> loginWithWechat() async {
    if (!agreedToTerms.value) {
      ToastUtils.showError('请先同意用户协议和隐私政策');
      return;
    }
    
    try {
      loading.value = true;
      
      // 这里应该调用微信SDK进行授权
      // 暂时模拟微信登录流程
      ToastUtils.showInfo('微信登录功能开发中...');
      
      // 模拟微信授权成功后的处理
      // final wechatCode = await _getWechatAuthCode();
      // if (wechatCode != null) {
      //   final response = await ApiClient.instance.post(
      //     '/auth/wechat-login',
      //     data: {
      //       'code': wechatCode,
      //       'type': 'wechat',
      //     },
      //   );
      //   
      //   if (response.data['code'] == 200) {
      //     final data = response.data['data'];
      //     await _handleLoginSuccess(data);
      //   } else {
      //     ToastUtils.showError(response.data['msg'] ?? '微信登录失败');
      //   }
      // }
    } catch (e) {
      ToastUtils.showError('微信登录失败');
    } finally {
      loading.value = false;
    }
  }
  
  // 处理登录成功
  Future<void> _handleLoginSuccess() async {
    print('🎉 Login success - showing toast');
    ToastUtils.showSuccess('登录成功');
    
    // 获取或创建用户控制器
    UserController userController;
    try {
      userController = Get.find<UserController>();
    } catch (e) {
      // 如果用户控制器未初始化，先注册它
      userController = Get.put(UserController());
    }
    
    // 直接从存储中获取用户信息并设置到控制器
    try {
      final userInfo = StorageService().getUserInfo();
      if (userInfo != null) {
        userController.setCurrentUser(userInfo);
        print('👤 User controller updated with user info');
      }
    } catch (e) {
      print('⚠️ Failed to update user controller: $e');
    }
    
    // 确保用户状态已更新后再跳转
    await Future.delayed(const Duration(milliseconds: 200));
    
    // 跳转到首页
    print('🚀 Navigating to /home');
    Get.offAllNamed('/home');
    
    // 延迟检查当前路由
    Future.delayed(const Duration(milliseconds: 500), () {
      print('📍 Current route after navigation: ${Get.currentRoute}');
    });
  }
  
  // 跳转到密码登录页面
  void showPasswordLogin() {
    Get.toNamed(AppRoutes.passwordLogin);
  }
  
  // 忘记密码
  void forgotPassword() {
    ToastUtils.showInfo('忘记密码功能开发中...');
  }
  
  // 获取微信授权码（需要集成微信SDK）
  // Future<String?> _getWechatAuthCode() async {
  //   // 这里应该调用微信SDK获取授权码
  //   // 返回授权码或null（用户取消授权）
  //   return null;
  // }
}

// 登录绑定
class LoginBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LoginController>(() => LoginController());
  }
}