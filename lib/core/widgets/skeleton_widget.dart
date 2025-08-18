import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_dimensions.dart';

/// 骨架屏组件
class SkeletonWidget extends StatefulWidget {
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final EdgeInsets? margin;
  
  const SkeletonWidget({
    Key? key,
    this.width,
    this.height,
    this.borderRadius,
    this.margin,
  }) : super(key: key);
  
  @override
  State<SkeletonWidget> createState() => _SkeletonWidgetState();
}

class _SkeletonWidgetState extends State<SkeletonWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _animationController.repeat(reverse: true);
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          margin: widget.margin,
          decoration: BoxDecoration(
            color: AppColors.grey200.withOpacity(_animation.value),
            borderRadius: widget.borderRadius ?? AppDimensions.borderRadiusM,
          ),
        );
      },
    );
  }
}

/// 骨架屏文本组件
class SkeletonText extends StatelessWidget {
  final double? width;
  final double height;
  final EdgeInsets? margin;
  
  const SkeletonText({
    Key? key,
    this.width,
    this.height = 16.0,
    this.margin,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return SkeletonWidget(
      width: width,
      height: height,
      margin: margin,
      borderRadius: AppDimensions.borderRadiusS,
    );
  }
}

/// 骨架屏圆形组件（用于头像等）
class SkeletonCircle extends StatelessWidget {
  final double size;
  final EdgeInsets? margin;
  
  const SkeletonCircle({
    Key? key,
    required this.size,
    this.margin,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return SkeletonWidget(
      width: size,
      height: size,
      margin: margin,
      borderRadius: BorderRadius.circular(size / 2),
    );
  }
}

/// 钱包余额卡片骨架屏
class WalletBalanceCardSkeleton extends StatelessWidget {
  const WalletBalanceCardSkeleton({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: AppDimensions.marginL,
      padding: AppDimensions.paddingXl,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: AppDimensions.borderRadiusXl,
        boxShadow: AppDimensions.shadowS,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const SkeletonCircle(size: 20),
              SizedBox(width: AppDimensions.spacingS),
              const SkeletonText(width: 80, height: 16),
            ],
          ),
          SizedBox(height: AppDimensions.spacingL),
          const SkeletonText(width: 120, height: 32),
          SizedBox(height: AppDimensions.spacingXl),
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    borderRadius: AppDimensions.borderRadiusXl,
                  ),
                ),
              ),
              SizedBox(width: AppDimensions.spacingM),
              Expanded(
                child: Container(
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    borderRadius: AppDimensions.borderRadiusXl,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// 充值选项骨架屏
class RechargeOptionSkeleton extends StatelessWidget {
  const RechargeOptionSkeleton({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: AppDimensions.marginL,
      padding: AppDimensions.paddingL,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppDimensions.borderRadiusXl,
        boxShadow: AppDimensions.shadowS,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const SkeletonCircle(size: 20),
              SizedBox(width: AppDimensions.spacingS),
              const SkeletonText(width: 100, height: 16),
            ],
          ),
          SizedBox(height: AppDimensions.spacingL),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            childAspectRatio: 2.5,
            mainAxisSpacing: AppDimensions.spacingM,
            crossAxisSpacing: AppDimensions.spacingM,
            children: List.generate(4, (index) {
              return Container(
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: AppDimensions.borderRadiusL,
                  border: Border.all(
                    color: Colors.grey[200]!,
                    width: AppDimensions.borderWidthNormal,
                  ),
                ),
                child: Padding(
                  padding: AppDimensions.paddingL,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SkeletonText(width: 60, height: 18),
                      SizedBox(height: AppDimensions.spacingXs),
                      const SkeletonText(width: 40, height: 14),
                    ],
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}