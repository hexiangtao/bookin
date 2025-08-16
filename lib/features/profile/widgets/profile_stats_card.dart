import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/profile_controller.dart';

class ProfileStatsCard extends StatelessWidget {
  final ProfileController controller;
  
  const ProfileStatsCard({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // 标题
          Row(
            children: [
              const Icon(
                Icons.receipt_long,
                color: Color(0xFF6C63FF),
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                '我的订单',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF333333),
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => controller.handleNavigation('orders'),
                child: Row(
                  children: [
                    const Text(
                      '查看全部',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF999999),
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.arrow_forward_ios,
                      size: 12,
                      color: Color(0xFF999999),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // 订单统计
          Row(
            children: [
              _buildOrderStatItem(
                icon: Icons.payment,
                label: '待付款',
                count: 'pending_payment',
                color: const Color(0xFFFF6B6B),
              ),
              _buildOrderStatItem(
                icon: Icons.schedule,
                label: '待服务',
                count: 'pending_service',
                color: const Color(0xFF4ECDC4),
              ),
              _buildOrderStatItem(
                icon: Icons.rate_review,
                label: '待评价',
                count: 'pending_review',
                color: const Color(0xFFFFE66D),
              ),
              _buildOrderStatItem(
                icon: Icons.history,
                label: '已完成',
                count: 'completed',
                color: const Color(0xFF95E1D3),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildOrderStatItem({
    required IconData icon,
    required String label,
    required String count,
    required Color color,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: () => controller.handleNavigation('orders', params: {'status': count}),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                icon,
                color: color,
                size: 20,
              ),
            ),
            
            const SizedBox(height: 8),
            
            Obx(() {
              final orderCount = controller.orderStats[count] ?? 0;
              return Text(
                orderCount.toString(),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: orderCount > 0 ? color : const Color(0xFF999999),
                ),
              );
            }),
            
            const SizedBox(height: 4),
            
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF666666),
              ),
            ),
          ],
        ),
      ),
    );
  }
}