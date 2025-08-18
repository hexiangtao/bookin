import 'package:get/get.dart';
import '../../../core/services/api_client.dart';
import '../api/wallet_api.dart';
import '../controllers/wallet_controller.dart';

class WalletBinding extends Bindings {
  @override
  void dependencies() {
    // 注册钱包API
    Get.lazyPut<WalletApi>(
      () => WalletApi(Get.find<ApiClient>()),
      fenix: true,
    );
    
    // 注册钱包控制器
    Get.lazyPut<WalletController>(
      () => WalletController(),
      fenix: true,
    );
  }
}