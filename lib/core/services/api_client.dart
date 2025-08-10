import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../config/app_config.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;
  ApiClient._internal();

  late Dio _dio;

  Dio get dio => _dio;

  void init() {
    _dio = Dio(BaseOptions(
      baseUrl: AppConfig.apiBaseUrl,
      connectTimeout: Duration(milliseconds: AppConfig.connectTimeout),
      receiveTimeout: Duration(milliseconds: AppConfig.receiveTimeout),
      sendTimeout: Duration(milliseconds: AppConfig.sendTimeout),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'User-Agent': '${AppConfig.appName}/${AppConfig.appVersion}',
      },
    ));

    // 添加拦截器
    _dio.interceptors.add(_createInterceptor());

    if (kDebugMode) {
      _dio.interceptors.add(LogInterceptor(
        requestBody: true,
        responseBody: true,
        requestHeader: true,
        responseHeader: false,
      ));
    }
  }

  InterceptorsWrapper _createInterceptor() {
    return InterceptorsWrapper(
      onRequest: (options, handler) {
        // 添加认证token
        final token = _getAuthToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        
        // 添加请求ID用于追踪
        options.headers['X-Request-ID'] = DateTime.now().millisecondsSinceEpoch.toString();
        
        // 添加设备信息
        options.headers['X-Platform'] = AppConfig.isAndroid ? 'android' : 
                                       AppConfig.isIOS ? 'ios' : 'web';
        
        if (AppConfig.enableApiLog) {
          print('🚀 [${DateTime.now()}] Request: ${options.method} ${options.uri}');
          print('📤 Headers: ${options.headers}');
          if (options.data != null) {
            print('📦 Data: ${options.data}');
          }
          if (options.queryParameters.isNotEmpty) {
            print('🔍 Query: ${options.queryParameters}');
          }
        }
        handler.next(options);
      },
      onResponse: (response, handler) {
        if (AppConfig.enableApiLog) {
          print('✅ [${DateTime.now()}] Response: ${response.statusCode} ${response.requestOptions.uri}');
          print('📥 Data: ${response.data}');
        }
        handler.next(response);
      },
      onError: (error, handler) {
        if (AppConfig.enableApiLog) {
          print('❌ [${DateTime.now()}] Error: ${error.requestOptions.method} ${error.requestOptions.uri}');
          print('💥 Status: ${error.response?.statusCode}');
          print('📄 Message: ${error.message}');
          print('🔍 Response: ${error.response?.data}');
        }
        _handleError(error);
        handler.next(error);
      },
    );
  }

  String? _getAuthToken() {
    // TODO: 从本地存储获取token
    return null;
  }

  void _handleError(DioException error) {
    if (kDebugMode) {
      print('API Error: ${error.message}');
      print('Status Code: ${error.response?.statusCode}');
      print('Response Data: ${error.response?.data}');
    }
  }

  // 通用GET请求
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await _dio.get<T>(
      path,
      queryParameters: queryParameters,
      options: options,
    );
  }

  // 通用POST请求
  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await _dio.post<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  // 通用PUT请求
  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await _dio.put<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  // 通用DELETE请求
  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await _dio.delete<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }
}