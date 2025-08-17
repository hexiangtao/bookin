import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:get/get.dart';
import '../../../core/models/coupon_model.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class CouponDialog extends StatelessWidget {
  final List<CouponModel> coupons;
  final Function(int couponId) onReceive;
  final VoidCallback onClose;

  const CouponDialog({
    super.key,
    required this.coupons,
    required this.onReceive,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    if (coupons.isEmpty) {
      return const SizedBox.shrink();
    }

    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          // 蒙层背景
          GestureDetector(
            onTap: onClose,
            child: Container(
              width: double.infinity,
              height: double.infinity,
              color: Colors.black.withOpacity(0.5),
            ),
          ),
          // 弹窗内容
          Center(
            child: Container(
              width: Get.width * 0.9,
              constraints: BoxConstraints(
                maxHeight: Get.height * 0.8,
              ),
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    offset: const Offset(0, 8),
                    blurRadius: 32,
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 头部
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppColors.secondary, AppColors.secondaryLight],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(24),
                        topRight: Radius.circular(24),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.local_offer_rounded,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '新人专享优惠券',
                                style: AppTextStyles.h2.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '限时领取，先到先得',
                                style: AppTextStyles.label.copyWith(
                                  color: Colors.white.withOpacity(0.9),
                                ),
                              ),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: onClose,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.close_rounded,
                              size: 20,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // 优惠券列表
                  Flexible(
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                            child: ListView.builder(
                              shrinkWrap: true,
                              itemCount: coupons.length,
                              itemBuilder: (context, index) {
                                return _buildCouponCard(coupons[index]);
                              },
                            ),
                          ),
                          const SizedBox(height: 12),
                          // 底部按钮
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  height: 48,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: AppColors.border,
                                      width: 1.5,
                                    ),
                                    borderRadius: BorderRadius.circular(24),
                                  ),
                                  child: TextButton(
                                    onPressed: onClose,
                                    style: TextButton.styleFrom(
                                      foregroundColor: AppColors.textSecondary,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(24),
                                      ),
                                    ),
                                    child: Text(
                                      '稍后再说',
                                      style: AppTextStyles.buttonMedium.copyWith(
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                flex: 2,
                                child: Container(
                                  height: 48,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [AppColors.secondary, AppColors.secondaryLight],
                                      begin: Alignment.centerLeft,
                                      end: Alignment.centerRight,
                                    ),
                                    borderRadius: BorderRadius.circular(24),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.secondary.withOpacity(0.3),
                                        offset: const Offset(0, 4),
                                        blurRadius: 12,
                                      ),
                                    ],
                                  ),
                                  child: ElevatedButton(
                                    onPressed: () {
                                      // 一键领取所有优惠券
                                      for (final coupon in coupons) {
                                        if (coupon.canReceive) {
                                          onReceive(coupon.id);
                                        }
                                      }
                                      onClose();
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.transparent,
                                      foregroundColor: Colors.white,
                                      elevation: 0,
                                      shadowColor: Colors.transparent,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(24),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const Icon(
                                          Icons.card_giftcard_rounded,
                                          size: 18,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          '一键领取',
                                          style: AppTextStyles.buttonMedium.copyWith(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCouponCard(CouponModel coupon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.border.withOpacity(0.5),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            offset: const Offset(0, 2),
            blurRadius: 8,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // 优惠券金额
            Container(
              width: 65,
              height: 65,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.secondary, AppColors.secondaryLight],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.secondary.withOpacity(0.2),
                    offset: const Offset(0, 2),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '¥${(coupon.value / 100).toStringAsFixed(0)}',
                    style: AppTextStyles.h1.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '优惠券',
                    style: AppTextStyles.label.copyWith(
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // 优惠券信息
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    coupon.name,
                    style: AppTextStyles.h3.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    coupon.description,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '有效期至 ${coupon.endTime.toString().split(' ')[0]}',
                      style: AppTextStyles.label.copyWith(
                        color: AppColors.secondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // 领取按钮
            Container(
              width: 72,
              height: 32,
              decoration: BoxDecoration(
                gradient: coupon.canReceive
                    ? LinearGradient(
                        colors: [AppColors.secondary, AppColors.secondaryLight],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      )
                    : null,
                color: coupon.canReceive ? null : AppColors.border,
                borderRadius: BorderRadius.circular(24),
                boxShadow: coupon.canReceive
                    ? [
                        BoxShadow(
                          color: AppColors.secondary.withOpacity(0.3),
                          offset: const Offset(0, 2),
                          blurRadius: 8,
                        ),
                      ]
                    : null,
              ),
              child: TextButton(
                onPressed: coupon.canReceive ? () => onReceive(coupon.id) : null,
                style: TextButton.styleFrom(
                  foregroundColor: coupon.canReceive ? Colors.white : AppColors.textSecondary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  padding: EdgeInsets.zero,
                ),
                child: Text(
                  coupon.canReceive ? '领取' : '已领取',
                  style: AppTextStyles.label.copyWith(
                    color: coupon.canReceive ? Colors.white : AppColors.textSecondary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}