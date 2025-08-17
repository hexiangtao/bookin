import 'dart:io';
import 'package:dio/dio.dart' hide FormData, MultipartFile;
import 'package:dio/dio.dart' as dio show FormData, MultipartFile;
import 'package:get/get.dart';
import '../../../core/services/api_client.dart';
import '../../../core/config/app_config.dart';

/// 头像上传服务
class AvatarUploadService extends GetxService {
  final ApiClient _apiClient = Get.find<ApiClient>();
  
  /// 上传头像
  /// 
  /// [imageFile] 要上传的图片文件
  /// 返回上传后的图片URL
  Future<String> uploadAvatar(File imageFile) async {
    try {
      // 创建FormData
      final formData = dio.FormData.fromMap({
        'avatar': await dio.MultipartFile.fromFile(
          imageFile.path,
          filename: 'avatar_${DateTime.now().millisecondsSinceEpoch}.jpg',
        ),
      });
      
      // 发送上传请求
      final response = await _apiClient.post(
        '/user/upload-avatar',
        data: formData,
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data',
          },
        ),
      );
      
      if (response.data['success'] == true) {
        final avatarUrl = response.data['data']['avatar_url'] as String;
        if (AppConfig.enableApiLog) {
          print('头像上传成功: $avatarUrl');
        }
        return avatarUrl;
      } else {
        throw Exception(response.data['message'] ?? '上传失败');
      }
    } catch (e) {
      if (AppConfig.enableApiLog) {
        print('头像上传失败: $e');
      }
      
      // 处理不同类型的错误
      if (e is DioException) {
        switch (e.type) {
          case DioExceptionType.connectionTimeout:
          case DioExceptionType.sendTimeout:
          case DioExceptionType.receiveTimeout:
            throw Exception('网络连接超时，请检查网络后重试');
          case DioExceptionType.badResponse:
            final statusCode = e.response?.statusCode;
            if (statusCode == 413) {
              throw Exception('图片文件过大，请选择小于5MB的图片');
            } else if (statusCode == 415) {
              throw Exception('不支持的图片格式，请选择JPG或PNG格式');
            } else {
              throw Exception('服务器错误，请稍后重试');
            }
          case DioExceptionType.cancel:
            throw Exception('上传已取消');
          case DioExceptionType.unknown:
            throw Exception('网络连接失败，请检查网络设置');
          default:
            throw Exception('上传失败，请重试');
        }
      } else {
        throw Exception('上传失败: ${e.toString()}');
      }
    }
  }
  
  /// 验证图片文件
  /// 
  /// [imageFile] 要验证的图片文件
  /// 返回验证结果，如果验证失败会抛出异常
  Future<void> validateImageFile(File imageFile) async {
    try {
      // 检查文件是否存在
      if (!await imageFile.exists()) {
        throw Exception('图片文件不存在');
      }
      
      // 检查文件大小（限制5MB）
      final fileSize = await imageFile.length();
      const maxSize = 5 * 1024 * 1024; // 5MB
      if (fileSize > maxSize) {
        throw Exception('图片文件过大，请选择小于5MB的图片');
      }
      
      // 检查文件扩展名
      final fileName = imageFile.path.toLowerCase();
      final allowedExtensions = ['.jpg', '.jpeg', '.png', '.webp'];
      final hasValidExtension = allowedExtensions.any((ext) => fileName.endsWith(ext));
      
      if (!hasValidExtension) {
        throw Exception('不支持的图片格式，请选择JPG、PNG或WebP格式');
      }
      
      if (AppConfig.enableApiLog) {
        print('图片文件验证通过: ${imageFile.path}');
      }
    } catch (e) {
      if (AppConfig.enableApiLog) {
        print('图片文件验证失败: $e');
      }
      rethrow;
    }
  }
  
  /// 压缩图片（如果需要）
  /// 
  /// [imageFile] 原始图片文件
  /// [quality] 压缩质量 (0-100)
  /// 返回压缩后的图片文件
  Future<File> compressImage(File imageFile, {int quality = 80}) async {
    try {
      // 这里可以使用 flutter_image_compress 等库来压缩图片
      // 目前先直接返回原文件
      if (AppConfig.enableApiLog) {
        print('图片压缩完成: ${imageFile.path}');
      }
      return imageFile;
    } catch (e) {
      if (AppConfig.enableApiLog) {
        print('图片压缩失败: $e');
      }
      // 如果压缩失败，返回原文件
      return imageFile;
    }
  }
}