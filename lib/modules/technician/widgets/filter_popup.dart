import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../technician_controller.dart';

class FilterPopup extends StatelessWidget {
  final TechnicianController controller;
  
  const FilterPopup({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() => AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      transform: Matrix4.translationValues(
        0, 
        controller.showFilterPopup.value ? 0 : MediaQuery.of(context).size.height,
        0,
      ),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.7,
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
            
            // 筛选内容
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 服务类型
                    _buildServiceTypeSection(),
                    
                    const SizedBox(height: 30),
                    
                    // 价格区间
                    _buildPriceRangeSection(),
                    
                    const SizedBox(height: 30),
                    
                    // 评分
                    _buildRatingSection(),
                  ],
                ),
              ),
            ),
            
            // 底部按钮
            _buildBottomButtons(),
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
            onTap: () => controller.showFilterPopup.value = false,
            child: const Icon(
              Icons.close,
              size: 24,
              color: Color(0xFF333333),
            ),
          ),
          
          const Expanded(
            child: Text(
              '筛选',
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

  /// 构建服务类型筛选
  Widget _buildServiceTypeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '服务类型',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF333333),
          ),
        ),
        
        const SizedBox(height: 15),
        
        Obx(() => Wrap(
          spacing: 12,
          runSpacing: 12,
          children: controller.serviceTypes.map((option) {
            final isSelected = option.selected;
            
            return GestureDetector(
              onTap: () => controller.selectFilterOption('serviceTypes', controller.serviceTypes.indexOf(option)),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFFFF5777) : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? const Color(0xFFFF5777) : const Color(0xFFE5E5E5),
                    width: 1,
                  ),
                ),
                child: Text(
                  option.name,
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

  /// 构建价格区间筛选
  Widget _buildPriceRangeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '价格区间',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF333333),
          ),
        ),
        
        const SizedBox(height: 15),
        
        Obx(() => Wrap(
          spacing: 12,
          runSpacing: 12,
          children: controller.priceRanges.map((option) {
            final isSelected = option.selected;
            
            return GestureDetector(
              onTap: () => controller.selectFilterOption('priceRanges', controller.priceRanges.indexOf(option)),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFFFF5777) : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? const Color(0xFFFF5777) : const Color(0xFFE5E5E5),
                    width: 1,
                  ),
                ),
                child: Text(
                  option.name,
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

  /// 构建评分筛选
  Widget _buildRatingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '评分',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF333333),
          ),
        ),
        
        const SizedBox(height: 15),
        
        Obx(() => Column(
          children: controller.ratingOptions.asMap().entries.map((entry) {
            final index = entry.key;
            final option = entry.value;
            final isSelected = option.selected;
            
            return GestureDetector(
              onTap: () => controller.selectFilterOption('ratings', index),
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFFFFF0F4) : Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSelected ? const Color(0xFFFF5777) : const Color(0xFFE5E5E5),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    // 星级显示
                    Row(
                      children: List.generate(5, (index) {
                        return Icon(
                          index < (int.tryParse(option.id.replaceAll('+', '').split('.').first) ?? 0) ? Icons.star : Icons.star_border,
                          size: 16,
                          color: const Color(0xFFFFB800),
                        );
                      }),
                    ),
                    
                    const SizedBox(width: 8),
                    
                    Text(
                      option.name,
                      style: TextStyle(
                        fontSize: 14,
                        color: isSelected ? const Color(0xFFFF5777) : const Color(0xFF333333),
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
        )),
      ],
    );
  }

  /// 构建底部按钮
  Widget _buildBottomButtons() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Color(0xFFF5F5F5), width: 1)),
      ),
      child: Row(
        children: [
          // 重置按钮
          Expanded(
            child: GestureDetector(
              onTap: () => controller.resetFilters(),
              child: Container(
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: const Color(0xFFE5E5E5), width: 1),
                ),
                child: const Center(
                  child: Text(
                    '重置',
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF333333),
                    ),
                  ),
                ),
              ),
            ),
          ),
          
          const SizedBox(width: 15),
          
          // 确认按钮
          Expanded(
            flex: 2,
            child: GestureDetector(
              onTap: () => controller.applyFilters(),
              child: Container(
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFFF5777),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: const Center(
                  child: Text(
                    '确认',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}