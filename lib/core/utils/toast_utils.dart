import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../theme/app_colors.dart';
import '../widgets/custom_toast.dart';

class ToastUtils {
  // 显示成功提示
  static void showSuccess(String message) {
    CustomToast.showSuccess(message);
  }
  
  // 显示错误提示
  static void showError(String message) {
    CustomToast.showError(message);
  }
  
  // 显示警告提示
  static void showWarning(String message) {
    CustomToast.showWarning(message);
  }
  
  // 显示信息提示
  static void showInfo(String message) {
    CustomToast.showInfo(message);
  }
  
  // 显示加载提示
  static void showLoading([String message = '加载中...']) {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.black87,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
              const SizedBox(height: 16),
              Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }
  
  // 隐藏加载提示
  static void hideLoading() {
    if (Get.isDialogOpen == true) {
      Get.back();
    }
  }
  
  // 显示确认对话框
  static Future<bool> showConfirm({
    required String title,
    required String message,
    String confirmText = '确认',
    String cancelText = '取消',
  }) async {
    final result = await Get.dialog<bool>(
      AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text(
              cancelText,
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: Text(
              confirmText,
              style: TextStyle(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
    
    return result ?? false;
  }
  
  // 显示底部提示
  static void showBottomToast(String message) {
    Get.snackbar(
      '',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.black87,
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
      titleText: const SizedBox.shrink(),
    );
  }
  
  // 显示自定义Snackbar
  static void showCustom({
    required String title,
    required String message,
    Color? backgroundColor,
    Color? textColor,
    Widget? icon,
    Duration? duration,
    SnackPosition position = SnackPosition.TOP,
  }) {
    Get.snackbar(
      title,
      message,
      snackPosition: position,
      backgroundColor: backgroundColor ?? AppColors.primary,
      colorText: textColor ?? Colors.white,
      duration: duration ?? const Duration(seconds: 2),
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
      icon: icon,
    );
  }
}