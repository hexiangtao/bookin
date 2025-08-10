import 'package:flutter/material.dart';
import 'package:bookin/features/payment/data/api/wallet_api.dart'; // Assuming wallet API handles earnings/transactions

class TechnicianEarningsPage extends StatefulWidget {
  const TechnicianEarningsPage({super.key});

  @override
  State<TechnicianEarningsPage> createState() => _TechnicianEarningsPageState();
}

class _TechnicianEarningsPageState extends State<TechnicianEarningsPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final WalletApi _walletApi = WalletApi(); // Using WalletApi for transactions
  List<WalletTransaction> _earningsRecords = [];
  bool _isLoading = true;
  String? _errorMessage;
  int _currentPage = 1;
  bool _hasMore = true;

  // Map tab index to transaction type: 'all', 'income', 'withdrawal'
  final List<String?> _typeMap = [null, 'income', 'withdrawal']; // Assuming 'income' and 'withdrawal' types

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _typeMap.length, vsync: this);
    _tabController.addListener(_handleTabSelection);
    _fetchEarningsRecords();
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
        _earningsRecords.clear();
        _currentPage = 1;
        _hasMore = true;
        _isLoading = true;
        _errorMessage = null;
      });
      _fetchEarningsRecords();
    }
  }

  Future<void> _fetchEarningsRecords() async {
    if (!_hasMore || _isLoading) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final String? currentType = _typeMap[_tabController.index];
      final response = await _walletApi.getWalletTransactions(
        context, // Pass context
        type: currentType,
        page: _currentPage,
        pageSize: 10,
      );

      if (response.success) {
        setState(() {
          _earningsRecords.addAll(response.data ?? []);
          _hasMore = response.data?.isNotEmpty ?? false; // Assuming data.isNotEmpty implies hasMore
          _currentPage++;
        });
      } else {
        _errorMessage = response.message;
      }
    } catch (e) {
      _errorMessage = '加载收入明细失败: ${e.toString()}';
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
        title: const Text('收入明细'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: '全部'),
            Tab(text: '收入'),
            Tab(text: '提现'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: _typeMap.map((type) {
          return _isLoading && _earningsRecords.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : _errorMessage != null
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(_errorMessage!),
                          ElevatedButton(
                            onPressed: _fetchEarningsRecords,
                            child: const Text('重试'),
                          ),
                        ],
                      ),
                    )
                  : NotificationListener<ScrollNotification>(
                      onNotification: (ScrollNotification scrollInfo) {
                        if (!_isLoading && _hasMore && scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
                          _fetchEarningsRecords();
                          return true;
                        }
                        return false;
                      },
                      child: ListView.builder(
                        itemCount: _earningsRecords.length + (_hasMore ? 1 : 0), // Add 1 for loading indicator
                        itemBuilder: (context, index) {
                          if (index == _earningsRecords.length) {
                            return const Center(child: CircularProgressIndicator());
                          }
                          final record = _earningsRecords[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                            child: ListTile(
                              title: Text(record.description),
                              subtitle: Text(record.transactionTime),
                              trailing: Text(
                                '${record.type == 'recharge' ? '+' : '-'}¥${(record.amount / 100).toStringAsFixed(2)}',
                                style: TextStyle(
                                  color: record.type == 'recharge' ? Colors.green : Colors.red,
                                  fontWeight: FontWeight.bold,
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
}
