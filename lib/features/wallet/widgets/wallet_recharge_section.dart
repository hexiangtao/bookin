import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/semantics.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/skeleton_widget.dart';
import '../../../core/widgets/empty_state_widget.dart';
import '../../../core/widgets/accessibility_helper.dart';
import '../../../core/widgets/animated_widgets.dart';
import '../controllers/wallet_controller.dart';
import '../models/recharge_option_model.dart';

class _RechargeOptionsGrid extends StatelessWidget {
  final List<RechargeOptionModel> options;
  final double? selectedAmount;
  final double? customAmount;
  final Function(double) onOptionSelected;
  final Function(String) onCustomAmountChanged;

  const _RechargeOptionsGrid({
    required this.options,
    required this.selectedAmount,
    required this.customAmount,
    required this.onOptionSelected,
    required this.onCustomAmountChanged,
  });

  WalletController get controller => Get.find<WalletController>();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 预设金额选项网格
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 2.5,
            crossAxisSpacing: AppDimensions.spacingM,
            mainAxisSpacing: AppDimensions.spacingM,
          ),
          itemCount: options.length,
          itemBuilder: (context, index) {
            final option = options[index];
            final isSelected = selectedAmount == option.valueInYuan;
            
            return AnimatedWidgets.listItemAnimation(
              index: index,
              child: _buildRechargeOptionItem(option, isSelected),
            );
          },
        ),
        
        SizedBox(height: AppDimensions.spacingL),
        
        // 自定义金额输入
        AnimatedWidgets.slideIn(
          visible: true,
          child: _buildCustomAmountInput(),
        ),
      ],
    );
  }

  Widget _buildRechargeOptionItem(RechargeOptionModel option, bool isSelected) {
    return AnimatedWidgets.bounceButton(
      onPressed: () => onOptionSelected(option.valueInYuan),
      child: Container(
        padding: AppDimensions.paddingM,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white,
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: 2,
          ),
          borderRadius: AppDimensions.borderRadiusM,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '¥${option.valueInYuan.toStringAsFixed(0)}',
              style: AppTextStyles.h3.copyWith(
                color: isSelected ? Colors.white : AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (option.gift > 0) ...[
              SizedBox(height: AppDimensions.spacingXs),
              Text(
                '送¥${option.giftInYuan.toStringAsFixed(0)}',
                style: AppTextStyles.bodySmall.copyWith(
                  color: isSelected ? Colors.white70 : AppColors.textSecondary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCustomAmountInput() {
    return Container(
      padding: AppDimensions.paddingM,
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: AppDimensions.borderRadiusM,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '自定义金额',
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: AppDimensions.spacingS),
          TextField(
            keyboardType: TextInputType.number,
            onChanged: onCustomAmountChanged,
            decoration: InputDecoration(
              hintText: '请输入充值金额',
              prefixText: '¥',
              border: OutlineInputBorder(
                borderRadius: AppDimensions.borderRadiusS,
              ),
              contentPadding: AppDimensions.paddingM,
            ),
          ),
        ],
      ),
    );
  }
}

class RechargeOptionsSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 2.5,
        crossAxisSpacing: AppDimensions.spacingM,
        mainAxisSpacing: AppDimensions.spacingM,
      ),
      itemCount: 4,
      itemBuilder: (context, index) {
        return SkeletonWidget(
          height: 60,
          borderRadius: AppDimensions.borderRadiusM,
        );
      },
    );
  }
}

class RechargeOptionsErrorWidget extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const RechargeOptionsErrorWidget({
    Key? key,
    required this.message,
    required this.onRetry,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      icon: Icons.error_outline,
      title: '加载失败',
      subtitle: message,
      actionText: '重试',
      onAction: onRetry,
    );
  }
}

class WalletRechargeSection extends StatelessWidget {
  const WalletRechargeSection({Key? key}) : super(key: key);

  WalletController get controller => Get.find<WalletController>();

  @override
  Widget build(BuildContext context) {
    return AnimatedWidgets.slideIn(
      visible: true,
      child: Container(
        margin: AppDimensions.marginL,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '选择充值金额',
              style: AppTextStyles.h3.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: AppDimensions.spacingL),
            GetBuilder<WalletController>(
              id: 'recharge_section',
              builder: (controller) {
                if (controller.isLoadingOptions) {
                  return AnimatedWidgets.loadingPulse(
                    child: RechargeOptionsSkeleton(),
                  );
                }
                
                if (controller.hasRechargeError) {
                  return AnimatedWidgets.slideIn(
                    visible: true,
                    child: RechargeOptionsErrorWidget(
                      message: controller.rechargeErrorMessage,
                      onRetry: controller.fetchRechargeOptions,
                    ),
                  );
                }
                
                if (controller.rechargeOptions.isEmpty) {
                  return Container(
                    padding: const EdgeInsets.all(20),
                    child: Text(
                      '暂无充值选项',
                      style: TextStyle(color: Colors.grey[600]),
                      textAlign: TextAlign.center,
                    ),
                  );
                }
                
                return AnimatedWidgets.fadeInOut(
                  visible: true,
                  child: _RechargeOptionsGrid(
                    options: controller.rechargeOptions,
                    selectedAmount: controller.selectedAmount,
                    customAmount: controller.customAmount,
                    onOptionSelected: (amount) {
                      // 根据金额找到对应的充值选项
                      final option = controller.rechargeOptions.firstWhere(
                        (opt) => opt.valueInYuan == amount,
                        orElse: () => RechargeOptionModel(value: (amount * 100).round(), gift: 0),
                      );
                      controller.selectRechargeOption(option);
                    },
                    onCustomAmountChanged: controller.setCustomAmountFromInput,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
  
  /// 构建充值选项网格
  Widget _buildRechargeOptions(List options) {
    return Column(
      children: [
        // 第一行：前两个选项
        Row(
          children: [
            if (options.isNotEmpty)
              Expanded(
                child: _buildRechargeOptionItem(options[0], controller.selectedRechargeOption == options[0]),
              ),
            if (options.length > 1) ...[
              SizedBox(width: AppDimensions.spacingM),
              Expanded(
                child: _buildRechargeOptionItem(options[1], controller.selectedRechargeOption == options[1]),
              ),
            ],
          ],
        ),
        
        if (options.length > 2) ...[
          SizedBox(height: AppDimensions.spacingM),
          // 第二行：后两个选项
          Row(
            children: [
              if (options.length > 2)
                Expanded(
                  child: _buildRechargeOptionItem(options[2], controller.selectedRechargeOption == options[2]),
                ),
              if (options.length > 3) ...[
                const SizedBox(width: 12),
                Expanded(
                  child: _buildRechargeOptionItem(options[3], controller.selectedRechargeOption == options[3]),
                ),
              ],
            ],
          ),
        ],
      ],
    );
  }
  
  Widget _buildRechargeOptionItem(RechargeOptionModel option, bool isSelected) {
    return AnimatedWidgets.bounceButton(
      onPressed: () => controller.selectRechargeOption(option),
      child: Semantics(
        button: true,
        selected: isSelected,
        label: '充值金额 ${option.valueInYuan.toStringAsFixed(0)} 元',
        hint: isSelected ? '已选中' : '点击选择此充值金额',
        child: Container(
          padding: AppDimensions.paddingM,
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.white,
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.border,
              width: 2,
            ),
            borderRadius: AppDimensions.borderRadiusM,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '¥${option.valueInYuan.toStringAsFixed(0)}',
                style: AppTextStyles.h3.copyWith(
                  color: isSelected ? Colors.white : AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (option.gift > 0) ...[
                SizedBox(height: AppDimensions.spacingXs),
                Text(
                  '送¥${option.giftInYuan.toStringAsFixed(0)}',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: isSelected ? Colors.white70 : AppColors.textSecondary,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
  
  /// 构建自定义金额输入
  Widget _buildCustomAmountInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '自定义金额',
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        
        const SizedBox(height: 8),
        
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.grey[200]!,
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: controller.customAmountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
            ],
            decoration: InputDecoration(
              hintText: '其他金额，请输入',
              hintStyle: AppTextStyles.bodyMedium.copyWith(
                color: Colors.grey[400],
              ),
              prefixIcon: Container(
                margin: const EdgeInsets.only(left: 16, right: 8),
                child: Text(
                  '¥',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                alignment: Alignment.centerLeft,
                width: 20,
              ),
              prefixIconConstraints: const BoxConstraints(
                minWidth: 44,
                minHeight: 0,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
            style: AppTextStyles.bodyMedium.copyWith(
              fontSize: 16,
            ),
            onChanged: controller.onCustomMoneyInput,
          ),
        ),
        
        const SizedBox(height: 8),
        
        // 金额限制提示
        Obx(() {
          final errorText = controller.customAmountError;
          if (errorText == null || errorText.isEmpty) {
            return Text(
              '单次充值金额：¥1 - ¥50000',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            );
          }
          
          return Text(
            errorText,
            style: TextStyle(
              fontSize: 12,
              color: Colors.red,
            ),
          );
        }),
      ],
    );
  }
  
  /// 构建空状态
  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          Icon(
            Icons.error_outline,
            size: 48,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            '暂无充值选项',
            style: AppTextStyles.bodyMedium.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: controller.fetchRechargeOptions,
            child: Text(
              '重新加载',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}