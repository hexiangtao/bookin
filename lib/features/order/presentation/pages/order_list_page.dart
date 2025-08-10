import 'package:flutter/material.dart';
import 'package:bookin/features/order/data/api/order_operations_api.dart';
import 'package:bookin/features/order/data/api/order_api.dart';
import 'package:bookin/features/order/data/models/order_constants.dart';
import 'package:bookin/features/order/presentation/pages/order_detail_page.dart'; // Import order detail page

class OrderListPage extends StatefulWidget {
  final int initialTab;
  
  const OrderListPage({super.key, this.initialTab = 0});

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
  final TextEditingController _searchController = TextEditingController();
  String _searchKeyword = '';
  bool _showSearch = false;

  // Map tab index to order status code
  // 0: All, 1: WAITING_PAYMENT, 2: WAITING_SERVICE, 3: COMPLETED, 4: CANCELED
  final List<int?> _statusMap = [null, OrderStatus.WAITING_PAYMENT.code, OrderStatus.WAITING_SERVICE.code, OrderStatus.COMPLETED.code, OrderStatus.CANCELED.code];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: _statusMap.length, 
      vsync: this,
      initialIndex: widget.initialTab,
    );
    _tabController.addListener(_handleTabSelection);
    _fetchOrders();
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabSelection);
    _tabController.dispose();
    _searchController.dispose();
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
    if (!_hasMore) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final int? currentStatus = _statusMap[_tabController.index];
      final response = await _orderApi.getOrderList(
        context, // Pass context
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

  void _handleSearch(String keyword) {
    setState(() {
      _searchKeyword = keyword;
      _orders.clear();
      _currentPage = 1;
      _hasMore = true;
      _isLoading = true;
      _errorMessage = null;
    });
    _fetchOrders();
  }

  void _toggleSearch() {
    setState(() {
      _showSearch = !_showSearch;
      if (!_showSearch) {
        _searchController.clear();
        _searchKeyword = '';
        _orders.clear();
        _currentPage = 1;
        _hasMore = true;
        _isLoading = true;
        _errorMessage = null;
      }
    });
    if (!_showSearch) {
      _fetchOrders();
    }
  }

  Future<void> _refreshOrders() async {
    setState(() {
      _orders.clear();
      _currentPage = 1;
      _hasMore = true;
      _isLoading = true;
      _errorMessage = null;
    });
    await _fetchOrders();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _showSearch
            ? TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  hintText: '搜索订单...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Colors.white70),
                ),
                style: const TextStyle(color: Colors.white),
                onSubmitted: _handleSearch,
              )
            : const Text('我的订单'),
        actions: [
          IconButton(
            icon: Icon(_showSearch ? Icons.close : Icons.search),
            onPressed: _toggleSearch,
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'refresh':
                  _refreshOrders();
                  break;
                case 'filter':
                  // TODO: Implement filter functionality
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('筛选功能开发中...')),
                  );
                  break;
              }
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem<String>(
                value: 'refresh',
                child: ListTile(
                  leading: Icon(Icons.refresh),
                  title: Text('刷新'),
                ),
              ),
              const PopupMenuItem<String>(
                value: 'filter',
                child: ListTile(
                  leading: Icon(Icons.filter_list),
                  title: Text('筛选'),
                ),
              ),
            ],
          ),
        ],
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
                            child: InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => OrderDetailPage(orderId: order.orderId),
                                  ),
                                );
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Order header
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          '订单号: ${order.orderId}',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey,
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: _getStatusColor(order.status).withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Text(
                                            NewOrderStatusExtension.fromCode(order.status).description,
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: _getStatusColor(order.status),
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    // Order content
                                    Row(
                                      children: [
                                        // Project image
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(8.0),
                                          child: order.projectImage.isNotEmpty
                                              ? Image.network(
                                                  order.projectImage,
                                                  width: 60,
                                                  height: 60,
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (context, error, stackTrace) {
                                                    return Container(
                                                      width: 60,
                                                      height: 60,
                                                      color: Colors.grey[300],
                                                      child: const Icon(Icons.image, color: Colors.grey),
                                                    );
                                                  },
                                                  loadingBuilder: (context, child, loadingProgress) {
                                                    if (loadingProgress == null) return child;
                                                    return Container(
                                                      width: 60,
                                                      height: 60,
                                                      color: Colors.grey[300],
                                                      child: const Center(
                                                        child: SizedBox(
                                                          width: 20,
                                                          height: 20,
                                                          child: CircularProgressIndicator(strokeWidth: 2),
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                )
                                              : Container(
                                                  width: 60,
                                                  height: 60,
                                                  color: Colors.grey[300],
                                                  child: const Icon(Icons.image, color: Colors.grey),
                                                ),
                                        ),
                                        const SizedBox(width: 12),
                                        // Order details
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                order.projectName,
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                '技师: ${order.techName}',
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                '服务时间: ${order.serviceTime}',
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        // Price
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.end,
                                          children: [
                                            Text(
                                              '¥${(order.actualPrice / 100).toStringAsFixed(2)}',
                                              style: const TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.red,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    // Action buttons
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: _buildActionButtons(order),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    );
        }).toList(),
      ),
    );
  }

  Color _getStatusColor(int status) {
    switch (status) {
      case 1: // WAITING_PAYMENT
        return Colors.orange;
      case 2: // WAITING_SERVICE
        return Colors.blue;
      case 3: // COMPLETED
        return Colors.green;
      case 4: // CANCELED
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  List<Widget> _buildActionButtons(OrderListItem order) {
    List<Widget> buttons = [];

    switch (order.status) {
      case 1: // WAITING_PAYMENT
        buttons.addAll([
          OutlinedButton(
            onPressed: () {
              // TODO: Cancel order
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('取消订单功能开发中...')),
              );
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.grey,
              side: const BorderSide(color: Colors.grey),
            ),
            child: const Text('取消订单'),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () {
              // TODO: Pay order
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('支付功能开发中...')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
            child: const Text('立即支付'),
          ),
        ]);
        break;
      case 2: // WAITING_SERVICE
        buttons.addAll([
          OutlinedButton(
            onPressed: () {
              // TODO: Contact technician
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('联系技师功能开发中...')),
              );
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.blue,
              side: const BorderSide(color: Colors.blue),
            ),
            child: const Text('联系技师'),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () {
              // TODO: View service progress
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('查看进度功能开发中...')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
            child: const Text('查看进度'),
          ),
        ]);
        break;
      case 3: // COMPLETED
        buttons.addAll([
          OutlinedButton(
            onPressed: () {
              // TODO: Reorder
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('再次预约功能开发中...')),
              );
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.green,
              side: const BorderSide(color: Colors.green),
            ),
            child: const Text('再次预约'),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () {
              // TODO: Comment
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('评价功能开发中...')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: const Text('评价'),
          ),
        ]);
        break;
      case 4: // CANCELED
        buttons.add(
          OutlinedButton(
            onPressed: () {
              // TODO: Delete order
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('删除订单功能开发中...')),
              );
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
              side: const BorderSide(color: Colors.red),
            ),
            child: const Text('删除订单'),
          ),
        );
        break;
    }

    return buttons;
  }
}
