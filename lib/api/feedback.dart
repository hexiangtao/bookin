import 'package:bookin/api/base.dart';
import 'package:flutter/material.dart'; // Import for BuildContext

// Data model for submitting feedback
class SubmitFeedbackReq {
  final int typeCode;
  final String typeName;
  final String content;
  final List<String> images;
  final String contact;
  final String userId;

  SubmitFeedbackReq({
    required this.typeCode,
    required this.typeName,
    required this.content,
    this.images = const [],
    required this.contact,
    required this.userId,
  });

  Map<String, dynamic> toJson() {
    return {
      'typeCode': typeCode,
      'typeName': typeName,
      'content': content,
      'images': images,
      'contact': contact,
      'userId': userId,
    };
  }
}

// Data model for feedback type
class FeedbackType {
  final int code;
  final String name;

  FeedbackType({
    required this.code,
    required this.name,
  });

  factory FeedbackType.fromJson(Map<String, dynamic> json) {
    return FeedbackType(
      code: json['code'] as int,
      name: json['name'] as String,
    );
  }
}

// Data model for feedback history item
class FeedbackHistoryItem {
  final String id;
  final int typeCode;
  final String typeName;
  final String content;
  final List<String> images;
  final String contact;
  final String userId;
  final String createTime;
  final String status;
  final String? replyContent;
  final String? replyTime;

  FeedbackHistoryItem({
    required this.id,
    required this.typeCode,
    required this.typeName,
    required this.content,
    required this.images,
    required this.contact,
    required this.userId,
    required this.createTime,
    required this.status,
    this.replyContent,
    this.replyTime,
  });

  factory FeedbackHistoryItem.fromJson(Map<String, dynamic> json) {
    return FeedbackHistoryItem(
      id: json['id'].toString(),
      typeCode: json['typeCode'] as int,
      typeName: json['typeName'] as String,
      content: json['content'] as String,
      images: (json['images'] as List).map((e) => e as String).toList(),
      contact: json['contact'] as String,
      userId: json['userId'] as String,
      createTime: json['createTime'] as String,
      status: json['status'] as String,
      replyContent: json['replyContent'] as String?,
      replyTime: json['replyTime'] as String?,
    );
  }
}

class FeedbackApi {
  /// Submit feedback.
  Future<ApiResponse<void>> submit(BuildContext context, SubmitFeedbackReq data) async {
    return BaseApi.post(context, '/feedback/submit', data.toJson());
  }

  /// Get list of feedback types.
  Future<ApiResponse<List<FeedbackType>>> getTypes(BuildContext context) async {
    return BaseApi.get(
      context,
      '/feedback/types',
      fromJsonT: (json) => (json as List).map((e) => FeedbackType.fromJson(e)).toList(),
    );
  }

  /// Get user feedback history.
  Future<ApiResponse<List<FeedbackHistoryItem>>> getHistory(BuildContext context, {
    int page = 1,
    int pageSize = 10,
  }) async {
    return BaseApi.get(
      context,
      '/feedback/history',
      queryParameters: {'page': page, 'pageSize': pageSize},
      fromJsonT: (json) => (json as List).map((e) => FeedbackHistoryItem.fromJson(e)).toList(),
    );
  }
}