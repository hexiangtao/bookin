import 'package:bookin/api/base.dart';
import 'package:flutter/material.dart'; // Import for BuildContext

// Data model for Wallet Info
class WalletInfo {
  final double balance; // In currency units
  final int points;

  WalletInfo({
    required this.balance,
    required this.points,
  });

  factory WalletInfo.fromJson(Map<String, dynamic> json) {
    return WalletInfo(
      balance: (json['balance'] as num).toDouble(),
      points: json['points'] as int,
    );
  }
}

// Data model for Recharge Option
class RechargeOption {
  final String id;
  final int amount; // In cents
  final int bonus; // In cents
  final String description;

  RechargeOption({
    required this.id,
    required this.amount,
    required this.bonus,
    required this.description,
  });

  factory RechargeOption.fromJson(Map<String, dynamic> json) {
    return RechargeOption(
      id: json['id'] as String,
      amount: json['amount'] as int,
      bonus: json['bonus'] as int,
      description: json['description'] as String,
    );
  }
}

// Data model for Create Recharge Order Request
class CreateRechargeOrderReq {
  final int amount;
  final int payType; // 1: alipay, 2: wechat

  CreateRechargeOrderReq({
    required this.amount,
    required this.payType,
  });

  Map<String, dynamic> toJson() {
    return {
      'amount': amount,
      'payType': payType,
    };
  }
}

// Data model for Recharge Status
class RechargeStatus {
  final String orderNo;
  final int status; // 0-pending, 1-success, 2-cancelled

  RechargeStatus({
    required this.orderNo,
    required this.status,
  });

  factory RechargeStatus.fromJson(Map<String, dynamic> json) {
    return RechargeStatus(
      orderNo: json['orderNo'] as String,
      status: json['status'] as int,
    );
  }
}

// Data model for Wallet Transaction
class WalletTransaction {
  final String id;
  final String type; // 'recharge', 'consume', 'refund'
  final int amount; // In cents
  final String description;
  final String transactionTime;
  final String? orderId;

  WalletTransaction({
    required this.id,
    required this.type,
    required this.amount,
    required this.description,
    required this.transactionTime,
    this.orderId,
  });

  factory WalletTransaction.fromJson(Map<String, dynamic> json) {
    return WalletTransaction(
      id: json['id'] as String,
      type: json['type'] as String,
      amount: json['amount'] as int,
      description: json['description'] as String,
      transactionTime: json['transactionTime'] as String,
      orderId: json['orderId'] as String?,
    );
  }
}

class WalletApi {
  /// Get wallet balance and info.
  Future<ApiResponse<WalletInfo>> getWalletInfo(BuildContext context) async {
    return BaseApi.get(
      context,
      '/wallet/info',
      fromJsonT: (json) => WalletInfo.fromJson(json),
    );
  }

  /// Get recharge options (tiers).
  Future<ApiResponse<List<RechargeOption>>> getRechargeOptions(BuildContext context) async {
    return BaseApi.get(
      context,
      '/wallet/recharge/options',
      fromJsonT: (json) => (json as List).map((e) => RechargeOption.fromJson(e)).toList(),
    );
  }

  /// Create a recharge order.
  Future<ApiResponse<Map<String, dynamic>>> createRechargeOrder(BuildContext context, CreateRechargeOrderReq data) async {
    return BaseApi.post(
      context,
      '/wallet/recharge/create',
      data.toJson(),
      fromJsonT: (json) => json as Map<String, dynamic>, // Assuming payment parameters are returned
    );
  }

  /// Query recharge order status.
  Future<ApiResponse<RechargeStatus>> getRechargeStatus(BuildContext context, String orderNo) async {
    return BaseApi.get(
      context,
      '/wallet/recharge/status/$orderNo',
      fromJsonT: (json) => RechargeStatus.fromJson(json),
    );
  }

  /// Get wallet transaction records.
  Future<ApiResponse<List<WalletTransaction>>> getWalletTransactions(BuildContext context, {
    String? type,
    int page = 1,
    int pageSize = 10,
  }) async {
    final Map<String, dynamic> query = {
      'current': page,
      'size': pageSize,
    };
    if (type != null) query['type'] = type;

    return BaseApi.post(
      context,
      '/wallet/transactions',
      query,
      fromJsonT: (json) => (json['list'] as List).map((e) => WalletTransaction.fromJson(e)).toList(),
    );
  }
}