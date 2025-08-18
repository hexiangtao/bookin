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
                  color: AppColors.secondary,
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
      
      return AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: EdgeInsets.only(
          bottom: index < controller.paymentMethods.length - 1 ? 10 : 0,
        ),
        child: GestureDetector(
          onTap: () => controller.selectPayment(index),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: isSelected 
                ? LinearGradient(
                    colors: [
                      _getPaymentColor(method.type).withOpacity(0.1),
                      _getPaymentColor(method.type).withOpacity(0.05),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : LinearGradient(
                    colors: [Colors.white, Colors.grey[50]!],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected ? _getPaymentColor(method.type) : Colors.grey[200]!,
                width: isSelected ? 2 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: isSelected 
                      ? _getPaymentColor(method.type).withOpacity(0.2)
                      : Colors.black.withOpacity(0.03),
                  blurRadius: isSelected ? 12 : 6,
                  offset: const Offset(0, 4),
                  spreadRadius: isSelected ? 1 : 0,
                ),
              ],
            ),
            child: Row(
              children: [
                // 支付方式图标
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isSelected 
                        ? [
                            _getPaymentColor(method.type),
                            _getPaymentColor(method.type).withOpacity(0.8),
                          ]
                        : [
                            _getPaymentColor(method.type).withOpacity(0.1),
                            _getPaymentColor(method.type).withOpacity(0.05),
                          ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: isSelected ? [
                      BoxShadow(
                        color: _getPaymentColor(method.type).withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ] : null,
                  ),
                  child: Icon(
                    _getPaymentIcon(method.type),
                    color: isSelected ? Colors.white : _getPaymentColor(method.type),
                    size: 24,
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
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: isSelected 
                            ? _getPaymentColor(method.type)
                            : AppColors.textPrimary,
                        ),
                      ),
                      if (method.description != null && method.description!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          method.description!,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: Colors.grey[600],
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                
                // 选中状态指示器
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: isSelected 
                      ? LinearGradient(
                          colors: [
                            _getPaymentColor(method.type),
                            _getPaymentColor(method.type).withOpacity(0.8),
                          ],
                        )
                      : null,
                    color: isSelected ? null : Colors.transparent,
                    border: Border.all(
                      color: isSelected ? _getPaymentColor(method.type) : Colors.grey[400]!,
                      width: 2,
                    ),
                    boxShadow: isSelected ? [
                      BoxShadow(
                        color: _getPaymentColor(method.type).withOpacity(0.3),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ] : null,
                  ),
                  child: isSelected
                      ? const Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 14,
                        )
                      : null,
                ),
              ],
            ),
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