import 'package:bookin/features/shared/services/base_api.dart';
import 'package:flutter/material.dart'; // Import for BuildContext

// Data model for membership information
class MembershipInfo {
  final String userId;
  final bool isMember;
  final String? memberLevel;
  final String? expireDate;
  final int? points;

  MembershipInfo({
    required this.userId,
    required this.isMember,
    this.memberLevel,
    this.expireDate,
    this.points,
  });

  factory MembershipInfo.fromJson(Map<String, dynamic> json) {
    return MembershipInfo(
      userId: json['userId'] as String,
      isMember: json['isMember'] as bool,
      memberLevel: json['memberLevel'] as String?,
      expireDate: json['expireDate'] as String?,
      points: json['points'] as int?,
    );
  }
}

// Data model for creating a membership order request
class CreateMembershipOrderReq {
  final int planId;
  final String payType;

  CreateMembershipOrderReq({
    required this.planId,
    required this.payType,
  });

  Map<String, dynamic> toJson() {
    return {
      'planId': planId,
      'payType': payType,
    };
  }
}

// Data model for membership order status response
class MembershipOrderStatus {
  final String rechargeOrderNo;
  final int rechargeStatus; // 0-pending, 1-success, 2-cancelled

  MembershipOrderStatus({
    required this.rechargeOrderNo,
    required this.rechargeStatus,
  });

  factory MembershipOrderStatus.fromJson(Map<String, dynamic> json) {
    return MembershipOrderStatus(
      rechargeOrderNo: json['rechargeOrderNo'] as String,
      rechargeStatus: json['rechargeStatus'] as int,
    );
  }
}

class MembershipApi {
  /// Get membership information.
  Future<ApiResponse<MembershipInfo>> getMembershipInfo(BuildContext context) async {
    return BaseApi.get(
      context,
      '/membership/getInfo',
      fromJsonT: (json) => MembershipInfo.fromJson(json),
    );
  }

  /// Create a membership opening order.
  Future<ApiResponse<Map<String, dynamic>>> createMembershipOrder(BuildContext context, CreateMembershipOrderReq data) async {
    return BaseApi.post(
      context,
      '/membership/create',
      data.toJson(),
      fromJsonT: (json) => json as Map<String, dynamic>, // Assuming payment parameters are returned
    );
  }

  /// Query membership order status.
  Future<ApiResponse<MembershipOrderStatus>> getMembershipOrderStatus(BuildContext context, String orderNo) async {
    return BaseApi.get(
      context,
      '/membership/status/$orderNo',
      fromJsonT: (json) => MembershipOrderStatus.fromJson(json),
    );
  }
}