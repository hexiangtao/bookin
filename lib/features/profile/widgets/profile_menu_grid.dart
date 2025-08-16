import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/profile_controller.dart';

class ProfileMenuGrid extends StatelessWidget {
  final ProfileController controller;
  
  const ProfileMenuGrid({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        children: [
          // 快捷功能
          _buildQuickActions(),
          
          const SizedBox(height: 16),
          
          // 邀请好友
          _buildInviteCard(),
          
          const SizedBox(height: 16),
          
          // 常用工具
          _buildToolsGrid(),
          
          const SizedBox(height: 16),
          
          // 退出登录
          _buildLogoutButton(),
        ],
      ),
    );
  }
  
  Widget _buildQuickActions() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildQuickActionItem(
            icon: Icons.favorite_border,
            label: '关注',
            color: const Color(0xFFFF6B6B),
            onTap: () => controller.handleNavigation('favorites'),
          ),
          _buildQuickActionItem(
            icon: Icons.send,
            label: '推荐',
            color: const Color(0xFF4ECDC4),
            onTap: () => controller.handleNavigation('invite_friends'),
          ),
          _buildQuickActionItem(
            icon: Icons.card_giftcard,
            label: '代金券',
            color: const Color(0xFFFFE66D),
            onTap: () => controller.handleNavigation('coupons'),
          ),
          _buildQuickActionItem(
            icon: Icons.headset_mic,
            label: '联系客服',
            color: const Color(0xFF95E1D3),
            onTap: () => controller.handleNavigation('customer_service'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildQuickActionItem({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                icon,
                color: color,
                size: 20,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF666666),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildInviteCard() {
    return GestureDetector(
      onTap: () => controller.handleNavigation('invite_friends'),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              Color(0xFFFF9A9E),
              Color(0xFFFECFEF),
            ],
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.card_giftcard,
              color: Colors.white,
              size: 24,
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '邀请好友',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '分享给好友，赢取丰厚大礼',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              color: Colors.white,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildToolsGrid() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '常用工具',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Color(0xFF333333),
            ),
          ),
          const SizedBox(height: 16),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 3,
            childAspectRatio: 1.2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            children: [
              _buildToolItem(
                icon: Icons.headset_mic_outlined,
                label: '领务中心',
                color: const Color(0xFF6C63FF),
                onTap: () => controller.handleNavigation('technician_center'),
              ),
              _buildToolItem(
                icon: Icons.person_add,
                label: '技师入驻',
                color: const Color(0xFFFF6B6B),
                onTap: () => controller.handleNavigation('technician_recruitment'),
              ),
              _buildToolItem(
                icon: Icons.store,
                label: '附近加盟',
                color: const Color(0xFF4ECDC4),
                onTap: () => controller.handleNavigation('nearby_stores'),
              ),
              _buildToolItem(
                icon: Icons.shopping_bag_outlined,
                label: '专属管家',
                color: const Color(0xFFFFE66D),
                onTap: () => controller.handleNavigation('customer_service'),
              ),
              _buildToolItem(
                icon: Icons.info_outline,
                label: '关于我们',
                color: const Color(0xFF95E1D3),
                onTap: () => controller.handleNavigation('about'),
              ),
              _buildToolItem(
                icon: Icons.feedback,
                label: '意见反馈',
                color: const Color(0xFFFFA726),
                onTap: () => controller.handleNavigation('feedback'),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildToolItem({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              icon,
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF666666),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
  
  Widget _buildLogoutButton() {
    return GestureDetector(
      onTap: controller.logout,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFFFF6B6B).withOpacity(0.3),
          ),
        ),
        child: const Text(
          '退出登录',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            color: Color(0xFFFF6B6B),
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}