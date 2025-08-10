import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_styles.dart';

/// 价格显示组件
/// 统一价格展示的样式和逻辑
class PriceDisplay extends StatelessWidget {
  const PriceDisplay({
    super.key,
    required this.price,
    this.originalPrice,
    this.size = PriceDisplaySize.medium,
    this.showCurrency = true,
    this.color,
  });

  final int price; // 价格（分为单位）
  final int? originalPrice; // 原价（分为单位）
  final PriceDisplaySize size;
  final bool showCurrency;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final priceValue = (price / 100).toStringAsFixed(2);
    final originalPriceValue = originalPrice != null
        ? (originalPrice! / 100).toStringAsFixed(2)
        : null;

    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        if (showCurrency)
          Text(
            '¥',
            style: _getCurrencyStyle(),
          ),
        Text(
          priceValue,
          style: _getPriceStyle(),
        ),
        if (originalPriceValue != null && originalPrice! > price) ...[
          const SizedBox(width: 12),
          Text(
            '¥$originalPriceValue',
            style: _getOriginalPriceStyle(),
          ),
        ],
      ],
    );
  }

  TextStyle _getCurrencyStyle() {
    final baseColor = color ?? AppColors.primary;
    
    switch (size) {
      case PriceDisplaySize.small:
        return TextStyle(
          fontSize: 12,
          color: baseColor,
          fontWeight: FontWeight.bold,
        );
      case PriceDisplaySize.medium:
        return AppStyles.priceSymbol.copyWith(color: baseColor);
      case PriceDisplaySize.large:
        return TextStyle(
          fontSize: 20,
          color: baseColor,
          fontWeight: FontWeight.bold,
        );
    }
  }

  TextStyle _getPriceStyle() {
    final baseColor = color ?? AppColors.primary;
    
    switch (size) {
      case PriceDisplaySize.small:
        return TextStyle(
          fontSize: 16,
          color: baseColor,
          fontWeight: FontWeight.bold,
        );
      case PriceDisplaySize.medium:
        return TextStyle(
          fontSize: 24,
          color: baseColor,
          fontWeight: FontWeight.bold,
        );
      case PriceDisplaySize.large:
        return AppStyles.priceLarge.copyWith(color: baseColor);
    }
  }

  TextStyle _getOriginalPriceStyle() {
    switch (size) {
      case PriceDisplaySize.small:
        return const TextStyle(
          fontSize: 12,
          color: AppColors.textHint,
          decoration: TextDecoration.lineThrough,
        );
      case PriceDisplaySize.medium:
        return const TextStyle(
          fontSize: 14,
          color: AppColors.textHint,
          decoration: TextDecoration.lineThrough,
        );
      case PriceDisplaySize.large:
        return AppStyles.priceOriginal;
    }
  }
}

/// 价格显示尺寸枚举
enum PriceDisplaySize {
  small,
  medium,
  large,
}

/// 价格标签组件
/// 用于显示折扣、优惠等标签
class PriceTag extends StatelessWidget {
  const PriceTag({
    super.key,
    required this.text,
    this.backgroundColor,
    this.textColor,
  });

  final String text;
  final Color? backgroundColor;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: (backgroundColor ?? AppColors.primary).withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          color: textColor ?? AppColors.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}