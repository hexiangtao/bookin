import 'package:bookin/features/shared/services/base_api.dart';
import 'package:flutter/material.dart'; // Import for BuildContext

// Data model for a project item within an order
class OrderProjectItem {
  final String projectId;
  final int num;

  OrderProjectItem({
    required this.projectId,
    required this.num,
  });

  Map<String, dynamic> toJson() {
    return {
      'projectId': projectId,
      'num': num,
    };
  }
}

// Data model for creating an order request
class CreateOrderReq {
  final String techId;
  final String serviceTime;
  final String travelMode;
  final String addressId;
  final String? remark;
  final int originalTotalAmount;
  final int actualTotalAmount;
  final String paymentMethod;
  final String? couponId;
  final List<OrderProjectItem> projectItems;

  CreateOrderReq({
    required this.techId,
    required this.serviceTime,
    required this.travelMode,
    required this.addressId,
    this.remark,
    required this.originalTotalAmount,
    required this.actualTotalAmount,
    required this.paymentMethod,
    this.couponId,
    required this.projectItems,
  });

  Map<String, dynamic> toJson() {
    return {
      'techId': techId,
      'serviceTime': serviceTime,
      'travelMode': travelMode,
      'addressId': addressId,
      if (remark != null) 'remark': remark,
      'originalTotalAmount': originalTotalAmount,
      'actualTotalAmount': actualTotalAmount,
      'paymentMethod': paymentMethod,
      if (couponId != null) 'couponId': couponId,
      'projectItems': projectItems.map((e) => e.toJson()).toList(),
    };
  }
}

// Data model for order detail (simplified, based on order.js transformOrderData)
class OrderDetail {
  final String id;
  final int status;
  final String statusText;
  final String? statusDesc;
  final Map<String, dynamic> service;
  final Map<String, dynamic> technician;
  final Map<String, dynamic> address;
  final Map<String, dynamic> payment;
  final Map<String, dynamic>? review;
  final Map<String, dynamic> times;

  OrderDetail({
    required this.id,
    required this.status,
    required this.statusText,
    this.statusDesc,
    required this.service,
    required this.technician,
    required this.address,
    required this.payment,
    this.review,
    required this.times,
  });

  factory OrderDetail.fromJson(Map<String, dynamic> json) {
    return OrderDetail(
      id: json['id'] as String,
      status: json['status'] as int,
      statusText: json['statusText'] as String,
      statusDesc: json['statusDesc'] as String?,
      service: json['service'] as Map<String, dynamic>,
      technician: json['technician'] as Map<String, dynamic>,
      address: json['address'] as Map<String, dynamic>,
      payment: json['payment'] as Map<String, dynamic>,
      review: json['review'] as Map<String, dynamic>?,
      times: json['times'] as Map<String, dynamic>,
    );
  }
}

// Data model for order list item (simplified)
class OrderListItem {
  final String orderId;
  final int status;
  final String statusText;
  final String projectName;
  final String projectImage;
  final String techName;
  final String serviceTime;
  final int actualPrice;

  OrderListItem({
    required this.orderId,
    required this.status,
    required this.statusText,
    required this.projectName,
    required this.projectImage,
    required this.techName,
    required this.serviceTime,
    required this.actualPrice,
  });

  factory OrderListItem.fromJson(Map<String, dynamic> json) {
    return OrderListItem(
      orderId: json['orderId'] as String,
      status: json['status'] as int,
      statusText: json['statusText'] as String,
      projectName: json['projectName'] as String,
      projectImage: json['projectImage'] as String,
      techName: json['techName'] as String,
      serviceTime: json['serviceTime'] as String,
      actualPrice: json['actualPrice'] as int,
    );
  }
}

// Data model for payment creation response
class PaymentCreateResponse {
  final String orderStatus;
  final bool isBalancePaySuccess;
  final String payMethod;
  final Map<String, dynamic>? prepayInfo; // For WeChat Pay
  final String? paymentUrl; // For Alipay

  PaymentCreateResponse({
    required this.orderStatus,
    required this.isBalancePaySuccess,
    required this.payMethod,
    this.prepayInfo,
    this.paymentUrl,
  });

  factory PaymentCreateResponse.fromJson(Map<String, dynamic> json) {
    return PaymentCreateResponse(
      orderStatus: json['orderStatus'] as String,
      isBalancePaySuccess: json['isBalancePaySuccess'] as bool? ?? false,
      payMethod: json['payMethod'] as String,
      prepayInfo: json['prepayInfo'] as Map<String, dynamic>?,
      paymentUrl: json['paymentUrl'] as String?,
    );
  }
}

// Data model for refund amount query response
class RefundAmountResponse {
  final int refundableAmount; // In cents
  final String reason;

  RefundAmountResponse({
    required this.refundableAmount,
    required this.reason,
  });

  factory RefundAmountResponse.fromJson(Map<String, dynamic> json) {
    return RefundAmountResponse(
      refundableAmount: json['refundableAmount'] as int,
      reason: json['reason'] as String,
    );
  }
}

// Data model for apply refund request
class ApplyRefundReq {
  final String orderId;
  final int refundAmount;
  final String reason;
  final List<String>? images;

  ApplyRefundReq({
    required this.orderId,
    required this.refundAmount,
    required this.reason,
    this.images,
  });

  Map<String, dynamic> toJson() {
    return {
      'orderId': orderId,
      'refundAmount': refundAmount,
      'reason': reason,
      if (images != null) 'images': images,
    };
  }
}

// Data model for submit review request
class SubmitReviewReq {
  final String orderId;
  final int rating;
  final String comment;
  final List<String>? tags;
  final Map<String, int>? dimensions;
  final bool isAnonymous;
  final List<String>? images;

  SubmitReviewReq({
    required this.orderId,
    required this.rating,
    required this.comment,
    this.tags,
    this.dimensions,
    this.isAnonymous = false,
    this.images,
  });

  Map<String, dynamic> toJson() {
    return {
      'orderId': orderId,
      'rating': rating,
      'comment': comment,
      if (tags != null) 'tags': tags,
      if (dimensions != null) 'dimensions': dimensions,
      'isAnonymous': isAnonymous,
      if (images != null) 'images': images,
    };
  }
}

class OrderApi {
  /// Create an order.
  Future<ApiResponse<Map<String, dynamic>>> create(BuildContext context, CreateOrderReq data) async {
    return BaseApi.post(
      context,
      '/order/create',
      data.toJson(),
      fromJsonT: (json) => json as Map<String, dynamic>, // Assuming a generic response with orderId
    );
  }

  /// Get order list.
  Future<ApiResponse<List<OrderListItem>>> getOrderList(BuildContext context, {
    int? status,
    int page = 1,
    int pageSize = 10,
  }) async {
    final Map<String, dynamic> params = {
      'page': page,
      'pageSize': pageSize,
    };
    if (status != null) {
      params['status'] = status;
    }
    return BaseApi.post(
      context,
      '/order/list',
      params,
      fromJsonT: (json) => (json['list'] as List).map((e) => OrderListItem.fromJson(e)).toList(),
    );
  }

  /// Get order detail.
  Future<ApiResponse<OrderDetail>> getOrderDetail(BuildContext context, String orderId) async {
    return BaseApi.get(
      context,
      '/order/detail/$orderId',
      fromJsonT: (json) => OrderDetail.fromJson(json),
    );
  }

  /// Cancel an order.
  Future<ApiResponse<void>> cancel(BuildContext context, String orderId, String reason) async {
    return BaseApi.post(context, '/order/cancel', {'orderId': orderId, 'reason': reason});
  }

  /// Review an order.
  Future<ApiResponse<void>> review(BuildContext context, String orderId, Map<String, dynamic> data) async {
    return BaseApi.post(context, '/order/review', {'orderId': orderId, ...data});
  }

  /// Pay for an order (unified payment creation).
  Future<ApiResponse<PaymentCreateResponse>> createPayment(
    BuildContext context, String orderId, String paymentMethod, {Map<String, dynamic>? extras}
  ) async {
    return BaseApi.post(
      context,
      '/order/payment/create',
      {
        'orderId': orderId,
        'paymentMethod': paymentMethod,
        ...?extras,
      },
      fromJsonT: (json) => PaymentCreateResponse.fromJson(json),
    );
  }

  /// Confirm an order (e.g., user confirms service completion).
  Future<ApiResponse<void>> confirm(BuildContext context, String orderId) async {
    return BaseApi.post(context, '/order/confirm', {'orderId': orderId});
  }

  /// Query refundable amount for an order.
  Future<ApiResponse<RefundAmountResponse>> queryRefundAmount(BuildContext context, String orderId) async {
    return BaseApi.get(
      context,
      '/order/queryRefundAmount/$orderId',
      fromJsonT: (json) => RefundAmountResponse.fromJson(json),
    );
  }

  /// Apply for a refund.
  Future<ApiResponse<void>> applyRefund(BuildContext context, ApplyRefundReq data) async {
    return BaseApi.post(context, '/order/refund', data.toJson());
  }

  /// Confirm service completion (redundant with `confirm`? Check backend).
  Future<ApiResponse<void>> confirmService(BuildContext context, String orderId) async {
    return BaseApi.post(context, '/order/confirm', {'orderId': orderId});
  }

  /// Submit a review (more detailed than `review`).
  Future<ApiResponse<void>> submitReview(BuildContext context, SubmitReviewReq data) async {
    return BaseApi.post(context, '/order/review', data.toJson());
  }

  /// Rebook an order.
  Future<ApiResponse<void>> rebookOrder(BuildContext context, String orderId) async {
    return BaseApi.post(context, '/order/rebook', {'orderId': orderId});
  }

  /// Get service info (project detail).
  Future<ApiResponse<Map<String, dynamic>>> getServiceInfo(BuildContext context, String serviceId) async {
    return BaseApi.get(
      context,
      '/project/detail/$serviceId',
      fromJsonT: (json) => json as Map<String, dynamic>,
    );
  }

  /// Get technician info.
  Future<ApiResponse<Map<String, dynamic>>> getTechnicianInfo(BuildContext context, String technicianId) async {
    return BaseApi.get(
      context,
      '/tech/detail/$technicianId',
      fromJsonT: (json) => json as Map<String, dynamic>,
    );
  }

  /// Delete an order.
  Future<ApiResponse<void>> deleteOrder(BuildContext context, String orderId) async {
    return BaseApi.delete(context, '/order/$orderId');
  }

  /// Get user address list.
  Future<ApiResponse<List<dynamic>>> getUserAddressList(BuildContext context) async {
    return BaseApi.get(
      context,
      '/user/address/list',
      fromJsonT: (json) => json as List, // Assuming a list of generic objects
    );
  }

  /// Get user coupons.
  Future<ApiResponse<List<dynamic>>> getUserCoupons(BuildContext context, List<String> projectIds, int amount) async {
    return BaseApi.post(
      context,
      '/user/coupon/available',
      {'projectIds': projectIds, 'amount': amount},
      fromJsonT: (json) => json as List, // Assuming a list of generic objects
    );
  }

  /// Get user balance.
  Future<ApiResponse<Map<String, dynamic>>> getUserBalance(BuildContext context) async {
    return BaseApi.get(
      context,
      '/wallet/balance',
      fromJsonT: (json) => json as Map<String, dynamic>,
    );
  }

  /// Get technician available times.
  Future<ApiResponse<Map<String, dynamic>>> getTechAvailableTimes(BuildContext context, String technicianId, String date) async {
    return BaseApi.post(
      context,
      '/teacher/available-times',
      {'technicianId': technicianId, 'date': date},
      fromJsonT: (json) => json as Map<String, dynamic>,
    );
  }

  /// Get travel fee information.
  Future<ApiResponse<Map<String, dynamic>>> getTravelFeeInfo(BuildContext context, String addressId, String technicianId) async {
    return BaseApi.post(
      context,
      '/order/travel-fee',
      {'addressId': addressId, 'technicianId': technicianId},
      fromJsonT: (json) => json as Map<String, dynamic>,
    );
  }

  /// Calculate order price (including membership discount).
  Future<ApiResponse<Map<String, dynamic>>> calculateOrderPrice(BuildContext context, Map<String, dynamic> data) async {
    return BaseApi.post(
      context,
      '/order/price/calculate',
      data,
      fromJsonT: (json) => json as Map<String, dynamic>,
    );
  }
}