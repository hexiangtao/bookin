import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'tab_shell_controller.dart';
import '../../modules/home/home_page.dart';
import '../../modules/teacher/teacher_page.dart';
import '../../modules/order/order_page.dart';
import '../../modules/user/user_page.dart';

class TabShellPage extends GetView<TabShellController> {
  const TabShellPage({super.key});

  @override
  Widget build(BuildContext context) {
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
        selectedItemColor: const Color(0xFFFF5777),
        unselectedItemColor: const Color(0xFF333333),
        backgroundColor: Colors.white,
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