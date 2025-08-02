import 'package:flutter/material.dart';
import 'package:bookin/api/technician.dart';
import 'package:bookin/api/order_constants.dart';
import 'package:bookin/api/order_operations.dart';
import 'package:bookin/pages/technician/technician_order_complete_page.dart'; // Import complete page

class TechnicianOrderDetailPage extends StatefulWidget {
  final String orderId;

  const TechnicianOrderDetailPage({super.key, required this.orderId});

  @override
  State<TechnicianOrderDetailPage> createState() => _TechnicianOrderDetailPageState();
}

class _TechnicianOrderDetailPageState extends State<TechnicianOrderDetailPage> {
  final TechnicianApi _technicianApi = TechnicianApi();
  TechnicianOrder? _orderDetail;
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
      final response = await _technicianApi.getOrderDetail(context, widget.orderId); // Pass context
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
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    getDetailedOrderStatusText(Order(
                                      orderId: _orderDetail!.orderId,
                                      status: _orderDetail!.status,
                                      technicianOperate: _orderDetail!.technicianOperate,
                                      customerPhone: _orderDetail!.customerPhone,
                                      customerName: _orderDetail!.customerName,
                                      refundInfo: _orderDetail!.refundInfo,
                                    )),
                                    style: Theme.of(context).textTheme.headlineSmall,
                                  ),
                                  const SizedBox(height: 8),
                                  Text('订单号: ${_orderDetail!.orderId}'),
                                  Text('项目: ${_orderDetail!.projectName}'),
                                  Text('服务时间: ${_orderDetail!.serviceTime}'),
                                  Text('服务地址: ${_orderDetail!.address}'),
                                  Text('客户: ${_orderDetail!.customerName} (${_orderDetail!.customerPhone})'),
                                  Text('金额: ¥${(_orderDetail!.actualPrice / 100).toStringAsFixed(2)}'),
                                ],
                              ),
                            ),
                          ),

                          // Action Buttons (Technician Operations)
                          // These buttons would trigger actions like accept, depart, arrive, start service, complete service
                          // and would need to integrate with location and upload services.
                          if (_orderDetail!.status == NewOrderStatus.WAIT_ACCEPT.code)
                            ElevatedButton(
                              onPressed: () {
                                // handleOrderAction(_orderDetail!, TechnicianOperate.ACCEPT, () => _fetchOrderDetail(), (error) => print(error));
                                print('接单操作');
                              },
                              child: const Text('接单'),
                            ),
                          if (_orderDetail!.status == NewOrderStatus.PENDING_SERVICE.code && _orderDetail!.technicianOperate < TechnicianOperate.DEPART.code)
                            ElevatedButton(
                              onPressed: () {
                                // handleOrderAction(_orderDetail!, TechnicianOperate.DEPART, () => _fetchOrderDetail(), (error) => print(error));
                                print('出发操作');
                              },
                              child: const Text('出发'),
                            ),
                          if (_orderDetail!.status == NewOrderStatus.PENDING_SERVICE.code && _orderDetail!.technicianOperate == TechnicianOperate.DEPART.code)
                            ElevatedButton(
                              onPressed: () {
                                // handleOrderAction(_orderDetail!, TechnicianOperate.ARRIVE, () => _fetchOrderDetail(), (error) => print(error));
                                print('到达操作');
                              },
                              child: const Text('到达'),
                            ),
                          if (_orderDetail!.status == NewOrderStatus.PENDING_SERVICE.code && _orderDetail!.technicianOperate == TechnicianOperate.ARRIVE.code)
                            ElevatedButton(
                              onPressed: () {
                                // handleOrderAction(_orderDetail!, TechnicianOperate.START_SERVICE, () => _fetchOrderDetail(), (error) => print(error));
                                print('开始服务操作');
                              },
                              child: const Text('开始服务'),
                            ),
                          if (_orderDetail!.status == NewOrderStatus.SERVICE.code)
                            ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => TechnicianOrderCompletePage(orderId: widget.orderId),
                                  ),
                                );
                              },
                              child: const Text('完成服务'),
                            ),

                          // Refund Info (if applicable)
                          if (_orderDetail!.refundInfo != null)
                            Card(
                              margin: const EdgeInsets.only(top: 16.0),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('退款信息', style: Theme.of(context).textTheme.titleLarge),
                                    const Divider(),
                                    Text('退款金额: ¥${(_orderDetail!.refundInfo!['refundAmount'] / 100).toStringAsFixed(2)}'),
                                    Text('退款原因: ${_orderDetail!.refundInfo!['reason']}'),
                                    Text('退款状态: ${getRefundStatusText(RefundStatusExtension.fromCode(_orderDetail!.refundInfo!['status']))}'),
                                    // Add refund action buttons if status is pending
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
    );
  }
}