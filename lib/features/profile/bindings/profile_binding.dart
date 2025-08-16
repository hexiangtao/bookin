import 'package:get/get.dart';
import '../controllers/profile_controller.dart';
import '../../../core/services/user_service.dart';

class ProfileBinding extends Bindings {
  @override
  void dependencies() {
    // 注入用户服务
    Get.lazyPut<UserService>(() => UserService());
    
    // 注入个人资料控制器
    Get.lazyPut<ProfileController>(
      () => ProfileController(),
    );
  }
}