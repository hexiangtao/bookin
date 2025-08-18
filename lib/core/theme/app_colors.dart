import 'package:flutter/material.dart';

class AppColors {
  // 主色调
  static const Color primary = Color(0xFF2E7DFF);
  static const Color primaryLight = Color(0xFF5A9BFF);
  static const Color primaryDark = Color(0xFF1E5FCC);
  
  // 辅助色
  static const Color secondary = Color(0xFFFF5777);
  static const Color secondaryLight = Color(0xFFFF7A99);
  static const Color secondaryDark = Color(0xFFCC4562);
  
  // 背景色
  static const Color background = Color(0xFFF7F8FA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF5F5F5);
  
  // 文本色
  static const Color textPrimary = Color(0xFF333333);
  static const Color textSecondary = Color(0xFF666666);
  static const Color textTertiary = Color(0xFF999999);
  static const Color textDisabled = Color(0xFFCCCCCC);
  
  // 状态色
  static const Color success = Color(0xFF52C41A);
  static const Color warning = Color(0xFFFAAD14);
  static const Color error = Color(0xFFFF4D4F);
  static const Color info = Color(0xFF1890FF);
  
  // 边框色
  static const Color border = Color(0xFFE8E8E8);
  static const Color borderLight = Color(0xFFF0F0F0);
  static const Color borderDark = Color(0xFFD9D9D9);
  
  // 分割线
  static const Color divider = Color(0xFFE8E8E8);
  
  // 阴影色
  static const Color shadow = Color(0x1A000000);
  
  // 灰色系列
  static const Color grey200 = Color(0xFFEEEEEE);
  static const Color grey400 = Color(0xFFBDBDBD);
  static const Color grey500 = Color(0xFF9E9E9E);
  static const Color grey600 = Color(0xFF757575);
  
  // 透明度变体
  static Color primaryWithOpacity(double opacity) => primary.withOpacity(opacity);
  static Color textPrimaryWithOpacity(double opacity) => textPrimary.withOpacity(opacity);
  static Color blackWithOpacity(double opacity) => Colors.black.withOpacity(opacity);
  static Color whiteWithOpacity(double opacity) => Colors.white.withOpacity(opacity);
}