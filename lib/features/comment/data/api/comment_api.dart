import 'package:bookin/features/shared/services/base_api.dart';
import 'package:flutter/material.dart'; // Import for BuildContext

// Data model for a single comment reply
class CommentReply {
  final String id;
  final String userId;
  final String userName;
  final String userAvatar;
  final String content;
  final String createTime;
  final bool isOfficial;

  CommentReply({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userAvatar,
    required this.content,
    required this.createTime,
    required this.isOfficial,
  });

  factory CommentReply.fromJson(Map<String, dynamic> json) {
    return CommentReply(
      id: json['id'].toString(),
      userId: json['userId'] as String,
      userName: json['userName'] as String,
      userAvatar: json['userAvatar'] as String,
      content: json['content'] as String,
      createTime: json['createTime'] as String,
      isOfficial: json['isOfficial'] as bool,
    );
  }
}

// Data model for a single comment
class Comment {
  final String id;
  final String userId;
  final String userName;
  final String userAvatar;
  final String targetId;
  final String targetType;
  final int rating;
  final String content;
  final List<String> images;
  final String createTime;
  final int likes;
  final bool isLiked;
  final int replyCount;
  final List<CommentReply> replies;

  Comment({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userAvatar,
    required this.targetId,
    required this.targetType,
    required this.rating,
    required this.content,
    required this.images,
    required this.createTime,
    required this.likes,
    required this.isLiked,
    required this.replyCount,
    required this.replies,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'].toString(),
      userId: json['userId'] as String,
      userName: json['userName'] as String,
      userAvatar: json['userAvatar'] as String,
      targetId: json['targetId'] as String,
      targetType: json['targetType'] as String,
      rating: json['rating'] as int,
      content: json['content'] as String,
      images: (json['images'] as List).map((e) => e as String).toList(),
      createTime: json['createTime'] as String,
      likes: json['likes'] as int,
      isLiked: json['isLiked'] as bool,
      replyCount: json['replyCount'] as int,
      replies: (json['replies'] as List).map((e) => CommentReply.fromJson(e)).toList(),
    );
  }
}

// Data model for comment statistics
class CommentStats {
  final int total;
  final String averageRating;
  final Map<String, int> ratingDistribution;

  CommentStats({
    required this.total,
    required this.averageRating,
    required this.ratingDistribution,
  });

  factory CommentStats.fromJson(Map<String, dynamic> json) {
    return CommentStats(
      total: json['total'] as int,
      averageRating: json['averageRating'] as String,
      ratingDistribution: (json['ratingDistribution'] as Map<String, dynamic>).map((k, v) => MapEntry(k, v as int)),
    );
  }
}

// Data model for comment list response (including pagination and stats)
class CommentListResponse {
  final List<Comment> list;
  final Map<String, dynamic> pagination;
  final CommentStats stats;

  CommentListResponse({
    required this.list,
    required this.pagination,
    required this.stats,
  });

  factory CommentListResponse.fromJson(Map<String, dynamic> json) {
    return CommentListResponse(
      list: (json['list'] as List).map((e) => Comment.fromJson(e)).toList(),
      pagination: json['pagination'] as Map<String, dynamic>,
      stats: CommentStats.fromJson(json['stats']),
    );
  }
}

// Data model for submitting a comment
class SubmitCommentReq {
  final String targetId;
  final String targetType;
  final String orderId;
  final int rating;
  final String content;
  final List<String> images;

  SubmitCommentReq({
    required this.targetId,
    required this.targetType,
    required this.orderId,
    required this.rating,
    required this.content,
    this.images = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'targetId': targetId,
      'targetType': targetType,
      'orderId': orderId,
      'rating': rating,
      'content': content,
      'images': images,
    };
  }
}

// Data model for replying to a comment
class ReplyCommentReq {
  final String commentId;
  final String content;

  ReplyCommentReq({
    required this.commentId,
    required this.content,
  });

  Map<String, dynamic> toJson() {
    return {
      'commentId': commentId,
      'content': content,
    };
  }
}

// Data model for pending comment orders
class PendingCommentOrder {
  final String orderId;
  final String projectId;
  final String projectName;
  final String projectImage;
  final String techId;
  final String techName;
  final String orderTime;
  final int price;

  PendingCommentOrder({
    required this.orderId,
    required this.projectId,
    required this.projectName,
    required this.projectImage,
    required this.techId,
    required this.techName,
    required this.orderTime,
    required this.price,
  });

  factory PendingCommentOrder.fromJson(Map<String, dynamic> json) {
    return PendingCommentOrder(
      orderId: json['orderId'] as String,
      projectId: json['projectId'] as String,
      projectName: json['projectName'] as String,
      projectImage: json['projectImage'] as String,
      techId: json['techId'] as String,
      techName: json['techName'] as String,
      orderTime: json['orderTime'] as String,
      price: json['price'] as int,
    );
  }
}

class CommentApi {
  /// Get comment list
  Future<ApiResponse<CommentListResponse>> getCommentList(BuildContext context, {
    required String targetId,
    String targetType = 'project',
    int page = 1,
    int pageSize = 10,
    String sortBy = 'time-desc',
    int rating = 0,
  }) async {
    final Map<String, dynamic> params = {
      'targetId': targetId,
      'targetType': targetType,
      'page': page,
      'pageSize': pageSize,
      'sortBy': sortBy,
      'rating': rating,
    };
    return BaseApi.get(
      context,
      '/comment/list',
      queryParameters: params,
      fromJsonT: (json) => CommentListResponse.fromJson(json),
    );
  }

  /// Submit a comment
  Future<ApiResponse<Comment>> submitComment(BuildContext context, SubmitCommentReq data) async {
    return BaseApi.post(
      context,
      '/comment/submit',
      data.toJson(),
      fromJsonT: (json) => Comment.fromJson(json),
    );
  }

  /// Toggle like/unlike for a comment
  Future<ApiResponse<Map<String, dynamic>>> toggleLike(BuildContext context, String commentId, bool isLike) async {
    return BaseApi.post(
      context,
      '/comment/like',
      {'commentId': commentId, 'isLike': isLike},
      fromJsonT: (json) => json as Map<String, dynamic>,
    );
  }

  /// Reply to a comment
  Future<ApiResponse<CommentReply>> replyComment(BuildContext context, ReplyCommentReq data) async {
    return BaseApi.post(
      context,
      '/comment/reply',
      data.toJson(),
      fromJsonT: (json) => CommentReply.fromJson(json),
    );
  }

  /// Get list of orders pending comment
  Future<ApiResponse<List<PendingCommentOrder>>> getPendingCommentOrders(BuildContext context) async {
    return BaseApi.get(
      context,
      '/comment/pending-orders',
      fromJsonT: (json) => (json as List).map((e) => PendingCommentOrder.fromJson(e)).toList(),
    );
  }
}