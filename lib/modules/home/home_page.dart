import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/theme/app_colors.dart';
import 'home_controller.dart';
import '../../core/shell/tab_shell_controller.dart';
import 'widgets/announcement_banner.dart';
import 'widgets/announcement_dialog.dart';
import 'widgets/coupon_dialog.dart';

class HomePage extends GetView<HomeController> {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          Column(
            children: [
              _buildFixedHeader(),
              Expanded(
                child: Obx(() {
                  if (controller.showError) {
                    return _buildErrorState();
                  }
                  
                  return RefreshIndicator(
                    onRefresh: controller.refreshData,
                    child: CustomScrollView(
                      physics: const ClampingScrollPhysics(),
                      slivers: [
                        SliverToBoxAdapter(child: _buildBannerSection()),
                        // 公告横幅
                        SliverToBoxAdapter(
                          child: Obx(() {
                            if (controller.bannerAnnouncements.isEmpty) {
                              return const SizedBox.shrink();
                            }
                            return Container(
                              margin: const EdgeInsets.fromLTRB(15, 0, 15, 10),
                              child: AnnouncementBanner(
                                announcements: controller.bannerAnnouncements,
                              ),
                            );
                          }),
                        ),
                        SliverToBoxAdapter(child: _buildServiceFeatures()),
                        SliverToBoxAdapter(child: _buildFeaturedTechnicians()),
                        SliverToBoxAdapter(child: _buildProjectList()),
                        const SliverToBoxAdapter(
                          child: SizedBox(height: 80), // 底部间距，避免被TabBar遮挡
                        ),
                      ],
                    ),
                  );
                }),
              ),
            ],
          ),
          // 公告弹窗
          Obx(() {
            if (!controller.showAnnouncementDialog.value || controller.popupAnnouncements.isEmpty) {
              return const SizedBox.shrink();
            }
            return AnnouncementDialog(
              announcement: controller.popupAnnouncements.first,
              onClose: controller.closeAnnouncementDialog,
            );
          }),
          // 优惠券弹窗
          Obx(() {
            if (!controller.showCouponDialog.value || controller.availableCoupons.isEmpty) {
              return const SizedBox.shrink();
            }
            return CouponDialog(
              coupons: controller.availableCoupons,
              onReceive: controller.receiveCoupon,
              onClose: controller.closeCouponDialog,
            );
          }),
        ],
      ),
    );
  }

  /// 构建错误状态
  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              '加载失败',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Obx(() => Text(
              controller.errorMessage.value,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            )),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: controller.retryLoad,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6C5CE7),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('重试'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFixedHeader() {
    return Container(
      height: 90,
      decoration: BoxDecoration(
        color: AppColors.surface.withOpacity(0.9),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, 2),
            blurRadius: 10,
          ),
        ],
      ),
      child: SafeArea(
        child: const Center(
          child: Text(
            '摩联到家',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF333333),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBannerSection() {
    return Container(
      height: 170,
      margin: const EdgeInsets.fromLTRB(15, 10, 15, 0),
      child: Obx(() {
        // 显示加载状态
        if (controller.bannersLoading.value) {
          return Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.grey[200],
            ),
            child: const Center(child: CircularProgressIndicator()),
          );
        }
        
        // 显示错误状态
        if (controller.bannersError.value) {
          return Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.grey[100],
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, color: Colors.grey[400], size: 32),
                  const SizedBox(height: 8),
                  Text('横幅加载失败', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                  const SizedBox(height: 8),
                  TextButton(
                     onPressed: () => controller.loadBanners(),
                     child: const Text('重试', style: TextStyle(fontSize: 12)),
                   ),
                ],
              ),
            ),
          );
        }
        
        // 显示空状态或数据
        if (controller.banners.isEmpty) {
          return Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.grey[100],
            ),
            child: Center(
              child: Text('暂无横幅', style: TextStyle(color: Colors.grey[500], fontSize: 14)),
            ),
          );
        }
        return Stack(
          children: [
            PageView.builder(
              controller: controller.pageController,
              onPageChanged: controller.updateBannerIndex,
              itemCount: controller.banners.length,
              itemBuilder: (context, index) {
                final banner = controller.banners[index];
                return ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    banner.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[200],
                        alignment: Alignment.center,
                        child: const Icon(Icons.image_not_supported, color: Colors.grey),
                      );
                    },
                  ),
                );
              },
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 8,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(controller.banners.length, (i) {
                  final bool active = controller.bannerIndex.value == i;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: active ? 14 : 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: active ? const Color(0xFFFF5777) : Colors.white.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  );
                }),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildServiceFeatures() {
    return Container(
      margin: const EdgeInsets.fromLTRB(15, 10, 15, 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            offset: const Offset(0, 2),
            blurRadius: 12,
          ),
        ],
      ),
      child: Row(
        children: [
          _buildFeatureItem(Icons.verified, '正规资质'),
          _buildFeatureDivider(),
          _buildFeatureItem(Icons.flash_on, '快速响应'),
          _buildFeatureDivider(),
          _buildFeatureItem(Icons.attach_money, '价格透明'),
          _buildFeatureDivider(),
          _buildFeatureItem(Icons.security, '服务保障'),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String text) {
    return Expanded(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 16, color: const Color(0xFF666666)),
          const SizedBox(width: 4),
          Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF333333),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureDivider() {
    return Container(
      width: 1,
      height: 16,
      color: const Color(0xFFE5E5E5),
    );
  }

  Widget _buildFeaturedTechnicians() {
    return Container(
      margin: const EdgeInsets.fromLTRB(15, 0, 15, 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            offset: const Offset(0, 2),
            blurRadius: 12,
          ),
        ],
      ),
      child: Column(
        children: [
          _buildSectionHeader(Icons.group, '精选技师', '查看全部', () {
            controller.goToTechnicianList();
          }),
          Obx(() {
            // 显示加载状态
            if (controller.techniciansLoading.value) {
              return const Padding(
                padding: EdgeInsets.all(24),
                child: Center(child: CircularProgressIndicator()),
              );
            }
            
            // 显示错误状态
            if (controller.techniciansError.value) {
              return Padding(
                padding: const EdgeInsets.all(24),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.error_outline, color: Colors.grey[400], size: 32),
                      const SizedBox(height: 8),
                      Text('技师加载失败', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: () => controller.loadFeaturedTechnicians(),
                        child: const Text('重试', style: TextStyle(fontSize: 12)),
                      ),
                    ],
                  ),
                ),
              );
            }
            
            // 显示空状态
            if (controller.featuredTechnicians.isEmpty) {
              return Padding(
                padding: const EdgeInsets.all(24),
                child: Center(
                  child: Text('暂无推荐技师', style: TextStyle(color: Colors.grey[500], fontSize: 14)),
                ),
              );
            }
            // 限制显示3个技师，使用Row布局平均分配宽度
            final displayTechnicians = controller.featuredTechnicians.take(3).toList();
            return Container(
              height: 140,
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: Row(
                children: displayTechnicians.asMap().entries.map((entry) {
                  final index = entry.key;
                  final tech = entry.value;
                  return Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(
                        left: index == 0 ? 0 : 4,
                        right: index == displayTechnicians.length - 1 ? 0 : 4,
                      ),
                      child: _buildTechnicianCard(tech),
                    ),
                  );
                }).toList(),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(IconData icon, String title, String moreText, VoidCallback onMore) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: const Color(0xFF333333)),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF333333),
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: onMore,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: const Color(0xFFFF5777).withOpacity(0.05),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '查看全部',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFFFF5777),
                    ),
                  ),
                  SizedBox(width: 2),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 10,
                    color: Color(0xFFFF5777),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTechnicianCard(dynamic tech) {
    return GestureDetector(
      onTap: () => controller.goToTechnicianDetail(tech),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
          children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        offset: const Offset(0, 4),
                        blurRadius: 12,
                      ),
                    ],
                  ),
                  child: Image.network(
                    tech.avatar,
                    width: double.infinity,
                    height: 94,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: double.infinity,
                        height: 94,
                        color: Colors.grey[200],
                        alignment: Alignment.center,
                        child: const Icon(Icons.person, color: Colors.grey),
                      );
                    },
                  ),
                ),
              ),
              if (tech.isHot)
                Positioned(
                  top: 0,
                  left: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFFFF4757), Color(0xFFFF3742)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.only(
                        bottomRight: Radius.circular(12),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Color(0x66FF4757),
                          offset: Offset(0, 2),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.whatshot, size: 8, color: Colors.white),
                        SizedBox(width: 2),
                        Text(
                          'HOT',
                          style: TextStyle(
                            fontSize: 9,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 2),
          SizedBox(
            height: 14,
            child: Text(
              tech.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF333333),
              ),
            ),
          ),
          const SizedBox(height: 1),
          SizedBox(
            height: 11,
            child: Text(
              '已服务${tech.orderCount}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 9,
                color: Color(0xFF999999),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProjectList() {
    return Obx(() {
      // 显示加载状态
      if (controller.projectsLoading.value) {
        return Container(
          margin: const EdgeInsets.fromLTRB(15, 0, 15, 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                offset: const Offset(0, 2),
                blurRadius: 12,
              ),
            ],
          ),
          child: const Padding(
            padding: EdgeInsets.all(24),
            child: Center(child: CircularProgressIndicator()),
          ),
        );
      }
      
      // 显示错误状态
      if (controller.projectsError.value) {
        return Container(
          margin: const EdgeInsets.fromLTRB(15, 0, 15, 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                offset: const Offset(0, 2),
                blurRadius: 12,
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Center(
              child: Column(
                children: [
                  Icon(Icons.error_outline, color: Colors.grey[400], size: 32),
                  const SizedBox(height: 8),
                  Text('项目加载失败', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () => controller.loadHotProjects(),
                    child: const Text('重试', style: TextStyle(fontSize: 12)),
                  ),
                ],
              ),
            ),
          ),
        );
      }
      
      // 显示空状态或数据
      if (controller.projects.isEmpty) {
        return const SizedBox();
      }
      
      return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: controller.projects.length,
        itemBuilder: (context, index) {
          final project = controller.projects[index];
          return _buildProjectCard(project);
        },
      );
    });
  }

  Widget _buildProjectCard(dynamic project) {
    return Container(
      height: 132,
      margin: const EdgeInsets.fromLTRB(15, 0, 15, 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, 2),
            blurRadius: 10,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Container(
                width: 100,
                height: 100,
                color: Colors.grey[200],
                child: project.imageUrl != null
                    ? Image.network(
                        project.imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(Icons.spa, color: Colors.grey, size: 40);
                        },
                      )
                    : const Icon(Icons.spa, color: Colors.grey, size: 40),
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    project.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF333333),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: Color(0xFFFF5777),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${project.duration}分钟',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF666666),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '已出售${project.orderCount ?? 0}+',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF999999),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          const Text(
                            '¥',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFFFF5777),
                            ),
                          ),
                          Text(
                            '${project.priceYuan}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFFF5777),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 10),
                      if (project.originalPriceYuan != null)
                        Text(
                          '¥${project.originalPriceYuan}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF999999),
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF5777),
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFFF5777).withOpacity(0.3),
                              offset: const Offset(0, 2),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                        child: const Text(
                          '选择技师',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}