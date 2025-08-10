// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserModel _$UserModelFromJson(Map<String, dynamic> json) => UserModel(
  id: json['id'] as String,
  phone: json['phone'] as String,
  nickname: json['nickname'] as String,
  avatar: json['avatar'] as String?,
  gender: (json['gender'] as num?)?.toInt() ?? 0,
  birthday: json['birthday'] as String?,
  email: json['email'] as String?,
  isVerified: json['isVerified'] as bool? ?? false,
  level: (json['level'] as num?)?.toInt() ?? 1,
  points: (json['points'] as num?)?.toInt() ?? 0,
  balance: (json['balance'] as num?)?.toInt() ?? 0,
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
  lastLoginAt: json['lastLoginAt'] == null
      ? null
      : DateTime.parse(json['lastLoginAt'] as String),
  status: (json['status'] as num?)?.toInt() ?? 0,
  referralCode: json['referralCode'] as String?,
  referrerId: json['referrerId'] as String?,
  tags: (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList(),
  preferences: json['preferences'] == null
      ? null
      : UserPreferences.fromJson(json['preferences'] as Map<String, dynamic>),
  statistics: json['statistics'] == null
      ? null
      : UserStatistics.fromJson(json['statistics'] as Map<String, dynamic>),
);

Map<String, dynamic> _$UserModelToJson(UserModel instance) => <String, dynamic>{
  'id': instance.id,
  'phone': instance.phone,
  'nickname': instance.nickname,
  'avatar': instance.avatar,
  'gender': instance.gender,
  'birthday': instance.birthday,
  'email': instance.email,
  'isVerified': instance.isVerified,
  'level': instance.level,
  'points': instance.points,
  'balance': instance.balance,
  'createdAt': instance.createdAt?.toIso8601String(),
  'lastLoginAt': instance.lastLoginAt?.toIso8601String(),
  'status': instance.status,
  'referralCode': instance.referralCode,
  'referrerId': instance.referrerId,
  'tags': instance.tags,
  'preferences': instance.preferences,
  'statistics': instance.statistics,
};

UserPreferences _$UserPreferencesFromJson(Map<String, dynamic> json) =>
    UserPreferences(
      pushNotification: json['pushNotification'] as bool? ?? true,
      smsNotification: json['smsNotification'] as bool? ?? true,
      emailNotification: json['emailNotification'] as bool? ?? false,
      marketingNotification: json['marketingNotification'] as bool? ?? false,
      language: json['language'] as String? ?? 'zh-CN',
      theme: json['theme'] as String? ?? 'auto',
      defaultAddressId: json['defaultAddressId'] as String?,
      preferredServices: (json['preferredServices'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$UserPreferencesToJson(UserPreferences instance) =>
    <String, dynamic>{
      'pushNotification': instance.pushNotification,
      'smsNotification': instance.smsNotification,
      'emailNotification': instance.emailNotification,
      'marketingNotification': instance.marketingNotification,
      'language': instance.language,
      'theme': instance.theme,
      'defaultAddressId': instance.defaultAddressId,
      'preferredServices': instance.preferredServices,
    };

UserStatistics _$UserStatisticsFromJson(Map<String, dynamic> json) =>
    UserStatistics(
      totalOrders: (json['totalOrders'] as num?)?.toInt() ?? 0,
      completedOrders: (json['completedOrders'] as num?)?.toInt() ?? 0,
      cancelledOrders: (json['cancelledOrders'] as num?)?.toInt() ?? 0,
      totalSpent: (json['totalSpent'] as num?)?.toInt() ?? 0,
      totalSaved: (json['totalSaved'] as num?)?.toInt() ?? 0,
      averageRating: (json['averageRating'] as num?)?.toDouble() ?? 0.0,
      favoriteTechnicians: (json['favoriteTechnicians'] as num?)?.toInt() ?? 0,
      usedCoupons: (json['usedCoupons'] as num?)?.toInt() ?? 0,
      referralCount: (json['referralCount'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$UserStatisticsToJson(UserStatistics instance) =>
    <String, dynamic>{
      'totalOrders': instance.totalOrders,
      'completedOrders': instance.completedOrders,
      'cancelledOrders': instance.cancelledOrders,
      'totalSpent': instance.totalSpent,
      'totalSaved': instance.totalSaved,
      'averageRating': instance.averageRating,
      'favoriteTechnicians': instance.favoriteTechnicians,
      'usedCoupons': instance.usedCoupons,
      'referralCount': instance.referralCount,
    };
