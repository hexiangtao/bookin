import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../controllers/profile_controller.dart';

class ProfileMenuList extends StatelessWidget {
  final ProfileController controller;
  
  const ProfileMenuList({
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
          
          // 技师专属功能
          _buildTechnicianMenu(),
          
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
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.blackWithOpacity(0.05),
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
              style: AppTextStyles.label.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildTechnicianMenu() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.blackWithOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildMenuItem(
            icon: Icons.work_outline,
            label: '领务中心',
            color: const Color(0xFF6C63FF),
            onTap: () => controller.handleNavigation('technician_center'),
          ),
          _buildDivider(),
          _buildMenuItem(
            icon: Icons.person_outline,
            label: '我是技师',
            color: const Color(0xFFFF6B6B),
            onTap: () => controller.handleNavigation('technician_center'),
          ),
          _buildDivider(),
          _buildMenuItem(
            icon: Icons.store,
            label: '招商加盟',
            color: const Color(0xFF4ECDC4),
            onTap: () => controller.handleNavigation('technician_recruitment'),
          ),
          _buildDivider(),
          _buildMenuItem(
            icon: Icons.shopping_bag_outlined,
            label: '专属管家',
            color: const Color(0xFFFFE66D),
            onTap: () => controller.handleNavigation('customer_service'),
          ),
          _buildDivider(),
          _buildMenuItem(
            icon: Icons.info_outline,
            label: '关于我们',
            color: const Color(0xFF95E1D3),
            onTap: () => controller.handleNavigation('about'),
          ),
          _buildDivider(),
          _buildMenuItem(
            icon: Icons.feedback,
            label: '意见反馈',
            color: const Color(0xFFFFA726),
            onTap: () => controller.handleNavigation('feedback'),
            showArrow: false,
          ),
        ],
      ),
    );
  }
  
  Widget _buildMenuItem({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
    bool showArrow = true,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                icon,
                color: color,
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textPrimary,
            ),
              ),
            ),
            if (showArrow)
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: AppColors.textTertiary,
              ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildDivider() {
    return Container(
      margin: const EdgeInsets.only(left: 60),
      height: 1,
      color: AppColors.divider,
    );
  }
  
  Widget _buildLogoutButton() {
    return GestureDetector(
      onTap: controller.logout,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.error.withOpacity(0.3),
          ),
        ),
        child: Text(
          '退出登录',
          textAlign: TextAlign.center,
          style: AppTextStyles.buttonMedium.copyWith(
             color: AppColors.error,
           ),
        ),
      ),
    );
  }
}