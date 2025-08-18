import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../controllers/wallet_controller.dart';

class WalletBottomAction extends GetView<WalletController> {
  const WalletBottomAction({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: 20 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          // 价格信息
          Expanded(
            child: Obx(() {
              final amount = controller.selectedAmount;
              if (amount <= 0) {
                return Text(
                  '请选择充值金额',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: Colors.grey[600],
                    fontSize: 16,
                  ),
                );
              }
              
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 充值金额标签
                  Text(
                    '充值金额',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: Colors.grey[500],
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // 充值金额
                  Text(
                    '¥${amount.toStringAsFixed(2)}',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              );
            }),
          ),
          
          const SizedBox(width: 20),
          
          // 支付按钮
          Obx(() {
            final canPay = controller.canProceedPayment;
            final isProcessing = controller.isProcessingPayment;
            
            return AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              child: ElevatedButton(
                onPressed: canPay && !isProcessing ? controller.doRecharge : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: canPay ? AppColors.primary : Colors.grey[300],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 18,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: canPay ? 6 : 0,
                  shadowColor: canPay ? AppColors.primary.withOpacity(0.3) : null,
                ),
                child: Container(
                  constraints: const BoxConstraints(minWidth: 140),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (isProcessing) ...[
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                      Text(
                      isProcessing ? '处理中...' : _getPayButtonText(),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
  
  /// 获取支付按钮文本
  String _getPayButtonText() {
    final selectedPayment = controller.selectedPaymentMethod;
    if (selectedPayment == null) {
      return '立即充值';
    }
    
    switch (selectedPayment.type) {
      case 'wechat':
        return '微信支付';
      case 'alipay':
        return '支付宝支付';
      default:
        return '立即充值';
    }
  }
}