import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../models/banner_model.dart';
import '../models/project_model.dart';
import '../models/technician_model.dart';
import '../models/announcement_model.dart';
import '../models/coupon_model.dart';
import 'api_client.dart';
import 'api_endpoints.dart';
import 'network_exception.dart';

class HomeService {
  final ApiClient _apiClient = ApiClient();

  /// 获取首页横幅
  Future<List<BannerModel>> fetchBanners() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.banners);
      
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        if (data['success'] == true && data['data'] != null) {
          final List<dynamic> bannerList = data['data'];
          return bannerList.map((json) => BannerModel.fromJson(json)).toList();
        }
      }
      
      throw NetworkException(
        message: '获取横幅数据失败',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      throw NetworkException.fromDioException(e);
    } catch (e) {
      throw NetworkException(message: '获取横幅数据失败: $e');
    }
  }



  /// 获取热门项目
  Future<List<ProjectModel>> fetchHotProjects() async {
    try {
      // 使用POST请求，与H5项目保持一致
      final response = await _apiClient.post(
        ApiEndpoints.hotProjects,
        data: {
          'category': 'all',
          'isHot': true,
          'page': 1,
          'pageSize': 5
        },
      );
      
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        if (data['success'] == true && data['data'] != null) {
          // H5项目返回的数据结构是 data.list
          final List<dynamic> projectList = data['data']['list'] ?? data['data'];
          return projectList.map((json) => ProjectModel.fromJson(json)).toList();
        }
      }
      
      throw NetworkException(
        message: '获取热门项目失败',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      throw NetworkException.fromDioException(e);
    } catch (e) {
      throw NetworkException(message: '获取热门项目失败: $e');
    }
  }



  /// 获取精选技师
  Future<List<TechnicianModel>> fetchFeaturedTechnicians() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.featuredTechnicians);
      
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        if (data['success'] == true && data['data'] != null) {
          final List<dynamic> technicianList = data['data'];
          return technicianList.map((json) => TechnicianModel.fromJson(json)).toList();
        }
      }
      
      throw NetworkException(
        message: '获取精选技师失败',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      throw NetworkException.fromDioException(e);
    } catch (e) {
      throw NetworkException(message: '获取精选技师失败: $e');
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

  /// 获取公告列表
  Future<List<AnnouncementModel>> fetchAnnouncements() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.announcements);
      
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        if (data['success'] == true && data['data'] != null) {
          final List<dynamic> announcementList = data['data'];
          return announcementList.map((json) => AnnouncementModel.fromJson(json)).toList();
        }
      }
      
      throw NetworkException(
        message: '获取公告数据失败',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      throw NetworkException.fromDioException(e);
    } catch (e) {
      throw NetworkException(message: '获取公告数据失败: $e');
    }
  }

  /// 获取优惠券列表
  Future<List<CouponModel>> fetchCoupons() async {
    try {
      // 使用POST请求，与H5项目保持一致
      final response = await _apiClient.post(
        ApiEndpoints.coupons,
        data: {
          'current': 1,
          'size': 10
        },
      );
      
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        if ((data['code'] == 0 || data['code'] == '0' || data['success'] == true) && data['data'] != null) {
          final List<dynamic> couponList = data['data']['list'] ?? data['data'];
          return couponList.map((json) => CouponModel.fromJson(json)).toList();
        }
      }
      
      throw NetworkException(
        message: '获取优惠券数据失败',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      throw NetworkException.fromDioException(e);
    } catch (e) {
      throw NetworkException(message: '获取优惠券数据失败: $e');
    }
  }

  /// 领取优惠券
  Future<bool> receiveCoupon(int couponId) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.receiveCoupon,
        data: {
          'couponId': couponId
        },
      );
      
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        return data['code'] == 0 || data['code'] == '0' || data['success'] == true;
      }
      
      return false;
    } on DioException catch (e) {
      throw NetworkException.fromDioException(e);
    } catch (e) {
      throw NetworkException(message: '领取优惠券失败: $e');
    }
  }
}