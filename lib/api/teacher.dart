import 'package:bookin/api/base.dart';
import 'package:flutter/material.dart'; // Import for BuildContext

// Data model for a Teacher (技师)
class Teacher {
  final String id;
  final String name;
  final String avatar;
  final double rating;
  final int serviceCount;
  final List<String> tags;
  final String? gender;
  final int? age;
  final int? experience;
  final String? goodRate;
  final int? price; // Assuming price is in cents
  final String? specialty;
  final int? orderCount;
  final String? popularity;
  final String? distance;
  final String? introduction;
  final String? certification;
  final List<String> specialties;
  final String? address;
  final bool isVerified;
  final bool isRecommend; // 是否推荐技师（红牌）

  Teacher({
    required this.id,
    required this.name,
    required this.avatar,
    required this.rating,
    required this.serviceCount,
    required this.tags,
    this.gender,
    this.age,
    this.experience,
    this.goodRate,
    this.price,
    this.specialty,
    this.orderCount,
    this.popularity,
    this.distance,
    this.introduction,
    this.certification,
    this.specialties = const [],
    this.address,
    this.isVerified = false,
    this.isRecommend = false,
  });

  factory Teacher.fromJson(Map<String, dynamic> json) {
    return Teacher(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      avatar: json['avatar']?.toString() ?? '',
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      serviceCount: json['orderCount'] as int? ?? 0, // 使用orderCount作为serviceCount
      tags: (json['tags'] as List?)?.map((e) => e.toString()).toList() ?? [],
      gender: json['gender']?.toString(),
      age: json['age'] as int?,
      experience: json['experience'] as int?,
      goodRate: json['goodRate']?.toString(),
      price: json['price'] as int?,
      specialty: json['specialty']?.toString(),
      orderCount: json['orderCount'] as int?,
      popularity: json['popularity']?.toString(),
      distance: json['distance']?.toString(),
      introduction: json['introduction']?.toString(),
      certification: json['certification']?.toString(),
      specialties: (json['specialties'] as List?)?.map((e) => e.toString()).toList() ?? [],
      address: json['address']?.toString(),
      isVerified: json['isVerified'] as bool? ?? false,
      isRecommend: json['isRecommend'] as bool? ?? false, // 处理isRecommend字段
    );
  }
}

// Data model for Teacher Project
class TeacherProject {
  final String id;
  final String name;
  final String icon;
  final String tips;
  final int originalPrice;
  final int price;
  final int num;
  final String tag;
  final int timer;
  final int buycount;

  TeacherProject({
    required this.id,
    required this.name,
    required this.icon,
    required this.tips,
    required this.originalPrice,
    required this.price,
    required this.num,
    required this.tag,
    required this.timer,
    required this.buycount,
  });

  factory TeacherProject.fromJson(Map<String, dynamic> json) {
    return TeacherProject(
      id: json['id'].toString(),
      name: json['name'] as String,
      icon: json['icon'] as String,
      tips: json['tips'] as String,
      originalPrice: json['originalPrice'] as int,
      price: json['price'] as int,
      num: json['num'] as int,
      tag: json['tag'] as String,
      timer: json['timer'] as int,
      buycount: json['buycount'] as int,
    );
  }
}

// Data model for Teacher Certificate
class TeacherCertificate {
  final String id;
  final String name;
  final String imageUrl;
  final String issueDate;
  final String? expireDate;

  TeacherCertificate({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.issueDate,
    this.expireDate,
  });

  factory TeacherCertificate.fromJson(Map<String, dynamic> json) {
    return TeacherCertificate(
      id: json['id'].toString(),
      name: json['name'] as String,
      imageUrl: json['imageUrl'] as String,
      issueDate: json['issueDate'] as String,
      expireDate: json['expireDate'] as String?,
    );
  }
}

// Data model for Teacher Apply Request
class TeacherApplyReq {
  final String name;
  final String phone;
  final String gender;
  final int age;
  final String city;
  final List<String> serviceTypes;
  final String experience;
  final String description;
  final List<String> certificateImages;
  final List<String> personalImages;

  TeacherApplyReq({
    required this.name,
    required this.phone,
    required this.gender,
    required this.age,
    required this.city,
    required this.serviceTypes,
    required this.experience,
    required this.description,
    required this.certificateImages,
    required this.personalImages,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'phone': phone,
      'gender': gender,
      'age': age,
      'city': city,
      'serviceTypes': serviceTypes,
      'experience': experience,
      'description': description,
      'certificateImages': certificateImages,
      'personalImages': personalImages,
    };
  }
}

// Data model for Teacher Ranking
class TeacherRankingItem {
  final String id;
  final String name;
  final String avatar;
  final double rating;
  final int orderCount;

  TeacherRankingItem({
    required this.id,
    required this.name,
    required this.avatar,
    required this.rating,
    required this.orderCount,
  });

  factory TeacherRankingItem.fromJson(Map<String, dynamic> json) {
    return TeacherRankingItem(
      id: json['id'].toString(),
      name: json['name'] as String,
      avatar: json['avatar'] as String,
      rating: (json['rating'] as num).toDouble(),
      orderCount: json['orderCount'] as int,
    );
  }
}

// Data model for Teacher Info (used in list)
class TeacherInfo {
  final String id;
  final String name;
  final String avatar;
  final double rating;
  final int serviceCount;
  final List<String> specialties;
  final int price;
  final bool freeTravel;
  final bool available;
  final String? distance;
  final String? city;

  TeacherInfo({
    required this.id,
    required this.name,
    required this.avatar,
    required this.rating,
    required this.serviceCount,
    required this.specialties,
    required this.price,
    required this.freeTravel,
    required this.available,
    this.distance,
    this.city,
  });

  factory TeacherInfo.fromJson(Map<String, dynamic> json) {
    return TeacherInfo(
      id: json['id'].toString(),
      name: json['name'] as String,
      avatar: json['avatar'] as String,
      rating: (json['rating'] as num).toDouble(),
      serviceCount: json['serviceCount'] as int? ?? 0,
      specialties: (json['specialties'] as List?)?.map((e) => e as String).toList() ?? [],
      price: json['price'] as int? ?? 0,
      freeTravel: json['freeTravel'] as bool? ?? false,
      available: json['available'] as bool? ?? false,
      distance: json['distance'] as String?,
      city: json['city'] as String?,
    );
  }
}

class TeacherApi {
  /// Get technician list (new method for list page).
  Future<ApiResponse<List<TeacherInfo>>> getTeacherList(BuildContext context, {
    int page = 1,
    int pageSize = 10,
    String? keyword,
    String? city,
    String? serviceType,
    String? priceRange,
    double? minRating,
    bool? freeTravel,
    bool? available,
  }) async {
    final Map<String, dynamic> params = {
      'page': page,
      'pageSize': pageSize,
    };
    if (keyword != null) params['keyword'] = keyword;
    if (city != null) params['city'] = city;
    if (serviceType != null) params['serviceType'] = serviceType;
    if (priceRange != null) params['priceRange'] = priceRange;
    if (minRating != null) params['minRating'] = minRating;
    if (freeTravel != null) params['freeTravel'] = freeTravel;
    if (available != null) params['available'] = available;

    return BaseApi.post(
      context,
      '/teacher/list',
      params,
      fromJsonT: (json) => (json['page']['list'] as List).map((e) => TeacherInfo.fromJson(e)).toList(),
    );
  }

  /// Get technician list.
  Future<ApiResponse<List<Teacher>>> getTechList(BuildContext context, {
    int page = 1,
    int pageSize = 10,
    String? keyword,
    int? tab,
    String? city,
    String? serviceType,
    String? priceRange,
    String? rating,
    String? projectId,
  }) async {
    final Map<String, dynamic> params = {
      'page': page,
      'pageSize': pageSize,
    };
    if (keyword != null) params['keyword'] = keyword;
    if (tab != null) params['tab'] = tab;
    if (city != null) params['city'] = city;
    if (serviceType != null) params['serviceType'] = serviceType;
    if (priceRange != null) params['priceRange'] = priceRange;
    if (rating != null) params['rating'] = rating;
    if (projectId != null) params['projectId'] = projectId;

    return BaseApi.post(
      context,
      '/teacher/list',
      params,
      fromJsonT: (json) => (json['page']['list'] as List).map((e) => Teacher.fromJson(e)).toList(),
    );
  }

  /// Get technician details.
  Future<ApiResponse<Teacher>> getTechDetail(BuildContext context, String id) async {
    return BaseApi.get(
      context,
      '/teacher/detail/$id',
      fromJsonT: (json) => Teacher.fromJson(json),
    );
  }

  /// Get technician's service projects.
  Future<ApiResponse<List<TeacherProject>>> getTeachProjects(BuildContext context, String id) async {
    return BaseApi.get(
      context,
      '/teacher/projects/$id',
      fromJsonT: (json) => (json as List).map((e) => TeacherProject.fromJson(e)).toList(),
    );
  }

  /// Get technician comments.
  Future<ApiResponse<List<dynamic>>> getTechComments(BuildContext context, {
    required String techId,
    int page = 1,
    int pageSize = 10,
  }) async {
    final Map<String, dynamic> params = {
      'techId': techId,
      'page': page,
      'pageSize': pageSize,
    };
    return BaseApi.post(
      context,
      '/teacher/comments',
      params,
      fromJsonT: (json) => json['list'] as List, // Assuming list of comments, adapt as needed
    );
  }

  /// Toggle collect/uncollect technician.
  Future<ApiResponse<void>> toggleCollect(BuildContext context, String id, bool isCollect) async {
    return BaseApi.post(context, '/teacher/collect', {'id': id, 'isCollect': isCollect});
  }

  /// Get technician's certificates.
  Future<ApiResponse<List<TeacherCertificate>>> getTechCertificates(BuildContext context, String id) async {
    return BaseApi.get(
      context,
      '/teacher/certificates/$id',
      fromJsonT: (json) => (json as List).map((e) => TeacherCertificate.fromJson(e)).toList(),
    );
  }

  /// Get technician's available time.
  Future<ApiResponse<List<String>>> getTechAvailableTime(BuildContext context, String id, String date) async {
    return BaseApi.get(
      context,
      '/teacher/available-time/$id',
      queryParameters: {'date': date},
      fromJsonT: (json) => (json as List).map((e) => e as String).toList(),
    );
  }

  /// Submit technician application.
  Future<ApiResponse<void>> applySettle(BuildContext context, TeacherApplyReq data) async {
    return BaseApi.post(context, '/teacher/apply', data.toJson());
  }

  /// Upload technician photo.
  Future<ApiResponse<String>> uploadPhoto(BuildContext context, String filePath, Map<String, String> formData) async {
    return BaseApi.upload(context, '/teacher/upload-photo', filePath, 'photo', formData);
  }

  /// Upload technician certificate.
  Future<ApiResponse<String>> uploadCertificate(BuildContext context, String filePath, Map<String, String> formData) async {
    return BaseApi.upload(context, '/teacher/upload-certificate', filePath, 'certificate', formData);
  }

  /// Get technician ranking list.
  Future<ApiResponse<List<TeacherRankingItem>>> getTechRanking(BuildContext context, String type, {int limit = 10}) async {
    return BaseApi.get(
      context,
      '/teacher/ranking',
      queryParameters: {'type': type, 'limit': limit},
      fromJsonT: (json) => (json as List).map((e) => TeacherRankingItem.fromJson(e)).toList(),
    );
  }

  /// Get recommended technicians.
  Future<ApiResponse<List<Teacher>>> getRecommendedTechs(BuildContext context, {int limit = 4}) async {
    return BaseApi.get(
      context,
      '/teacher/recommended',
      queryParameters: {'limit': limit},
      fromJsonT: (json) => (json as List).map((e) => Teacher.fromJson(e)).toList(),
    );
  }

  /// Get nearby technicians.
  Future<ApiResponse<List<Teacher>>> getNearbyTechs(BuildContext context, double latitude, double longitude, {int distance = 5, int limit = 10}) async {
    return BaseApi.get(
      context,
      '/teacher/nearby',
      queryParameters: {'latitude': latitude, 'longitude': longitude, 'distance': distance, 'limit': limit},
      fromJsonT: (json) => (json as List).map((e) => Teacher.fromJson(e)).toList(),
    );
  }

  /// Get city list for technicians.
  Future<ApiResponse<List<String>>> getCityList(BuildContext context) async {
    return BaseApi.get(
      context,
      '/teacher/city-list',
      fromJsonT: (json) => (json as List).map((e) => e as String).toList(),
    );
  }

  /// Get filter options for technicians.
  Future<ApiResponse<Map<String, dynamic>>> getFilterOptions(BuildContext context) async {
    return BaseApi.get(
      context,
      '/teacher/filter-options',
      fromJsonT: (json) => json as Map<String, dynamic>,
    );
  }

  /// Get technician application status.
  Future<ApiResponse<Map<String, dynamic>>> getApplyStatus(BuildContext context) async {
    return BaseApi.get(
      context,
      '/teacher/apply/status',
      fromJsonT: (json) => json as Map<String, dynamic>,
    );
  }

  /// Get high-quality teachers list.
  Future<ApiResponse<List<Teacher>>> getHighQualityTeachers(BuildContext context) async {
    return BaseApi.get(
      context,
      '/teacher/list-high-quantity',
      fromJsonT: (json) => (json as List).map((e) => Teacher.fromJson(e)).toList(),
    );
  }
}