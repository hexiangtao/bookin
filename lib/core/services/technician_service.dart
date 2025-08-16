import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../models/technician_model.dart';
import 'api_client.dart';
import 'api_endpoints.dart';
import 'network_exception.dart';

class TechnicianService {
  final ApiClient _apiClient = ApiClient();

  /// 获取技师列表
  Future<List<TechnicianModel>> fetchTechnicians({
    int page = 1,
    int pageSize = 20,
    String? category,
    String? location,
    String? sortBy,
  }) async {
    try {
      // 使用POST请求，与H5项目保持一致
      final response = await _apiClient.post(
        ApiEndpoints.technicians,
        data: {
          'page': page,
          'pageSize': pageSize,
          if (category != null) 'category': category,
          if (location != null) 'location': location,
          if (sortBy != null) 'sort_by': sortBy,
        },
      );
      
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        if ((data['code'] == 0 || data['code'] == '0' || data['success'] == true) && data['data'] != null) {
          // H5项目返回的数据结构是 data.list
          final List<dynamic> technicianList = data['data']['list'] ?? data['data']['items'] ?? [];
          return technicianList.map((json) => TechnicianModel.fromJson(json)).toList();
        }
      }
      
      throw NetworkException(
        message: '获取技师列表失败',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      throw NetworkException.fromDioException(e);
    } catch (e) {
      throw NetworkException(message: '获取技师列表失败: $e');
    }
  }

  /// 获取技师详情
  Future<TechnicianModel> fetchTechnicianDetail(int technicianId) async {
    try {
      final response = await _apiClient.get(
        ApiEndpoints.technicianDetail.replaceAll('{id}', technicianId.toString()),
      );
      
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        if (data['success'] == true && data['data'] != null) {
          return TechnicianModel.fromJson(data['data']);
        }
      }
      
      throw NetworkException(
        message: '获取技师详情失败',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      throw NetworkException.fromDioException(e);
    } catch (e) {
      throw NetworkException(message: '获取技师详情失败: $e');
    }
  }

  /// 获取技师评价
  Future<List<Map<String, dynamic>>> fetchTechnicianReviews(
    int technicianId, {
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final response = await _apiClient.get(
        ApiEndpoints.technicianReviews.replaceAll('{id}', technicianId.toString()),
        queryParameters: {
          'page': page,
          'page_size': pageSize,
        },
      );
      
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        if (data['success'] == true && data['data'] != null) {
          return List<Map<String, dynamic>>.from(data['data']['items'] ?? []);
        }
      }
      
      throw NetworkException(
        message: '获取技师评价失败',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      throw NetworkException.fromDioException(e);
    } catch (e) {
      throw NetworkException(message: '获取技师评价失败: $e');
    }
  }

  /// 搜索技师
  Future<List<TechnicianModel>> searchTechnicians({
    required String keyword,
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final response = await _apiClient.get(
        ApiEndpoints.search,
        queryParameters: {
          'keyword': keyword,
          'type': 'technician',
          'page': page,
          'page_size': pageSize,
        },
      );
      
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        if (data['success'] == true && data['data'] != null) {
          final List<dynamic> technicianList = data['data']['items'] ?? [];
          return technicianList.map((json) => TechnicianModel.fromJson(json)).toList();
        }
      }
      
      throw NetworkException(
        message: '搜索技师失败',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      throw NetworkException.fromDioException(e);
    } catch (e) {
      throw NetworkException(message: '搜索技师失败: $e');
    }
  }


}