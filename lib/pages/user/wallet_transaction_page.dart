import 'package:flutter/material.dart';
import 'package:bookin/api/wallet.dart';

class WalletTransactionPage extends StatefulWidget {
  final String? initialType; // 'recharge', 'consume', 'refund', or null for all
  
  const WalletTransactionPage({super.key, this.initialType});

  @override
  State<WalletTransactionPage> createState() => _WalletTransactionPageState();
}

class _WalletTransactionPageState extends State<WalletTransactionPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final WalletApi _walletApi = WalletApi();
  final List<List<WalletTransaction>> _transactionsByTab = [[], [], [], []]; // All, Recharge, Consume, Refund
  final List<bool> _isLoadingByTab = [true, true, true, true];
  final List<String?> _errorMessageByTab = [null, null, null, null];
  final List<int> _currentPageByTab = [1, 1, 1, 1];
  final List<bool> _hasMoreByTab = [true, true, true, true];
  
  // Map tab index to transaction type: null for all, specific types for others
  final List<String?> _typeMap = [null, 'recharge', 'consume', 'refund'];
  final List<String> _tabTitles = ['全部', '充值', '消费', '退款'];

  @override
  void initState() {
    super.initState();
    
    // Determine initial tab based on initialType
    int initialIndex = 0;
    if (widget.initialType != null) {
      final typeIndex = _typeMap.indexOf(widget.initialType);
      if (typeIndex != -1) {
        initialIndex = typeIndex;
      }
    }
    
    _tabController = TabController(length: _typeMap.length, vsync: this, initialIndex: initialIndex);
    _tabController.addListener(_handleTabSelection);
    _fetchTransactions();
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabSelection);
    _tabController.dispose();
    super.dispose();
  }

  void _handleTabSelection() {
    if (_tabController.indexIsChanging) {
      _fetchTransactions();
    }
  }

  Future<void> _fetchTransactions({bool isRefresh = false}) async {
    final int currentTabIndex = _tabController.index;
    
    if (!_hasMoreByTab[currentTabIndex] && !isRefresh) return;
    if (_isLoadingByTab[currentTabIndex] && !isRefresh) return;

    setState(() {
      _isLoadingByTab[currentTabIndex] = true;
      if (isRefresh) {
        _errorMessageByTab[currentTabIndex] = null;
        _transactionsByTab[currentTabIndex].clear();
        _currentPageByTab[currentTabIndex] = 1;
        _hasMoreByTab[currentTabIndex] = true;
      }
    });

    try {
      final String? currentType = _typeMap[currentTabIndex];
      final response = await _walletApi.getWalletTransactions(
        context,
        type: currentType,
        page: _currentPageByTab[currentTabIndex],
        pageSize: 15,
      );

      if (response.success) {
        final newTransactions = response.data ?? [];
        setState(() {
          if (isRefresh) {
            _transactionsByTab[currentTabIndex] = newTransactions;
          } else {
            _transactionsByTab[currentTabIndex].addAll(newTransactions);
          }
          _hasMoreByTab[currentTabIndex] = newTransactions.length >= 15; // Assume no more if less than pageSize
          _currentPageByTab[currentTabIndex]++;
        });
      } else {
        setState(() {
          _errorMessageByTab[currentTabIndex] = response.message;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessageByTab[currentTabIndex] = '加载交易记录失败: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoadingByTab[currentTabIndex] = false;
      });
    }
  }

  Future<void> _onRefresh() async {
    await _fetchTransactions(isRefresh: true);
  }

  String _getAmountPrefix(String type) {
    switch (type) {
      case 'recharge':
      case 'refund':
        return '+';
      case 'consume':
        return '-';
      default:
        return '';
    }
  }

  Color _getAmountColor(String type) {
    switch (type) {
      case 'recharge':
      case 'refund':
        return Colors.green;
      case 'consume':
        return Colors.red;
      default:
        return Colors.black;
    }
  }

  String _getTypeDisplayName(String type) {
    switch (type) {
      case 'recharge':
        return '充值';
      case 'consume':
        return '消费';
      case 'refund':
        return '退款';
      default:
        return type;
    }
  }

  Widget _buildTransactionList(int tabIndex) {
    final transactions = _transactionsByTab[tabIndex];
    final isLoading = _isLoadingByTab[tabIndex];
    final errorMessage = _errorMessageByTab[tabIndex];
    final hasMore = _hasMoreByTab[tabIndex];

    if (isLoading && transactions.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('加载中...'),
          ],
        ),
      );
    }

    if (errorMessage != null && transactions.isEmpty) {
      return Center(
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
              errorMessage,
              style: TextStyle(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _fetchTransactions(isRefresh: true),
              child: const Text('重试'),
            ),
          ],
        ),
      );
    }

    if (transactions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              '暂无${_tabTitles[tabIndex]}记录',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '您还没有任何${_tabTitles[tabIndex]}记录~',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[400],
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: NotificationListener<ScrollNotification>(
        onNotification: (ScrollNotification scrollInfo) {
          if (!isLoading && hasMore && scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
            _fetchTransactions();
            return true;
          }
          return false;
        },
        child: ListView.builder(
          padding: const EdgeInsets.all(8.0),
          itemCount: transactions.length + (hasMore ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == transactions.length) {
              return Container(
                padding: const EdgeInsets.all(16.0),
                alignment: Alignment.center,
                child: isLoading
                    ? const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          SizedBox(width: 12),
                          Text('加载中...', style: TextStyle(color: Colors.grey)),
                        ],
                      )
                    : const Text(
                        '上拉加载更多',
                        style: TextStyle(color: Colors.grey),
                      ),
              );
            }

            final transaction = transactions[index];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 4.0),
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _getTypeDisplayName(transaction.type),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        Text(
                          '${_getAmountPrefix(transaction.type)}¥${(transaction.amount / 100).toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: _getAmountColor(transaction.type),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '订单号：${transaction.orderId ?? '--'}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '已完成',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.green[700],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '时间',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        Text(
                          transaction.transactionTime,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    if (transaction.description.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        transaction.description,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('交易记录'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Theme.of(context).primaryColor,
          unselectedLabelColor: Colors.grey[600],
          indicatorColor: Theme.of(context).primaryColor,
          indicatorWeight: 3,
          tabs: _tabTitles.map((title) => Tab(text: title)).toList(),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: List.generate(
          _typeMap.length,
          (index) => _buildTransactionList(index),
        ),
      ),
    );
  }
}