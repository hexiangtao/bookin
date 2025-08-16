import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../theme/app_colors.dart';

class CustomToast {
  static OverlayEntry? _overlayEntry;
  static Timer? _timer;

  static void show({
    required String message,
    ToastType type = ToastType.info,
    Duration duration = const Duration(seconds: 3),
    ToastPosition position = ToastPosition.top,
  }) {
    _removeCurrentToast();
    
    _overlayEntry = OverlayEntry(
      builder: (context) => _ToastWidget(
        message: message,
        type: type,
        position: position,
      ),
    );
    
    Overlay.of(Get.overlayContext!).insert(_overlayEntry!);
    
    _timer = Timer(duration, () {
      _removeCurrentToast();
    });
  }
  
  static void _removeCurrentToast() {
    _timer?.cancel();
    _timer = null;
    _overlayEntry?.remove();
    _overlayEntry = null;
  }
  
  static void showSuccess(String message) {
    show(message: message, type: ToastType.success);
  }
  
  static void showError(String message) {
    show(message: message, type: ToastType.error, duration: const Duration(seconds: 4));
  }
  
  static void showWarning(String message) {
    show(message: message, type: ToastType.warning);
  }
  
  static void showInfo(String message) {
    show(message: message, type: ToastType.info);
  }
}

enum ToastType { success, error, warning, info }
enum ToastPosition { top, center, bottom }

class _ToastWidget extends StatefulWidget {
  final String message;
  final ToastType type;
  final ToastPosition position;
  
  const _ToastWidget({
    required this.message,
    required this.type,
    required this.position,
  });
  
  @override
  State<_ToastWidget> createState() => _ToastWidgetState();
}

class _ToastWidgetState extends State<_ToastWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));
    
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));
    
    _animationController.forward();
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: widget.position == ToastPosition.top ? 60 : null,
      bottom: widget.position == ToastPosition.bottom ? 60 : null,
      left: 16,
      right: 16,
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Material(
                  color: Colors.transparent,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      color: _getBackgroundColor(),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _getColor().withOpacity(0.2),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: _getColor().withOpacity(0.15),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                          spreadRadius: 0,
                        ),
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 4,
                          offset: const Offset(0, 1),
                          spreadRadius: 0,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: _getColor().withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            _getIcon(),
                            color: _getColor(),
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            widget.message,
                            style: TextStyle(
                              color: _getTextColor(),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
  
  Color _getColor() {
    switch (widget.type) {
      case ToastType.success:
        return const Color(0xFF52C41A); // 更柔和的绿色
      case ToastType.error:
        return const Color(0xFFFF4D4F); // 更柔和的红色
      case ToastType.warning:
        return const Color(0xFFFAAD14); // 更柔和的橙色
      case ToastType.info:
        return const Color(0xFF1890FF); // 更柔和的蓝色
    }
  }
  
  Color _getBackgroundColor() {
    switch (widget.type) {
      case ToastType.success:
        return const Color(0xFFF6FFED); // 浅绿色背景
      case ToastType.error:
        return const Color(0xFFFFF2F0); // 浅红色背景
      case ToastType.warning:
        return const Color(0xFFFFFBE6); // 浅橙色背景
      case ToastType.info:
        return const Color(0xFFE6F7FF); // 浅蓝色背景
    }
  }
  
  Color _getTextColor() {
    switch (widget.type) {
      case ToastType.success:
        return const Color(0xFF135200); // 深绿色文字
      case ToastType.error:
        return const Color(0xFFA8071A); // 深红色文字
      case ToastType.warning:
        return const Color(0xFFAD4E00); // 深橙色文字
      case ToastType.info:
        return const Color(0xFF003A8C); // 深蓝色文字
    }
  }
  
  IconData _getIcon() {
    switch (widget.type) {
      case ToastType.success:
        return Icons.check_circle_rounded;
      case ToastType.error:
        return Icons.error_rounded;
      case ToastType.warning:
        return Icons.warning_rounded;
      case ToastType.info:
        return Icons.info_rounded;
    }
  }
}