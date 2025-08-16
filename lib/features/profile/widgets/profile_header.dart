import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../controllers/profile_controller.dart';

class ProfileHeader extends StatelessWidget {
  final ProfileController controller;
  
  const ProfileHeader({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final user = controller.userInfo.value;
      
      return Container(
        height: 120, // 更紧凑的高度
        child: Stack(
          children: [
            // 背景层 - 限制在容器范围内
            Positioned.fill(
              child: ClipRect(
                child: _buildBackgroundDecoration(user?.avatar),
              ),
            ),
            // 内容层
            SafeArea(
              bottom: false, // 不使用底部SafeArea
              child: Padding(
                padding: const EdgeInsets.only(
                  left: 16.0,
                  right: 16.0,
                  top: 0.0, // 移除顶部边距
                  bottom: 8.0, // 最小底部边距
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween, // 分散对齐
                  children: [
                    // 顶部工具栏 - 只保留设置按钮
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          onPressed: () => controller.handleNavigation('settings'),
                          icon: const Icon(
                            Icons.settings,
                            color: Colors.white,
                            size: 24,
                          ),
                          padding: EdgeInsets.zero, // 移除按钮内边距
                          constraints: const BoxConstraints(), // 移除最小尺寸约束
                        ),
                      ],
                    ),
                    
                    // 用户信息
                    Obx(() {
                      final user = controller.userInfo.value;
                      
                      return Row(
                        children: [
                          // 用户头像
                          GestureDetector(
                            onTap: () => controller.handleNavigation('settings'),
                            child: Container(
                              width: 75, // 适中的头像尺寸
                              height: 75,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: controller.getUserAvatarBackground(),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.4), // 增加边框透明度
                                  width: 3, // 增加边框宽度
                                ),
                                boxShadow: [ // 添加阴影效果
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: user?.avatar?.isNotEmpty == true
                                  ? ClipOval(
                                      child: CachedNetworkImage(
                                        imageUrl: user!.avatar!,
                                        fit: BoxFit.cover,
                                        placeholder: (context, url) => const Center(
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                          ),
                                        ),
                                        errorWidget: (context, url, error) => _buildAvatarPlaceholder(),
                                      ),
                                    )
                                  : _buildAvatarPlaceholder(),
                            ),
                          ),
                          
                          const SizedBox(width: 10), // 紧凑的头像和文本间距
                          
                          // 用户信息
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // 用户名 - 添加阴影增强可读性
                                Text(
                                  controller.getUserDisplayName(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18, // 适中的字体大小
                                    fontWeight: FontWeight.bold,
                                    height: 1.2, // 紧凑的行高
                                    shadows: [
                                      Shadow(
                                        offset: Offset(0, 1),
                                        blurRadius: 2,
                                        color: Color.fromRGBO(0, 0, 0, 0.6),
                                      ),
                                    ],
                                  ),
                                ),
                                
                                const SizedBox(height: 2), // 最小间距
                                
                                // 用户类型或等级
                                if (user?.userType != null)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      _getUserTypeText(user!.userType!),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        height: 1.1,
                                        shadows: [
                                          Shadow(
                                            offset: Offset(0, 1),
                                            blurRadius: 1.5,
                                            color: Color.fromRGBO(0, 0, 0, 0.4),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          
                          // 切换按钮（如果是技师）
                          if (controller.layoutType.value == 'technician')
                            GestureDetector(
                              onTap: () => controller.handleNavigation('technician_center'),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.3),
                                  ),
                                ),
                                child: const Text(
                                  '切换',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    shadows: [
                                      Shadow(
                                        offset: Offset(0, 1),
                                        blurRadius: 2,
                                        color: Color.fromRGBO(0, 0, 0, 0.4),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                        ],
                      );
                    }),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
  
  /// 构建背景装饰 - 使用头像图片作为模糊背景
  Widget _buildBackgroundDecoration(String? avatarUrl) {
    if (avatarUrl?.isNotEmpty == true) {
      return Stack(
        children: [
          // 背景图片
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: CachedNetworkImageProvider(avatarUrl!),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // 模糊效果层
           BackdropFilter(
             filter: ImageFilter.blur(sigmaX: 25.0, sigmaY: 25.0),
             child: Container(
               decoration: BoxDecoration(
                 color: Colors.black.withOpacity(0.4),
                 gradient: LinearGradient(
                   begin: Alignment.topCenter,
                   end: Alignment.bottomCenter,
                   colors: [
                     Colors.black.withOpacity(0.3),
                     Colors.black.withOpacity(0.5),
                     Colors.black.withOpacity(0.2),
                   ],
                   stops: const [0.0, 0.6, 1.0],
                 ),
               ),
             ),
           ),
        ],
      );
    }
    
    return _buildDefaultBackground();
  }
  
  /// 构建默认背景
  Widget _buildDefaultBackground() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF667EEA), // 柔和的蓝色
            Color(0xFF764BA2), // 柔和的紫色
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarPlaceholder() {
    return Center(
      child: Text(
        controller.getUserDisplayName().substring(0, 1).toUpperCase(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
  
  String _getUserTypeText(String userType) {
    switch (userType) {
      case 'technician':
        return '技师';
      case 'vip':
        return 'VIP用户';
      case 'premium':
        return '高级用户';
      default:
        return '普通用户';
    }
  }
}