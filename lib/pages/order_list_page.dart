import 'package:flutter/material.dart';
import 'package:bookin/api/order.dart';
import 'package:bookin/api/order_constants.dart';
import 'package:bookin/pages/order/order_detail_page.dart'; // Import order detail page

class OrderListPage extends StatefulWidget {
  const OrderListPage({super.key});

  @override
  State<OrderListPage> createState() => _OrderListPageState();
}

class _OrderListPageState extends State<OrderListPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final OrderApi _orderApi = OrderApi();
  final List<OrderListItem> _orders = [];
  bool _isLoading = true;
  String? _errorMessage;
  int _currentPage = 1;
  bool _hasMore = true;

  // Map tab index to order status code
  // 0: All, 1: WAITING_PAYMENT, 2: WAITING_SERVICE, 3: COMPLETED, 4: CANCELED
  final List<int?> _statusMap = [null, OrderStatus.WAITING_PAYMENT.code, OrderStatus.WAITING_SERVICE.code, OrderStatus.COMPLETED.code, OrderStatus.CANCELED.code];

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
      final response = await _orderApi.getOrderList(
        context,
        status: currentStatus,
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
        title: const Text('我的订单'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: '全部'),
            Tab(text: '待支付'),
            Tab(text: '待服务'),
            Tab(text: '已完成'),
            Tab(text: '已取消'),
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
                              leading: order.projectImage.isNotEmpty
                                  ? Image.network(order.projectImage, width: 50, height: 50, fit: BoxFit.cover)
                                  : const Icon(Icons.image),
                              title: Text(order.projectName),
                              subtitle: Text('技师: ${order.techName} | 时间: ${order.serviceTime}'),
                              trailing: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text('¥${(order.actualPrice / 100).toStringAsFixed(2)}'),
                                  Text(order.statusText, style: TextStyle(color: OrderStatusExtension.fromCode(order.status).cssClass == 'pending-section' ? Colors.orange : Colors.green)),
                                ],
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => OrderDetailPage(orderId: order.orderId),
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
