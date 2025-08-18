import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// 可访问性辅助工具类
class AccessibilityHelper {
  /// 提供触觉反馈
  static void provideTactileFeedback() {
    HapticFeedback.lightImpact();
  }

  /// 提供选择反馈
  static void provideSelectionFeedback() {
    HapticFeedback.selectionClick();
  }

  /// 提供错误反馈
  static void provideErrorFeedback() {
    HapticFeedback.heavyImpact();
  }

  /// 创建可访问的按钮
  static Widget accessibleButton({
    required Widget child,
    required VoidCallback onPressed,
    required String semanticLabel,
    String? hint,
    bool enabled = true,
  }) {
    return Semantics(
      button: true,
      enabled: enabled,
      label: semanticLabel,
      hint: hint,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: enabled ? () {
            provideTactileFeedback();
            onPressed();
          } : null,
          borderRadius: BorderRadius.circular(8),
          child: child,
        ),
      ),
    );
  }

  /// 创建可访问的输入框
  static Widget accessibleTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    TextInputType? keyboardType,
    ValueChanged<String>? onChanged,
    String? errorText,
  }) {
    return Semantics(
      textField: true,
      label: label,
      hint: hint,
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          errorText: errorText,
          border: OutlineInputBorder(),
        ),
      ),
    );
  }

  /// 创建可访问的列表项
  static Widget accessibleListItem({
    required Widget child,
    required String semanticLabel,
    VoidCallback? onTap,
    bool selected = false,
    String? hint,
  }) {
    return Semantics(
      button: onTap != null,
      selected: selected,
      label: semanticLabel,
      hint: hint,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap != null ? () {
            provideSelectionFeedback();
            onTap();
          } : null,
          child: child,
        ),
      ),
    );
  }

  /// 创建可访问的标题
  static Widget accessibleHeader({
    required String text,
    required TextStyle style,
    int level = 1,
  }) {
    return Semantics(
      header: true,
      child: Text(
        text,
        style: style,
      ),
    );
  }

  /// 创建实时更新区域
  static Widget liveRegion({
    required Widget child,
    bool polite = true,
  }) {
    return Semantics(
      liveRegion: true,
      child: child,
    );
  }

  /// 检查是否启用了可访问性服务
  static bool isAccessibilityEnabled(BuildContext context) {
    return MediaQuery.of(context).accessibleNavigation;
  }

  /// 获取推荐的最小触摸目标尺寸
  static double getMinimumTouchTargetSize() {
    return 48.0; // Material Design 推荐的最小触摸目标尺寸
  }

  /// 创建可访问的图标按钮
  static Widget accessibleIconButton({
    required IconData icon,
    required VoidCallback onPressed,
    required String semanticLabel,
    String? tooltip,
    Color? color,
    double? size,
  }) {
    return Semantics(
      button: true,
      label: semanticLabel,
      hint: tooltip,
      child: IconButton(
        icon: Icon(icon, color: color, size: size),
        onPressed: () {
          provideTactileFeedback();
          onPressed();
        },
        tooltip: tooltip,
        iconSize: size ?? 24,
      ),
    );
  }

  /// 创建可访问的开关
  static Widget accessibleSwitch({
    required bool value,
    required ValueChanged<bool> onChanged,
    required String label,
    String? description,
  }) {
    return Semantics(
      toggled: value,
      label: label,
      hint: description,
      child: Switch(
        value: value,
        onChanged: (newValue) {
          provideSelectionFeedback();
          onChanged(newValue);
        },
      ),
    );
  }
}