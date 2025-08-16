import 'package:get/get.dart';
import 'login_controller.dart';
import 'password_login_controller.dart';

class LoginBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LoginController>(() => LoginController());
    Get.lazyPut<PasswordLoginController>(() => PasswordLoginController());
  }
}