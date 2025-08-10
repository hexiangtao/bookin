import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// 应用标签组件
/// 统一标签的显示样式和行为
class AppTag extends StatelessWidget {
  const AppTag({
    super.key,
    required this.text,
    this.type = AppTagType.primary,
    this.size = AppTagSize.medium,
    this.onTap,
  });

  final String text;
  final AppTagType type;
  final AppTagSize size;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: _getPadding(),
        decoration: BoxDecoration(
          color: _getBackgroundColor(),
          gradient: _getGradient(),
          borderRadius: BorderRadius.circular(_getBorderRadius()),
          border: _getBorder(),
          boxShadow: _getShadow(),
        ),
        child: Text(
          text,
          style: _getTextStyle(),
        ),
      ),
    );
  }

  EdgeInsets _getPadding() {
    switch (size) {
      case AppTagSize.small:
        return const EdgeInsets.symmetric(horizontal: 6, vertical: 2);
      case AppTagSize.medium:
        return const EdgeInsets.symmetric(horizontal: 8, vertical: 4);
      case AppTagSize.large:
        return const EdgeInsets.symmetric(horizontal: 12, vertical: 6);
    }
  }

  double _getBorderRadius() {
    switch (size) {
      case AppTagSize.small:
        return 8;
      case AppTagSize.medium:
        return 10;
      case AppTagSize.large:
        return 12;
    }
  }

  Color? _getBackgroundColor() {
    switch (type) {
      case AppTagType.primary:
      case AppTagType.gradient:
        return null; // 使用渐变
      case AppTagType.secondary:
        return AppColors.primary.withOpacity(0.1);
      case AppTagType.outline:
        return Colors.transparent;
      case AppTagType.success:
        return AppColors.success.withOpacity(0.1);
      case AppTagType.warning:
        return AppColors.warning.withOpacity(0.1);
      case AppTagType.error:
        return AppColors.error.withOpacity(0.1);
      case AppTagType.neutral:
        return AppColors.backgroundGrey;
    }
  }

  Gradient? _getGradient() {
    switch (type) {
      case AppTagType.primary:
        return AppGradients.primary;
      case AppTagType.gradient:
        return AppGradients.primaryAlt;
      default:
        return null;
    }
  }

  Border? _getBorder() {
    if (type == AppTagType.outline) {
      return Border.all(
        color: AppColors.primary,
        width: 1,
      );
    }
    return null;
  }

  List<BoxShadow>? _getShadow() {
    if (type == AppTagType.primary || type == AppTagType.gradient) {
      return [
        BoxShadow(
          color: AppColors.primary.withOpacity(0.2),
          blurRadius: 4,
          offset: const Offset(0, 2),
        ),
      ];
    }
    return null;
  }

  Color _getTextColor() {
    switch (type) {
      case AppTagType.primary:
      case AppTagType.gradient:
        return AppColors.textWhite;
      case AppTagType.secondary:
      case AppTagType.outline:
        return AppColors.primary;
      case AppTagType.success:
        return AppColors.success;
      case AppTagType.warning:
        return AppColors.warning;
      case AppTagType.error:
        return AppColors.error;
      case AppTagType.neutral:
        return AppColors.textSecondary;
    }
  }

  TextStyle _getTextStyle() {
    final color = _getTextColor();
    
    switch (size) {
      case AppTagSize.small:
        return TextStyle(
          fontSize: 10,
          color: color,
          fontWeight: FontWeight.bold,
        );
      case AppTagSize.medium:
        return TextStyle(
          fontSize: 11,
          color: color,
          fontWeight: FontWeight.bold,
        );
      case AppTagSize.large:
        return TextStyle(
          fontSize: 12,
          color: color,
          fontWeight: FontWeight.bold,
        );
    }
  }
}

/// 标签类型枚举
enum AppTagType {
  primary,   // 主要标签（渐变背景）
  gradient,  // 渐变标签（不同渐变）
  secondary, // 次要标签（浅色背景）
  outline,   // 边框标签
  success,   // 成功标签
  warning,   // 警告标签
  error,     // 错误标签
  neutral,   // 中性标签
}

/// 标签尺寸枚举
enum AppTagSize {
  small,
  medium,
  large,
}

/// 标签组合组件
/// 用于显示多个标签
class AppTagGroup extends StatelessWidget {
  const AppTagGroup({
    super.key,
    required this.tags,
    this.spacing = 6.0,
    this.runSpacing = 4.0,
    this.maxLines,
  });

  final List<String> tags;
  final double spacing;
  final double runSpacing;
  final int? maxLines;

  @override
  Widget build(BuildContext context) {
    final displayTags = maxLines != null && tags.length > maxLines!
        ? tags.take(maxLines!).toList()
        : tags;

    return Wrap(
      spacing: spacing,
      runSpacing: runSpacing,
      children: [
        ...displayTags.map((tag) => AppTag(
          text: tag,
          type: AppTagType.secondary,
          size: AppTagSize.small,
        )),
        if (maxLines != null && tags.length > maxLines!)
          AppTag(
            text: '+${tags.length - maxLines!}',
            type: AppTagType.neutral,
            size: AppTagSize.small,
          ),
      ],
    );
  }
}