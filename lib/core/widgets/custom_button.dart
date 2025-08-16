import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

enum ButtonType {
  primary,
  secondary,
  outline,
  text,
}

enum ButtonSize {
  large,
  medium,
  small,
}

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final ButtonType type;
  final ButtonSize size;
  final bool isLoading;
  final bool isDisabled;
  final Widget? icon;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? borderColor;
  final double? borderRadius;
  final EdgeInsetsGeometry? padding;
  final double? width;
  final double? height;
  final TextStyle? textStyle;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.type = ButtonType.primary,
    this.size = ButtonSize.medium,
    this.isLoading = false,
    this.isDisabled = false,
    this.icon,
    this.backgroundColor,
    this.textColor,
    this.borderColor,
    this.borderRadius,
    this.padding,
    this.width,
    this.height,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    final isEnabled = !isDisabled && !isLoading && onPressed != null;
    
    return SizedBox(
      width: width,
      height: height ?? _getButtonHeight(),
      child: ElevatedButton(
        onPressed: isEnabled ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: _getBackgroundColor(isEnabled),
          foregroundColor: _getTextColor(isEnabled),
          elevation: type == ButtonType.outline || type == ButtonType.text ? 0 : 2,
          shadowColor: AppColors.shadow,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius ?? _getBorderRadius()),
            side: _getBorderSide(isEnabled),
          ),
          padding: padding ?? _getPadding(),
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        child: isLoading
            ? SizedBox(
                width: _getLoadingSize(),
                height: _getLoadingSize(),
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    _getTextColor(isEnabled),
                  ),
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    icon!,
                    const SizedBox(width: 8),
                  ],
                  Text(
                    text,
                    style: textStyle ?? _getTextStyle(isEnabled),
                  ),
                ],
              ),
      ),
    );
  }

  double _getButtonHeight() {
    switch (size) {
      case ButtonSize.large:
        return 48;
      case ButtonSize.medium:
        return 40;
      case ButtonSize.small:
        return 32;
    }
  }

  double _getBorderRadius() {
    switch (size) {
      case ButtonSize.large:
        return 8;
      case ButtonSize.medium:
        return 6;
      case ButtonSize.small:
        return 4;
    }
  }

  EdgeInsetsGeometry _getPadding() {
    switch (size) {
      case ButtonSize.large:
        return const EdgeInsets.symmetric(horizontal: 24, vertical: 12);
      case ButtonSize.medium:
        return const EdgeInsets.symmetric(horizontal: 16, vertical: 8);
      case ButtonSize.small:
        return const EdgeInsets.symmetric(horizontal: 12, vertical: 6);
    }
  }

  double _getLoadingSize() {
    switch (size) {
      case ButtonSize.large:
        return 20;
      case ButtonSize.medium:
        return 16;
      case ButtonSize.small:
        return 14;
    }
  }

  Color _getBackgroundColor(bool isEnabled) {
    if (backgroundColor != null) return backgroundColor!;
    
    if (!isEnabled) {
      return AppColors.textDisabled;
    }
    
    switch (type) {
      case ButtonType.primary:
        return AppColors.primary;
      case ButtonType.secondary:
        return AppColors.secondary;
      case ButtonType.outline:
        return Colors.transparent;
      case ButtonType.text:
        return Colors.transparent;
    }
  }

  Color _getTextColor(bool isEnabled) {
    if (textColor != null) return textColor!;
    
    if (!isEnabled) {
      return Colors.white;
    }
    
    switch (type) {
      case ButtonType.primary:
      case ButtonType.secondary:
        return Colors.white;
      case ButtonType.outline:
        return AppColors.primary;
      case ButtonType.text:
        return AppColors.primary;
    }
  }

  BorderSide _getBorderSide(bool isEnabled) {
    if (type == ButtonType.outline) {
      return BorderSide(
        color: borderColor ?? (isEnabled ? AppColors.primary : AppColors.textDisabled),
        width: 1,
      );
    }
    return BorderSide.none;
  }

  TextStyle _getTextStyle(bool isEnabled) {
    switch (size) {
      case ButtonSize.large:
        return AppTextStyles.buttonLarge.copyWith(
          color: _getTextColor(isEnabled),
        );
      case ButtonSize.medium:
        return AppTextStyles.buttonMedium.copyWith(
          color: _getTextColor(isEnabled),
        );
      case ButtonSize.small:
        return AppTextStyles.buttonSmall.copyWith(
          color: _getTextColor(isEnabled),
        );
    }
  }
}

// 便捷构造函数
class PrimaryButton extends CustomButton {
  const PrimaryButton({
    super.key,
    required super.text,
    super.onPressed,
    super.size = ButtonSize.medium,
    super.isLoading = false,
    super.isDisabled = false,
    super.icon,
    super.width,
    super.height,
  }) : super(type: ButtonType.primary);
}

class SecondaryButton extends CustomButton {
  const SecondaryButton({
    super.key,
    required super.text,
    super.onPressed,
    super.size = ButtonSize.medium,
    super.isLoading = false,
    super.isDisabled = false,
    super.icon,
    super.width,
    super.height,
  }) : super(type: ButtonType.secondary);
}

class OutlineButton extends CustomButton {
  const OutlineButton({
    super.key,
    required super.text,
    super.onPressed,
    super.size = ButtonSize.medium,
    super.isLoading = false,
    super.isDisabled = false,
    super.icon,
    super.width,
    super.height,
  }) : super(type: ButtonType.outline);
}

class TextButton extends CustomButton {
  const TextButton({
    super.key,
    required super.text,
    super.onPressed,
    super.size = ButtonSize.medium,
    super.isLoading = false,
    super.isDisabled = false,
    super.icon,
    super.width,
    super.height,
  }) : super(type: ButtonType.text);
}