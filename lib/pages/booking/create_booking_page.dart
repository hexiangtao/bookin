import 'package:flutter/material.dart';
import 'package:bookin/api/booking.dart';
import 'package:bookin/api/address.dart' as address_api;
import 'package:bookin/api/user.dart';
import 'package:bookin/api/order.dart';
import 'package:bookin/api/project.dart';
import 'package:bookin/pages/order/order_success_page.dart';
import 'package:bookin/pages/user/address_selection_page.dart';
import 'package:bookin/pages/user/coupon_selection_page.dart'; // Import coupon selection page

class CreateBookingPage extends StatefulWidget {
  final String techId;
  final String projectId;
  final String date;
  final String startTime;

  const CreateBookingPage({
    super.key,
    required this.techId,
    required this.projectId,
    required this.date,
    required this.startTime,
  });

  @override
  State<CreateBookingPage> createState() => _CreateBookingPageState();
}

class _CreateBookingPageState extends State<CreateBookingPage> {
  final BookingApi _bookingApi = BookingApi();
  final address_api.AddressApi _addressApi = address_api.AddressApi();
  final UserApi _userApi = UserApi();
  final OrderApi _orderApi = OrderApi();
  final ProjectApi _projectApi = ProjectApi();

  address_api.Address? _selectedAddress;
  List<address_api.Address> _addresses = [];
  List<Coupon> _availableCoupons = [];
  Coupon? _selectedCoupon;

  Project? _projectDetail;

  bool _isLoading = true;
  String? _errorMessage;

  // Order calculation results
  int _originalPrice = 0;
  int _discountPrice = 0;
  int _actualPrice = 0;

  @override
  void initState() {
    super.initState();
    _fetchInitialData();
  }

  Future<void> _fetchInitialData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      // Fetch project details
      final projectResponse = await _projectApi.getProjectDetail(context, widget.projectId); // Pass context
      if (projectResponse.success) {
        _projectDetail = projectResponse.data;
      } else {
        _errorMessage = projectResponse.message;
        setState(() { _isLoading = false; });
        return;
      }

      // Fetch addresses
      final addressResponse = await _addressApi.getAddressList(context); // Pass context
      if (addressResponse.success) {
        _addresses = addressResponse.data ?? [];
        _selectedAddress = _addresses.isNotEmpty ? _addresses.firstWhere((addr) => addr.isDefault, orElse: () => _addresses.first) : null;
      } else {
        _errorMessage = addressResponse.message;
        setState(() { _isLoading = false; });
        return;
      }

      // Fetch available coupons (assuming project ID and amount are needed)
      // For now, use a dummy amount for coupon calculation
      final couponResponse = await _userApi.getAvailableCoupons(context, current: 1, size: 10); // Pass context
      if (couponResponse.success) {
        _availableCoupons = couponResponse.data ?? [];
      } else {
        _errorMessage = couponResponse.message;
        setState(() { _isLoading = false; });
        return;
      }

      // Calculate initial order price
      await _calculateOrderPrice();

    } catch (e) {
      _errorMessage = '加载数据失败: ${e.toString()}';
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _calculateOrderPrice() async {
    if (_projectDetail == null) return;

    final List<Map<String, dynamic>> projectItems = [
      {
        'projectId': _projectDetail!.id,
        'num': 1, // Assuming 1 unit for now
      }
    ];

    final Map<String, dynamic> data = {
      'projectItems': projectItems,
      'travelFee': 0, // Assuming no travel fee for now, or fetch it separately
    };
    if (_selectedCoupon != null) {
      data['couponId'] = _selectedCoupon!.id;
    }

    try {
      final response = await _orderApi.calculateOrderPrice(context, data); // Pass context
      if (response.success && response.data != null) {
        setState(() {
          _originalPrice = response.data!['originalPrice'] as int;
          _discountPrice = response.data!['discountPrice'] as int;
          _actualPrice = response.data!['actualPrice'] as int;
        });
      } else {
        _errorMessage = response.message;
      }
    } catch (e) {
      _errorMessage = '计算价格失败: ${e.toString()}';
    }
  }

  Future<void> _createBooking() async {
    if (_selectedAddress == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('请选择服务地址')));
      return;
    }
    if (_projectDetail == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('项目信息缺失')));
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final createBookingReq = CreateBookingReq(
        techId: widget.techId,
        projectId: widget.projectId,
        date: widget.date,
        startTime: widget.startTime,
        addressId: _selectedAddress!.id,
        couponId: _selectedCoupon?.id,
        remarks: '', // Add a text field for remarks if needed
      );

      final response = await _bookingApi.createBooking(context, createBookingReq); // Pass context
      if (response.success) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('预约成功！')));
        // Navigate to order success page
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => OrderSuccessPage(orderId: response.data!['orderId']),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('预约失败: ${response.message}')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('预约失败: ${e.toString()}')));
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
        title: const Text('确认预约'),
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
                        onPressed: _fetchInitialData,
                        child: const Text('重试'),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Project Info
                      Card(
                        margin: const EdgeInsets.only(bottom: 16.0),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('服务项目', style: Theme.of(context).textTheme.titleLarge),
                              const Divider(),
                              ListTile(
                                leading: _projectDetail?.cover != null
                                    ? Image.network(_projectDetail!.cover!, width: 50, height: 50, fit: BoxFit.cover)
                                    : const Icon(Icons.medical_services),
                                title: Text(_projectDetail?.name ?? '未知项目'),
                                subtitle: Text('时长: ${_projectDetail?.duration ?? '-'}分钟'),
                                trailing: Text('¥${(_projectDetail?.price ?? 0 / 100).toStringAsFixed(2)}'),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Booking Time
                      Card(
                        margin: const EdgeInsets.only(bottom: 16.0),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('预约时间', style: Theme.of(context).textTheme.titleLarge),
                              const Divider(),
                              Text('日期: ${widget.date}'),
                              Text('时间: ${widget.startTime}'),
                            ],
                          ),
                        ),
                      ),

                      // Address Selection
                      Card(
                        margin: const EdgeInsets.only(bottom: 16.0),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('服务地址', style: Theme.of(context).textTheme.titleLarge),
                              const Divider(),
                              if (_selectedAddress != null)
                                ListTile(
                                  title: Text(_selectedAddress!.name),
                                  subtitle: Text('${_selectedAddress!.phone}\n${_selectedAddress!.address}'),
                                  trailing: const Icon(Icons.edit),
                                  onTap: () async {
                                    final result = await Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => const AddressSelectionPage()),
                                    );
                                    if (result != null) {
                                      setState(() {
                                        _selectedAddress = result as address_api.Address;
                                      });
                                      _calculateOrderPrice();
                                    }
                                  },
                                ) else
                                  ListTile(
                                    title: const Text('请选择服务地址'),
                                    trailing: const Icon(Icons.add),
                                    onTap: () async {
                                      final result = await Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) => const AddressSelectionPage()),
                                      );
                                      if (result != null) {
                                        setState(() {
                                          _selectedAddress = result as address_api.Address;
                                        });
                                        _calculateOrderPrice();
                                      }
                                    },
                                  ),
                            ],
                          ),
                        ),
                      ),

                      // Coupon Selection
                      Card(
                        margin: const EdgeInsets.only(bottom: 16.0),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('优惠券', style: Theme.of(context).textTheme.titleLarge),
                              const Divider(),
                              ListTile(
                                title: Text(_selectedCoupon?.name ?? '不使用优惠券'),
                                trailing: const Icon(Icons.arrow_forward_ios),
                                onTap: () async {
                                  final result = await Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => const CouponSelectionPage()),
                                  );
                                  if (result != null && result is Coupon) {
                                    setState(() {
                                      _selectedCoupon = result;
                                    });
                                    _calculateOrderPrice();
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Price Details
                      Card(
                        margin: const EdgeInsets.only(bottom: 16.0),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('费用明细', style: Theme.of(context).textTheme.titleLarge),
                              const Divider(),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('项目原价'),
                                  Text('¥${(_originalPrice / 100).toStringAsFixed(2)}'),
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('优惠'),
                                  Text('-¥${(_discountPrice / 100).toStringAsFixed(2)}'),
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('实付金额', style: TextStyle(fontWeight: FontWeight.bold)),
                                  Text(
                                    '¥${(_actualPrice / 100).toStringAsFixed(2)}',
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.redAccent),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Submit Button
                      ElevatedButton(
                        onPressed: _createBooking,
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 50),
                        ),
                        child: const Text('提交订单'),
                      ),
                    ],
                  ),
                ),
    );
  }
}