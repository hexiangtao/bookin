import 'package:flutter/material.dart';

/// 应用颜色常量
/// 统一管理应用中使用的所有颜色，提高可维护性
class AppColors {
  // 私有构造函数，防止实例化
  AppColors._();

  // 主色调
  static const primary = Color(0xFFFF5777);
  static const primaryLight = Color(0xFFFF7A9E);
  static const primaryDark = Color(0xFFFF4A6A);

  // 渐变色
  static const gradientStart = Color(0xFFFF5777);
  static const gradientEnd = Color(0xFFFF7A9E);
  static const gradientAlt = Color(0xFFFF7A9E);
  static const gradientAltEnd = Color(0xFFFF4A6A);

  // 文本颜色
  static const textPrimary = Color(0xFF333333);
  static const textSecondary = Color(0xFF666666);
  static const textHint = Color(0xFF999999);
  static const textWhite = Color(0xFFFFFFFF);
  static const textLight = Color(0xFFFFFFFF70); // 70% opacity white

  // 背景色
  static const background = Color(0xFFF5F5F5);
  static const backgroundWhite = Color(0xFFFFFFFF);
  static const backgroundGrey = Color(0xFFF0F0F0);

  // 状态颜色
  static const success = Color(0xFF4CAF50);
  static const warning = Color(0xFFFF9800);
  static const error = Color(0xFFF44336);
  static const info = Color(0xFF2196F3);

  // 边框颜色
  static const border = Color(0xFFE0E0E0);
  static const borderLight = Color(0xFFF0F0F0);

  // 阴影颜色
  static const shadow = Color(0x1A000000); // 10% black
  static const shadowLight = Color(0x0D000000); // 5% black
}

/// 常用渐变色定义
class AppGradients {
  AppGradients._();

  static const primary = LinearGradient(
    colors: [AppColors.gradientStart, AppColors.gradientEnd],
  );

  static const primaryAlt = LinearGradient(
    colors: [AppColors.gradientAlt, AppColors.gradientAltEnd],
  );

  static const primaryVertical = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [AppColors.gradientStart, AppColors.gradientEnd],
  );
}