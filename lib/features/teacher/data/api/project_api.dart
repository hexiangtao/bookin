import 'package:bookin/features/shared/services/base_api.dart';
import 'package:flutter/material.dart'; // Import for BuildContext

// Data model for a service project
class Project {
  final int id;
  final String name;
  final String? icon; // 项目图标URL
  final String? cover; // 保留cover字段以便兼容
  final String? tips; // Optional tips/description
  final int originalPrice; // 原价，以分为单位
  final int price; // 现价，以分为单位
  final int? num; // Number of available items/slots
  final String? tag; // e.g., "热门", "推荐"
  final int? duration; // Duration in minutes (API字段)
  final int? buyCount; // Number of times bought
  final String? desc; // 保留desc字段
  final String? description; // API中的description字段
  final double? rating; // 评分，浮点数
  final int? salesCount; // Number of sales
  final int? commentCount; // 评论数量
  final bool? isCollected; // 是否已收藏
  final String? goodRate; // Good review rate, e.g., "90%"
  final List<String> tags; // List of tags
  final List<String> images; // Project images
  final String? suitableCrowd; // 适用人群
  final String? contraindications; // 禁忌症
  final bool? isHot; // 是否为热门
  final bool? isNew; // 是否为新品
  final int? weight; // 权重
  final List<String> features; // 特色功效
  final List<String> process; // 服务流程
  final List<String> attention; // 注意事项
  final List<dynamic> recommendTechs; // 推荐技师
  final List<dynamic> recommendProjects; // 推荐项目

  Project({
    required this.id,
    required this.name,
    this.icon,
    this.cover,
    this.tips,
    required this.originalPrice,
    required this.price,
    this.num,
    this.tag,
    this.duration,
    this.buyCount,
    this.desc,
    this.description,
    this.rating,
    this.salesCount,
    this.commentCount,
    this.isCollected,
    this.goodRate,
    this.tags = const [],
    this.images = const [],
    this.suitableCrowd,
    this.contraindications,
    this.isHot,
    this.isNew,
    this.weight,
    this.features = const [],
    this.process = const [],
    this.attention = const [],
    this.recommendTechs = const [],
    this.recommendProjects = const [],
  });

  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      id: json['id'] as int? ?? 0,
      name: json['name']?.toString() ?? '',
      icon: json['icon']?.toString(),
      cover: json['cover']?.toString(), // 保留兼容性
      tips: json['tips']?.toString(),
      originalPrice: json['originalPrice'] as int? ?? 0,
      price: json['price'] as int? ?? 0,
      num: json['num'] as int?,
      tag: json['tag']?.toString(),
      duration: json['duration'] as int?,
      buyCount: json['buyCount'] as int?,
      desc: json['desc']?.toString(),
      description: json['description']?.toString(),
      rating: (json['rating'] as Object?)?.toString() != null ? double.tryParse(json['rating'].toString()) : null,
      salesCount: json['salesCount'] as int?,
      commentCount: json['commentCount'] as int?,
      isCollected: json['isCollected'] as bool?,
      goodRate: json['goodRate']?.toString(),
      tags: json['tags'] != null ? List<String>.from(json['tags'] as List) : [],
      images: json['images'] != null ? List<String>.from(json['images'] as List) : [],
      suitableCrowd: json['suitableCrowd']?.toString(),
      contraindications: json['contraindications']?.toString(),
      isHot: json['isHot'] as bool?,
      isNew: json['isNew'] as bool?,
      weight: json['weight'] as int?,
      features: json['features'] != null ? List<String>.from(json['features'] as List) : [],
      process: json['process'] != null ? List<String>.from(json['process'] as List) : [],
      attention: json['attention'] != null ? List<String>.from(json['attention'] as List) : [],
      recommendTechs: json['recommendTechs'] != null ? List<dynamic>.from(json['recommendTechs'] as List) : [],
      recommendProjects: json['recommendProjects'] != null ? List<dynamic>.from(json['recommendProjects'] as List) : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'cover': cover,
      'tips': tips,
      'originalPrice': originalPrice,
      'price': price,
      'num': num,
      'tag': tag,
      'duration': duration,
      'buyCount': buyCount,
      'desc': desc,
      'description': description,
      'rating': rating,
      'salesCount': salesCount,
      'commentCount': commentCount,
      'isCollected': isCollected,
      'goodRate': goodRate,
      'tags': tags,
      'suitableCrowd': suitableCrowd,
      'contraindications': contraindications,
      'isHot': isHot,
      'isNew': isNew,
      'weight': weight,
      'features': features,
      'process': process,
      'attention': attention,
      'recommendTechs': recommendTechs,
      'recommendProjects': recommendProjects,
    };
  }
}

class ProjectApi {
  /// Get project details by ID.
  Future<ApiResponse<Project>> getProjectDetail(BuildContext context, String id) async {
    return BaseApi.get(
      context,
      '/project/detail/$id',
      fromJsonT: (json) => Project.fromJson(json),
    );
  }

  /// Get recommended service projects.
  Future<ApiResponse<List<Project>>> getRecommendProjects(BuildContext context, {int limit = 4}) async {
    return BaseApi.get(
      context,
      '/project/recommend',
      queryParameters: {'limit': limit},
      fromJsonT: (json) => (json as List).map((e) => Project.fromJson(e)).toList(),
    );
  }
}