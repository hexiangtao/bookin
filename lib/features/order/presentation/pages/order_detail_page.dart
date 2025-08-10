import 'package:flutter/material.dart';
import 'package:bookin/features/order/data/api/order_operations_api.dart';
import 'package:bookin/features/order/data/api/order_api.dart';
import 'package:bookin/features/order/data/models/order_constants.dart';
// import 'package:bookin/features/comment/presentation/pages/comment_submit_page.dart';
import 'package:bookin/features/order/presentation/pages/order_success_page.dart'; // Import order success page

class OrderDetailPage extends StatefulWidget {
  final String orderId;

  const OrderDetailPage({super.key, required this.orderId});

  @override
  State<OrderDetailPage> createState() => _OrderDetailPageState();
}

class _OrderDetailPageState extends State<OrderDetailPage> {
  final OrderApi _orderApi = OrderApi();
  OrderDetail? _orderDetail;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchOrderDetail();
  }

  Future<void> _fetchOrderDetail() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final response = await _orderApi.getOrderDetail(context, widget.orderId); // Pass context
      if (response.success) {
        _orderDetail = response.data;
      } else {
        _errorMessage = response.message;
      }
    } catch (e) {
      _errorMessage = '加载订单详情失败: ${e.toString()}';
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _simulatePayment() async {
    setState(() {
      _isLoading = true;
    });
    try {
      // Simulate a successful payment. In a real app, this would involve
      // calling a payment gateway API and handling its response.
      await Future.delayed(const Duration(seconds: 2)); // Simulate network delay

      // Assuming payment is successful, navigate to success page
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => OrderSuccessPage(orderId: widget.orderId),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('支付失败: ${e.toString()}'),
          duration: const Duration(seconds: 2),
        ),
      );
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
        title: const Text('订单详情'),
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
                        onPressed: _fetchOrderDetail,
                        child: const Text('重试'),
                      ),
                    ],
                  ),
                )
              : _orderDetail == null
                  ? const Center(child: Text('订单不存在'))
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Order Status
                          Card(
                            margin: const EdgeInsets.only(bottom: 16.0),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Row(
                                children: [
                                  Icon(
                                    OrderStatusExtension.fromCode(_orderDetail!.status).icon == 'clock-fill' ? Icons.access_time : Icons.check_circle,
                                    color: OrderStatusExtension.fromCode(_orderDetail!.status).cssClass == 'pending-section' ? Colors.orange : Colors.green,
                                    size: 40,
                                  ),
                                  const SizedBox(width: 16.0),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _orderDetail!.statusText,
                                        style: Theme.of(context).textTheme.headlineSmall,
                                      ),
                                      if (_orderDetail!.statusDesc != null)
                                        Text(
                                          _orderDetail!.statusDesc!,
                                          style: Theme.of(context).textTheme.bodySmall,
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // Service Info
                          Card(
                            margin: const EdgeInsets.only(bottom: 16.0),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('服务信息', style: Theme.of(context).textTheme.titleLarge),
                                  const Divider(),
                                  ListTile(
                                    leading: _orderDetail!.service['image'] != null
                                        ? ClipRRect(
                                    borderRadius: BorderRadius.circular(4.0),
                                    child: Image.network(
                                      _orderDetail!.service['image'],
                                      width: 50,
                                      height: 50,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        return Container(
                                          width: 50,
                                          height: 50,
                                          color: Colors.grey[300],
                                          child: const Icon(Icons.error, color: Colors.grey),
                                        );
                                      },
                                      loadingBuilder: (context, child, loadingProgress) {
                                        if (loadingProgress == null) return child;
                                        return Container(
                                          width: 50,
                                          height: 50,
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
                                    ),
                                  )
                                        : const Icon(Icons.image),
                                    title: Text(_orderDetail!.service['name']),
                                    subtitle: Text('时长: ${_orderDetail!.service['duration']}分钟'),
                                    trailing: Text('¥${(_orderDetail!.service['price'] / 100).toStringAsFixed(2)}'),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // Technician Info
                          Card(
                            margin: const EdgeInsets.only(bottom: 16.0),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('技师信息', style: Theme.of(context).textTheme.titleLarge),
                                  const Divider(),
                                  ListTile(
                                    leading: CircleAvatar(
                                      backgroundImage: NetworkImage(_orderDetail!.technician['avatar']),
                                    ),
                                    title: Text(_orderDetail!.technician['name']),
                                    subtitle: Text('电话: ${_orderDetail!.technician['phone']}'),
                                    trailing: Text('评分: ${_orderDetail!.technician['rating']}'),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // Address Info
                          Card(
                            margin: const EdgeInsets.only(bottom: 16.0),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('服务地址', style: Theme.of(context).textTheme.titleLarge),
                                  const Divider(),
                                  Text(_orderDetail!.address['name']),
                                  Text(_orderDetail!.address['phone']),
                                  Text(_orderDetail!.address['address']),
                                ],
                              ),
                            ),
                          ),

                          // Payment Info
                          Card(
                            margin: const EdgeInsets.only(bottom: 16.0),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('支付信息', style: Theme.of(context).textTheme.titleLarge),
                                  const Divider(),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text('原价:'),
                                      Text('¥${(_orderDetail!.payment['originalPrice'] / 100).toStringAsFixed(2)}'),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text('优惠:'),
                                      Text('-¥${(_orderDetail!.payment['discountPrice'] / 100).toStringAsFixed(2)}'),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text('实付:'),
                                      Text(
                                        '¥${(_orderDetail!.payment['actualPrice'] / 100).toStringAsFixed(2)}',
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                                      ),
                                    ],
                                  ),
                                  Text('支付方式: ${getPaymentMethodText(_orderDetail!.payment['method'])}'),
                                  if (_orderDetail!.payment['coupon'] != null)
                                    Text('优惠券: ${_orderDetail!.payment['coupon']['name']}'),
                                ],
                              ),
                            ),
                          ),

                          // Time Info
                          Card(
                            margin: const EdgeInsets.only(bottom: 16.0),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('时间信息', style: Theme.of(context).textTheme.titleLarge),
                                  const Divider(),
                                  Text('创建时间: ${_orderDetail!.times['createTime']}'),
                                  if (_orderDetail!.times['payTime'] != null)
                                    Text('支付时间: ${_orderDetail!.times['payTime']}'),
                                  if (_orderDetail!.times['serviceTime'] != null)
                                    Text('服务时间: ${_orderDetail!.times['serviceTime']}'),
                                  if (_orderDetail!.times['completeTime'] != null)
                                    Text('完成时间: ${_orderDetail!.times['completeTime']}'),
                                  if (_orderDetail!.times['cancelTime'] != null)
                                    Text('取消时间: ${_orderDetail!.times['cancelTime']}'),
                                  if (_orderDetail!.times['refundTime'] != null)
                                    Text('退款时间: ${_orderDetail!.times['refundTime']}'),
                                  if (_orderDetail!.times['expireTime'] != null)
                                    Text('过期时间: ${_orderDetail!.times['expireTime']}'),
                                ],
                              ),
                            ),
                          ),

                          // Action Buttons (e.g., Pay, Cancel, Review, Rebook)
                          // These would be conditionally rendered based on order status
                          if (_orderDetail!.status == OrderStatus.WAITING_PAYMENT.code)
                            ElevatedButton(
                              onPressed: _simulatePayment,
                              child: const Text('去支付'),
                            ),
                          if (_orderDetail!.status == OrderStatus.WAITING_SERVICE.code)
                            ElevatedButton(
                              onPressed: () {
                                // Implement cancel logic
                              },
                              child: const Text('取消订单'),
                            ),
                          if (_orderDetail!.status == OrderStatus.COMPLETED.code && (_orderDetail!.review == null || _orderDetail!.review!['id'] == null))
                            ElevatedButton(
                              onPressed: () async {
                                // final result = await Navigator.push(
                                //   context,
                                //   MaterialPageRoute(
                                //     builder: (context) => CommentSubmitPage(
                                //       orderId: widget.orderId,
                                //       targetId: _orderDetail!.service['id'], // Assuming service ID is target ID
                                //       targetType: 'project', // Or 'tech' if commenting on technician
                                //     ),
                                //   ),
                                // );
                                // if (result == true) {
                                //   _fetchOrderDetail(); // Refresh order detail after comment
                                // }
                              },
                              child: const Text('去评价'),
                            ),
                          ElevatedButton(
                            onPressed: () {
                              // Implement rebook logic
                            },
                            child: const Text('再次预约'),
                          ),
                        ],
                      ),
                    ),
    );
  }
}