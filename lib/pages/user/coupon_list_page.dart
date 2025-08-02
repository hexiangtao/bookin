import 'package:flutter/material.dart';
import 'package:bookin/api/user.dart';

class CouponListPage extends StatefulWidget {
  const CouponListPage({super.key});

  @override
  State<CouponListPage> createState() => _CouponListPageState();
}

class _CouponListPageState extends State<CouponListPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final UserApi _userApi = UserApi();
  final List<Coupon> _coupons = [];
  bool _isLoading = true;
  String? _errorMessage;
  int _currentPage = 1;
  bool _hasMore = true;

  // Map tab index to coupon status: 0-unused, 1-used, 2-expired
  final List<int?> _statusMap = [null, 0, 1, 2];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _statusMap.length, vsync: this);
    _tabController.addListener(_handleTabSelection);
    _fetchCoupons();
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
        _coupons.clear();
        _currentPage = 1;
        _hasMore = true;
        _isLoading = true;
        _errorMessage = null;
      });
      _fetchCoupons();
    }
  }

  Future<void> _fetchCoupons() async {
    if (!_hasMore || _isLoading) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final int? currentStatus = _statusMap[_tabController.index];
      final response = await _userApi.getCouponList(
        context, // Pass context
        status: currentStatus,
        current: _currentPage,
        size: 10,
      );

      if (response.success) {
        setState(() {
          _coupons.addAll(response.data ?? []);
          _hasMore = response.data?.isNotEmpty ?? false; // Assuming data.isNotEmpty implies hasMore
          _currentPage++;
        });
      } else {
        _errorMessage = response.message;
      }
    } catch (e) {
      _errorMessage = '加载优惠券失败: ${e.toString()}';
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _receiveCoupon(String couponId) async {
    setState(() {
      _isLoading = true;
    });
    try {
      final response = await _userApi.receiveCoupon(context, couponId); // Pass context
      if (response.success) {
        _showSnackBar('优惠券领取成功！');
        // Refresh the list after claiming
        setState(() {
          _coupons.clear();
          _currentPage = 1;
          _hasMore = true;
        });
        _fetchCoupons();
      } else {
        _showSnackBar('领取失败: ${response.message}');
      }
    } catch (e) {
      _showSnackBar('领取失败: ${e.toString()}');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('我的优惠券'),
      ),
      body: _isLoading && _coupons.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(_errorMessage!),
                      ElevatedButton(
                        onPressed: _fetchCoupons,
                        child: const Text('重试'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _fetchCoupons,
                  child: _coupons.isEmpty
                      ? const Center(child: Text('暂无可用优惠券'))
                      : NotificationListener<ScrollNotification>(
                          onNotification: (ScrollNotification scrollInfo) {
                            if (!_isLoading && _hasMore && scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
                              _fetchCoupons();
                              return true;
                            }
                            return false;
                          },
                          child: ListView.builder(
                            itemCount: _coupons.length + (_hasMore ? 1 : 0),
                            itemBuilder: (context, index) {
                              if (index == _coupons.length) {
                                return const Center(child: CircularProgressIndicator());
                              }
                              final coupon = _coupons[index];
                              return Card(
                                margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                                child: ListTile(
                                  title: Text(coupon.name),
                                  subtitle: Text('满${(coupon.minConsume / 100).toStringAsFixed(2)}减${(coupon.amount / 100).toStringAsFixed(2)}'),
                                  trailing: ElevatedButton(
                                    onPressed: () => _receiveCoupon(coupon.id),
                                    child: const Text('立即领取'),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                ),
    );
  }
}