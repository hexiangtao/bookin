import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class NetworkImageWithFallback extends StatelessWidget {
  final String imageUrl;
  final Widget? placeholder;
  final Widget? errorWidget;
  final BoxFit? fit;
  final double? width;
  final double? height;
  final Color? color;
  final BlendMode? colorBlendMode;

  const NetworkImageWithFallback({
    Key? key,
    required this.imageUrl,
    this.placeholder,
    this.errorWidget,
    this.fit,
    this.width,
    this.height,
    this.color,
    this.colorBlendMode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 如果图片URL为空，直接显示错误组件
    if (imageUrl.isEmpty) {
      return errorWidget ?? _buildDefaultErrorWidget();
    }

    // 在Web环境中，使用特殊的处理方式
    if (kIsWeb) {
      return _buildWebImage();
    }

    // 非Web环境使用标准的Image.network
    return Image.network(
      imageUrl,
      width: width,
      height: height,
      fit: fit,
      color: color,
      colorBlendMode: colorBlendMode,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return placeholder ?? _buildDefaultPlaceholder();
      },
      errorBuilder: (context, error, stackTrace) {
        return errorWidget ?? _buildDefaultErrorWidget();
      },
    );
  }

  Widget _buildWebImage() {
    // 在Web环境中，使用带有特殊头部的请求
    return Image.network(
      _getCorsProxiedUrl(imageUrl),
      width: width,
      height: height,
      fit: fit,
      color: color,
      colorBlendMode: colorBlendMode,
      headers: kIsWeb ? {
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Methods': 'GET, OPTIONS',
        'Access-Control-Allow-Headers': 'Content-Type, Accept',
        'Cache-Control': 'no-cache',
        'Pragma': 'no-cache',
      } : null,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return placeholder ?? _buildDefaultPlaceholder();
      },
      errorBuilder: (context, error, stackTrace) {
        print('Image loading error: $error');
        return errorWidget ?? _buildDefaultErrorWidget();
      },
    );
  }

  String _getCorsProxiedUrl(String originalUrl) {
    // 如果是阿里云OSS图片，尝试添加CORS参数
    if (originalUrl.contains('aliyuncs.com')) {
      // 添加时间戳避免缓存问题
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final separator = originalUrl.contains('?') ? '&' : '?';
      return '$originalUrl${separator}t=$timestamp';
    }
    
    // 对于其他图片，可以考虑使用代理
    return originalUrl;
  }

  Widget _buildDefaultPlaceholder() {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFFFF5777).withOpacity(0.1),
            const Color(0xFFFF8CA0).withOpacity(0.1),
          ],
        ),
      ),
      child: const Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF5777)),
          ),
        ),
      ),
    );
  }

  Widget _buildDefaultErrorWidget() {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFFFF5777).withOpacity(0.1),
            const Color(0xFFFF8CA0).withOpacity(0.1),
          ],
        ),
      ),
      child: const Center(
        child: Icon(
          Icons.image_not_supported,
          color: Color(0xFFFF5777),
          size: 24,
        ),
      ),
    );
  }
}

// 扩展的网络图片组件，专门用于头像
class AvatarImageWithFallback extends StatelessWidget {
  final String imageUrl;
  final String fallbackText;
  final double size;
  final Color? backgroundColor;

  const AvatarImageWithFallback({
    Key? key,
    required this.imageUrl,
    required this.fallbackText,
    this.size = 60,
    this.backgroundColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
      ),
      child: ClipOval(
        child: NetworkImageWithFallback(
          imageUrl: imageUrl,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorWidget: _buildAvatarPlaceholder(),
          placeholder: _buildAvatarPlaceholder(),
        ),
      ),
    );
  }

  Widget _buildAvatarPlaceholder() {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: backgroundColor ?? const Color(0xFFFF5777).withOpacity(0.1),
        gradient: backgroundColor == null ? LinearGradient(
          colors: [
            const Color(0xFFFF5777).withOpacity(0.2),
            const Color(0xFFFF8CA0).withOpacity(0.2),
          ],
        ) : null,
      ),
      child: Center(
        child: Text(
          fallbackText.isNotEmpty ? fallbackText[0].toUpperCase() : '?',
          style: TextStyle(
            fontSize: size * 0.4,
            fontWeight: FontWeight.bold,
            color: const Color(0xFFFF5777),
          ),
        ),
      ),
    );
  }
} 