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
      
      return ClipRRect(
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        child: Container(
          height: 180, // 恢复原始高度避免与顶部图标过于紧凑
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
                  bottom: 20.0, // 优化底部边距
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end, // 内容下移对齐
                  children: [
                    // 用户信息 - 水平排列布局，包含设置图标
                    Obx(() {
                      final user = controller.userInfo.value;
                      
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // 左侧：用户头像和昵称
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // 用户头像
                              GestureDetector(
                                onTap: () => controller.handleNavigation('settings'),
                                child: Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: controller.getUserAvatarBackground(),
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.4),
                                      width: 2,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.2),
                                        blurRadius: 6,
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
                              
                              const SizedBox(width: 12), // 头像和昵称间距
                              
                              // 用户名
                              Text(
                                controller.getUserDisplayName(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  height: 1.2,
                                  shadows: [
                                    Shadow(
                                      offset: Offset(0, 1),
                                      blurRadius: 2,
                                      color: Color.fromRGBO(0, 0, 0, 0.6),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          
                          // 右侧：编辑图标
                          GestureDetector(
                            onTap: () => controller.handleNavigation('edit_profile'),
                            child: Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.edit,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ],
                      );
                    }),
                    
                    // 用户类型或等级 - 居中显示
                    Obx(() {
                      final user = controller.userInfo.value;
                      return Column(
                        children: [
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
                                  fontSize: 11,
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
                          
                          // 切换按钮（如果是技师）- 居中显示
                          if (controller.layoutType.value == 'technician')
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: GestureDetector(
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
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
          ),
          // 模糊效果层
           BackdropFilter(
             filter: ImageFilter.blur(sigmaX: 35.0, sigmaY: 35.0),
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
                 borderRadius: const BorderRadius.only(
                   bottomLeft: Radius.circular(30),
                   bottomRight: Radius.circular(30),
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
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF667EEA), // 柔和的蓝色
            Color(0xFF764BA2), // 柔和的紫色
          ],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
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