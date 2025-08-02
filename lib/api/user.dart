import 'package:bookin/api/base.dart';
import 'package:flutter/material.dart'; // Import for BuildContext

// Data model for User Info
class UserInfo {
  final String id;
  final String phone;
  final String nickname;
  final String? avatar;
  final int? gender;
  final String? birthday;
  final String? wechat;
  final String? inviteCode;
  final double? balance; // In currency units
  final int? points;
  final bool? isMember;
  final String? memberLevel;
  final int? orderCount;
  final int? favoriteCount;
  final int? pendingPaymentCount;
  final int? pendingServiceCount;
  final int? inServiceCount;
  final int? pendingCommentCount;
  final int? couponCount;

  UserInfo({
    required this.id,
    required this.phone,
    required this.nickname,
    this.avatar,
    this.gender,
    this.birthday,
    this.wechat,
    this.inviteCode,
    this.balance,
    this.points,
    this.isMember,
    this.memberLevel,
    this.orderCount,
    this.favoriteCount,
    this.pendingPaymentCount,
    this.pendingServiceCount,
    this.inServiceCount,
    this.pendingCommentCount,
    this.couponCount,
  });

  factory UserInfo.fromJson(Map<String, dynamic> json) {
    return UserInfo(
      id: json['id']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      nickname: json['nickname']?.toString() ?? '',
      avatar: json['avatar']?.toString(),
      gender: json['gender'] as int?,
      birthday: json['birthday']?.toString(),
      wechat: json['wechat']?.toString(),
      inviteCode: json['inviteCode']?.toString(),
      balance: (json['balance'] as num?)?.toDouble(),
      points: json['points'] as int?,
      isMember: json['isMember'] as bool?,
      memberLevel: json['memberLevel']?.toString(),
      orderCount: json['orderCount'] as int?,
      favoriteCount: json['favoriteCount'] as int?,
      pendingPaymentCount: json['pendingPaymentCount'] as int?,
      pendingServiceCount: json['pendingServiceCount'] as int?,
      inServiceCount: json['inServiceCount'] as int?,
      pendingCommentCount: json['pendingCommentCount'] as int?,
      couponCount: json['couponCount'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'phone': phone,
      'nickname': nickname,
      'avatar': avatar,
      'gender': gender,
      'birthday': birthday,
      'wechat': wechat,
      'inviteCode': inviteCode,
      'balance': balance,
      'points': points,
      'isMember': isMember,
      'memberLevel': memberLevel,
      'orderCount': orderCount,
      'favoriteCount': favoriteCount,
      'pendingPaymentCount': pendingPaymentCount,
      'pendingServiceCount': pendingServiceCount,
      'inServiceCount': inServiceCount,
      'pendingCommentCount': pendingCommentCount,
      'couponCount': couponCount,
    };
  }
}

// Data model for Coupon
class Coupon {
  final String id;
  final String name;
  final int amount; // In cents
  final int minConsume; // In cents
  final String beginTime;
  final String expireTime;
  final bool isExpired;
  final bool isUsed;
  final String? useTime;
  final String type; // e.g., 'cash', 'discount'
  final double? discountRate;

  Coupon({
    required this.id,
    required this.name,
    required this.amount,
    required this.minConsume,
    required this.beginTime,
    required this.expireTime,
    required this.isExpired,
    required this.isUsed,
    this.useTime,
    required this.type,
    this.discountRate,
  });

  factory Coupon.fromJson(Map<String, dynamic> json) {
    return Coupon(
      id: json['id'] as String,
      name: json['name'] as String,
      amount: json['amount'] as int,
      minConsume: json['minConsume'] as int,
      beginTime: json['beginTime'] as String,
      expireTime: json['expireTime'] as String,
      isExpired: json['isExpired'] as bool,
      isUsed: json['isUsed'] as bool,
      useTime: json['useTime'] as String?,
      type: json['type'] as String,
      discountRate: (json['discountRate'] as num?)?.toDouble(),
    );
  }
}

// Data model for Address (simplified, assuming it's similar to api/address.dart)
class Address {
  final String id;
  final String name;
  final String phone;
  final String address;
  final bool isDefault;

  Address({
    required this.id,
    required this.name,
    required this.phone,
    required this.address,
    this.isDefault = false,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      id: json['id'].toString(),
      name: json['name'] as String,
      phone: json['phone'].toString(),
      address: json['address'] as String,
      isDefault: json['isDefault'] as bool? ?? false,
    );
  }
}

// Data model for Collect Item (Service or Tech)
class CollectItem {
  final String id;
  final String type;
  final String title;
  final String image;
  final int price;
  final int originalPrice;
  final List<String> tags;
  final String collectTime;
  final String rating;
  final int ratingCount;
  final String? specialty;
  final String? experience;
  final String? orderCount;
  final String? popularity;

  CollectItem({
    required this.id,
    required this.type,
    required this.title,
    required this.image,
    required this.price,
    required this.originalPrice,
    required this.tags,
    required this.collectTime,
    required this.rating,
    required this.ratingCount,
    this.specialty,
    this.experience,
    this.orderCount,
    this.popularity,
  });

  factory CollectItem.fromJson(Map<String, dynamic> json) {
    return CollectItem(
      id: json['id'].toString(),
      type: json['type'] as String,
      title: json['title'] as String,
      image: json['image'] as String,
      price: json['price'] as int,
      originalPrice: json['originalPrice'] as int,
      tags: (json['tags'] as List).map((e) => e as String).toList(),
      collectTime: json['collectTime'] as String,
      rating: json['rating'] as String,
      ratingCount: json['ratingCount'] as int,
      specialty: json['specialty'] as String?,
      experience: json['experience'] as String?,
      orderCount: json['orderCount'] as String?,
      popularity: json['popularity'] as String?,
    );
  }
}

// Data model for Record (Consume or Refund)
class RecordItem {
  final String type;
  final int amount;
  final String orderNo;
  final String status;
  final String date;

  RecordItem({
    required this.type,
    required this.amount,
    required this.orderNo,
    required this.status,
    required this.date,
  });

  factory RecordItem.fromJson(Map<String, dynamic> json) {
    return RecordItem(
      type: json['type'] as String,
      amount: json['amount'] as int,
      orderNo: json['orderNo'] as String,
      status: json['status'] as String,
      date: json['date'] as String,
    );
  }
}

// Data model for Salesperson Info
class SalespersonInfo {
  final String id;
  final String name;
  final String avatar;
  final String inviteCode;
  final String qrCodeUrl;

  SalespersonInfo({
    required this.id,
    required this.name,
    required this.avatar,
    required this.inviteCode,
    required this.qrCodeUrl,
  });

  factory SalespersonInfo.fromJson(Map<String, dynamic> json) {
    return SalespersonInfo(
      id: json['id'].toString(),
      name: json['name'] as String,
      avatar: json['avatar'] as String,
      inviteCode: json['inviteCode'] as String,
      qrCodeUrl: json['qrCodeUrl'] as String,
    );
  }
}

class UserApi {
  /// User login with phone and code.
  Future<ApiResponse<Map<String, dynamic>>> login(BuildContext context, String phone, String code, {String? inviteCode}) async {
    if (phone.isEmpty || code.isEmpty) {
      return ApiResponse.error('手机号或验证码不能为空');
    }
    final Map<String, dynamic> data = {'phone': phone, 'code': code};
    if (inviteCode != null) data['inviteCode'] = inviteCode;
    return BaseApi.post(
      context,
      '/user/login',
      data,
      fromJsonT: (json) => {
        'token': json['token'] as String,
        'userInfo': UserInfo.fromJson(json['userInfo']),
      },
    );
  }

  /// Send verification code to phone.
  Future<ApiResponse<void>> sendCode(BuildContext context, String phone) async {
    if (phone.isEmpty || phone.length != 11) {
      return ApiResponse.error('请输入正确的手机号码');
    }
    return BaseApi.post(context, '/user/send-code', {'phone': phone});
  }

  /// Get user information.
  Future<ApiResponse<UserInfo>> getInfo(BuildContext context) async {
    return BaseApi.get(
      context,
      '/user/info',
      fromJsonT: (json) => UserInfo.fromJson(json['userInfo']),
    );
  }

  /// Get user coupons.
  Future<ApiResponse<List<Coupon>>> getCoupons(BuildContext context, {int? status}) async {
    final Map<String, dynamic> params = {};
    if (status != null) params['status'] = status;
    return BaseApi.get(
      context,
      '/user/coupons',
      queryParameters: params,
      fromJsonT: (json) => (json as List).map((e) => Coupon.fromJson(e)).toList(),
    );
  }

  /// Get coupon list (for coupon.vue page).
  Future<ApiResponse<List<Coupon>>> getCouponList(BuildContext context, {
    int? status,
    int current = 1,
    int size = 10,
  }) async {
    final Map<String, dynamic> params = {
      'current': current,
      'size': size,
    };
    if (status != null) params['status'] = status;
    return BaseApi.post(
      context,
      '/user/coupon/list',
      params,
      fromJsonT: (json) => (json['list'] as List).map((e) => Coupon.fromJson(e)).toList(),
    );
  }

  /// Use a coupon.
  Future<ApiResponse<void>> useCoupon(BuildContext context, String couponId) async {
    return BaseApi.post(context, '/user/coupon/use', {'couponId': couponId});
  }

  /// Get user address list.
  Future<ApiResponse<List<Address>>> getAddressList(BuildContext context) async {
    return BaseApi.get(
      context,
      '/user/address/list',
      fromJsonT: (json) => (json as List).map((e) => Address.fromJson(e)).toList(),
    );
  }

  /// Get user collection list.
  Future<ApiResponse<List<CollectItem>>> getCollectList(BuildContext context, String type, {int page = 1, int size = 10}) async {
    return BaseApi.get(
      context,
      '/user/collect/list',
      queryParameters: {'type': type, 'page': page, 'size': size},
      fromJsonT: (json) => (json['list'] as List).map((e) => CollectItem.fromJson(e)).toList(),
    );
  }

  /// Delete a collection item.
  Future<ApiResponse<void>> deleteCollect(BuildContext context, String id) async {
    return BaseApi.post(context, '/favorite/delete', {'id': id});
  }

  /// Get recommended technicians list.
  Future<ApiResponse<List<dynamic>>> getRecommendedTechs(BuildContext context) async {
    return BaseApi.get(
      context,
      '/user/recommended-techs',
      fromJsonT: (json) => json as List, // Assuming a list of generic objects
    );
  }

  /// Get service features list.
  Future<ApiResponse<List<Map<String, dynamic>>>> getServiceFeatures(BuildContext context) async {
    return BaseApi.get(
      context,
      '/user/service-features',
      fromJsonT: (json) => (json as List).map((e) => e as Map<String, dynamic>).toList(),
    );
  }

  /// Get consumption/refund records.
  Future<ApiResponse<List<RecordItem>>> getRecords(BuildContext context, String type, {int page = 1, int size = 10}) async {
    return BaseApi.get(
      context,
      '/user/records',
      queryParameters: {'type': type, 'page': page, 'size': size},
      fromJsonT: (json) => (json['list'] as List).map((e) => RecordItem.fromJson(e)).toList(),
    );
  }

  /// Update user information.
  Future<ApiResponse<UserInfo>> updateInfo(BuildContext context, UserInfo data) async {
    return BaseApi.post(
      context,
      '/user/update',
      data.toJson(),
      fromJsonT: (json) => UserInfo.fromJson(json['userInfo']),
    );
  }

  /// User login with password.
  Future<ApiResponse<Map<String, dynamic>>> loginWithPassword(BuildContext context, String phone, String password) async {
    if (phone.isEmpty || password.isEmpty) {
      return ApiResponse.error('手机号或密码不能为空');
    }
    return BaseApi.post(
      context,
      '/user/password-login',
      {'phone': phone, 'password': password},
      fromJsonT: (json) => {
        'token': json['token'] as String,
        'userInfo': UserInfo.fromJson(json['userInfo']),
      },
    );
  }

  /// User logout.
  Future<ApiResponse<void>> logout(BuildContext context) async {
    return BaseApi.post(context, '/user/logout', {});
  }

  /// Get user favorite list.
  Future<ApiResponse<List<CollectItem>>> getFavoriteList(BuildContext context, {
    int pageIndex = 1,
    int pageSize = 10,
  }) async {
    return BaseApi.post(
      context,
      '/favorite/list',
      {'pageIndex': pageIndex, 'pageSize': pageSize},
      fromJsonT: (json) => (json['list'] as List).map((e) => CollectItem.fromJson(e)).toList(),
    );
  }

  /// Get available coupons for claiming.
  Future<ApiResponse<List<Coupon>>> getAvailableCoupons(BuildContext context, {
    int current = 1,
    int size = 10,
    String? type,
  }) async {
    final Map<String, dynamic> params = {
      'current': current,
      'size': size,
    };
    if (type != null) params['type'] = type;
    return BaseApi.post(
      context,
      '/coupon/available',
      params,
      fromJsonT: (json) => (json['list'] as List).map((e) => Coupon.fromJson(e)).toList(),
    );
  }

  /// Receive a coupon.
  Future<ApiResponse<void>> receiveCoupon(BuildContext context, String couponId) async {
    if (couponId.isEmpty) {
      return ApiResponse.error('优惠券ID不能为空');
    }
    return BaseApi.post(context, '/coupon/receive', {'couponId': couponId});
  }

  /// Get invite QR code.
  Future<ApiResponse<String>> getInviteQRCode(BuildContext context, String inviteCode) async {
    if (inviteCode.isEmpty) {
      return ApiResponse.error('邀请码不能为空');
    }
    return BaseApi.get(
      context,
      '/user/invite/qrcode',
      queryParameters: {'inviteCode': inviteCode},
      fromJsonT: (json) => json['qrCodeUrl'] as String, // Assuming direct URL is returned
    );
  }

  /// WeChat login.
  Future<ApiResponse<Map<String, dynamic>>> wechatLogin(BuildContext context, String code, {String? inviteCode}) async {
    if (code.isEmpty) {
      return ApiResponse.error('WeChat code不能为空');
    }
    final Map<String, dynamic> data = {'code': code};
    if (inviteCode != null) data['inviteCode'] = inviteCode;
    return BaseApi.post(
      context,
      '/user/wechat-login',
      data,
      fromJsonT: (json) => {
        'token': json['token'] as String,
        'userInfo': UserInfo.fromJson(json['userInfo']),
      },
    );
  }

  /// Bind phone number.
  Future<ApiResponse<UserInfo>> bindPhone(BuildContext context, {
    required String phone,
    required String code,
    required String openid,
  }) async {
    if (phone.isEmpty || code.isEmpty || openid.isEmpty) {
      return ApiResponse.error('手机号、验证码或OpenID不能为空');
    }
    return BaseApi.post(
      context,
      '/user/bind-phone',
      {'phone': phone, 'code': code, 'openid': openid},
      fromJsonT: (json) => UserInfo.fromJson(json['userInfo']),
    );
  }

  /// Update user location information.
  Future<ApiResponse<void>> updateUserLocation(BuildContext context, {
    required double latitude,
    required double longitude,
  }) async {
    return BaseApi.post(context, '/user/update-location', {'latitude': latitude, 'longitude': longitude});
  }

  /// Get openid by WeChat code.
  Future<ApiResponse<String>> getOpenidByCode(BuildContext context, String code) async {
    if (code.isEmpty) {
      return ApiResponse.error('WeChat code不能为空');
    }
    return BaseApi.post(
      context,
      '/user/wechat/openid',
      {'code': code},
      fromJsonT: (json) => json['openid'] as String, // Assuming openid is directly returned
    );
  }

  /// Get salesperson information (invite page data).
  Future<ApiResponse<SalespersonInfo>> getSalespersonInfo(BuildContext context) async {
    return BaseApi.get(
      context,
      '/user/salesperson',
      fromJsonT: (json) => SalespersonInfo.fromJson(json),
    );
  }

  /// Bind WeChat account.
  Future<ApiResponse<UserInfo>> bindWx(BuildContext context, String code) async {
    if (code.isEmpty) {
      return ApiResponse.error('微信授权code不能为空');
    }
    return BaseApi.post(
      context,
      '/user/bindWx',
      {'code': code},
      fromJsonT: (json) => UserInfo.fromJson(json['userInfo']),
    );
  }

  /// Get popup coupon information.
  Future<ApiResponse<Coupon?>> getPopupCouponInfo(BuildContext context) async {
    return BaseApi.get(
      context,
      '/coupon/popupCouponInfo',
      fromJsonT: (json) => json != null ? Coupon.fromJson(json) : null,
    );
  }
}