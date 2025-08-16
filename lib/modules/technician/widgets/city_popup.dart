import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../technician_controller.dart';

class CityPopup extends StatelessWidget {
  final TechnicianController controller;
  
  const CityPopup({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() => AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      transform: Matrix4.translationValues(
        0, 
        controller.showCityPopup.value ? 0 : MediaQuery.of(context).size.height,
        0,
      ),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          children: [
            // 头部
            _buildHeader(),
            
            // 城市内容
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 当前定位
                    _buildCurrentLocationSection(),
                    
                    const SizedBox(height: 30),
                    
                    // 热门城市
                    _buildHotCitiesSection(),
                    
                    const SizedBox(height: 30),
                    
                    // 城市列表
                    _buildCityListSection(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ));
  }

  /// 构建头部
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFF5F5F5), width: 1)),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => controller.showCityPopup.value = false,
            child: const Icon(
              Icons.close,
              size: 24,
              color: Color(0xFF333333),
            ),
          ),
          
          const Expanded(
            child: Text(
              '选择城市',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF333333),
              ),
              textAlign: TextAlign.center,
            ),
          ),
          
          const SizedBox(width: 24), // 占位，保持标题居中
        ],
      ),
    );
  }

  /// 构建当前定位区域
  Widget _buildCurrentLocationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '当前定位',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF333333),
          ),
        ),
        
        const SizedBox(height: 15),
        
        Obx(() {
          if (controller.isLoadingCities.value) {
            return Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF5777)),
                    ),
                  ),
                  SizedBox(width: 10),
                  Text(
                    '正在定位...',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF666666),
                    ),
                  ),
                ],
              ),
            );
          }
          
          return GestureDetector(
            onTap: () => controller.gpsLocatedCity.value != null 
                ? controller.selectCity(controller.gpsLocatedCity.value!) 
                : null,
            child: Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: controller.selectedCity.value == controller.gpsLocatedCity.value
                    ? const Color(0xFFFFF0F4)
                    : const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: controller.selectedCity.value == controller.gpsLocatedCity.value
                      ? const Color(0xFFFF5777)
                      : Colors.transparent,
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.location_on,
                    size: 20,
                    color: controller.selectedCity.value == controller.gpsLocatedCity.value
                        ? const Color(0xFFFF5777)
                        : const Color(0xFF666666),
                  ),
                  
                  const SizedBox(width: 10),
                  
                  Text(
                    controller.gpsLocatedCity.value?.name ?? '定位失败，请手动选择',
                    style: TextStyle(
                      fontSize: 14,
                      color: controller.selectedCity.value == controller.gpsLocatedCity.value
                          ? const Color(0xFFFF5777)
                          : const Color(0xFF333333),
                      fontWeight: controller.selectedCity.value == controller.gpsLocatedCity.value
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                  
                  const Spacer(),
                  
                  if (controller.selectedCity.value == controller.gpsLocatedCity.value)
                    const Icon(
                      Icons.check,
                      size: 16,
                      color: Color(0xFFFF5777),
                    ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  /// 构建热门城市区域
  Widget _buildHotCitiesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '热门城市',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF333333),
          ),
        ),
        
        const SizedBox(height: 15),
        
        Obx(() => GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 2.5,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: controller.hotCities.length,
          itemBuilder: (context, index) {
            final city = controller.hotCities[index];
            final isSelected = controller.selectedCity.value == city.name;
            
            return GestureDetector(
              onTap: () => controller.selectCity(city),
              child: Container(
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFFFF5777) : Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSelected ? const Color(0xFFFF5777) : const Color(0xFFE5E5E5),
                    width: 1,
                  ),
                ),
                child: Center(
                  child: Text(
                    city.name,
                    style: TextStyle(
                      fontSize: 14,
                      color: isSelected ? Colors.white : const Color(0xFF333333),
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              ),
            );
          },
        )),
      ],
    );
  }

  /// 构建城市列表区域
  Widget _buildCityListSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '城市列表',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF333333),
          ),
        ),
        
        const SizedBox(height: 15),
        
        Obx(() {
          if (controller.isLoadingCities.value) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF5777)),
                ),
              ),
            );
          }
          
          return Column(
            children: controller.cityGroups.entries.map((entry) {
              final letter = entry.key;
              final cities = entry.value;
              
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 字母标题
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      letter,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF666666),
                      ),
                    ),
                  ),
                  
                  // 城市列表
                  ...cities.map((city) {
                    final isSelected = controller.selectedCity.value == city.name;
                    
                    return GestureDetector(
                      onTap: () => controller.selectCity(city),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 15),
                        margin: const EdgeInsets.only(bottom: 1),
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0xFFFFF0F4) : Colors.white,
                          border: Border.all(
                            color: isSelected ? const Color(0xFFFF5777) : const Color(0xFFF5F5F5),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Text(
                              city.name,
                              style: TextStyle(
                                fontSize: 14,
                                color: isSelected ? const Color(0xFFFF5777) : const Color(0xFF333333),
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                            
                            const Spacer(),
                            
                            if (isSelected)
                              const Icon(
                                Icons.check,
                                size: 16,
                                color: Color(0xFFFF5777),
                              ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                  
                  const SizedBox(height: 20),
                ],
              );
            }).toList(),
          );
        }),
      ],
    );
  }
}