import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_styles.dart';

/// 应用卡片组件
/// 统一卡片的样式和布局
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius,
    this.elevation,
    this.backgroundColor,
    this.onTap,
    this.showShadow = true,
  });

  final Widget child;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final BorderRadius? borderRadius;
  final double? elevation;
  final Color? backgroundColor;
  final VoidCallback? onTap;
  final bool showShadow;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin ?? const EdgeInsets.all(AppSizes.spacingS),
      child: Material(
        color: backgroundColor ?? AppColors.backgroundWhite,
        borderRadius: borderRadius ?? BorderRadius.circular(AppSizes.radiusM),
        elevation: elevation ?? (showShadow ? AppSizes.cardElevation : 0),
        shadowColor: AppColors.shadow,
        child: InkWell(
          onTap: onTap,
          borderRadius: borderRadius ?? BorderRadius.circular(AppSizes.radiusM),
          child: Container(
            padding: padding ?? const EdgeInsets.all(AppSizes.spacingM),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// 项目卡片组件
/// 专门用于显示项目信息的卡片
class ProjectCard extends StatelessWidget {
  const ProjectCard({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.price,
    this.originalPrice,
    this.tags = const [],
    this.rating,
    this.reviewCount,
    this.onTap,
  });

  final String imageUrl;
  final String title;
  final int price;
  final int? originalPrice;
  final List<String> tags;
  final double? rating;
  final int? reviewCount;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 项目图片
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(AppSizes.radiusM),
              topRight: Radius.circular(AppSizes.radiusM),
            ),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: AppColors.backgroundGrey,
                    child: const Icon(
                      Icons.image_not_supported,
                      color: AppColors.textHint,
                    ),
                  );
                },
              ),
            ),
          ),
          
          // 项目信息
          Padding(
            padding: const EdgeInsets.all(AppSizes.spacingM),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 标题
                Text(
                  title,
                  style: AppStyles.titleSmall,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                
                const SizedBox(height: AppSizes.spacingS),
                
                // 价格
                Row(
                  children: [
                    Text(
                      '¥${(price / 100).toStringAsFixed(2)}',
                      style: AppStyles.priceLarge.copyWith(fontSize: 20),
                    ),
                    if (originalPrice != null && originalPrice! > price) ...[
                      const SizedBox(width: AppSizes.spacingS),
                      Text(
                        '¥${(originalPrice! / 100).toStringAsFixed(2)}',
                        style: AppStyles.priceOriginal.copyWith(fontSize: 12),
                      ),
                    ],
                  ],
                ),
                
                if (rating != null || tags.isNotEmpty)
                  const SizedBox(height: AppSizes.spacingS),
                
                // 评分和标签
                Row(
                  children: [
                    if (rating != null) ...[
                      Icon(
                        Icons.star,
                        size: AppSizes.iconXS,
                        color: AppColors.warning,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        rating!.toStringAsFixed(1),
                        style: AppStyles.caption,
                      ),
                      if (reviewCount != null) ...[
                        const SizedBox(width: 2),
                        Text(
                          '($reviewCount)',
                          style: AppStyles.caption,
                        ),
                      ],
                      const SizedBox(width: AppSizes.spacingS),
                    ],
                    Expanded(
                      child: Wrap(
                        spacing: 4,
                        children: tags.take(2).map((tag) => Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            tag,
                            style: AppStyles.caption.copyWith(
                              color: AppColors.primary,
                              fontSize: 10,
                            ),
                          ),
                        )).toList(),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 技师卡片组件
/// 专门用于显示技师信息的卡片
class TechnicianCard extends StatelessWidget {
  const TechnicianCard({
    super.key,
    required this.avatarUrl,
    required this.name,
    required this.experience,
    this.rating,
    this.serviceCount,
    this.distance,
    this.tags = const [],
    this.onTap,
    this.onBookTap,
  });

  final String avatarUrl;
  final String name;
  final String experience;
  final double? rating;
  final int? serviceCount;
  final String? distance;
  final List<String> tags;
  final VoidCallback? onTap;
  final VoidCallback? onBookTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      child: Row(
        children: [
          // 头像
          ClipRRect(
            borderRadius: BorderRadius.circular(AppSizes.radiusS),
            child: Image.network(
              avatarUrl,
              width: 60,
              height: 60,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 60,
                  height: 60,
                  color: AppColors.backgroundGrey,
                  child: const Icon(
                    Icons.person,
                    color: AppColors.textHint,
                  ),
                );
              },
            ),
          ),
          
          const SizedBox(width: AppSizes.spacingM),
          
          // 技师信息
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 姓名和经验
                Row(
                  children: [
                    Text(
                      name,
                      style: AppStyles.titleSmall,
                    ),
                    const SizedBox(width: AppSizes.spacingS),
                    Text(
                      experience,
                      style: AppStyles.caption,
                    ),
                  ],
                ),
                
                const SizedBox(height: AppSizes.spacingXS),
                
                // 统计信息
                Row(
                  children: [
                    if (rating != null) ...[
                      Icon(
                        Icons.star,
                        size: AppSizes.iconXS,
                        color: AppColors.warning,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        rating!.toStringAsFixed(1),
                        style: AppStyles.caption,
                      ),
                      const SizedBox(width: AppSizes.spacingS),
                    ],
                    if (serviceCount != null) ...[
                      Icon(
                        Icons.chat_bubble_outline,
                        size: AppSizes.iconXS,
                        color: AppColors.textHint,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        '$serviceCount',
                        style: AppStyles.caption,
                      ),
                      const SizedBox(width: AppSizes.spacingS),
                    ],
                    if (distance != null) ...[
                      Icon(
                        Icons.location_on,
                        size: AppSizes.iconXS,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        distance!,
                        style: AppStyles.caption,
                      ),
                    ],
                  ],
                ),
                
                if (tags.isNotEmpty) ...[
                  const SizedBox(height: AppSizes.spacingS),
                  Wrap(
                    spacing: 4,
                    children: tags.take(3).map((tag) => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        tag,
                        style: AppStyles.caption.copyWith(
                          color: AppColors.primary,
                          fontSize: 10,
                        ),
                      ),
                    )).toList(),
                  ),
                ],
              ],
            ),
          ),
          
          // 预约按钮
          if (onBookTap != null)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.spacingM,
                vertical: AppSizes.spacingS,
              ),
              decoration: BoxDecoration(
                gradient: AppGradients.primary,
                borderRadius: BorderRadius.circular(AppSizes.radiusL),
              ),
              child: GestureDetector(
                onTap: onBookTap,
                child: Text(
                  '立即预约',
                  style: AppStyles.buttonTextSmall,
                ),
              ),
            ),
        ],
      ),
    );
  }
}