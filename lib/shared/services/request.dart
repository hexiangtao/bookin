import 'package:flutter/material.dart';
import 'package:bookin/features/shared/services/base_api.dart';

// This file serves as a placeholder for a more advanced HTTP client wrapper
// if needed, similar to the original project's `request.js`.
// For now, it simply re-exports BaseApi or provides a thin wrapper.

// You might use a package like `dio` for more advanced features like:
// - Interceptors (for logging, authentication, error handling)
// - FormData for file uploads
// - Request cancellation
// - Global configurations

// Example of a simple wrapper around BaseApi:
class Request {
  static Future<ApiResponse<T>> get<T>(BuildContext context, String path, {Map<String, dynamic>? queryParameters, T Function(dynamic json)? fromJsonT}) {
    return BaseApi.get(context, path, queryParameters: queryParameters, fromJsonT: fromJsonT);
  }

  static Future<ApiResponse<T>> post<T>(BuildContext context, String path, dynamic body, {T Function(dynamic json)? fromJsonT}) {
    return BaseApi.post(context, path, body, fromJsonT: fromJsonT);
  }

  static Future<ApiResponse<T>> put<T>(BuildContext context, String path, dynamic body, {T Function(dynamic json)? fromJsonT}) {
    return BaseApi.put(context, path, body, fromJsonT: fromJsonT);
  }

  static Future<ApiResponse<T>> delete<T>(BuildContext context, String path, {Map<String, dynamic>? queryParameters, dynamic body, T Function(dynamic json)? fromJsonT}) {
    return BaseApi.delete(context, path, queryParameters: queryParameters, body: body, fromJsonT: fromJsonT);
  }

  static Future<ApiResponse<String>> upload(BuildContext context, String path, String filePath, String name, Map<String, String> formData) {
    return BaseApi.upload(context, path, filePath, name, formData);
  }
}
