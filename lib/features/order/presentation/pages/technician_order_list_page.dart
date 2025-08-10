import 'package:flutter/material.dart';
import 'package:bookin/features/technician/data/api/technician_api.dart';
import 'package:bookin/features/order/data/models/order_constants.dart'; // For order status text
import 'package:bookin/features/order/presentation/pages/technician_order_detail_page.dart'; // Import technician order detail page

class TechnicianOrderListPage extends StatefulWidget {
  const TechnicianOrderListPage({super.key});

  @override
  State<TechnicianOrderListPage> createState() => _TechnicianOrderListPageState();
}

class _TechnicianOrderListPageState extends State<TechnicianOrderListPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TechnicianApi _technicianApi = TechnicianApi();
  final List<TechnicianOrder> _orders = [];
  bool _isLoading = true;
  String? _errorMessage;
  int _currentPage = 1;
  bool _hasMore = true;

  // Map tab index to order status code for technician orders
  final List<int?> _statusMap = [
    null, // All
    NewOrderStatus.WAIT_ACCEPT.code, // 待接单
    NewOrderStatus.PENDING_SERVICE.code, // 待服务
    NewOrderStatus.SERVICE.code, // 服务中
    NewOrderStatus.COMPLETED.code, // 已完成
    NewOrderStatus.CANCELLED.code, // 已取消
    NewOrderStatus.REFUNDING.code, // 退款中
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _statusMap.length, vsync: this);
    _tabController.addListener(_handleTabSelection);
    _fetchOrders();
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabSelection);
    _tabController.dispose();
    super.dispose();
  }

  void _handleTabSelection() {
    if (_tabController.indexIsChanging) {
      setState(() {
        _orders.clear();
        _currentPage = 1;
        _hasMore = true;
        _isLoading = true;
        _errorMessage = null;
      });
      _fetchOrders();
    }
  }

  Future<void> _fetchOrders() async {
    if (!_hasMore || _isLoading) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final int? currentStatus = _statusMap[_tabController.index];
      final response = await _technicianApi.getOrders(
        context, // Pass context
        status: currentStatus != null ? currentStatus.toString() : null, // API expects string status
        page: _currentPage,
        pageSize: 10,
      );

      if (response.success) {
        setState(() {
          _orders.addAll(response.data ?? []);
          _hasMore = response.data?.isNotEmpty ?? false; // Assuming data.isNotEmpty implies hasMore
          _currentPage++;
        });
      } else {
        _errorMessage = response.message;
      }
    } catch (e) {
      _errorMessage = '加载订单列表失败: ${e.toString()}';
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
        title: const Text('订单管理'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: '全部'),
            Tab(text: '待接单'),
            Tab(text: '待服务'),
            Tab(text: '服务中'),
            Tab(text: '已完成'),
            Tab(text: '已取消'),
            Tab(text: '退款中'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: _statusMap.map((status) {
          return _isLoading && _orders.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : _errorMessage != null
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(_errorMessage!),
                          ElevatedButton(
                            onPressed: _fetchOrders,
                            child: const Text('重试'),
                          ),
                        ],
                      ),
                    )
                  : NotificationListener<ScrollNotification>(
                      onNotification: (ScrollNotification scrollInfo) {
                        if (!_isLoading && _hasMore && scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
                          _fetchOrders();
                          return true;
                        }
                        return false;
                      },
                      child: ListView.builder(
                        itemCount: _orders.length + (_hasMore ? 1 : 0), // Add 1 for loading indicator
                        itemBuilder: (context, index) {
                          if (index == _orders.length) {
                            return const Center(child: CircularProgressIndicator());
                          }
                          final order = _orders[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                            child: ListTile(
                              title: Text('订单号: ${order.orderId}'),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('项目: ${order.projectName}'),
                                  Text('客户: ${order.customerName} (${order.customerPhone})'),
                                  Text('服务时间: ${order.serviceTime}'),
                                  Text('地址: ${order.address}'),
                                ],
                              ),
                              trailing: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text('¥${(order.actualPrice / 100).toStringAsFixed(2)}'),
                                  Text(NewOrderStatusExtension.fromCode(order.status).description, style: TextStyle(color: NewOrderStatusExtension.fromCode(order.status).cssClass == 'pending-section' ? Colors.orange : Colors.green)),
                                ],
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => TechnicianOrderDetailPage(orderId: order.orderId),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
                    );
        }).toList(),
      ),
    );
  }
}
