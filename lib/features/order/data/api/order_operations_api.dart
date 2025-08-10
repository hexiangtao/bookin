import 'package:flutter/material.dart';
import 'package:bookin/features/technician/data/api/technician_api.dart'; // Assuming technicianApi is defined here
import 'package:bookin/features/order/data/models/order_constants.dart';
// import 'package:bookin/utils/location_service.dart'; // Assuming locationService
// import 'package:bookin/utils/upload_service.dart'; // Assuming uploadService

// Placeholder for Order model, replace with actual Order model from order.dart
class Order {
  final String orderId;
  int status;
  final int technicianOperate;
  final String? customerPhone;
  final String? customerName;
  final Map<String, dynamic>? refundInfo;

  Order({
    required this.orderId,
    required this.status,
    required this.technicianOperate,
    this.customerPhone,
    this.customerName,
    this.refundInfo,
  });
}

/// Technician operation types
enum TechnicianOperate {
  ACCEPT, // 10
  DEPART, // 20
  ARRIVE, // 30
  START_SERVICE, // 40
  COMPLETE_SERVICE, // 50
  UNKNOWN,
}

extension TechnicianOperateExtension on TechnicianOperate {
  int get code {
    switch (this) {
      case TechnicianOperate.ACCEPT: return 10;
      case TechnicianOperate.DEPART: return 20;
      case TechnicianOperate.ARRIVE: return 30;
      case TechnicianOperate.START_SERVICE: return 40;
      case TechnicianOperate.COMPLETE_SERVICE: return 50;
      case TechnicianOperate.UNKNOWN: return -1;
    }
  }

  String get name {
    switch (this) {
      case TechnicianOperate.ACCEPT: return '接单';
      case TechnicianOperate.DEPART: return '出发';
      case TechnicianOperate.ARRIVE: return '已到达';
      case TechnicianOperate.START_SERVICE: return '开始服务';
      case TechnicianOperate.COMPLETE_SERVICE: return '完成服务';
      case TechnicianOperate.UNKNOWN: return '未知操作';
    }
  }

  String get successText {
    switch (this) {
      case TechnicianOperate.ACCEPT: return '接单成功';
      case TechnicianOperate.DEPART: return '已出发';
      case TechnicianOperate.ARRIVE: return '已确认到达';
      case TechnicianOperate.START_SERVICE: return '服务已开始';
      case TechnicianOperate.COMPLETE_SERVICE: return '服务已完成';
      case TechnicianOperate.UNKNOWN: return '操作成功';
    }
  }

  static TechnicianOperate fromCode(int code) {
    switch (code) {
      case 10: return TechnicianOperate.ACCEPT;
      case 20: return TechnicianOperate.DEPART;
      case 30: return TechnicianOperate.ARRIVE;
      case 40: return TechnicianOperate.START_SERVICE;
      case 50: return TechnicianOperate.COMPLETE_SERVICE;
      default: return TechnicianOperate.UNKNOWN;
    }
  }
}

/// Refund status
enum RefundStatus {
  PENDING, // 0
  APPROVED, // 10
  REJECTED, // 20
  UNKNOWN,
}

extension RefundStatusExtension on RefundStatus {
  int get code {
    switch (this) {
      case RefundStatus.PENDING: return 0;
      case RefundStatus.APPROVED: return 10;
      case RefundStatus.REJECTED: return 20;
      case RefundStatus.UNKNOWN: return -1;
    }
  }

  String get text {
    switch (this) {
      case RefundStatus.PENDING: return '待审核';
      case RefundStatus.APPROVED: return '已通过';
      case RefundStatus.REJECTED: return '已拒绝';
      case RefundStatus.UNKNOWN: return '未知状态';
    }
  }

  String get cssClass {
    switch (this) {
      case RefundStatus.PENDING: return 'pending';
      case RefundStatus.APPROVED: return 'approved';
      case RefundStatus.REJECTED: return 'rejected';
      case RefundStatus.UNKNOWN: return 'pending';
    }
  }

  static RefundStatus fromCode(int code) {
    switch (code) {
      case 0: return RefundStatus.PENDING;
      case 10: return RefundStatus.APPROVED;
      case 20: return RefundStatus.REJECTED;
      default: return RefundStatus.UNKNOWN;
    }
  }
}

/// Get detailed order status text (combines with technician operation status)
String getDetailedOrderStatusText(Order order) {
  final baseStatus = NewOrderStatusExtension.fromCode(order.status).description;

  // If it's pending service and there's a technician operation record, show detailed status
  if (order.status == NewOrderStatus.PENDING_SERVICE.code && order.technicianOperate != TechnicianOperate.UNKNOWN.code) {
    final operateText = TechnicianOperateExtension.fromCode(order.technicianOperate).name;
    if (operateText.isNotEmpty) {
      return '$baseStatus · $operateText';
    }
  }
  return baseStatus;
}

/// Get technician operation status text
String getTechnicianOperateText(int technicianOperate) {
  return TechnicianOperateExtension.fromCode(technicianOperate).name;
}

/// Get order status corresponding CSS class name
String getOrderStatusClass(int status) {
  return NewOrderStatusExtension.fromCode(status).cssClass;
}

/// Get operation name
String getOperationName(TechnicianOperate operateType) {
  return operateType.name;
}

/// Get operation success prompt text
String getOperationSuccessText(TechnicianOperate operateType) {
  return operateType.successText;
}

// Placeholder for UI related functions (showLoading, showToast, showModal, showActionSheet, navigateTo, makePhoneCall)
// These will be implemented using Flutter's UI components and navigation.

// Example of how executeOrderOperation might look (simplified)
Future<void> executeOrderOperation(
  BuildContext context, {
  required Order order,
  required TechnicianOperate operateType,
  required Map<String, String> location,
  String? remark,
  List<String>? photoUrls,
}) async {
  // uni.showLoading({
  //   title: '处理中...'
  // });

  try {
    final response = await TechnicianApi().updateOrderStatus(
      context, // Add BuildContext as first parameter
      orderId: order.orderId,
      operateType: operateType.code,
      longitude: location['longitude']!,
      latitude: location['latitude']!,
      remark: remark,
      photoUrls: photoUrls,
    );

    if (response.success) {
      // updateLocalOrderStatus(order, operateType);
      // uni.showToast({
      //   title: getOperationSuccessText(operateType),
      //   icon: 'success'
      // });
      print('Operation successful: ${getOperationSuccessText(operateType)}');
    } else {
      throw Exception(response.message);
    }
  } catch (error) {
    print('Order operation failed: $error');
    // uni.showToast({
    //   title: errorMessage,
    //   icon: 'none'
    // });
    rethrow;
  } finally {
    // uni.hideLoading();
  }
}

// Placeholder for updateLocalOrderStatus
void updateLocalOrderStatus(Order order, TechnicianOperate operateType) {
  // This would typically update the state of the order object locally
  // For example:
  // order.status = NewOrderStatus.fromCode(statusMap[operateType.code]!); // Assuming statusMap is defined
  // order.technicianOperate = operateType.code;
  // order.technicianOperateTime = DateTime.now().toIso8601String();
}

// Placeholder for handleOrderAction
Future<void> handleOrderAction(Order order, TechnicianOperate operateType, Function onSuccess, Function onError) async {
  // This function would involve UI interactions (e.g., showing modals, action sheets)
  // and location services, which are Flutter-specific.
  // For now, it's a placeholder.
  print('handleOrderAction called for order: ${order.orderId}, operateType: ${operateType.name}');
  // Example: await getCurrentLocation();
  // Example: await chooseAndUploadPhotos();
  // Example: await executeOrderOperation(...);
}

// Placeholder for rejectOrder
void rejectOrder(Order order, Function onSuccess) {
  print('Rejecting order: ${order.orderId}');
  // Implement UI confirmation and API call
}

// Placeholder for contactCustomer
void contactCustomer(Order order) {
  print('Contacting customer: ${order.customerPhone}');
  // Implement phone call functionality (e.g., using url_launcher package)
}

// Placeholder for viewOrderDetail
void viewOrderDetail(Order order) {
  print('Viewing order detail for: ${order.orderId}');
  // Implement navigation to order detail page
}

/// Get refund status text
String getRefundStatusText(RefundStatus refundStatus) {
  return refundStatus.text;
}

/// Get refund status corresponding CSS class name
String getRefundStatusClass(RefundStatus refundStatus) {
  return refundStatus.cssClass;
}

// Placeholder for approveRefund
Future<void> approveRefund(Order order, Function onSuccess) async {
  print('Approving refund for order: ${order.orderId}');
  // Implement UI confirmation and API call
}

// Placeholder for rejectRefund
Future<void> rejectRefund(Order order, Function onSuccess) async {
  print('Rejecting refund for order: ${order.orderId}');
  // Implement UI confirmation and API call
}

// Placeholder for blockCustomer
Future<void> blockCustomer(Order order, Function onSuccess) async {
  print('Blocking customer for order: ${order.orderId}');
  // Implement UI confirmation and API call
}
