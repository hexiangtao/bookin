import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import 'password_login_controller.dart';

class PasswordLoginPage extends GetView<PasswordLoginController> {
  const PasswordLoginPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          '密码登录',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    
                    // 页面标题
                    Text(
                      '密码登录',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    
                    const SizedBox(height: 8),
                    
                    Text(
                      '请输入您的手机号和密码',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    
                    const SizedBox(height: 40),
                    
                    // 手机号输入
                    Container(
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: Colors.grey.shade300,
                            width: 1,
                          ),
                        ),
                      ),
                      child: TextField(
                        controller: controller.phoneController,
                        keyboardType: TextInputType.phone,
                        maxLength: 11,
                        onChanged: (value) => controller.validatePhone(),
                        decoration: InputDecoration(
                          hintText: '请输入手机号码',
                          hintStyle: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 16,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 16,
                            horizontal: 0,
                          ),
                          counterText: '',
                        ),
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // 密码输入
                    Obx(() => Container(
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: Colors.grey.shade300,
                            width: 1,
                          ),
                        ),
                      ),
                      child: TextField(
                        controller: controller.passwordController,
                        obscureText: !controller.showPassword.value,
                        onChanged: (value) => controller.validatePassword(),
                        decoration: InputDecoration(
                          hintText: '请输入密码',
                          hintStyle: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 16,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 16,
                            horizontal: 0,
                          ),
                          suffixIcon: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: controller.togglePasswordVisibility,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                child: Text(
                                  controller.showPassword.value ? '隐藏' : '显示',
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black,
                        ),
                      ),
                    )),
                    
                    const SizedBox(height: 8),
                    
                    // 忘记密码
                    Align(
                      alignment: Alignment.centerRight,
                      child: GestureDetector(
                        onTap: controller.forgotPassword,
                        child: Text(
                          '忘记密码？',
                          style: TextStyle(
                            color: const Color(0xFFFF6B9D),
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 60),
                    
                    // 登录按钮
                    Obx(() => Container(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: controller.canLogin 
                            ? controller.loginWithPassword 
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: controller.canLogin
                              ? const Color(0xFFFF6B9D)
                              : Colors.grey.shade300,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                        ),
                        child: controller.loading.value
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : const Text(
                                '登录',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                      ),
                    )),
                    
                    const SizedBox(height: 20),
                    
                    // 验证码登录链接
                    Center(
                      child: GestureDetector(
                        onTap: controller.backToSmsLogin,
                        child: Text(
                          '验证码登录',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 14,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // 底部协议
            _buildAgreement(controller),
          ],
        ),
      ),
    );
  }

  // 底部协议
  Widget _buildAgreement(PasswordLoginController controller) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // 协议勾选
          Obx(() => Row(
            children: [
              Checkbox(
                value: controller.agreedToTerms.value,
                onChanged: (value) => controller.agreedToTerms.value = value ?? false,
                activeColor: const Color(0xFFFF6B9D),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              Expanded(
                child: RichText(
                  text: TextSpan(
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 12,
                    ),
                    children: [
                      const TextSpan(text: '我已阅读并同意'),
                      TextSpan(
                        text: '《用户协议》',
                        style: TextStyle(
                          color: const Color(0xFFFF6B9D),
                          decoration: TextDecoration.underline,
                        ),
                      ),
                      const TextSpan(text: '、'),
                      TextSpan(
                        text: '《隐私政策》',
                        style: TextStyle(
                          color: const Color(0xFFFF6B9D),
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          )),
        ],
      ),
    );
  }
}