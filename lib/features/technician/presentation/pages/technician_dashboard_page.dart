import 'package:flutter/material.dart';
import 'package:bookin/features/technician/data/api/technician_api.dart';
// import 'package:bookin/features/technician/presentation/pages/technician_order_list_page.dart';
import 'package:bookin/features/technician/presentation/pages/technician_schedule_page.dart';
import 'package:bookin/features/technician/presentation/pages/technician_profile_edit_page.dart';
// import 'package:bookin/features/technician/presentation/pages/withdrawal_accounts_page.dart';
import 'package:bookin/features/technician/presentation/pages/technician_auth_page.dart';
import 'package:bookin/features/technician/presentation/pages/technician_notifications_page.dart';
import 'package:bookin/features/technician/presentation/pages/technician_profile_gallery_page.dart';
import 'package:bookin/features/payment/presentation/pages/technician_settle_page.dart';
import 'package:bookin/features/payment/presentation/pages/technician_earnings_page.dart';
import 'package:bookin/features/technician/presentation/pages/technician_messages_page.dart';
import 'package:bookin/features/payment/presentation/pages/withdrawal_accounts_page.dart';
import 'package:bookin/features/order/presentation/pages/technician_order_list_page.dart';
import 'package:bookin/features/technician/presentation/pages/technician_service_cities_page.dart';
import 'package:bookin/features/technician/presentation/pages/technician_service_projects_page.dart'; // Import service projects page

class TechnicianDashboardPage extends StatefulWidget {
  const TechnicianDashboardPage({super.key});

  @override
  State<TechnicianDashboardPage> createState() => _TechnicianDashboardPageState();
}

class _TechnicianDashboardPageState extends State<TechnicianDashboardPage> {
  final TechnicianApi _technicianApi = TechnicianApi();
  TechnicianDashboard? _dashboardData;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchDashboardData();
  }

  Future<void> _fetchDashboardData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final response = await _technicianApi.getDashboard(context); // Pass context
      if (response.success) {
        _dashboardData = response.data;
      } else {
        _errorMessage = response.message;
      }
    } catch (e) {
      _errorMessage = '加载仪表板数据失败: ${e.toString()}';
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('技师工作台'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(_errorMessage!),
                      ElevatedButton(
                        onPressed: _fetchDashboardData,
                        child: const Text('重试'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _fetchDashboardData,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Overview Cards
                          GridView.count(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisCount: 2,
                            crossAxisSpacing: 16.0,
                            mainAxisSpacing: 16.0,
                            children: [
                              _buildDashboardCard(
                                '总订单',
                                _dashboardData?.totalOrders.toString() ?? '0',
                                Icons.receipt,
                                Colors.blueAccent,
                              ),
                              _buildDashboardCard(
                                '已完成订单',
                                _dashboardData?.completedOrders.toString() ?? '0',
                                Icons.check_circle,
                                Colors.green,
                              ),
                              _buildDashboardCard(
                                '待处理订单',
                                _dashboardData?.pendingOrders.toString() ?? '0',
                                Icons.pending_actions,
                                Colors.orange,
                              ),
                              _buildDashboardCard(
                                '总收入',
                                '¥${(_dashboardData?.totalEarnings ?? 0.0).toStringAsFixed(2)}',
                                Icons.attach_money,
                                Colors.purple,
                              ),
                              _buildDashboardCard(
                                '待提现',
                                '¥${(_dashboardData?.pendingWithdrawal ?? 0.0).toStringAsFixed(2)}',
                                Icons.account_balance_wallet,
                                Colors.teal,
                              ),
                              _buildDashboardCard(
                                '未读消息',
                                _dashboardData?.unreadMessages.toString() ?? '0',
                                Icons.message,
                                Colors.redAccent,
                              ),
                              _buildDashboardCard(
                                '未读通知',
                                _dashboardData?.unreadNotifications.toString() ?? '0',
                                Icons.notifications,
                                Colors.deepOrange,
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          // Quick Actions
                          Text('快捷操作', style: Theme.of(context).textTheme.titleLarge),
                          const Divider(),
                          Wrap(
                            spacing: 10.0,
                            runSpacing: 10.0,
                            children: [
                              _buildQuickActionButton('订单管理', Icons.list_alt, () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const TechnicianOrderListPage()),
                                );
                              }),
                              _buildQuickActionButton('排班管理', Icons.calendar_today, () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const TechnicianSchedulePage()),
                                );
                              }),
                              _buildQuickActionButton('个人资料', Icons.person_outline, () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const TechnicianProfileEditPage()),
                                );
                              }),
                              _buildQuickActionButton('提现管理', Icons.credit_card, () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const WithdrawalAccountsPage()),
                                );
                              }),
                              _buildQuickActionButton('服务项目', Icons.medical_services, () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const TechnicianServiceProjectsPage()),
                                );
                              }),
                              _buildQuickActionButton('认证中心', Icons.verified_user, () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const TechnicianAuthPage()),
                                );
                              }),
                              _buildQuickActionButton('通知公告', Icons.notifications_active, () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const TechnicianNotificationsPage()),
                                );
                              }),
                              _buildQuickActionButton('个人相册', Icons.photo_library, () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const TechnicianProfileGalleryPage()),
                                );
                              }),
                              _buildQuickActionButton('技师入驻', Icons.person_add, () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const TechnicianSettlePage()),
                                );
                              }),
                              _buildQuickActionButton('收入明细', Icons.money, () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const TechnicianEarningsPage()),
                                );
                              }),
                              _buildQuickActionButton('消息中心', Icons.message, () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const TechnicianMessagesPage()),
                                );
                              }),
                              _buildQuickActionButton('服务城市', Icons.location_city, () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const TechnicianServiceCitiesPage()),
                                );
                              }),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
    );
  }

  Widget _buildDashboardCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(icon, size: 36, color: color),
            const SizedBox(height: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionButton(String title, IconData icon, VoidCallback onPressed) {
    return SizedBox(
      width: 100,
      child: Column(
        children: [
          ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              shape: const CircleBorder(),
              padding: const EdgeInsets.all(15),
              backgroundColor: Colors.blue.shade50,
              foregroundColor: Colors.blueAccent,
            ),
            child: Icon(icon, size: 30),
          ),
          const SizedBox(height: 5),
          Text(title, textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}
