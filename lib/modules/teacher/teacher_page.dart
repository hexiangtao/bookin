import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../technician/technician_controller.dart';
import '../technician/widgets/filter_popup.dart';
import '../technician/widgets/city_popup.dart';
import '../../core/models/technician_model.dart';
import '../../core/widgets/custom_app_bar.dart';
import '../../core/widgets/loading_widget.dart';
import '../../core/widgets/empty_widget.dart';

class TeacherPage extends StatelessWidget {
  const TeacherPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<TechnicianController>();
    
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // 主要内容
          Column(
            children: [
              // 自定义导航栏
              CustomAppBar(
                title: '技师',
                showBack: false,
                backgroundColor: Colors.white,
              ),
              
              // 固定头部区域
              _buildFixedHeader(controller),
              
              // 可滚动内容区域
              Expanded(
                child: _buildScrollableContent(controller),
              ),
            ],
          ),
          
          // 筛选弹窗
          Obx(() => controller.showFilterPopup.value
              ? Container(
                  color: Colors.black.withOpacity(0.5),
                  child: GestureDetector(
                    onTap: () => controller.showFilterPopup.value = false,
                    child: Container(),
                  ),
                )
              : const SizedBox.shrink()),
          
          Obx(() => controller.showFilterPopup.value
              ? Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: FilterPopup(controller: controller),
                )
              : const SizedBox.shrink()),
          
          // 城市选择弹窗
          Obx(() => controller.showCityPopup.value
              ? Container(
                  color: Colors.black.withOpacity(0.5),
                  child: GestureDetector(
                    onTap: () => controller.showCityPopup.value = false,
                    child: Container(),
                  ),
                )
              : const SizedBox.shrink()),
          
          Obx(() => controller.showCityPopup.value
              ? Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: CityPopup(controller: controller),
                )
              : const SizedBox.shrink()),
        ],
      ),
    );
  }

  /// 构建固定头部区域
  Widget _buildFixedHeader(TechnicianController controller) {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          // 搜索区域
          _buildSearchHeader(controller),
          
          // 筛选标签
          _buildFilterTabs(controller),
        ],
      ),
    );
  }

  /// 构建搜索头部
  Widget _buildSearchHeader(TechnicianController controller) {
    return Container(
      padding: const EdgeInsets.all(15),
      child: Row(
        children: [
          // 城市选择器
          GestureDetector(
            onTap: () => controller.showCityPopup.value = true,
            child: Obx(() => Row(
              children: [
                Text(
                  controller.selectedCity.value,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.keyboard_arrow_down,
                  size: 16,
                  color: AppColors.textPrimary,
                ),
              ],
            )),
          ),
          
          const SizedBox(width: 15),
          
          // 搜索框
          Expanded(
            child: Container(
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(18),
              ),
              child: TextField(
                onChanged: (value) => controller.searchKeyword.value = value,
                onSubmitted: (_) => controller.searchTechnicians(),
                decoration: InputDecoration(
                  hintText: '请输入技师姓名',
                  hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textTertiary),
                  prefixIcon: Icon(Icons.search, color: AppColors.textTertiary, size: 20),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                ),
              ),
            ),
          ),
          
          const SizedBox(width: 10),
          
          // 搜索按钮
          GestureDetector(
            onTap: () => controller.searchTechnicians(),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.secondary,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Text(
                '搜索',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.surface,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建筛选标签
  Widget _buildFilterTabs(TechnicianController controller) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Color(0xFFF5F5F5), width: 1)),
      ),
      child: Row(
        children: [
          _buildFilterTab(controller, 0, '全部'),
          _buildFilterTab(controller, 1, '免出行费'),
          _buildFilterTab(controller, 2, '可服务'),
          const Spacer(),
          GestureDetector(
            onTap: () => controller.showFilterPopup.value = true,
            child: Row(
              children: [
                const Text(
                  '筛选',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF333333),
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(
                  Icons.keyboard_arrow_down,
                  size: 16,
                  color: Color(0xFF333333),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 构建单个筛选标签
  Widget _buildFilterTab(TechnicianController controller, int index, String title) {
    return Expanded(
      child: GestureDetector(
        onTap: () => controller.switchTab(index),
        child: Obx(() => Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  color: controller.currentTab.value == index 
                      ? const Color(0xFFFF5777) 
                      : const Color(0xFF333333),
                  fontWeight: controller.currentTab.value == index 
                      ? FontWeight.bold 
                      : FontWeight.normal,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              if (controller.currentTab.value == index)
                Container(
                  width: 20,
                  height: 2,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF5777),
                    borderRadius: BorderRadius.circular(1),
                  ),
                ),
            ],
          ),
        )),
      ),
    );
  }

  /// 构建可滚动内容
  Widget _buildScrollableContent(TechnicianController controller) {
    return Obx(() {
      if (controller.isLoading.value && controller.technicians.isEmpty) {
        return const LoadingWidget();
      }
      
      if (controller.hasError.value && controller.technicians.isEmpty) {
        return EmptyWidget(
          message: '加载失败，请重试',
          onRetry: () => controller.refresh(),
        );
      }
      
      if (controller.technicians.isEmpty) {
        return const EmptyWidget(
          message: '暂无技师数据',
        );
      }
      
      return NotificationListener<ScrollNotification>(
        onNotification: (ScrollNotification scrollInfo) {
          if (scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
            controller.loadMore();
          }
          return false;
        },
        child: ListView.builder(
          padding: const EdgeInsets.all(15),
          itemCount: controller.technicians.length + (controller.hasMore.value ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == controller.technicians.length) {
              return _buildLoadMoreWidget(controller);
            }
            
            final technician = controller.technicians[index];
            return _buildTechnicianCard(technician);
          },
        ),
      );
    });
  }

  /// 构建技师卡片
  Widget _buildTechnicianCard(TechnicianModel technician) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            offset: const Offset(0, 2),
            blurRadius: 8,
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 头像区域
          _buildTechnicianAvatar(technician),
          
          const SizedBox(width: 12),
          
          // 信息区域
          Expanded(
            child: _buildTechnicianInfo(technician),
          ),
          
          const SizedBox(width: 12),
          
          // 预约区域
          _buildBookingArea(technician),
        ],
      ),
    );
  }

  /// 构建技师头像
  Widget _buildTechnicianAvatar(TechnicianModel technician) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(
            technician.avatarShape == 0 ? 30 : 8,
          ),
          child: Image.network(
            technician.avatar,
            width: 60,
            height: 60,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(
                    technician.avatarShape == 0 ? 30 : 8,
                  ),
                ),
                child: const Icon(
                  Icons.person,
                  color: Color(0xFF999999),
                  size: 30,
                ),
              );
            },
          ),
        ),
        
        // 优质标签
        if (technician.goodRate != null && technician.goodRate! >= 95)
          Positioned(
            top: 0,
            right: 0,
            child: Container(
              width: 16,
              height: 16,
              decoration: const BoxDecoration(
                color: Color(0xFFFF5777),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text(
                  '优',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  /// 构建技师信息
  Widget _buildTechnicianInfo(TechnicianModel technician) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 姓名和徽章
        Row(
          children: [
            Text(
              technician.name,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF333333),
              ),
            ),
            
            if (technician.isVerified) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF5777),
                  borderRadius: BorderRadius.circular(2),
                ),
                child: const Text(
                  'V',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
            
            if (technician.isRecommend) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF0F4),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFFF5777), width: 0.5),
                ),
                child: const Text(
                  '官方推荐',
                  style: TextStyle(
                    color: Color(0xFFFF5777),
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ],
        ),
        
        const SizedBox(height: 4),
        
        // 服务次数
        Text(
          '已服务：${technician.orderCount}单',
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF666666),
          ),
        ),
        
        const SizedBox(height: 4),
        
        // 店铺和统计信息
        Row(
          children: [
            if (technician.shopName != null) ...[
              Text(
                technician.shopName!,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF999999),
                ),
              ),
              const SizedBox(width: 12),
            ],
            
            Icon(
              Icons.chat_bubble_outline,
              size: 12,
              color: const Color(0xFF999999),
            ),
            const SizedBox(width: 2),
            Text(
              '${technician.commentCount}',
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF999999),
              ),
            ),
            
            const SizedBox(width: 12),
            
            Icon(
              Icons.favorite_border,
              size: 12,
              color: const Color(0xFF999999),
            ),
            const SizedBox(width: 2),
            Text(
              '${technician.likeCount}',
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF999999),
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 6),
        
        // 标签
        if (technician.tags.isNotEmpty)
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: technician.tags.take(3).map((tag) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  tag,
                  style: const TextStyle(
                    fontSize: 10,
                    color: Color(0xFF666666),
                  ),
                ),
              );
            }).toList(),
          ),
      ],
    );
  }

  /// 构建预约区域
  Widget _buildBookingArea(TechnicianModel technician) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // 距离信息
        if (technician.distance != null)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.location_on,
                size: 12,
                color: Color(0xFFFF5777),
              ),
              const SizedBox(width: 2),
              Text(
                '${technician.distance!.toStringAsFixed(1)}km',
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF666666),
                ),
              ),
            ],
          ),
        
        const SizedBox(height: 8),
        
        // 预约按钮
        GestureDetector(
          onTap: () => _handleBookingTap(technician),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: _getBookingButtonColor(technician.status),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Text(
              _getBookingButtonText(technician.status),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// 构建加载更多组件
  Widget _buildLoadMoreWidget(TechnicianController controller) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Center(
        child: Obx(() {
          if (controller.isLoadingMore.value) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF5777)),
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  '努力加载中...',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF999999),
                  ),
                ),
              ],
            );
          } else if (!controller.hasMore.value) {
            return const Text(
              '没有更多数据了',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF999999),
              ),
            );
          } else {
            return const Text(
              '上拉加载更多',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF999999),
              ),
            );
          }
        }),
      ),
    );
  }

  /// 获取预约按钮颜色
  Color _getBookingButtonColor(int status) {
    switch (status) {
      case 0: // 可预约
        return const Color(0xFFFF5777);
      case 1: // 忙碌
        return const Color(0xFF999999);
      case 2: // 休息
        return const Color(0xFF999999);
      default:
        return const Color(0xFFFF5777);
    }
  }

  /// 获取预约按钮文本
  String _getBookingButtonText(int status) {
    switch (status) {
      case 0: // 可预约
        return '选择技师';
      case 1: // 忙碌
        return '忙碌中';
      case 2: // 休息
        return '休息中';
      default:
        return '选择技师';
    }
  }

  /// 处理预约按钮点击
  void _handleBookingTap(TechnicianModel technician) {
    if (technician.status == 0) {
      // 可预约，跳转到技师详情页
      Get.toNamed('/technician/detail', arguments: technician.id);
    } else {
      // 不可预约，显示提示
      Get.snackbar(
        '提示',
        technician.status == 1 ? '技师忙碌中，请选择其他技师' : '技师休息中，请选择其他技师',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}