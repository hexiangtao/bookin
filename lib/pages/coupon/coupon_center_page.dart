import 'package:flutter/material.dart';
import 'package:bookin/api/user.dart';

class CouponCenterPage extends StatefulWidget {
  const CouponCenterPage({super.key});

  @override
  State<CouponCenterPage> createState() => _CouponCenterPageState();
}

class _CouponCenterPageState extends State<CouponCenterPage> {
  final UserApi _userApi = UserApi();
  List<Coupon> _availableCoupons = [];
  bool _isLoading = true;
  String? _errorMessage;
  int _currentPage = 1;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    _fetchAvailableCoupons();
  }

  Future<void> _fetchAvailableCoupons() async {
    if (!_hasMore || _isLoading) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await _userApi.getAvailableCoupons(
        context, // Pass context
        current: _currentPage,
        size: 10,
      );

      if (response.success) {
        setState(() {
          _availableCoupons.addAll(response.data ?? []);
          _hasMore = response.data?.isNotEmpty ?? false; // Assuming data.isNotEmpty implies hasMore
          _currentPage++;
        });
      } else {
        _errorMessage = response.message;
      }
    } catch (e) {
      _errorMessage = '加载可用优惠券失败: ${e.toString()}';
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
          _availableCoupons.clear();
          _currentPage = 1;
          _hasMore = true;
        });
        _fetchAvailableCoupons();
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
        title: const Text('优惠券中心'),
      ),
      body: _isLoading && _availableCoupons.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(_errorMessage!),
                      ElevatedButton(
                        onPressed: _fetchAvailableCoupons,
                        child: const Text('重试'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _fetchAvailableCoupons,
                  child: _availableCoupons.isEmpty
                      ? const Center(child: Text('暂无可用优惠券'))
                      : NotificationListener<ScrollNotification>(
                          onNotification: (ScrollNotification scrollInfo) {
                            if (!_isLoading && _hasMore && scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
                              _fetchAvailableCoupons();
                              return true;
                            }
                            return false;
                          },
                          child: ListView.builder(
                            itemCount: _availableCoupons.length + (_hasMore ? 1 : 0),
                            itemBuilder: (context, index) {
                              if (index == _availableCoupons.length) {
                                return const Center(child: CircularProgressIndicator());
                              }
                              final coupon = _availableCoupons[index];
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