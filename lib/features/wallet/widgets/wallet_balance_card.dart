import 'package:flutter/material.dart';
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
import '../models/wallet_balance_model.dart';

class WalletBalanceCard extends GetView<WalletController> {
  const WalletBalanceCard({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return AnimatedWidgets.fadeInOut(
      visible: true,
      child: Container(
        width: double.infinity,
        margin: AppDimensions.marginL,
        decoration: BoxDecoration(
          borderRadius: AppDimensions.borderRadiusXl,
          boxShadow: AppDimensions.shadowL,
        ),
        child: Obx(() {
          // 使用单独的Obx来监听不同的状态，减少重建
          if (controller.isLoading) {
            return AnimatedWidgets.loadingPulse(
              child: const WalletBalanceCardSkeleton(),
            );
          }
          
          if (controller.hasError) {
            return AnimatedWidgets.slideIn(
              visible: true,
              child: WalletLoadErrorWidget(
                message: controller.errorMessage,
                onRetry: controller.fetchBalance,
              ),
            );
          }
          
          return Obx(() {
            final balance = controller.walletBalance;
            if (balance == null) {
              return AnimatedWidgets.slideIn(
                visible: true,
                child: WalletLoadErrorWidget(
                  message: '钱包数据为空',
                  onRetry: controller.fetchBalance,
                ),
              );
            }
            
            return AnimatedWidgets.scale(
              visible: true,
              child: _BalanceCardContent(
                balance: balance,
                controller: controller,
              ),
            );
          });
        }),
      ),
    );
  }
}

/// 余额卡片内容组件（分离以减少重建）
class _BalanceCardContent extends StatelessWidget {
  final WalletBalanceModel balance;
  final WalletController controller;
  
  const _BalanceCardContent({
    required this.balance,
    required this.controller,
  });
  
  @override
  Widget build(BuildContext context) {
    return _buildBalanceCard(balance);
  }
  

  
  /// 构建余额卡片
  Widget _buildBalanceCard(WalletBalanceModel balance) {
    return Semantics(
      label: '钱包余额卡片',
      value: '当前余额 ${balance.formattedBalance}',
      child: Container(
        padding: AppDimensions.paddingXl,
        decoration: BoxDecoration(
          gradient: _getCardGradient(balance.levelClass),
          borderRadius: AppDimensions.borderRadiusXl,
        ),
        child: Stack(
          children: [
            // 背景网格
            _buildBackgroundGrid(),
            
            // 卡片内容
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 余额标题和等级
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.account_balance_wallet,
                          color: Colors.white.withOpacity(0.8),
                          size: 20,
                          semanticLabel: '钱包图标',
                        ),
                        SizedBox(width: AppDimensions.spacingS),
                        Semantics(
                          header: true,
                          child: Text(
                            '钱包余额',
                            style: AppTextStyles.h4.copyWith(
                              color: Colors.white.withOpacity(0.9),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (balance.levelName.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          balance.levelName,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
                
                SizedBox(height: AppDimensions.spacingL),
                
                // 余额金额
                Semantics(
                  liveRegion: true,
                  child: Text(
                    balance.formattedBalance,
                    style: AppTextStyles.h1.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 36,
                      letterSpacing: 1,
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(0.3),
                          offset: const Offset(0, 2),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 12),
                
                // 操作按钮
                Row(
                   children: [
                     AccessibilityHelper.accessibleButton(
                       semanticLabel: '充值按钮',
                       hint: '点击进行钱包充值',
                       onPressed: controller.showRecharge,
                       child: AnimatedWidgets.bounceButton(
                         onPressed: controller.showRecharge,
                         child: _buildActionButton(
                           icon: Icons.add_circle_outline,
                           text: '充值',
                           onTap: () {},
                         ),
                       ),
                     ),
                     SizedBox(width: AppDimensions.spacingM),
                     AccessibilityHelper.accessibleButton(
                       semanticLabel: '明细按钮',
                       hint: '查看交易明细记录',
                       onPressed: controller.toConsumeRecords,
                       child: AnimatedWidgets.bounceButton(
                         onPressed: controller.toConsumeRecords,
                         child: _buildActionButton(
                           icon: Icons.history,
                           text: '明细',
                           onTap: () {},
                         ),
                       ),
                     ),
                   ],
                 ),
              ],
            ),
            
            // 钱包图标装饰
            Positioned(
              right: 0,
              top: 0,
              child: Opacity(
                opacity: 0.1,
                child: Icon(
                  Icons.account_balance_wallet,
                  size: 80,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  /// 获取卡片渐变色
  LinearGradient _getCardGradient(String levelClass) {
    switch (levelClass) {
      case 'gold':
        return LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary,
            AppColors.primaryDark,
          ],
          stops: const [0.0, 1.0],
        );
      case 'platinum':
        return LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary,
            AppColors.primaryDark,
          ],
          stops: const [0.0, 1.0],
        );
      case 'diamond':
        return LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary,
            AppColors.primaryDark,
          ],
          stops: const [0.0, 1.0],
        );
      default:
        return LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF2C2C2E),
            Color(0xFF1C1C1E),
          ],
        );
    }
  }
  
  /// 构建背景网格
  Widget _buildBackgroundGrid() {
    return Positioned.fill(
      child: CustomPaint(
        painter: GridPainter(),
      ),
    );
  }
  
  /// 构建操作按钮
  Widget _buildActionButton({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: AppDimensions.borderRadiusXl,
          border: Border.all(
            color: Colors.white.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: Colors.white,
            ),
            SizedBox(width: AppDimensions.spacingXs),
            Text(
              text,
              style: AppTextStyles.bodySmall.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 网格背景画笔
class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.08)
      ..strokeWidth = 1;
    
    const gridSize = 20.0;
    
    // 绘制垂直线
    for (double x = 0; x <= size.width; x += gridSize) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        paint,
      );
    }
    
    // 绘制水平线
    for (double y = 0; y <= size.height; y += gridSize) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}