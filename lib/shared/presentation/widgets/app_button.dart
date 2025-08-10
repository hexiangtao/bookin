import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_styles.dart';

/// 应用通用按钮组件
/// 提供统一的按钮样式和行为
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.type = AppButtonType.primary,
    this.size = AppButtonSize.medium,
    this.isLoading = false,
    this.isEnabled = true,
    this.icon,
    this.width,
  });

  final String text;
  final VoidCallback? onPressed;
  final AppButtonType type;
  final AppButtonSize size;
  final bool isLoading;
  final bool isEnabled;
  final IconData? icon;
  final double? width;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: _getHeight(),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isEnabled && !isLoading ? onPressed : null,
          borderRadius: BorderRadius.circular(_getBorderRadius()),
          child: Container(
            decoration: BoxDecoration(
              gradient: _getGradient(),
              borderRadius: BorderRadius.circular(_getBorderRadius()),
              boxShadow: _getShadow(),
              border: _getBorder(),
            ),
            child: Center(
              child: isLoading
                  ? SizedBox(
                      width: _getIconSize(),
                      height: _getIconSize(),
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          _getTextColor(),
                        ),
                      ),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (icon != null) ...[
                          Icon(
                            icon,
                            size: _getIconSize(),
                            color: _getTextColor(),
                          ),
                          SizedBox(width: AppSizes.spacingXS),
                        ],
                        Text(
                          text,
                          style: _getTextStyle(),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }

  double _getHeight() {
    switch (size) {
      case AppButtonSize.small:
        return AppSizes.buttonHeightSmall;
      case AppButtonSize.medium:
        return AppSizes.buttonHeight;
      case AppButtonSize.large:
        return AppSizes.buttonHeightLarge;
    }
  }

  double _getBorderRadius() {
    switch (size) {
      case AppButtonSize.small:
        return AppSizes.radiusM;
      case AppButtonSize.medium:
        return AppSizes.radiusL;
      case AppButtonSize.large:
        return AppSizes.radiusXL;
    }
  }

  double _getIconSize() {
    switch (size) {
      case AppButtonSize.small:
        return AppSizes.iconS;
      case AppButtonSize.medium:
        return AppSizes.iconM;
      case AppButtonSize.large:
        return AppSizes.iconL;
    }
  }

  Gradient? _getGradient() {
    if (!isEnabled) return null;
    
    switch (type) {
      case AppButtonType.primary:
        return AppGradients.primary;
      case AppButtonType.secondary:
        return AppGradients.primaryAlt;
      case AppButtonType.outline:
      case AppButtonType.text:
        return null;
    }
  }

  Color _getBackgroundColor() {
    if (!isEnabled) return AppColors.backgroundGrey;
    
    switch (type) {
      case AppButtonType.primary:
      case AppButtonType.secondary:
        return Colors.transparent; // 使用渐变
      case AppButtonType.outline:
      case AppButtonType.text:
        return Colors.transparent;
    }
  }

  Color _getTextColor() {
    if (!isEnabled) return AppColors.textHint;
    
    switch (type) {
      case AppButtonType.primary:
      case AppButtonType.secondary:
        return AppColors.textWhite;
      case AppButtonType.outline:
      case AppButtonType.text:
        return AppColors.primary;
    }
  }

  TextStyle _getTextStyle() {
    final baseStyle = size == AppButtonSize.small
        ? AppStyles.buttonTextSmall
        : AppStyles.buttonText;
    
    return baseStyle.copyWith(color: _getTextColor());
  }

  List<BoxShadow>? _getShadow() {
    if (!isEnabled || type == AppButtonType.text) return null;
    
    switch (type) {
      case AppButtonType.primary:
      case AppButtonType.secondary:
        return AppShadows.primary;
      case AppButtonType.outline:
        return AppShadows.light;
      case AppButtonType.text:
        return null;
    }
  }

  Border? _getBorder() {
    if (type == AppButtonType.outline) {
      return Border.all(
        color: isEnabled ? AppColors.primary : AppColors.border,
        width: 1,
      );
    }
    return null;
  }
}

/// 按钮类型枚举
enum AppButtonType {
  primary,   // 主要按钮（渐变背景）
  secondary, // 次要按钮（不同渐变）
  outline,   // 边框按钮
  text,      // 文本按钮
}

/// 按钮尺寸枚举
enum AppButtonSize {
  small,
  medium,
  large,
}