import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../models/project_model.dart';
import 'api_client.dart';
import 'api_endpoints.dart';
import 'network_exception.dart';

class ProjectService {
  final ApiClient _apiClient = ApiClient();

  /// 获取项目列表
  Future<List<ProjectModel>> fetchProjects({
    int page = 1,
    int pageSize = 20,
    String? category,
    String? sortBy,
    double? minPrice,
    double? maxPrice,
  }) async {
    try {
      final response = await _apiClient.get(
        ApiEndpoints.projects,
        queryParameters: {
          'page': page,
          'page_size': pageSize,
          if (category != null) 'category': category,
          if (sortBy != null) 'sort_by': sortBy,
          if (minPrice != null) 'min_price': minPrice,
          if (maxPrice != null) 'max_price': maxPrice,
        },
      );
      
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        if (data['success'] == true && data['data'] != null) {
          final List<dynamic> projectList = data['data']['items'] ?? [];
          return projectList.map((json) => ProjectModel.fromJson(json)).toList();
        }
      }
      
      throw NetworkException(
        message: '获取项目列表失败',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      throw NetworkException.fromDioException(e);
    } catch (e) {
      throw NetworkException(message: '获取项目列表失败: $e');
    }
  }

  /// 获取项目详情
  Future<ProjectModel> fetchProjectDetail(int projectId) async {
    try {
      final response = await _apiClient.get(
        ApiEndpoints.projectDetail.replaceAll('{id}', projectId.toString()),
      );
      
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        if (data['success'] == true && data['data'] != null) {
          return ProjectModel.fromJson(data['data']);
        }
      }
      
      throw NetworkException(
        message: '获取项目详情失败',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      throw NetworkException.fromDioException(e);
    } catch (e) {
      throw NetworkException(message: '获取项目详情失败: $e');
    }
  }

  /// 获取项目分类
  Future<List<Map<String, dynamic>>> fetchProjectCategories() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.projectCategories);
      
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        if (data['success'] == true && data['data'] != null) {
          return List<Map<String, dynamic>>.from(data['data']);
        }
      }
      
      throw NetworkException(
        message: '获取项目分类失败',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      throw NetworkException.fromDioException(e);
    } catch (e) {
      throw NetworkException(message: '获取项目分类失败: $e');
    }
  }

  /// 搜索项目
  Future<List<ProjectModel>> searchProjects({
    required String keyword,
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final response = await _apiClient.get(
        ApiEndpoints.search,
        queryParameters: {
          'keyword': keyword,
          'type': 'project',
          'page': page,
          'page_size': pageSize,
        },
      );
      
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        if (data['success'] == true && data['data'] != null) {
          final List<dynamic> projectList = data['data']['items'] ?? [];
          return projectList.map((json) => ProjectModel.fromJson(json)).toList();
        }
      }
      
      throw NetworkException(
        message: '搜索项目失败',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      throw NetworkException.fromDioException(e);
    } catch (e) {
      throw NetworkException(message: '搜索项目失败: $e');
    }
  }


}