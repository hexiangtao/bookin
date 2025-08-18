import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../controllers/wallet_controller.dart';

class WalletPaymentSection extends GetView<WalletController> {
  const WalletPaymentSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题
          Row(
            children: [
              Container(
                width: 4,
                height: 16,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '选择支付方式',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // 支付方式列表
          Obx(() {
            final paymentMethods = controller.paymentMethods;
            return Column(
              children: paymentMethods.asMap().entries.map((entry) {
                final index = entry.key;
                final method = entry.value;
                return _buildPaymentMethodItem(method, index);
              }).toList(),
            );
          }),
        ],
      ),
    );
  }
  
  /// 构建支付方式项
  Widget _buildPaymentMethodItem(method, int index) {
    return Obx(() {
      final isSelected = controller.selectedPaymentIndex == index;
      
      return GestureDetector(
        onTap: () => controller.selectPayment(index),
        child: Container(
          margin: EdgeInsets.only(
            bottom: index < controller.paymentMethods.length - 1 ? 12 : 0,
          ),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? _getPaymentColor(method.type) : Colors.grey[200]!,
              width: isSelected ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: isSelected 
                    ? _getPaymentColor(method.type).withOpacity(0.15)
                    : Colors.black.withOpacity(0.03),
                blurRadius: isSelected ? 8 : 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // 支付方式图标
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _getPaymentColor(method.type).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getPaymentIcon(method.type),
                  color: _getPaymentColor(method.type),
                  size: 20,
                ),
              ),
              
              const SizedBox(width: 16),
              
              // 支付方式信息
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      method.name,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    if (method.description != null && method.description!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        method.description!,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              
              // 选中状态指示器
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected ? _getPaymentColor(method.type) : Colors.transparent,
                  border: Border.all(
                    color: isSelected ? _getPaymentColor(method.type) : Colors.grey[400]!,
                    width: 2,
                  ),
                ),
                child: isSelected
                    ? const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 12,
                      )
                    : null,
              ),
            ],
          ),
        ),
      );
    });
  }
  
  /// 获取支付方式图标
  IconData _getPaymentIcon(String type) {
    switch (type) {
      case 'wechat':
        return Icons.chat_bubble;
      case 'alipay':
        return Icons.account_balance_wallet;
      default:
        return Icons.payment;
    }
  }
  
  /// 获取支付方式颜色
  Color _getPaymentColor(String type) {
    switch (type) {
      case 'wechat':
        return const Color(0xFF44c35a); // 微信绿
      case 'alipay':
        return const Color(0xFF1890ff); // 支付宝蓝
      default:
        return Colors.grey;
    }
  }
}