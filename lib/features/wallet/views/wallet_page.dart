import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/custom_app_bar.dart';
import '../../../core/widgets/loading_widget.dart';
import '../controllers/wallet_controller.dart';
import '../widgets/wallet_balance_card.dart';
import '../widgets/wallet_quick_entry.dart';
import '../widgets/wallet_recharge_section.dart';
import '../widgets/wallet_payment_section.dart';
import '../widgets/wallet_bottom_action.dart';

class WalletPage extends GetView<WalletController> {
  const WalletPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: '我的钱包',
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: controller.refreshData,
        color: AppColors.secondary,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              // 余额卡片
              const WalletBalanceCard(),
              
              const SizedBox(height: 16),
              
              // 快捷入口
              const WalletQuickEntry(),
              
              const SizedBox(height: 16),
              
              // 充值区域
              Obx(() => AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                height: controller.showRechargeSection ? null : 0,
                child: controller.showRechargeSection
                    ? Column(
                        children: [
                          const WalletRechargeSection(),
                          const SizedBox(height: 16),
                          const WalletPaymentSection(),
                          const SizedBox(height: 16),
                          _buildSecurityTips(),
                          const SizedBox(height: 100), // 为底部操作栏留出空间
                        ],
                      )
                    : const SizedBox.shrink(),
              )),
              
              // 底部安全间距
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
      // 底部操作栏
      bottomSheet: Obx(() => controller.showRechargeSection
          ? const WalletBottomAction()
          : const SizedBox.shrink()),
    );
  }
  
  /// 构建安全提示
  Widget _buildSecurityTips() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.secondary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.secondary.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.security,
            size: 20,
            color: AppColors.secondary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '充值过程受银行级安全保护，请放心使用',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}