import 'package:flutter/material.dart';

class EmptyWidget extends StatelessWidget {
  final String message;
  final String? description;
  final Widget? icon;
  final VoidCallback? onRetry;
  final String? retryText;
  final EdgeInsetsGeometry? padding;
  final Color? textColor;
  final Color? buttonColor;

  const EmptyWidget({
    super.key,
    required this.message,
    this.description,
    this.icon,
    this.onRetry,
    this.retryText,
    this.padding,
    this.textColor,
    this.buttonColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.all(40),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 图标
            icon ??
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(40),
                  ),
                  child: const Icon(
                    Icons.inbox_outlined,
                    size: 40,
                    color: Color(0xFFCCCCCC),
                  ),
                ),
            
            const SizedBox(height: 20),
            
            // 主要消息
            Text(
              message,
              style: TextStyle(
                fontSize: 16,
                color: textColor ?? const Color(0xFF666666),
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            
            // 描述信息
            if (description != null) ...{
              const SizedBox(height: 8),
              Text(
                description!,
                style: TextStyle(
                  fontSize: 14,
                  color: textColor?.withOpacity(0.7) ?? const Color(0xFF999999),
                ),
                textAlign: TextAlign.center,
              ),
            },
            
            // 重试按钮
            if (onRetry != null) ...{
              const SizedBox(height: 24),
              GestureDetector(
                onTap: onRetry,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: buttonColor ?? const Color(0xFFFF5777),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    retryText ?? '重试',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            },
          ],
        ),
      ),
    );
  }
}

/// 网络错误空状态
class NetworkErrorWidget extends StatelessWidget {
  final VoidCallback? onRetry;
  final String? message;

  const NetworkErrorWidget({
    super.key,
    this.onRetry,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return EmptyWidget(
      message: message ?? '网络连接失败',
      description: '请检查网络设置后重试',
      icon: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(40),
        ),
        child: const Icon(
          Icons.wifi_off,
          size: 40,
          color: Color(0xFFCCCCCC),
        ),
      ),
      onRetry: onRetry,
      retryText: '重新加载',
    );
  }
}

/// 搜索无结果空状态
class SearchEmptyWidget extends StatelessWidget {
  final String? keyword;
  final VoidCallback? onClear;

  const SearchEmptyWidget({
    super.key,
    this.keyword,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return EmptyWidget(
      message: keyword != null ? '未找到"$keyword"相关结果' : '暂无搜索结果',
      description: '试试其他关键词吧',
      icon: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(40),
        ),
        child: const Icon(
          Icons.search_off,
          size: 40,
          color: Color(0xFFCCCCCC),
        ),
      ),
      onRetry: onClear,
      retryText: '清空搜索',
    );
  }
}