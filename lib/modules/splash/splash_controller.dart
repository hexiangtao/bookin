import 'package:get/get.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/storage_service.dart';
import '../user/user_controller.dart';

class SplashController extends GetxController {
  final loading = true.obs;
  
  @override
  void onInit() {
    super.onInit();
    _initializeApp();
  }
  
  /// 初始化应用
  Future<void> _initializeApp() async {
    try {
      print('🚀 SplashController: Initializing app');
      // 确保存储服务已初始化
      await StorageService().init();
      
      // 检查登录状态
      final isLoggedIn = await AuthService.instance.isLoggedIn();
      print('🔐 SplashController: Login status - $isLoggedIn');
      
      if (isLoggedIn) {
        // 用户已登录，初始化用户控制器并跳转到主页
        print('✅ SplashController: User is logged in, initializing UserController');
        final userController = Get.put(UserController());
        await userController.updateLoginStatus();
        
        // 延迟一下再跳转，让用户看到启动页面
        await Future.delayed(const Duration(milliseconds: 1500));
        
        // 检查当前路由，如果已经在主页或登录页面，则不再跳转
        final currentRoute = Get.currentRoute;
        print('🔍 SplashController: Current route before navigation: $currentRoute');
        
        if (currentRoute != '/home' && currentRoute != '/login') {
          print('🏠 SplashController: Navigating to /home');
          Get.offAllNamed('/home');
        } else {
          print('⏭️ SplashController: Already on target route, skipping navigation');
        }
      } else {
        // 用户未登录，跳转到登录页面
        print('❌ SplashController: User not logged in, navigating to /login');
        await Future.delayed(const Duration(milliseconds: 1500));
        Get.offAllNamed('/login');
      }
    } catch (e) {
      print('❌ SplashController: App initialization error - $e');
      // 出错时跳转到登录页面
      await Future.delayed(const Duration(milliseconds: 1500));
      Get.offAllNamed('/login');
    } finally {
      loading.value = false;
    }
  }
}

/// 启动页面绑定
class SplashBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SplashController>(() => SplashController());
  }
}