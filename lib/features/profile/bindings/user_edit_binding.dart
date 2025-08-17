import 'package:get/get.dart';
import '../controllers/user_edit_controller.dart';
import '../services/avatar_upload_service.dart';
import '../../../core/services/user_service.dart';

class UserEditBinding extends Bindings {
  @override
  void dependencies() {
    // 注入用户服务
    Get.lazyPut<UserService>(() => UserService());
    
    // 注入头像上传服务
    Get.lazyPut<AvatarUploadService>(() => AvatarUploadService());
    
    // 注入用户编辑控制器
    Get.lazyPut<UserEditController>(
      () => UserEditController(),
    );
  }
}