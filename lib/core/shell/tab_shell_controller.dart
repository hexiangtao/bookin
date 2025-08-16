import 'package:get/get.dart';

class TabShellController extends GetxController {
  final RxInt currentIndex = 0.obs;

  @override
  void onInit() {
    super.onInit();
    print('🏠 TabShellController initialized');
  }

  void changeTab(int index) {
    print('🔄 Changing tab to index: $index');
    currentIndex.value = index;
  }
}