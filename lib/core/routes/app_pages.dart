import 'package:get/get.dart';

import '../../modules/home/home_binding.dart';
import '../../modules/home/home_page.dart';
import 'app_routes.dart';
import 'package:flutter/material.dart';
import '../shell/tab_shell_page.dart';
// import '../shell/tab_shell_controller.dart';

class AppPages {
  static final routes = <GetPage<dynamic>>[
    GetPage(
      name: AppRoutes.initial,
      page: () => const TabShellPage(),
      // Binding moved to InitialBinding to avoid duplicate injection
    ),
    GetPage(
      name: AppRoutes.home,
      page: () => const HomePage(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: AppRoutes.teacher,
      page: () => const _PlaceholderPage(title: '技师'),
    ),
    GetPage(
      name: AppRoutes.order,
      page: () => const _PlaceholderPage(title: '订单'),
    ),
    GetPage(
      name: AppRoutes.user,
      page: () => const _PlaceholderPage(title: '我的'),
    ),
  ];
}

class _PlaceholderPage extends StatelessWidget {
  final String title;
  const _PlaceholderPage({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(child: Text('$title 页面建设中')),
    );
  }
}