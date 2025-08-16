import 'package:get/get.dart';

import '../services/storage_service.dart';
import '../shell/tab_shell_controller.dart';
import '../../modules/home/home_controller.dart';
import '../../modules/user/user_controller.dart';
import '../../modules/technician/technician_controller.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.putAsync<StorageService>(() async => await StorageService().init(), permanent: true);
    Get.put<TabShellController>(TabShellController(), permanent: true);
    Get.lazyPut<HomeController>(() => HomeController());
    Get.lazyPut<UserController>(() => UserController());
    Get.lazyPut<TechnicianController>(() => TechnicianController());
  }
}