import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_dimensions.dart';
import '../controllers/wallet_controller.dart';

class WalletQuickEntry extends GetView<WalletController> {
  const WalletQuickEntry({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: AppDimensions.marginL,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 12),
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 16,
                  decoration: BoxDecoration(
                    color: AppColors.secondary,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                SizedBox(width: AppDimensions.spacingS),
                Text(
                  '快捷入口',
                  style: AppTextStyles.h4.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          
          // 快捷入口网格 - 2x2布局
          Row(
            children: [
              Expanded(
                child: _buildQuickEntryCard(
                  icon: Icons.add_circle,
                  title: '充值记录',
                  color: AppColors.secondary,
                  onTap: controller.toRechargeRecords,
                ),
              ),
              SizedBox(width: AppDimensions.spacingM),
              Expanded(
                child: _buildQuickEntryCard(
                  icon: Icons.receipt_long,
                  title: '消费明细',
                  color: AppColors.secondaryLight,
                  onTap: controller.toConsumeRecords,
                ),
              ),
            ],
          ),
          
          SizedBox(height: AppDimensions.spacingM),
          
          Row(
            children: [
              Expanded(
                child: _buildQuickEntryCard(
                  icon: Icons.refresh,
                  title: '退款记录',
                  color: AppColors.secondary.withOpacity(0.8),
                  onTap: controller.toRefundRecords,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildQuickEntryCard(
                  icon: Icons.local_offer,
                  title: '我的优惠券',
                  color: AppColors.secondaryDark,
                  onTap: controller.toCoupons,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickEntryCard({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: AppDimensions.borderRadiusL,
          boxShadow: AppDimensions.shadowXs,
        ),
        child: Column(
          children: [
            // 图标背景
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: color,
                size: 20,
              ),
            ),
            
            const SizedBox(height: 8),
            
            // 标题
            Text(
              title,
              style: AppTextStyles.bodySmall.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}