import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart'; // Import for BuildContext
import 'package:provider/provider.dart'; // Import for Provider
import 'package:flutter/foundation.dart'; // Import for kIsWeb
import 'package:bookin/utils/storage_service.dart';
import 'package:bookin/config/app_config.dart';
import 'package:bookin/providers/app_provider.dart'; // Import AppProvider

// Base URL for your API. Now from AppConfig.
const String _baseUrl = AppConfig.baseUrl; 

// Enum for API response codes
enum ApiCode {
  SUCCESS,
  FAIL,
  UNAUTHORIZED,
  NETWORK_ERROR,
  UNKNOWN_ERROR,
}

// Generic API Response class
class ApiResponse<T> {
  final ApiCode code;
  final T? data;
  final String message;
  final bool success;

  ApiResponse({
    required this.code,
    this.data,
    this.message = '',
    required this.success,
  });

  factory ApiResponse.fromJson(Map<String, dynamic> json, T Function(dynamic json)? fromJsonT) {
    final success = json['code'] == 0 || json['code'] == '0' || json['success'] == true;
    final code = success ? ApiCode.SUCCESS : ApiCode.FAIL;
    final message = json['message'] as String? ?? json['msg'] as String? ?? 'Unknown error';
    
    T? data;
    if (success && json['data'] != null) {
      if (fromJsonT != null) {
        data = fromJsonT(json['data']);
      } else {
        data = json['data'] as T; // Direct cast if no specific parser is provided
      }
    }

    return ApiResponse(
      code: code,
      data: data,
      message: message,
      success: success,
    );
  }

  // Helper for success responses
  factory ApiResponse.success(T data, {String message = ''}) {
    return ApiResponse(code: ApiCode.SUCCESS, data: data, message: message, success: true);
  }

  // Helper for error responses
  factory ApiResponse.error(String message, {ApiCode code = ApiCode.FAIL}) {
    return ApiResponse(code: code, message: message, success: false);
  }
}

// Base API class for making HTTP requests
class BaseApi {
  // You can toggle this for development/testing with mock data if needed
  static const bool useRealApi = true; // Use real API that's shared with H5 version 

  static Future<Map<String, String>> _getHeaders() async {
    String? token = await StorageService.getToken();
    
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };

    // 在Web环境中添加额外的CORS相关头部
    if (kIsWeb) {
      headers.addAll({
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
        'Access-Control-Allow-Headers': 'Content-Type, Authorization, Accept',
        'Access-Control-Allow-Credentials': 'true',
        'X-Requested-With': 'XMLHttpRequest',
        'Cache-Control': 'no-cache',
      });
    }

    return headers;
  }

  static Future<ApiResponse<T>> _sendRequest<T>(
    BuildContext context, // Added BuildContext
    String method,
    String path, {
    Map<String, dynamic>? queryParameters,
    dynamic body,
    T Function(dynamic json)? fromJsonT,
  }) async {
    final appProvider = Provider.of<AppProvider>(context, listen: false);
    appProvider.setAppLoading(true); // Show global loading

    // Mock data handling
    if (!useRealApi) {
      await Future.delayed(const Duration(milliseconds: 500)); // Simulate network delay
      appProvider.setAppLoading(false);
      
      final mockData = _getMockData(path);
      if (mockData != null) {
        return ApiResponse.fromJson(mockData, fromJsonT);
      } else {
        return ApiResponse.error('Mock data not found for: $path');
      }
    }

    Uri uri = Uri.parse('$_baseUrl$path');

    if (queryParameters != null && queryParameters.isNotEmpty) {
      uri = uri.replace(queryParameters: queryParameters.map((key, value) => MapEntry(key, value.toString())));
    }

    try {
      http.Response response;
      final headers = await _getHeaders();

      // 在Web环境中，先发送OPTIONS预检请求
      if (kIsWeb && method.toUpperCase() != 'GET') {
        try {
          await http.Request('OPTIONS', uri)
            ..headers.addAll(headers)
            ..send();
        } catch (e) {
          // 忽略OPTIONS请求的错误，继续执行实际请求
          print('OPTIONS request failed: $e');
        }
      }

      switch (method.toUpperCase()) {
        case 'GET':
          response = await http.get(uri, headers: headers);
          break;
        case 'POST':
          response = await http.post(uri, headers: headers, body: jsonEncode(body));
          break;
        case 'PUT':
          response = await http.put(uri, headers: headers, body: jsonEncode(body));
          break;
        case 'DELETE':
          response = await http.delete(uri, headers: headers, body: jsonEncode(body));
          break;
        default:
          throw Exception('Unsupported HTTP method: $method');
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final jsonResponse = jsonDecode(response.body);
        return ApiResponse.fromJson(jsonResponse, fromJsonT);
      } else if (response.statusCode == 401) {
        // Handle unauthorized specifically (e.g., redirect to login)
        String errorMessage = '您的登录状态已过期，请重新登录';
        try {
          final errorBody = jsonDecode(response.body);
          errorMessage = errorBody['message'] ?? errorBody['msg'] ?? errorMessage;
        } catch (e) {
          // If JSON parsing fails, use the default error message
        }
        appProvider.setGlobalMessage(errorMessage);
        return ApiResponse.error(errorMessage, code: ApiCode.UNAUTHORIZED);
      } else {
        String errorMessage = 'Server error: ${response.statusCode}';
        try {
          final errorBody = jsonDecode(response.body);
          errorMessage = errorBody['message'] ?? errorBody['msg'] ?? errorMessage;
        } catch (e) {
          // If JSON parsing fails, use the default error message
        }
        appProvider.setGlobalMessage(errorMessage);
        return ApiResponse.error(errorMessage);
      }
    } on http.ClientException catch (e) {
      appProvider.setGlobalMessage('Network error: ${e.message}');
      return ApiResponse.error('Network error: ${e.message}', code: ApiCode.NETWORK_ERROR);
    } catch (e) {
      appProvider.setGlobalMessage('An unexpected error occurred: ${e.toString()}');
      return ApiResponse.error('An unexpected error occurred: ${e.toString()}', code: ApiCode.UNKNOWN_ERROR);
    } finally {
      appProvider.setAppLoading(false); // Hide global loading
    }
  }

  static Future<ApiResponse<T>> get<T>(BuildContext context, String path, {Map<String, dynamic>? queryParameters, T Function(dynamic json)? fromJsonT}) {
    return _sendRequest<T>(context, 'GET', path, queryParameters: queryParameters, fromJsonT: fromJsonT);
  }

  static Future<ApiResponse<T>> post<T>(BuildContext context, String path, dynamic body, {T Function(dynamic json)? fromJsonT}) {
    return _sendRequest<T>(context, 'POST', path, body: body, fromJsonT: fromJsonT);
  }

  static Future<ApiResponse<T>> put<T>(BuildContext context, String path, dynamic body, {T Function(dynamic json)? fromJsonT}) {
    return _sendRequest<T>(context, 'PUT', path, body: body, fromJsonT: fromJsonT);
  }

  static Future<ApiResponse<T>> delete<T>(BuildContext context, String path, {Map<String, dynamic>? queryParameters, dynamic body, T Function(dynamic json)? fromJsonT}) {
    return _sendRequest<T>(context, 'DELETE', path, queryParameters: queryParameters, body: body, fromJsonT: fromJsonT);
  }

  // File upload (simplified, might need more robust implementation for multipart/form-data)
  static Future<ApiResponse<String>> upload(BuildContext context, String path, String filePath, String name, Map<String, String> formData) async {
    final appProvider = Provider.of<AppProvider>(context, listen: false);
    appProvider.setAppLoading(true); // Show global loading

    final uri = Uri.parse('$_baseUrl$path');
    final request = http.MultipartRequest('POST', uri);
    request.headers.addAll(await _getHeaders());
    request.fields.addAll(formData);
    request.files.add(await http.MultipartFile.fromPath(name, filePath));

    try {
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final jsonResponse = jsonDecode(response.body);
        return ApiResponse.fromJson(jsonResponse, (json) => json['url'] as String); // Assuming 'url' is returned
      } else {
        String errorMessage = 'Upload failed: ${response.statusCode}';
        try {
          final errorBody = jsonDecode(response.body);
          errorMessage = errorBody['message'] ?? errorBody['msg'] ?? errorMessage;
        } catch (e) {
          // If JSON parsing fails, use the default error message
        }
        appProvider.setGlobalMessage(errorMessage);
        return ApiResponse.error(errorMessage);
      }
    } on http.ClientException catch (e) {
      appProvider.setGlobalMessage('Network error during upload: ${e.message}');
      return ApiResponse.error('Network error during upload: ${e.message}', code: ApiCode.NETWORK_ERROR);
    } catch (e) {
      appProvider.setGlobalMessage('An unexpected error occurred during upload: ${e.toString()}');
      return ApiResponse.error('An unexpected error occurred during upload: ${e.toString()}', code: ApiCode.UNKNOWN_ERROR);
    } finally {
      appProvider.setAppLoading(false); // Hide global loading
    }
  }

  // Mock data method
  static Map<String, dynamic>? _getMockData(String path) {
    switch (path) {
      case '/user/login':
        return {
          'code': 0,
          'success': true,
          'message': 'Login successful',
          'data': {
            'token': 'mock_jwt_token_12345',
            'userInfo': {
              'id': '1',
              'phone': '13800138000',
              'nickname': '测试用户',
              'avatar': 'https://via.placeholder.com/100x100',
              'gender': 1,
              'birthday': '1990-01-01',
              'inviteCode': 'ABC123',
              'balance': 100.0,
              'points': 500,
              'isMember': true,
              'memberLevel': 'VIP',
              'orderCount': 10,
              'favoriteCount': 5,
              'pendingPaymentCount': 1,
              'pendingServiceCount': 2,
              'inServiceCount': 0,
              'pendingCommentCount': 1,
              'couponCount': 3,
            }
          }
        };
      case '/user/password-login':
        return {
          'code': 0,
          'success': true,
          'message': 'Password login successful',
          'data': {
            'token': 'mock_jwt_token_password_12345',
            'userInfo': {
              'id': '1',
              'phone': '13800138000',
              'nickname': '测试用户',
              'avatar': 'https://via.placeholder.com/100x100',
              'gender': 1,
              'birthday': '1990-01-01',
              'inviteCode': 'ABC123',
              'balance': 100.0,
              'points': 500,
              'isMember': true,
              'memberLevel': 'VIP',
              'orderCount': 10,
              'favoriteCount': 5,
              'pendingPaymentCount': 1,
              'pendingServiceCount': 2,
              'inServiceCount': 0,
              'pendingCommentCount': 1,
              'couponCount': 3,
            }
          }
        };
      case '/user/wechat-login':
        return {
          'code': 0,
          'success': true,
          'message': 'WeChat login successful',
          'data': {
            'token': 'mock_jwt_token_wechat_12345',
            'userInfo': {
              'id': '1',
              'phone': '13800138000',
              'nickname': '微信用户',
              'avatar': 'https://via.placeholder.com/100x100',
              'gender': 1,
              'birthday': '1990-01-01',
              'inviteCode': 'ABC123',
              'balance': 100.0,
              'points': 500,
              'isMember': true,
              'memberLevel': 'VIP',
              'orderCount': 10,
              'favoriteCount': 5,
              'pendingPaymentCount': 1,
              'pendingServiceCount': 2,
              'inServiceCount': 0,
              'pendingCommentCount': 1,
              'couponCount': 3,
            }
          }
        };
      case '/home/recommend-techs':
        return {
          'code': 0,
          'success': true,
          'message': 'Success',
          'data': [
            {
              'id': '1',
              'name': '张师傅',
              'avatar': 'https://via.placeholder.com/100x100',
              'rating': 4.8,
              'serviceCount': 128,
              'tags': ['专业', '细心', '准时'],
              'gender': '男',
              'age': 32,
              'experience': 5,
              'goodRate': '98%',
              'price': 15000,
              'specialty': '家庭护理',
              'orderCount': 256,
              'popularity': '很受欢迎',
              'distance': '2.3km',
            },
            {
              'id': '2',
              'name': '李阿姨',
              'avatar': 'https://via.placeholder.com/100x100',
              'rating': 4.9,
              'serviceCount': 89,
              'tags': ['温柔', '耐心', '经验丰富'],
              'gender': '女',
              'age': 45,
              'experience': 8,
              'goodRate': '99%',
              'price': 18000,
              'specialty': '母婴护理',
              'orderCount': 189,
              'popularity': '金牌技师',
              'distance': '1.8km',
            },
            {
              'id': '3',
              'name': '王师傅',
              'avatar': 'https://via.placeholder.com/100x100',
              'rating': 4.7,
              'serviceCount': 156,
              'tags': ['技术过硬', '服务好'],
              'gender': '男',
              'age': 38,
              'experience': 6,
              'goodRate': '97%',
              'price': 16000,
              'specialty': '家电维修',
              'orderCount': 312,
              'popularity': '口碑很好',
              'distance': '3.1km',
            },
          ]
        };

      case '/home/banners':
        return {
          'code': 0,
          'success': true,
          'message': 'Success',
          'data': [
            {
              'id': '1',
              'imageUrl': 'https://via.placeholder.com/350x200/FF5777/FFFFFF?text=Banner+1',
              'targetUrl': '/project/1',
              'title': '专业家政服务'
            },
            {
              'id': '2',
              'imageUrl': 'https://via.placeholder.com/350x200/4ECDC4/FFFFFF?text=Banner+2',
              'targetUrl': '/project/2',
              'title': '优质护理服务'
            },
          ]
        };

      case '/home/projects':
        return {
          'code': 0,
          'success': true,
          'message': 'Success',
          'data': {
            'list': [
              {
                'id': '1',
                'name': '家庭保洁',
                'cover': 'https://via.placeholder.com/150x150',
                'originalPrice': 12000,
                'price': 10000,
                'salesCount': 128,
                'rating': '4.8',
                'tags': ['热门', '专业'],
              },
              {
                'id': '2',
                'name': '母婴护理',
                'cover': 'https://via.placeholder.com/150x150',
                'originalPrice': 25000,
                'price': 22000,
                'salesCount': 89,
                'rating': '4.9',
                'tags': ['推荐', '金牌'],
              },
            ]
          }
        };

      case '/teacher/list':
        return {
          'code': '0',
          'msg': 'ok',
          'success': true,
          'timestamp': 1753537391512,
          'data': {
            'cityCode': null,
            'isOpened': true,
            'notOpenTip': '当前城市暂未开放,敬请期待',
            'page': {
              'list': [
                {
                  'id': 6029,
                  'name': '婉妍',
                  'avatar': 'https://file.pic.meijiandaojia.com//userfiles/1/images/photo/2025/01/99a4f870615a09febb80a9679444ab5.jpg',
                  'gender': '女',
                  'age': 49,
                  'experience': 19,
                  'rating': 4.8,
                  'goodRate': 93,
                  'distance': '3.2',
                  'isFree': false,
                  'status': 0,
                  'tags': ['实名认证', '资质认证'],
                  'services': [
                    '悦享舒缓解乏按摩',
                    '沉浸芳香疗愈按摩',
                    '轻奢五感悠享spa',
                    '巴厘岛轻奢柔式spa',
                    '高级香薰帝王spa套餐'
                  ],
                  'orderCount': 366,
                  'commentCount': 258,
                  'likeCount': 184,
                  'isRecommend': false,
                  'merchantName': '摩豚到家',
                  'avatarShape': 1
                },
                {
                  'id': 6033,
                  'name': '苏郁',
                  'avatar': 'https://file.pic.meijiandaojia.com//userfiles/1/images/photo/2025/01/5ca99cd56234cc938f7052f2779871f.jpg',
                  'gender': '女',
                  'age': 33,
                  'experience': 18,
                  'rating': 4.7,
                  'goodRate': 94,
                  'distance': '3.2',
                  'isFree': false,
                  'status': 0,
                  'tags': ['实名认证', '资质认证'],
                  'services': [
                    '悦享舒缓解乏按摩',
                    '沉浸芳香疗愈按摩',
                    '轻奢五感悠享spa',
                    '巴厘岛轻奢柔式spa',
                    '高级香薰帝王spa套餐'
                  ],
                  'orderCount': 777,
                  'commentCount': 308,
                  'likeCount': 277,
                  'isRecommend': false,
                  'merchantName': '摩豚到家',
                  'avatarShape': 1
                },
                {
                  'id': 6017,
                  'name': '南枝',
                  'avatar': 'https://file.pic.meijiandaojia.com//userfiles/1/images/photo/2025/01/b2fdcf534e2899c5fbba88e50132f4f.png',
                  'gender': '女',
                  'age': 35,
                  'experience': 9,
                  'rating': 4.9,
                  'goodRate': 90,
                  'distance': '3.2',
                  'isFree': false,
                  'status': 0,
                  'tags': ['实名认证', '资质认证'],
                  'services': [
                    '悦享舒缓解乏按摩',
                    '沉浸芳香疗愈按摩',
                    '轻奢五感悠享spa',
                    '巴厘岛轻奢柔式spa',
                    '高级香薰帝王spa套餐'
                  ],
                  'orderCount': 422,
                  'commentCount': 342,
                  'likeCount': 125,
                  'isRecommend': false,
                  'merchantName': '摩豚到家',
                  'avatarShape': 1
                }
              ]
            }
          }
        };

      default:
        return null;
    }
  }
}