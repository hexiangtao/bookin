import 'package:bookin/api/base.dart';
import 'package:flutter/material.dart'; // Import for BuildContext
import 'package:bookin/api/project.dart'; // Assuming Project model is defined here
import 'package:bookin/api/teacher.dart'; // Assuming Teacher model is defined here

// Data model for a search result item (can be Project or Teacher)
class SearchResultItem {
  final String id;
  final String type; // 'project' or 'technician'
  final String name;
  final String? cover; // For projects
  final int? price; // For projects and technicians
  final int? originalPrice; // For projects
  final int? soldCount; // For projects
  final String? desc; // For projects
  final String? avatar; // For technicians
  final String? gender; // For technicians
  final int? age; // For technicians
  final int? experience; // For technicians
  final String? rating; // For both
  final String? goodRate; // For technicians
  final List<String>? tags; // For both

  SearchResultItem({
    required this.id,
    required this.type,
    required this.name,
    this.cover,
    this.price,
    this.originalPrice,
    this.soldCount,
    this.desc,
    this.avatar,
    this.gender,
    this.age,
    this.experience,
    this.rating,
    this.goodRate,
    this.tags,
  });

  factory SearchResultItem.fromJson(Map<String, dynamic> json) {
    return SearchResultItem(
      id: json['id'].toString(),
      type: json['type'] as String,
      name: json['name'] as String,
      cover: json['cover'] as String?,
      price: json['price'] as int?,
      originalPrice: json['originalPrice'] as int?,
      soldCount: json['soldCount'] as int?,
      desc: json['desc'] as String?,
      avatar: json['avatar'] as String?,
      gender: json['gender'] as String?,
      age: json['age'] as int?,
      experience: json['experience'] as int?,
      rating: json['rating'] as String?,
      goodRate: json['goodRate'] as String?,
      tags: (json['tags'] as List?)?.map((e) => e as String).toList(),
    );
  }
}

// Data model for search response (including pagination and stats)
class SearchResponse {
  final List<SearchResultItem> list;
  final Map<String, dynamic> pagination;
  final Map<String, dynamic> stats;

  SearchResponse({
    required this.list,
    required this.pagination,
    required this.stats,
  });

  factory SearchResponse.fromJson(Map<String, dynamic> json) {
    return SearchResponse(
      list: (json['list'] as List).map((e) => SearchResultItem.fromJson(e)).toList(),
      pagination: json['pagination'] as Map<String, dynamic>,
      stats: json['stats'] as Map<String, dynamic>,
    );
  }
}

// Data model for hot keyword
class HotKeyword {
  final int id;
  final String keyword;
  final int searchCount;

  HotKeyword({
    required this.id,
    required this.keyword,
    required this.searchCount,
  });

  factory HotKeyword.fromJson(Map<String, dynamic> json) {
    return HotKeyword(
      id: json['id'] as int,
      keyword: json['keyword'] as String,
      searchCount: json['searchCount'] as int,
    );
  }
}

// Data model for search history item
class SearchHistoryItem {
  final int id;
  final String keyword;
  final String timestamp;

  SearchHistoryItem({
    required this.id,
    required this.keyword,
    required this.timestamp,
  });

  factory SearchHistoryItem.fromJson(Map<String, dynamic> json) {
    return SearchHistoryItem(
      id: json['id'] as int,
      keyword: json['keyword'] as String,
      timestamp: json['timestamp'] as String,
    );
  }
}

// Data model for search suggestion
class SearchSuggestion {
  final String keyword;
  final int searchCount;

  SearchSuggestion({
    required this.keyword,
    required this.searchCount,
  });

  factory SearchSuggestion.fromJson(Map<String, dynamic> json) {
    return SearchSuggestion(
      keyword: json['keyword'] as String,
      searchCount: json['searchCount'] as int,
    );
  }
}

class SearchApi {
  /// Perform a comprehensive search.
  Future<ApiResponse<SearchResponse>> search(BuildContext context, {
    required String keyword,
    String type = 'all', // all, project, technician
    int page = 1,
    int pageSize = 10,
    String sortBy = 'default', // default, price, rating, sales
  }) async {
    if (keyword.trim().isEmpty) {
      return ApiResponse.error('关键词不能为空');
    }
    return BaseApi.post(
      context,
      '/search',
      {
        'keyword': keyword,
        'type': type,
        'page': page,
        'pageSize': pageSize,
        'sortBy': sortBy,
      },
      fromJsonT: (json) => SearchResponse.fromJson(json),
    );
  }

  /// Get hot search keywords.
  Future<ApiResponse<List<HotKeyword>>> getHotKeywords(BuildContext context) async {
    return BaseApi.get(
      context,
      '/search/hot-keywords',
      fromJsonT: (json) => (json as List).map((e) => HotKeyword.fromJson(e)).toList(),
    );
  }

  /// Get search history.
  Future<ApiResponse<List<SearchHistoryItem>>> getSearchHistory(BuildContext context) async {
    return BaseApi.get(
      context,
      '/search/history',
      fromJsonT: (json) => (json as List).map((e) => SearchHistoryItem.fromJson(e)).toList(),
    );
  }

  /// Clear search history.
  Future<ApiResponse<void>> clearSearchHistory(BuildContext context) async {
    return BaseApi.post(context, '/search/history/clear', {});
  }

  /// Delete a single search history item.
  Future<ApiResponse<void>> deleteSearchHistory(BuildContext context, String id) async {
    if (id.isEmpty) {
      return ApiResponse.error('搜索历史ID不能为空');
    }
    return BaseApi.delete(context, '/search/history/$id');
  }

  /// Get search suggestions.
  Future<ApiResponse<List<SearchSuggestion>>> getSuggestions(BuildContext context, String keyword) async {
    if (keyword.trim().isEmpty) {
      return ApiResponse.success([]);
    }
    return BaseApi.get(
      context,
      '/search/suggestions',
      queryParameters: {'keyword': keyword},
      fromJsonT: (json) => (json as List).map((e) => SearchSuggestion.fromJson(e)).toList(),
    );
  }

  /// Save a search keyword.
  Future<ApiResponse<Map<String, dynamic>>> saveKeyword(BuildContext context, String keyword) async {
    if (keyword.trim().isEmpty) {
      return ApiResponse.success({});
    }
    return BaseApi.post(
      context,
      '/search/save-keyword',
      {'keyword': keyword},
      fromJsonT: (json) => json as Map<String, dynamic>,
    );
  }
}