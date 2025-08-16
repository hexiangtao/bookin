import 'package:get/get.dart';
import 'technician_detail_controller.dart';

class TechnicianDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TechnicianDetailController>(
      () => TechnicianDetailController(),
    );
  }
}