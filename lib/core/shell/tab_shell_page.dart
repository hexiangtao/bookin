import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../theme/app_colors.dart';
import 'tab_shell_controller.dart';
import '../../modules/home/home_page.dart';
import '../../modules/teacher/teacher_page.dart';
import '../../modules/order/order_page.dart';
import '../../modules/user/user_page.dart';

class TabShellPage extends GetView<TabShellController> {
  const TabShellPage({super.key});

  @override
  Widget build(BuildContext context) {
    print('🏗️ Building TabShellPage');
    return Scaffold(
      body: Obx(() => IndexedStack(
        index: controller.currentIndex.value,
        children: const [
          HomePage(),
          TeacherPage(),
          OrderPage(),
          UserPage(),
        ],
      )),
      bottomNavigationBar: Obx(() => BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: controller.currentIndex.value,
        onTap: controller.changeTab,
        selectedItemColor: AppColors.secondary,
        unselectedItemColor: AppColors.textPrimary,
        backgroundColor: AppColors.surface,
        elevation: 8,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: '首页',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: '技师',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt_outlined),
            activeIcon: Icon(Icons.list_alt),
            label: '订单',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle_outlined),
            activeIcon: Icon(Icons.account_circle),
            label: '我的',
          ),
        ],
      )),
    );
  }
}