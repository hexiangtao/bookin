import 'package:flutter/material.dart';
import 'dart:convert';
import '../../utils/request.dart';
import '../../../features/shared/services/base_api.dart';
import '../widgets/app_state_widgets.dart';

/// API服务基类
/// 统一API调用的错误处理和响应格式
abstract class BaseApiService {
  /// 执行API请求并返回统一的状态
  Future<AppState<T>> executeRequest<T>(
    Future<ApiResponse<T>> Function() request, {
    String? errorMessage,
  }) async {
    try {
      final response = await request();
      
      if (response.success) {
        if (response.data == null) {
          return const AppState.empty();
        }
        return AppState.data(response.data!);
      } else {
        return AppState.error(response.message ?? errorMessage ?? '请求失败');
      }
    } catch (e) {
      debugPrint('API请求异常: $e');
      return AppState.error(_getErrorMessage(e, errorMessage));
    }
  }

  /// 执行API请求并返回列表状态
  Future<AppState<List<T>>> executeListRequest<T>(
    Future<ApiResponse<List<T>>> Function() request, {
    String? errorMessage,
  }) async {
    try {
      final response = await request();
      
      if (response.success) {
        final data = response.data ?? [];
        if (data.isEmpty) {
          return const AppState.empty();
        }
        return AppState.data(data);
      } else {
        return AppState.error(response.message ?? errorMessage ?? '请求失败');
      }
    } catch (e) {
      debugPrint('API请求异常: $e');
      return AppState.error(_getErrorMessage(e, errorMessage));
    }
  }

  /// 执行简单的API请求（不需要返回数据）
  Future<ApiResponse<void>> executeSimpleRequest(
    Future<ApiResponse<void>> Function() request,
  ) async {
    try {
      return await request();
    } catch (e) {
      debugPrint('API请求异常: $e');
      return ApiResponse<void>(
        code: ApiCode.FAIL,
        success: false,
        message: _getErrorMessage(e),
        data: null,
      );
    }
  }

  /// 获取错误信息
  String _getErrorMessage(dynamic error, [String? defaultMessage]) {
    if (error is String) {
      return error;
    }
    
    // 网络错误处理
    final errorString = error.toString().toLowerCase();
    if (errorString.contains('socket') || 
        errorString.contains('network') ||
        errorString.contains('connection')) {
      return '网络连接失败，请检查网络设置';
    }
    
    if (errorString.contains('timeout')) {
      return '请求超时，请稍后重试';
    }
    
    if (errorString.contains('format')) {
      return '数据格式错误';
    }
    
    return defaultMessage ?? '请求失败，请稍后重试';
  }

  /// GET请求封装
  Future<ApiResponse<T>> get<T>(
    BuildContext context,
    String path, {
    Map<String, dynamic>? params,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      return await BaseApi.get(context, path, queryParameters: params, fromJsonT: fromJson);
    } catch (e) {
      return ApiResponse<T>(
        code: ApiCode.FAIL,
        success: false,
        message: _getErrorMessage(e),
        data: null,
      );
    }
  }

  /// POST请求封装
  Future<ApiResponse<T>> post<T>(
    BuildContext context,
    String path, {
    Map<String, dynamic>? data,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      return await BaseApi.post(context, path, data, fromJsonT: fromJson);
    } catch (e) {
      return ApiResponse<T>(
        code: ApiCode.FAIL,
        success: false,
        message: _getErrorMessage(e),
        data: null,
      );
    }
  }

  /// PUT请求封装
  Future<ApiResponse<T>> put<T>(
    BuildContext context,
    String path, {
    Map<String, dynamic>? data,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      return await BaseApi.put(context, path, data, fromJsonT: fromJson);
    } catch (e) {
      return ApiResponse<T>(
        code: ApiCode.FAIL,
        success: false,
        message: _getErrorMessage(e),
        data: null,
      );
    }
  }

  /// DELETE请求封装
  Future<ApiResponse<T>> delete<T>(
    BuildContext context,
    String path, {
    Map<String, dynamic>? params,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      return await BaseApi.delete(context, path, queryParameters: params, fromJsonT: fromJson);
    } catch (e) {
      return ApiResponse<T>(
        code: ApiCode.FAIL,
        success: false,
        message: _getErrorMessage(e),
        data: null,
      );
    }
  }
}

/// 分页请求结果
class PaginatedResult<T> {
  const PaginatedResult({
    required this.items,
    required this.hasMore,
    required this.currentPage,
    required this.totalPages,
    required this.totalCount,
  });

  final List<T> items;
  final bool hasMore;
  final int currentPage;
  final int totalPages;
  final int totalCount;

  factory PaginatedResult.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) itemFromJson,
  ) {
    final items = (json['items'] as List<dynamic>? ?? [])
        .map((item) => itemFromJson(item as Map<String, dynamic>))
        .toList();
    
    return PaginatedResult<T>(
      items: items,
      hasMore: json['hasMore'] as bool? ?? false,
      currentPage: json['currentPage'] as int? ?? 1,
      totalPages: json['totalPages'] as int? ?? 1,
      totalCount: json['totalCount'] as int? ?? 0,
    );
  }
}