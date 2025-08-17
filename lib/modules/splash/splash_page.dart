import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/config/app_config.dart';
import 'splash_controller.dart';

class SplashPage extends GetView<SplashController> {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primary.withOpacity(0.9),
              AppColors.primaryLight.withOpacity(0.8),
              AppColors.secondary.withOpacity(0.7),
              AppColors.secondaryLight.withOpacity(0.6),
            ],
            stops: const [0.0, 0.3, 0.7, 1.0],
          ),
        ),
        child: Stack(
          children: [
            // 移除所有装饰元素，保持苹果风格的极简设计
            // 主要内容 - 苹果风格简约设计
            SafeArea(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // 简约应用图标
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.2),
                          width: 0.5,
                        ),
                      ),
                      child: Icon(
                        Icons.spa_outlined,
                        size: 48,
                        color: Colors.white,
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // 应用名称 - 简化样式
                    Text(
                      AppConfig.appName,
                      style: AppTextStyles.h1.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w300,
                        fontSize: 28,
                        letterSpacing: 1.0,
                      ),
                    ),
                    
                    const SizedBox(height: 120),
                    
                    // 极简加载指示器
                    Obx(() => controller.loading.value
                        ? SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white.withOpacity(0.8)),
                              backgroundColor: Colors.transparent,
                            ),
                          )
                        : const SizedBox.shrink()),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}