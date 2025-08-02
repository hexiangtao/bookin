import 'package:flutter/material.dart';
import 'package:bookin/api/user.dart';

class CouponSelectionPage extends StatefulWidget {
  const CouponSelectionPage({super.key});

  @override
  State<CouponSelectionPage> createState() => _CouponSelectionPageState();
}

class _CouponSelectionPageState extends State<CouponSelectionPage> {
  final UserApi _userApi = UserApi();
  List<Coupon> _availableCoupons = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchAvailableCoupons();
  }

  Future<void> _fetchAvailableCoupons() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      // Assuming getAvailableCoupons fetches coupons that can be used for current order
      final response = await _userApi.getAvailableCoupons(context, current: 1, size: 100); // Pass context
      if (response.success) {
        _availableCoupons = response.data ?? [];
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
        title: const Text('选择优惠券'),
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
                      : ListView.builder(
                          itemCount: _availableCoupons.length,
                          itemBuilder: (context, index) {
                            final coupon = _availableCoupons[index];
                            return Card(
                              margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                              child: ListTile(
                                title: Text(coupon.name),
                                subtitle: Text('满${(coupon.minConsume / 100).toStringAsFixed(2)}减${(coupon.amount / 100).toStringAsFixed(2)}'),
                                trailing: Text('有效期至: ${coupon.expireTime}'),
                                onTap: () {
                                  Navigator.pop(context, coupon); // Return selected coupon
                                },
                              ),
                            );
                          },
                        ),
                ),
    );
  }
}