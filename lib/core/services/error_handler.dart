import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'network_exception.dart';
import 'storage_service.dart';
import '../../modules/user/user_controller.dart';

class ErrorHandler {
  static final ErrorHandler _instance = ErrorHandler._internal();
  factory ErrorHandler() => _instance;
  ErrorHandler._internal();

  /// 处理并显示错误
  void handleError(dynamic error, {bool showSnackbar = true}) {
    String message = '未知错误';
    
    if (error is NetworkException) {
      message = error.message;
      
      // 特殊处理某些错误码
      switch (error.errorCode) {
        case 'UNAUTHORIZED':
          _handleUnauthorized();
          return;
        case 'CONNECTION_TIMEOUT':
        case 'CONNECTION_ERROR':
          message = '网络连接失败，请检查网络设置';
          break;
        case 'TOO_MANY_REQUESTS':
          message = '请求过于频繁，请稍后重试';
          break;
      }
    } else if (error is Exception) {
      message = error.toString().replaceFirst('Exception: ', '');
    } else {
      message = error.toString();
    }

    if (showSnackbar && Get.context != null) {
      _showErrorSnackbar(message);
    }
  }

  /// 显示错误提示
  void _showErrorSnackbar(String message) {
    Get.snackbar(
      '错误',
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.red.shade100,
      colorText: Colors.red.shade800,
      icon: const Icon(Icons.error_outline, color: Colors.red),
      duration: const Duration(seconds: 3),
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
    );
  }

  /// 处理未授权错误
  void _handleUnauthorized() {
    // 清除本地token
    try {
      final storageService = Get.find<StorageService>();
      storageService.removeToken();
      
      // 清除用户信息
      final userController = Get.find<UserController>();
      userController.logout();
    } catch (e) {
      print('⚠️ Failed to clear auth data: $e');
    }
    
    Get.snackbar(
      '登录过期',
      '请重新登录',
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.orange.shade100,
      colorText: Colors.orange.shade800,
      icon: const Icon(Icons.warning_outlined, color: Colors.orange),
      duration: const Duration(seconds: 3),
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
    );
    
    // 跳转到登录页面
    // TODO: 实现跳转到登录页面
    // Get.offAllNamed(AppRoutes.login);
  }

  /// 显示加载对话框
  void showLoading({String? message}) {
    Get.dialog(
      WillPopScope(
        onWillPop: () async => false,
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
                const CircularProgressIndicator(),
                if (message != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    message,
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  /// 隐藏加载对话框
  void hideLoading() {
    if (Get.isDialogOpen == true) {
      Get.back();
    }
  }

  /// 显示成功提示
  void showSuccess(String message) {
    Get.snackbar(
      '成功',
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.green.shade100,
      colorText: Colors.green.shade800,
      icon: const Icon(Icons.check_circle_outline, color: Colors.green),
      duration: const Duration(seconds: 2),
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
    );
  }

  /// 显示警告提示
  void showWarning(String message) {
    Get.snackbar(
      '提示',
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.orange.shade100,
      colorText: Colors.orange.shade800,
      icon: const Icon(Icons.warning_outlined, color: Colors.orange),
      duration: const Duration(seconds: 3),
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
    );
  }

  /// 显示确认对话框
  Future<bool> showConfirmDialog({
    required String title,
    required String content,
    String confirmText = '确定',
    String cancelText = '取消',
  }) async {
    final result = await Get.dialog<bool>(
      AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text(cancelText),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: Text(confirmText),
          ),
        ],
      ),
    );
    return result ?? false;
  }
}