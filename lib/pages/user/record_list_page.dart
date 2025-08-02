import 'package:flutter/material.dart';
import 'package:bookin/api/user.dart';

class RecordListPage extends StatefulWidget {
  const RecordListPage({super.key});

  @override
  State<RecordListPage> createState() => _RecordListPageState();
}

class _RecordListPageState extends State<RecordListPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final UserApi _userApi = UserApi();
  final List<RecordItem> _records = [];
  bool _isLoading = true;
  String? _errorMessage;
  int _currentPage = 1;
  bool _hasMore = true;

  // Map tab index to record type: 'consume' or 'refund'
  final List<String> _typeMap = ['consume', 'refund'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _typeMap.length, vsync: this);
    _tabController.addListener(_handleTabSelection);
    _fetchRecords();
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
        _records.clear();
        _currentPage = 1;
        _hasMore = true;
        _isLoading = true;
        _errorMessage = null;
      });
      _fetchRecords();
    }
  }

  Future<void> _fetchRecords() async {
    if (!_hasMore || _isLoading) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final String currentType = _typeMap[_tabController.index];
      final response = await _userApi.getRecords(
        context, // Pass context
        currentType,
        page: _currentPage,
        size: 10,
      );

      if (response.success) {
        setState(() {
          _records.addAll(response.data ?? []);
          _hasMore = response.data?.isNotEmpty ?? false; // Assuming data.isNotEmpty implies hasMore
          _currentPage++;
        });
      } else {
        _errorMessage = response.message;
      }
    } catch (e) {
      _errorMessage = '加载记录失败: ${e.toString()}';
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
        title: const Text('消费记录'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: '消费'),
            Tab(text: '退款'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: _typeMap.map((type) {
          return _isLoading && _records.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : _errorMessage != null
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(_errorMessage!),
                          ElevatedButton(
                            onPressed: _fetchRecords,
                            child: const Text('重试'),
                          ),
                        ],
                      ),
                    )
                  : NotificationListener<ScrollNotification>(
                      onNotification: (ScrollNotification scrollInfo) {
                        if (!_isLoading && _hasMore && scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
                          _fetchRecords();
                          return true;
                        }
                        return false;
                      },
                      child: ListView.builder(
                        itemCount: _records.length + (_hasMore ? 1 : 0), // Add 1 for loading indicator
                        itemBuilder: (context, index) {
                          if (index == _records.length) {
                            return const Center(child: CircularProgressIndicator());
                          }
                          final record = _records[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                            child: ListTile(
                              title: Text(record.type),
                              subtitle: Text(record.date),
                              trailing: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    '${record.type == '消费' ? '-' : '+'}¥${(record.amount / 100).toStringAsFixed(2)}',
                                    style: TextStyle(
                                      color: record.type == '消费' ? Colors.red : Colors.green,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(record.status),
                                ],
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
