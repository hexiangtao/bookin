import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_dimensions.dart';

/// 空状态组件
class EmptyStateWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final String? actionText;
  final VoidCallback? onAction;
  final Color? iconColor;
  final double? iconSize;
  
  const EmptyStateWidget({
    Key? key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.actionText,
    this.onAction,
    this.iconColor,
    this.iconSize,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: AppDimensions.paddingXl,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: iconSize ?? AppDimensions.iconXxl * 2,
              color: iconColor ?? AppColors.grey400,
            ),
            SizedBox(height: AppDimensions.spacingL),
            Text(
              title,
              style: AppTextStyles.titleMedium.copyWith(
                color: AppColors.grey600,
              ),
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              SizedBox(height: AppDimensions.spacingS),
              Text(
                subtitle!,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.grey500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (actionText != null && onAction != null) ...[
              SizedBox(height: AppDimensions.spacingXl),
              ElevatedButton(
                onPressed: onAction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: AppDimensions.paddingHorizontalL.copyWith(
                    top: AppDimensions.spacingM,
                    bottom: AppDimensions.spacingM,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: AppDimensions.borderRadiusL,
                  ),
                ),
                child: Text(
                  actionText!,
                  style: AppTextStyles.buttonMedium,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// 网络错误状态组件
class NetworkErrorWidget extends StatelessWidget {
  final String? message;
  final VoidCallback? onRetry;
  
  const NetworkErrorWidget({
    Key? key,
    this.message,
    this.onRetry,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      icon: Icons.wifi_off_rounded,
      title: '网络连接失败',
      subtitle: message ?? '请检查网络连接后重试',
      actionText: '重试',
      onAction: onRetry,
      iconColor: AppColors.error,
    );
  }
}

/// 数据加载失败状态组件
class LoadErrorWidget extends StatelessWidget {
  final String? message;
  final VoidCallback? onRetry;
  
  const LoadErrorWidget({
    Key? key,
    this.message,
    this.onRetry,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      icon: Icons.error_outline_rounded,
      title: '加载失败',
      subtitle: message ?? '数据加载失败，请重试',
      actionText: '重试',
      onAction: onRetry,
      iconColor: AppColors.warning,
    );
  }
}

/// 无充值选项状态组件
class NoRechargeOptionsWidget extends StatelessWidget {
  final VoidCallback? onRefresh;
  
  const NoRechargeOptionsWidget({
    Key? key,
    this.onRefresh,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      icon: Icons.payment_rounded,
      title: '暂无充值选项',
      subtitle: '当前没有可用的充值选项\n请稍后再试或联系客服',
      actionText: '刷新',
      onAction: onRefresh,
      iconColor: AppColors.primary,
    );
  }
}

/// 钱包余额加载失败组件
class WalletLoadErrorWidget extends StatelessWidget {
  final String? message;
  final VoidCallback? onRetry;
  
  const WalletLoadErrorWidget({
    Key? key,
    this.message,
    this.onRetry,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: AppDimensions.marginL,
      padding: AppDimensions.paddingXl,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppDimensions.borderRadiusXl,
        boxShadow: AppDimensions.shadowS,
        border: Border.all(
          color: AppColors.error.withOpacity(0.2),
          width: AppDimensions.borderWidthNormal,
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.account_balance_wallet_outlined,
            size: AppDimensions.iconXl,
            color: AppColors.error,
          ),
          SizedBox(height: AppDimensions.spacingM),
          Text(
            '钱包信息加载失败',
            style: AppTextStyles.titleSmall.copyWith(
              color: AppColors.error,
            ),
          ),
          if (message != null) ...[
            SizedBox(height: AppDimensions.spacingS),
            Text(
              message!,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.grey600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
          if (onRetry != null) ...[
            SizedBox(height: AppDimensions.spacingL),
            TextButton(
              onPressed: onRetry,
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary,
                padding: AppDimensions.paddingHorizontalL,
              ),
              child: Text(
                '重新加载',
                style: AppTextStyles.buttonSmall,
              ),
            ),
          ],
        ],
      ),
    );
  }
}