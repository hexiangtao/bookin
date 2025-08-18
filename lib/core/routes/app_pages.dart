import 'package:get/get.dart';
import 'package:flutter/material.dart';

import '../../modules/splash/splash_page.dart';
import '../../modules/splash/splash_binding.dart';
import '../shell/tab_shell_page.dart';
import '../../modules/teacher/teacher_page.dart';
import '../../modules/teacher/teacher_binding.dart';
import '../../features/profile/pages/profile_page.dart';
import '../../features/profile/bindings/profile_binding.dart';
import '../../features/profile/pages/user_edit_page.dart';
import '../../features/profile/bindings/user_edit_binding.dart';
import '../../modules/user/login_page.dart';
import '../../modules/user/login_binding.dart';
import '../../modules/user/password_login_page.dart';
import '../../modules/user/password_login_controller.dart';
import '../../modules/technician/technician_list_page.dart';
import '../../modules/technician/technician_list_binding.dart';
import '../../modules/technician/technician_detail_page.dart';
import '../../modules/technician/technician_detail_binding.dart';
import '../../features/wallet/views/wallet_page.dart';
import '../../features/wallet/bindings/wallet_binding.dart';
import 'app_routes.dart';



class AppPages {
  static final routes = <GetPage<dynamic>>[
    GetPage(
      name: AppRoutes.initial,
      page: () => const SplashPage(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashPage(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: AppRoutes.home,
      page: () => const TabShellPage(),
      // Binding moved to InitialBinding to avoid duplicate injection
    ),
    GetPage(
      name: AppRoutes.teacher,
      page: () => const TeacherPage(),
      binding: TeacherBinding(),
    ),
    GetPage(
      name: AppRoutes.order,
      page: () => const _PlaceholderPage(title: '订单'),
    ),
    GetPage(
      name: AppRoutes.user,
      page: () => const ProfilePage(),
      binding: ProfileBinding(),
    ),
    GetPage(
      name: AppRoutes.userEdit,
      page: () => const UserEditPage(),
      binding: UserEditBinding(),
    ),
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginPage(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: AppRoutes.passwordLogin,
      page: () => const PasswordLoginPage(),
      binding: PasswordLoginBinding(),
    ),
    GetPage(
      name: AppRoutes.teacherList,
      page: () => const TechnicianListPage(),
      binding: TechnicianListBinding(),
    ),
    GetPage(
      name: AppRoutes.teacherDetail,
      page: () => const TechnicianDetailPage(),
      binding: TechnicianDetailBinding(),
    ),
    GetPage(
      name: AppRoutes.userWallet,
      page: () => const WalletPage(),
      binding: WalletBinding(),
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