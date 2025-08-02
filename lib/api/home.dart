import 'package:flutter/material.dart';
import 'package:bookin/api/base.dart';
import 'package:bookin/api/project.dart'; // Assuming Project model is defined here
import 'package:bookin/api/teacher.dart'; // Assuming Teacher model is defined here

// Data model for a banner item
class BannerItem {
  final int id;
  final String imageUrl; // 对应API中的image字段
  final String targetUrl; // 对应API中的url字段
  final String title;
  final String subTitle;

  BannerItem({
    required this.id,
    required this.imageUrl,
    required this.targetUrl,
    required this.title,
    required this.subTitle,
  });

  factory BannerItem.fromJson(Map<String, dynamic> json) {
    return BannerItem(
      id: json['id'] as int? ?? 0,
      imageUrl: json['image']?.toString() ?? '',
      targetUrl: json['url']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      subTitle: json['subTitle']?.toString() ?? '',
    );
  }
}

// Data model for an announcement
class Announcement {
  final String id;
  final String title;
  final String content;
  final String publishDate;

  Announcement({
    required this.id,
    required this.title,
    required this.content,
    required this.publishDate,
  });

  factory Announcement.fromJson(Map<String, dynamic> json) {
    return Announcement(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      content: json['content']?.toString() ?? '',
      publishDate: json['publishDate']?.toString() ?? '',
    );
  }
}

// Data model for project list response with pagination
class ProjectListResponse {
  final List<Project> list;
  final bool hasMore;
  final int total;
  final int page;

  ProjectListResponse({
    required this.list,
    required this.hasMore,
    required this.total,
    required this.page,
  });

  factory ProjectListResponse.fromJson(Map<String, dynamic> json) {
    return ProjectListResponse(
      list: (json['list'] as List).map((e) => Project.fromJson(e)).toList(),
      hasMore: json['pagination']['hasMore'] as bool,
      total: json['pagination']['total'] as int,
      page: json['page'] as int,
    );
  }
}

// Home API class
class HomeApi {
  // Get banners
  Future<ApiResponse<List<BannerItem>>> getBanners(BuildContext context) async {
    return BaseApi.get<List<BannerItem>>(
      context,
      '/home/banners',
      fromJsonT: (json) {
        final List<dynamic> bannerList = json as List<dynamic>? ?? [];
        return bannerList.map((item) => BannerItem.fromJson(item as Map<String, dynamic>)).toList();
      },
    );
  }

  // Get hot projects
  Future<ApiResponse<List<Project>>> getHotProjects(BuildContext context) async {
    return BaseApi.post<List<Project>>(
      context,
      '/home/projects',
      {
        'category': 'all',
        'isHot': true,
        'page': 1,
        'pageSize': 5,
      },
      fromJsonT: (json) {
        final Map<String, dynamic> responseData = json as Map<String, dynamic>? ?? {};
        final List<dynamic> projectList = responseData['list'] as List<dynamic>? ?? [];
        return projectList.map((item) => Project.fromJson(item as Map<String, dynamic>)).toList();
      },
    );
  }

  // Get recommended technicians
  Future<ApiResponse<List<Teacher>>> getRecommendTechs(BuildContext context) async {
    return BaseApi.get<List<Teacher>>(
      context,
      '/home/recommend-techs',
      fromJsonT: (json) {
        final List<dynamic> techList = json as List<dynamic>? ?? [];
        return techList.map((item) => Teacher.fromJson(item as Map<String, dynamic>)).toList();
      },
    );
  }

  // Get announcements
  Future<ApiResponse<List<Announcement>>> getAnnouncements(BuildContext context) async {
    return BaseApi.get<List<Announcement>>(
      context,
      '/home/announcements',
      fromJsonT: (json) {
        final List<dynamic> announcementList = json as List<dynamic>? ?? [];
        return announcementList.map((item) => Announcement.fromJson(item as Map<String, dynamic>)).toList();
      },
    );
  }
}
