import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/models/technician_model.dart';
import '../../shared/widgets/custom_app_bar.dart';
import 'technician_list_controller.dart';

class TechnicianListPage extends StatelessWidget {
  const TechnicianListPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(TechnicianListController());
    
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Column(
        children: [
          // 自定义导航栏
          CustomAppBar(
            title: '找技师',
            showBack: true,
          ),
          
          // 固定头部区域
          Container(
            color: Colors.white,
            child: Column(
              children: [
                // 城市选择和搜索
                _buildSearchHeader(controller),
                // 筛选标签
                _buildFilterTabs(controller),
              ],
            ),
          ),
          
          // 技师列表
          Expanded(
            child: _buildTechnicianList(controller),
          ),
        ],
      ),
      
      // 筛选弹窗
      bottomSheet: Obx(() {
        if (controller.showFilterPopup.value) {
          return _buildFilterPopup(controller);
        } else if (controller.showCityPopup.value) {
          return _buildCityPopup(controller);
        } else {
          return const SizedBox.shrink();
        }
      }),
    );
  }

  // 搜索头部
  Widget _buildSearchHeader(TechnicianListController controller) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // 城市选择
          GestureDetector(
            onTap: () => controller.toggleCityPopup(),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F8F8),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Obx(() => Text(
                    controller.selectedCity.value,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF333333),
                    ),
                  )),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.keyboard_arrow_down,
                    size: 16,
                    color: Color(0xFF666666),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(width: 12),
          
          // 搜索框
          Expanded(
            child: Container(
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFFF8F8F8),
                borderRadius: BorderRadius.circular(18),
              ),
              child: TextField(
                onSubmitted: controller.onSearch,
                decoration: const InputDecoration(
                  hintText: '搜索技师姓名',
                  hintStyle: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF999999),
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    size: 20,
                    color: Color(0xFF999999),
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 筛选标签
  Widget _buildFilterTabs(TechnicianListController controller) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          _buildFilterTab('服务类型', controller.serviceTypes, () {
            controller.selectFilterItem('serviceType', 0);
            controller.toggleFilterPopup();
          }),
          const SizedBox(width: 16),
          _buildFilterTab('价格', controller.priceRanges, () {
            controller.selectFilterItem('priceRange', 0);
            controller.toggleFilterPopup();
          }),
          const SizedBox(width: 16),
          _buildFilterTab('评分', controller.ratings, () {
            controller.selectFilterItem('rating', 0);
            controller.toggleFilterPopup();
          }),
          const Spacer(),
          GestureDetector(
            onTap: () => controller.toggleFilterPopup(),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.tune,
                    size: 16,
                    color: Color(0xFF666666),
                  ),
                  SizedBox(width: 4),
                  Text(
                    '筛选',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF666666),
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

  // 筛选标签项
  Widget _buildFilterTab(String title, RxList<Map<String, dynamic>> options, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Obx(() {
        final selectedOption = options.firstWhereOrNull(
          (item) => item['selected'] == true
        );
        final isSelected = selectedOption != null && selectedOption['name'] != '全部';
        
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                selectedOption?['name'] ?? title,
                style: TextStyle(
                  fontSize: 14,
                  color: isSelected ? const Color(0xFF007AFF) : const Color(0xFF666666),
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.keyboard_arrow_down,
                size: 14,
                color: isSelected ? const Color(0xFF007AFF) : const Color(0xFF666666),
              ),
            ],
          ),
        );
      }),
    );
  }

  // 技师列表
  Widget _buildTechnicianList(TechnicianListController controller) {
    return Obx(() {
      if (controller.isLoading.value && controller.technicians.isEmpty) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      }
      
      if (controller.technicians.isEmpty) {
        return const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.person_off,
                size: 64,
                color: Color(0xFFCCCCCC),
              ),
              SizedBox(height: 16),
              Text(
                '暂无技师',
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF999999),
                ),
              ),
            ],
          ),
        );
      }
      
      return RefreshIndicator(
        onRefresh: controller.onRefresh,
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.technicians.length + (controller.hasMore.value ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == controller.technicians.length) {
              // 加载更多指示器
              if (controller.hasMore.value) {
                controller.onLoadMore();
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              }
              return const SizedBox.shrink();
            }
            
            final technician = controller.technicians[index];
            return _buildTechnicianCard(technician, controller);
          },
        ),
      );
    });
  }

  // 技师卡片
  Widget _buildTechnicianCard(TechnicianModel technician, TechnicianListController controller) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 技师头像
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(technician.avatarShape == 0 ? 30 : 8),
                child: Image.network(
                  technician.avatar,
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 60,
                      height: 60,
                      color: const Color(0xFFF0F0F0),
                      child: const Icon(
                        Icons.person,
                        color: Color(0xFFCCCCCC),
                      ),
                    );
                  },
                ),
              ),
              if (technician.isHot)
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF6B35),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      '优评',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          
          const SizedBox(width: 12),
          
          // 技师信息
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 姓名和认证
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
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.verified,
                        size: 16,
                        color: Color(0xFF007AFF),
                      ),
                    ],
                    if (technician.isRecommend) ...[
                      const SizedBox(width: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF6B35),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          '推荐',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                
                const SizedBox(height: 4),
                
                // 服务单数
                Text(
                  '服务单数：${technician.orderCount}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF666666),
                  ),
                ),
                
                const SizedBox(height: 4),
                
                // 店铺名称
                if (technician.shopName != null || technician.merchantName != null)
                  Text(
                    technician.shopName ?? technician.merchantName ?? '',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF666666),
                    ),
                  ),
                
                const SizedBox(height: 4),
                
                // 评论和点赞
                Row(
                  children: [
                    Text(
                      '评论 ${technician.commentCount}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF666666),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      '点赞 ${technician.likeCount}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF666666),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 8),
                
                // 标签
                if (technician.tags.isNotEmpty)
                  Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children: technician.tags.take(3).map((tag) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0F8FF),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          tag,
                          style: const TextStyle(
                            fontSize: 10,
                            color: Color(0xFF007AFF),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
              ],
            ),
          ),
          
          // 距离和预约按钮
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (technician.distance != null)
                Text(
                  '${technician.distance!.toStringAsFixed(1)}km',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF666666),
                  ),
                ),
              
              const SizedBox(height: 8),
              
              GestureDetector(
                onTap: () => controller.goToTechnicianDetail(technician),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF007AFF),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Text(
                    '预约',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 筛选弹窗
  Widget _buildFilterPopup(TechnicianListController controller) {
    return Container(
      height: MediaQuery.of(Get.context!).size.height * 0.6,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        children: [
          // 头部
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Color(0xFFEEEEEE))),
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => controller.resetFilter(),
                  child: const Text(
                    '重置',
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF666666),
                    ),
                  ),
                ),
                const Spacer(),
                const Text(
                  '筛选',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF333333),
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () => controller.applyFilter(),
                  child: const Text(
                    '确定',
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF007AFF),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // 筛选内容
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFilterSection('服务类型', controller.serviceTypes, 'serviceType', controller),
                  const SizedBox(height: 24),
                  _buildFilterSection('价格范围', controller.priceRanges, 'priceRange', controller),
                  const SizedBox(height: 24),
                  _buildFilterSection('评分', controller.ratings, 'rating', controller),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 筛选区域
  Widget _buildFilterSection(String title, RxList<Map<String, dynamic>> options, String type, TechnicianListController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF333333),
          ),
        ),
        const SizedBox(height: 12),
        Obx(() => Wrap(
          spacing: 12,
          runSpacing: 8,
          children: options.asMap().entries.map((entry) {
            final index = entry.key;
            final option = entry.value;
            final isSelected = option['selected'] == true;
            
            return GestureDetector(
              onTap: () => controller.selectFilterItem(type, index),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF007AFF) : const Color(0xFFF8F8F8),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? const Color(0xFF007AFF) : const Color(0xFFEEEEEE),
                  ),
                ),
                child: Text(
                  option['name'],
                  style: TextStyle(
                    fontSize: 14,
                    color: isSelected ? Colors.white : const Color(0xFF333333),
                  ),
                ),
              ),
            );
          }).toList(),
        )),
      ],
    );
  }

  // 城市选择弹窗
  Widget _buildCityPopup(TechnicianListController controller) {
    return Container(
      height: MediaQuery.of(Get.context!).size.height * 0.7,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        children: [
          // 头部
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Color(0xFFEEEEEE))),
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => controller.toggleCityPopup(),
                  child: const Icon(
                    Icons.close,
                    color: Color(0xFF666666),
                  ),
                ),
                const Spacer(),
                const Text(
                  '选择城市',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF333333),
                  ),
                ),
                const Spacer(),
                const SizedBox(width: 24),
              ],
            ),
          ),
          
          // 城市内容
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 当前定位
                  const Text(
                    '当前定位',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF333333),
                    ),
                  ),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: () => controller.selectCity(
                      controller.gpsLocatedCity.value,
                      controller.gpsLocatedCityCode.value,
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8F8F8),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Obx(() => Text(
                        controller.gpsLocatedCity.value,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF333333),
                        ),
                      )),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // 热门城市
                  const Text(
                    '热门城市',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF333333),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Obx(() => Wrap(
                    spacing: 12,
                    runSpacing: 8,
                    children: controller.hotCities.map((city) {
                      return GestureDetector(
                        onTap: () => controller.selectCity(city, ''),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8F8F8),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            city,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF333333),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  )),
                  
                  const SizedBox(height: 24),
                  
                  // 城市列表
                  Obx(() {
                    final cityGroups = controller.cityGroups;
                    return Column(
                      children: cityGroups.entries.map((entry) {
                        final letter = entry.key;
                        final cities = entry.value;
                        
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              letter,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF333333),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 12,
                              runSpacing: 8,
                              children: cities.map((city) {
                                return GestureDetector(
                                  onTap: () => controller.selectCity(city, ''),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF8F8F8),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      city,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Color(0xFF333333),
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: 24),
                          ],
                        );
                      }).toList(),
                    );
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}