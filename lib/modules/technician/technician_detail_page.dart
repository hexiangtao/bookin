import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../../core/models/technician_model.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/custom_button.dart';
import 'technician_detail_controller.dart';

class TechnicianDetailPage extends GetView<TechnicianDetailController> {
  const TechnicianDetailPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        
        if (controller.technician.value == null) {
          return const Center(child: Text('技师信息加载失败'));
        }
        
        return Column(
          children: [
            // 内容区域
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildTechnicianPhotos(),
                    _buildTechnicianHeader(),
                    _buildGuaranteeSection(),
                    _buildTabSection(),
                    const SizedBox(height: 100), // 底部间距
                  ],
                ),
              ),
            ),
          ],
        );
      }),
      
      // 底部预订按钮
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  // 技师照片轮播
  Widget _buildTechnicianPhotos() {
    return Obx(() {
      final technician = controller.technician.value!;
      final photos = technician.photos ?? [technician.avatar];
      
      return Container(
        height: 300,
        child: CarouselSlider(
          options: CarouselOptions(
            height: 300,
            viewportFraction: 1.0,
            autoPlay: photos.length > 1,
            autoPlayInterval: const Duration(seconds: 3),
            enableInfiniteScroll: photos.length > 1,
          ),
          items: photos.map((photo) {
            return Builder(
              builder: (BuildContext context) {
                return GestureDetector(
                  onTap: () => controller.previewImage(photo, photos),
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: NetworkImage(photo),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                );
              },
            );
          }).toList(),
        ),
      );
    });
  }

  // 技师头部信息
  Widget _buildTechnicianHeader() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Obx(() {
        final technician = controller.technician.value!;
        return Column(
          children: [
            Row(
              children: [
                // 头像
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(technician.avatarShape == 0 ? 30 : 8),
                    image: DecorationImage(
                      image: NetworkImage(technician.avatar),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                
                // 基本信息
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            technician.name,
                            style: AppTextStyles.h3.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (technician.isVerified) ...[
                            const SizedBox(width: 8),
                            Container(
                              width: 16,
                              height: 16,
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 12,
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      
                      // 评分
                      Row(
                        children: [
                          ...List.generate(5, (index) => Icon(
                            Icons.star,
                            size: 14,
                            color: index < (technician.rating?.floor() ?? 0)
                                ? AppColors.warning
                                : AppColors.textDisabled,
                          )),
                          const SizedBox(width: 4),
                          Text(
                            technician.rating?.toStringAsFixed(1) ?? '0.0',
                            style: AppTextStyles.bodySmall,
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      
                      // 统计信息
                      Text(
                        '${technician.orderCount}单 | 好评率${(technician.goodRate ?? 0).toStringAsFixed(1)}%',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      
                      // 店铺和距离信息
                      if (technician.merchantName != null || technician.distance != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Row(
                            children: [
                              if (technician.merchantName != null) ...[
                                Icon(Icons.home, size: 14, color: AppColors.textTertiary),
                                const SizedBox(width: 2),
                                Text(
                                  technician.merchantName!,
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                              if (technician.distance != null) ...[
                                if (technician.merchantName != null) const SizedBox(width: 12),
                                Icon(Icons.location_on, size: 14, color: AppColors.textTertiary),
                                const SizedBox(width: 2),
                                Text(
                                  '${technician.distance!.toStringAsFixed(1)}km',
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
                
                // 收藏按钮
                GestureDetector(
                  onTap: controller.toggleFavorite,
                  child: Icon(
                    controller.isFavorite.value ? Icons.favorite : Icons.favorite_border,
                    color: controller.isFavorite.value ? AppColors.error : AppColors.textSecondary,
                    size: 24,
                  ),
                ),
              ],
            ),
            
            // 技师介绍
            if (technician.description != null) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                child: Text(
                  technician.description!,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ],
        );
      }),
    );
  }

  // 保障标签栏
  Widget _buildGuaranteeSection() {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '保障',
              style: AppTextStyles.bodySmall.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 12),
          _buildGuaranteeTag(Icons.person, '实名认证'),
          const SizedBox(width: 12),
          _buildGuaranteeTag(Icons.verified, '平台保障'),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: controller.viewCertificates,
            child: _buildGuaranteeTag(Icons.description, '资质证书'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildGuaranteeTag(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppColors.primary),
        const SizedBox(width: 4),
        Text(
          text,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  // Tab切换区域
  Widget _buildTabSection() {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      color: Colors.white,
      child: Column(
        children: [
          // Tab头部
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => controller.switchTab('services'),
                    child: Obx(() => Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: controller.activeTab.value == 'services'
                                ? AppColors.primary
                                : Colors.transparent,
                            width: 2,
                          ),
                        ),
                      ),
                      child: Text(
                        '服务项目',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.bodyLarge.copyWith(
                          color: controller.activeTab.value == 'services'
                              ? AppColors.primary
                              : AppColors.textSecondary,
                          fontWeight: controller.activeTab.value == 'services'
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    )),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () => controller.switchTab('comments'),
                    child: Obx(() => Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: controller.activeTab.value == 'comments'
                                ? AppColors.primary
                                : Colors.transparent,
                            width: 2,
                          ),
                        ),
                      ),
                      child: Text(
                        '用户评价',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.bodyLarge.copyWith(
                          color: controller.activeTab.value == 'comments'
                              ? AppColors.primary
                              : AppColors.textSecondary,
                          fontWeight: controller.activeTab.value == 'comments'
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    )),
                  ),
                ),
              ],
            ),
          ),
          
          // Tab内容
          Obx(() {
            if (controller.activeTab.value == 'services') {
              return _buildServiceProjects();
            } else {
              return _buildComments();
            }
          }),
        ],
      ),
    );
  }

  // 服务项目内容
  Widget _buildServiceProjects() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Obx(() {
        if (controller.projects.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Text('暂无服务项目'),
            ),
          );
        }
        
        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: controller.projects.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final project = controller.projects[index];
            final count = controller.projectCounts[project.id] ?? 0;
            
            return Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.border),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  // 项目图片
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: Image.network(
                      project.cover,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        width: 60,
                        height: 60,
                        color: AppColors.surfaceVariant,
                        child: const Icon(Icons.image_not_supported),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  
                  // 项目信息
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          project.name,
                          style: AppTextStyles.bodyLarge.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '时长：${project.duration}分钟',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Text(
                              '¥${project.priceYuan}',
                              style: AppTextStyles.bodyLarge.copyWith(
                                color: AppColors.error,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (project.originalPriceYuan != null) ...[
                              const SizedBox(width: 8),
                              Text(
                                '¥${project.originalPriceYuan!}',
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.textTertiary,
                                  decoration: TextDecoration.lineThrough,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  // 数量选择器
                  Row(
                    children: [
                      GestureDetector(
                        onTap: count > 0 ? () => controller.decreaseCount(project) : null,
                        child: Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: count > 0 ? AppColors.primary : AppColors.textDisabled,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(
                            Icons.remove,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                      Container(
                        width: 40,
                        child: Text(
                          count.toString(),
                          textAlign: TextAlign.center,
                          style: AppTextStyles.bodyLarge.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => controller.increaseCount(project),
                        child: Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(
                            Icons.add,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      }),
    );
  }

  // 用户评价内容
  Widget _buildComments() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Obx(() {
        if (controller.commentsLoading.value && controller.comments.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: CircularProgressIndicator(),
            ),
          );
        }
        
        if (controller.comments.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Text('暂无评价'),
            ),
          );
        }
        
        return Column(
          children: [
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: controller.comments.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final comment = controller.comments[index];
                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 16,
                            backgroundImage: NetworkImage(comment['avatar'] ?? ''),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            comment['userName'] ?? '匿名用户',
                            style: AppTextStyles.bodyMedium.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const Spacer(),
                          Row(
                            children: List.generate(5, (i) => Icon(
                              Icons.star,
                              size: 14,
                              color: i < (comment['rating'] ?? 0) 
                                  ? AppColors.warning 
                                  : AppColors.textDisabled,
                            )),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        comment['content'] ?? '',
                        style: AppTextStyles.bodyMedium,
                      ),
                      if (comment['serviceType'] != null) ...[
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            comment['serviceType'],
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 4),
                      Text(
                        comment['time'] ?? '',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            
            // 加载更多按钮
            if (controller.hasMoreComments.value && !controller.commentsLoading.value)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: GestureDetector(
                  onTap: controller.loadMoreComments,
                  child: Text(
                    '加载更多',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
            
            // 加载中状态
            if (controller.commentsLoading.value)
              const Padding(
                padding: EdgeInsets.only(top: 16),
                child: CircularProgressIndicator(),
              ),
          ],
        );
      }),
    );
  }

  // 底部预订栏
  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Obx(() {
          final hasSelectedItems = controller.totalCount.value > 0;
          
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 订单摘要（仅在有选中项目时显示）
              if (hasSelectedItems)
                Container(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '已选${controller.totalCount.value}项',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        '¥${controller.totalPrice.value.toStringAsFixed(2)}',
                        style: AppTextStyles.h4.copyWith(
                          color: AppColors.error,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              
              // 按钮区域
              CustomButton(
                text: hasSelectedItems ? '立即预约' : '选择服务项目',
                onPressed: hasSelectedItems ? controller.bookNow : null,
                isLoading: controller.isBooking.value,
                backgroundColor: hasSelectedItems ? AppColors.primary : AppColors.textDisabled,
              ),
            ],
          );
        }),
      ),
    );
  }
}