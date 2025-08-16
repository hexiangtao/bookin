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
        child: Stack(
          children: [
            // 背景层
            Positioned.fill(
              child: _buildBackgroundDecoration(user?.avatar),
            ),
            // 内容层
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
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
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // 用户信息
                    Obx(() {
                      final user = controller.userInfo.value;
                      
                      return Row(
                        children: [
                          // 用户头像
                          GestureDetector(
                            onTap: () => controller.handleNavigation('settings'),
                            child: Container(
                              width: 70,
                              height: 70,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: controller.getUserAvatarBackground(),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.3),
                                  width: 2,
                                ),
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
                          
                          const SizedBox(width: 12),
                          
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
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    shadows: [
                                      Shadow(
                                        offset: Offset(0, 1),
                                        blurRadius: 3,
                                        color: Color.fromRGBO(0, 0, 0, 0.5),
                                      ),
                                      Shadow(
                                        offset: Offset(0, 2),
                                        blurRadius: 6,
                                        color: Color.fromRGBO(0, 0, 0, 0.3),
                                      ),
                                    ],
                                  ),
                                ),
                                
                                const SizedBox(height: 6),
                                
                                // 用户类型或等级
                                if (user?.userType != null)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 3,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      _getUserTypeText(user!.userType!),
                                      style: const TextStyle(
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
      return Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: CachedNetworkImageProvider(avatarUrl!),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.3),
              BlendMode.darken,
            ),
          ),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withOpacity(0.1),
              Colors.black.withOpacity(0.2),
              Colors.white.withOpacity(0.1),
            ],
            stops: const [0.0, 0.5, 1.0],
          ),
        ),
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