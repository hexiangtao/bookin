import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/custom_app_bar.dart';
import '../../core/widgets/custom_text_field.dart';
import 'login_controller.dart';

class LoginPage extends GetView<LoginController> {
  const LoginPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          '手机号登录',
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
                      '手机号登录',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    
                    const SizedBox(height: 60),
                    
                    // 登录表单
                    _buildPhoneLoginForm(),
                  ],
                ),
              ),
            ),
            
            // 底部协议
            _buildAgreement(),
          ],
        ),
      ),
    );
  }

  // 手机号登录表单
  Widget _buildPhoneLoginForm() {
    return Column(
      children: [
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
              hintText: '请输入手机号',
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
        
        // 验证码输入
        Container(
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: Colors.grey.shade300,
                width: 1,
              ),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: TextField(
                  controller: controller.codeController,
                  keyboardType: TextInputType.number,
                  maxLength: 4,
                  onChanged: (value) => controller.validateCode(),
                  decoration: InputDecoration(
                    hintText: '请输入验证码',
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
              const SizedBox(width: 12),
              Expanded(
                child: Obx(() => Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: controller.canSendCode.value ? controller.sendCode : null,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                      child: Text(
                        controller.codeButtonText.value,
                        style: TextStyle(
                          color: controller.canSendCode.value 
                              ? const Color(0xFFFF6B9D) 
                              : Colors.grey.shade400,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                )),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 60),
        
        // 登录按钮
        Obx(() => Container(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: controller.canLogin ? controller.loginWithPhone : null,
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
        
        // 密码登录链接
        GestureDetector(
          onTap: controller.showPasswordLogin,
          child: Text(
            '密码登录',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 14,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    );
  }



  // 底部协议
  Widget _buildAgreement() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // 自动注册提示
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Text(
              '未注册手机号验证后将自动注册',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 12,
              ),
            ),
          ),
          
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