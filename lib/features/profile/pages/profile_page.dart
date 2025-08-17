import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../controllers/profile_controller.dart';
import '../widgets/profile_header.dart';
import '../widgets/profile_menu_grid.dart';
import '../widgets/profile_menu_list.dart';
import '../widgets/profile_wallet_card.dart';
import '../widgets/profile_membership_card.dart';
import '../widgets/profile_stats_card.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ProfileController());
    
    return Scaffold(
      backgroundColor: AppColors.background, // 使用统一的背景色
      body: Obx(() {
        if (controller.isLoading.value && controller.userInfo.value == null) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        
        return RefreshIndicator(
          onRefresh: controller.onRefresh,
          child: CustomScrollView(
            slivers: [
              // 用户信息头部
              SliverToBoxAdapter(
                child: ProfileHeader(controller: controller),
              ),
              
              // 钱包卡片 - 添加上下边距
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: ProfileWalletCard(controller: controller),
                ),
              ),
              
              // 会员特权卡片 - 添加上下边距
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: ProfileMembershipCard(controller: controller),
                ),
              ),
          
              // 订单统计卡片 - 添加上下边距
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: ProfileStatsCard(controller: controller),
                ),
              ),
              
              // 根据布局类型显示不同的菜单 - 添加上下边距
              Obx(() {
                if (controller.layoutType.value == 'technician') {
                  return SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: ProfileMenuList(controller: controller),
                    ),
                  );
                } else {
                  return SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: ProfileMenuGrid(controller: controller),
                    ),
                  );
                }
              }),
              
              // 底部间距
              const SliverToBoxAdapter(
                child: SizedBox(height: 100),
              ),
            ],
          ),
        );
      }),
    );
  }
}