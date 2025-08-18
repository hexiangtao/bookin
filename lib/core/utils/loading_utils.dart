import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../theme/app_colors.dart';

class LoadingUtils {
  static OverlayEntry? _overlayEntry;
  static bool _isShowing = false;

  /// 显示加载对话框
  static void showLoading({String? message}) {
    if (_isShowing) return;
    
    _isShowing = true;
    _overlayEntry = OverlayEntry(
      builder: (context) => Material(
        color: Colors.black54,
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
                if (message != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    message,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
    
    Overlay.of(Get.context!)?.insert(_overlayEntry!);
  }

  /// 隐藏加载对话框
  static void hideLoading() {
    if (!_isShowing) return;
    
    _isShowing = false;
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  /// 显示带超时的加载
  static void showLoadingWithTimeout({
    String? message,
    Duration timeout = const Duration(seconds: 30),
  }) {
    showLoading(message: message);
    
    Future.delayed(timeout, () {
      if (_isShowing) {
        hideLoading();
        Get.snackbar(
          '提示',
          '请求超时，请检查网络连接',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
      }
    });
  }

  /// 检查是否正在显示加载
  static bool get isShowing => _isShowing;
}