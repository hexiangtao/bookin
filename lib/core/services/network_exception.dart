import 'package:dio/dio.dart';

class NetworkException implements Exception {
  final String message;
  final int? statusCode;
  final String? errorCode;
  final dynamic data;

  const NetworkException({
    required this.message,
    this.statusCode,
    this.errorCode,
    this.data,
  });

  factory NetworkException.fromDioException(DioException dioException) {
    switch (dioException.type) {
      case DioExceptionType.connectionTimeout:
        return const NetworkException(
          message: '连接超时，请检查网络连接',
          statusCode: -1,
          errorCode: 'CONNECTION_TIMEOUT',
        );
      case DioExceptionType.sendTimeout:
        return const NetworkException(
          message: '请求超时，请稍后重试',
          statusCode: -1,
          errorCode: 'SEND_TIMEOUT',
        );
      case DioExceptionType.receiveTimeout:
        return const NetworkException(
          message: '响应超时，请稍后重试',
          statusCode: -1,
          errorCode: 'RECEIVE_TIMEOUT',
        );
      case DioExceptionType.badResponse:
        return NetworkException._handleStatusCode(dioException.response!);
      case DioExceptionType.cancel:
        return const NetworkException(
          message: '请求已取消',
          statusCode: -1,
          errorCode: 'REQUEST_CANCELLED',
        );
      case DioExceptionType.connectionError:
        return const NetworkException(
          message: '网络连接失败，请检查网络设置',
          statusCode: -1,
          errorCode: 'CONNECTION_ERROR',
        );
      case DioExceptionType.badCertificate:
        return const NetworkException(
          message: '证书验证失败',
          statusCode: -1,
          errorCode: 'BAD_CERTIFICATE',
        );
      case DioExceptionType.unknown:
      default:
        return NetworkException(
          message: dioException.message ?? '未知错误',
          statusCode: -1,
          errorCode: 'UNKNOWN_ERROR',
        );
    }
  }

  factory NetworkException._handleStatusCode(Response response) {
    final statusCode = response.statusCode ?? 0;
    final data = response.data;
    
    // 尝试从响应中获取错误信息
    String message = '请求失败';
    String? errorCode;
    
    if (data is Map<String, dynamic>) {
      message = data['message'] ?? data['error'] ?? message;
      errorCode = data['code']?.toString();
    }

    switch (statusCode) {
      case 400:
        return NetworkException(
          message: message.isNotEmpty ? message : '请求参数错误',
          statusCode: statusCode,
          errorCode: errorCode ?? 'BAD_REQUEST',
          data: data,
        );
      case 401:
        return NetworkException(
          message: message.isNotEmpty ? message : '未授权，请重新登录',
          statusCode: statusCode,
          errorCode: errorCode ?? 'UNAUTHORIZED',
          data: data,
        );
      case 403:
        return NetworkException(
          message: message.isNotEmpty ? message : '访问被拒绝',
          statusCode: statusCode,
          errorCode: errorCode ?? 'FORBIDDEN',
          data: data,
        );
      case 404:
        return NetworkException(
          message: message.isNotEmpty ? message : '请求的资源不存在',
          statusCode: statusCode,
          errorCode: errorCode ?? 'NOT_FOUND',
          data: data,
        );
      case 422:
        return NetworkException(
          message: message.isNotEmpty ? message : '数据验证失败',
          statusCode: statusCode,
          errorCode: errorCode ?? 'VALIDATION_ERROR',
          data: data,
        );
      case 429:
        return NetworkException(
          message: message.isNotEmpty ? message : '请求过于频繁，请稍后重试',
          statusCode: statusCode,
          errorCode: errorCode ?? 'TOO_MANY_REQUESTS',
          data: data,
        );
      case 500:
        return NetworkException(
          message: message.isNotEmpty ? message : '服务器内部错误',
          statusCode: statusCode,
          errorCode: errorCode ?? 'INTERNAL_SERVER_ERROR',
          data: data,
        );
      case 502:
        return NetworkException(
          message: message.isNotEmpty ? message : '网关错误',
          statusCode: statusCode,
          errorCode: errorCode ?? 'BAD_GATEWAY',
          data: data,
        );
      case 503:
        return NetworkException(
          message: message.isNotEmpty ? message : '服务暂时不可用',
          statusCode: statusCode,
          errorCode: errorCode ?? 'SERVICE_UNAVAILABLE',
          data: data,
        );
      default:
        return NetworkException(
          message: message.isNotEmpty ? message : '请求失败 ($statusCode)',
          statusCode: statusCode,
          errorCode: errorCode ?? 'HTTP_ERROR',
          data: data,
        );
    }
  }

  @override
  String toString() {
    return 'NetworkException: $message (Code: $statusCode, Error: $errorCode)';
  }
}

// API响应包装类
class ApiResponse<T> {
  final bool success;
  final T? data;
  final String? message;
  final String? errorCode;
  final int? statusCode;

  const ApiResponse({
    required this.success,
    this.data,
    this.message,
    this.errorCode,
    this.statusCode,
  });

  factory ApiResponse.success(T data, {String? message}) {
    return ApiResponse(
      success: true,
      data: data,
      message: message,
    );
  }

  factory ApiResponse.error({
    required String message,
    String? errorCode,
    int? statusCode,
  }) {
    return ApiResponse(
      success: false,
      message: message,
      errorCode: errorCode,
      statusCode: statusCode,
    );
  }

  factory ApiResponse.fromException(NetworkException exception) {
    return ApiResponse(
      success: false,
      message: exception.message,
      errorCode: exception.errorCode,
      statusCode: exception.statusCode,
    );
  }
}