import 'package:flutter/material.dart';
import 'app_colors.dart';

/// 应用样式常量
/// 统一管理文本样式、间距、圆角等设计规范
class AppStyles {
  AppStyles._();

  // 文本样式
  static const TextStyle titleLarge = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    height: 1.2,
  );

  static const TextStyle titleMedium = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  static const TextStyle titleSmall = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    color: AppColors.textPrimary,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    color: AppColors.textPrimary,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    color: AppColors.textSecondary,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 11,
    color: AppColors.textHint,
  );

  // 价格样式
  static const TextStyle priceSymbol = TextStyle(
    fontSize: 18,
    color: AppColors.primary,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle priceLarge = TextStyle(
    fontSize: 32,
    color: AppColors.primary,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle priceOriginal = TextStyle(
    fontSize: 16,
    color: AppColors.textHint,
    decoration: TextDecoration.lineThrough,
  );

  // 按钮文本样式
  static const TextStyle buttonText = TextStyle(
    color: AppColors.textWhite,
    fontSize: 14,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle buttonTextSmall = TextStyle(
    color: AppColors.textWhite,
    fontSize: 13,
    fontWeight: FontWeight.bold,
  );
}

/// 应用尺寸常量
class AppSizes {
  AppSizes._();

  // 间距
  static const double spacingXS = 4.0;
  static const double spacingS = 8.0;
  static const double spacingM = 16.0;
  static const double spacingL = 24.0;
  static const double spacingXL = 32.0;

  // 圆角
  static const double radiusS = 8.0;
  static const double radiusM = 12.0;
  static const double radiusL = 16.0;
  static const double radiusXL = 20.0;
  static const double radiusXXL = 30.0;

  // 图标尺寸
  static const double iconXS = 12.0;
  static const double iconS = 16.0;
  static const double iconM = 20.0;
  static const double iconL = 24.0;
  static const double iconXL = 32.0;

  // 按钮尺寸
  static const double buttonHeight = 48.0;
  static const double buttonHeightSmall = 36.0;
  static const double buttonHeightLarge = 56.0;

  // 卡片尺寸
  static const double cardElevation = 2.0;
  static const double cardElevationHigh = 8.0;
}

/// 应用阴影样式
class AppShadows {
  AppShadows._();

  static List<BoxShadow> get light => [
        BoxShadow(
          color: AppColors.shadow,
          blurRadius: 4,
          offset: const Offset(0, 2),
        ),
      ];

  static List<BoxShadow> get medium => [
        BoxShadow(
          color: AppColors.shadow,
          blurRadius: 8,
          offset: const Offset(0, 4),
        ),
      ];

  static List<BoxShadow> get heavy => [
        BoxShadow(
          color: AppColors.shadow,
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
      ];

  static List<BoxShadow> get primary => [
        BoxShadow(
          color: AppColors.primary.withOpacity(0.3),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ];
}