import 'package:dio/dio.dart';
import '../config/app_config.dart';

class DioFactory {
  static Dio? _dio;

  static Dio getDio() {
    if (_dio == null) {
      _dio = Dio();
      _dio!.options = BaseOptions(
        baseUrl: AppConfig.baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );
      
      // Add interceptors if needed
      _dio!.interceptors.add(LogInterceptor(
        requestBody: true,
        responseBody: true,
        requestHeader: true,
        responseHeader: true,
      ));
    }
    return _dio!;
  }

  static void dispose() {
    _dio?.close();
    _dio = null;
  }
}