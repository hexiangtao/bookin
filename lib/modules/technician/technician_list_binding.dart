import 'package:get/get.dart';
import 'technician_list_controller.dart';

class TechnicianListBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TechnicianListController>(
      () => TechnicianListController(),
    );
  }
}