import 'package:flutter/material.dart';

/// 应用统一的尺寸规范
class AppDimensions {
  // 间距规范
  static const double spacingXs = 4.0;
  static const double spacingS = 8.0;
  static const double spacingM = 12.0;
  static const double spacingL = 16.0;
  static const double spacingXl = 20.0;
  static const double spacingXxl = 24.0;
  static const double spacingXxxl = 32.0;
  
  // 内边距规范
  static const EdgeInsets paddingXs = EdgeInsets.all(spacingXs);
  static const EdgeInsets paddingS = EdgeInsets.all(spacingS);
  static const EdgeInsets paddingM = EdgeInsets.all(spacingM);
  static const EdgeInsets paddingL = EdgeInsets.all(spacingL);
  static const EdgeInsets paddingXl = EdgeInsets.all(spacingXl);
  static const EdgeInsets paddingXxl = EdgeInsets.all(spacingXxl);
  
  // 水平内边距
  static const EdgeInsets paddingHorizontalXs = EdgeInsets.symmetric(horizontal: spacingXs);
  static const EdgeInsets paddingHorizontalS = EdgeInsets.symmetric(horizontal: spacingS);
  static const EdgeInsets paddingHorizontalM = EdgeInsets.symmetric(horizontal: spacingM);
  static const EdgeInsets paddingHorizontalL = EdgeInsets.symmetric(horizontal: spacingL);
  static const EdgeInsets paddingHorizontalXl = EdgeInsets.symmetric(horizontal: spacingXl);
  
  // 垂直内边距
  static const EdgeInsets paddingVerticalXs = EdgeInsets.symmetric(vertical: spacingXs);
  static const EdgeInsets paddingVerticalS = EdgeInsets.symmetric(vertical: spacingS);
  static const EdgeInsets paddingVerticalM = EdgeInsets.symmetric(vertical: spacingM);
  static const EdgeInsets paddingVerticalL = EdgeInsets.symmetric(vertical: spacingL);
  static const EdgeInsets paddingVerticalXl = EdgeInsets.symmetric(vertical: spacingXl);
  
  // 外边距规范
  static const EdgeInsets marginXs = EdgeInsets.all(spacingXs);
  static const EdgeInsets marginS = EdgeInsets.all(spacingS);
  static const EdgeInsets marginM = EdgeInsets.all(spacingM);
  static const EdgeInsets marginL = EdgeInsets.all(spacingL);
  static const EdgeInsets marginXl = EdgeInsets.all(spacingXl);
  
  // 圆角规范
  static const double radiusXs = 4.0;
  static const double radiusS = 6.0;
  static const double radiusM = 8.0;
  static const double radiusL = 12.0;
  static const double radiusXl = 16.0;
  static const double radiusXxl = 20.0;
  static const double radiusRound = 999.0;
  
  // BorderRadius
  static BorderRadius get borderRadiusXs => BorderRadius.circular(radiusXs);
  static BorderRadius get borderRadiusS => BorderRadius.circular(radiusS);
  static BorderRadius get borderRadiusM => BorderRadius.circular(radiusM);
  static BorderRadius get borderRadiusL => BorderRadius.circular(radiusL);
  static BorderRadius get borderRadiusXl => BorderRadius.circular(radiusXl);
  static BorderRadius get borderRadiusXxl => BorderRadius.circular(radiusXxl);
  static BorderRadius get borderRadiusRound => BorderRadius.circular(radiusRound);
  
  // 高度规范
  static const double buttonHeightS = 32.0;
  static const double buttonHeightM = 40.0;
  static const double buttonHeightL = 48.0;
  static const double buttonHeightXl = 56.0;
  
  static const double inputHeightS = 32.0;
  static const double inputHeightM = 40.0;
  static const double inputHeightL = 48.0;
  
  static const double cardHeightS = 60.0;
  static const double cardHeightM = 80.0;
  static const double cardHeightL = 100.0;
  
  // 图标尺寸
  static const double iconXs = 12.0;
  static const double iconS = 16.0;
  static const double iconM = 20.0;
  static const double iconL = 24.0;
  static const double iconXl = 32.0;
  static const double iconXxl = 48.0;
  
  // 阴影规范
  static List<BoxShadow> get shadowXs => [
    BoxShadow(
      color: Colors.black.withOpacity(0.04),
      blurRadius: 2,
      offset: const Offset(0, 1),
    ),
  ];
  
  static List<BoxShadow> get shadowS => [
    BoxShadow(
      color: Colors.black.withOpacity(0.06),
      blurRadius: 4,
      offset: const Offset(0, 2),
    ),
  ];
  
  static List<BoxShadow> get shadowM => [
    BoxShadow(
      color: Colors.black.withOpacity(0.08),
      blurRadius: 8,
      offset: const Offset(0, 4),
    ),
  ];
  
  static List<BoxShadow> get shadowL => [
    BoxShadow(
      color: Colors.black.withOpacity(0.12),
      blurRadius: 16,
      offset: const Offset(0, 8),
    ),
  ];
  
  static List<BoxShadow> get shadowXl => [
    BoxShadow(
      color: Colors.black.withOpacity(0.16),
      blurRadius: 24,
      offset: const Offset(0, 12),
    ),
  ];
  
  // 边框规范
  static const double borderWidthThin = 0.5;
  static const double borderWidthNormal = 1.0;
  static const double borderWidthThick = 2.0;
  
  // 分割线高度
  static const double dividerHeight = 0.5;
  
  // 最小触摸区域
  static const double minTouchTarget = 44.0;
}