import 'package:json_annotation/json_annotation.dart';
import 'base_model.dart';

part 'user_model.g.dart';

@JsonSerializable()
class UserModel {
  /// 用户ID
  @JsonKey(name: 'id', fromJson: _idFromJson)
  final String id;
  
  static String _idFromJson(dynamic value) {
    if (value is int) {
      return value.toString();
    }
    return value as String;
  }
  
  /// 手机号
  @JsonKey(name: 'phone')
  final String phone;
  
  /// 昵称
  @JsonKey(name: 'nickname')
  final String nickname;
  
  /// 头像URL
  @JsonKey(name: 'avatar')
  final String? avatar;
  
  /// 性别 (0: 未知, 1: 男, 2: 女)
  @JsonKey(name: 'gender')
  final int gender;
  
  /// 生日
  @JsonKey(name: 'birthday')
  final String? birthday;
  
  /// 邮箱
  @JsonKey(name: 'email')
  final String? email;
  
  /// 实名认证状态
  @JsonKey(name: 'isVerified')
  final bool isVerified;
  
  /// 用户等级
  @JsonKey(name: 'level')
  final int level;
  
  /// 积分
  @JsonKey(name: 'points')
  final int points;
  
  /// 余额（分）
  @JsonKey(name: 'balance')
  final int balance;
  
  /// 注册时间
  @JsonKey(name: 'createdAt')
  final DateTime? createdAt;
  
  /// 最后登录时间
  @JsonKey(name: 'lastLoginAt')
  final DateTime? lastLoginAt;
  
  /// 用户状态 (0: 正常, 1: 禁用)
  @JsonKey(name: 'status')
  final int status;
  
  /// 推荐码
  @JsonKey(name: 'referralCode')
  final String? referralCode;
  
  /// 推荐人ID
  @JsonKey(name: 'referrerId', fromJson: _referrerIdFromJson)
  final String? referrerId;
  
  static String? _referrerIdFromJson(dynamic value) {
    if (value == null) return null;
    if (value is int) {
      return value.toString();
    }
    return value as String;
  }
  
  /// 用户标签
  @JsonKey(name: 'tags')
  final List<String>? tags;
  
  /// 用户偏好设置
  @JsonKey(name: 'preferences')
  final UserPreferences? preferences;
  
  /// 用户统计信息
  @JsonKey(name: 'statistics')
  final UserStatistics? statistics;
  
  /// 用户类型 (customer: 客户, technician: 技师)
  @JsonKey(name: 'userType')
  final String? userType;
  
  const UserModel({
    required this.id,
    required this.phone,
    required this.nickname,
    this.avatar,
    this.gender = 0,
    this.birthday,
    this.email,
    this.isVerified = false,
    this.level = 1,
    this.points = 0,
    this.balance = 0,
    this.createdAt,
    this.lastLoginAt,
    this.status = 0,
    this.referralCode,
    this.referrerId,
    this.tags,
    this.preferences,
    this.statistics,
    this.userType,
  });
  
  factory UserModel.fromJson(Map<String, dynamic> json) => _$UserModelFromJson(json);
  
  Map<String, dynamic> toJson() => _$UserModelToJson(this);
  
  bool isValid() {
    return id.isNotEmpty && phone.isNotEmpty && nickname.isNotEmpty;
  }
  
  /// 获取性别文本
  String get genderText {
    switch (gender) {
      case 1:
        return '男';
      case 2:
        return '女';
      default:
        return '未知';
    }
  }
  
  /// 获取用户等级文本
  String get levelText {
    switch (level) {
      case 1:
        return '普通用户';
      case 2:
        return 'VIP用户';
      case 3:
        return '黄金用户';
      case 4:
        return '钻石用户';
      default:
        return '普通用户';
    }
  }
  
  /// 获取余额（元）
  double get balanceYuan => balance / 100.0;
  
  /// 是否为正常状态
  bool get isActive => status == 0;
  
  /// 是否为技师
  bool get isTechnician => userType == 'technician';
  
  /// 是否已完善个人信息
  bool get isProfileComplete {
    return nickname.isNotEmpty && 
           avatar != null && 
           avatar!.isNotEmpty &&
           birthday != null &&
           email != null &&
           email!.isNotEmpty;
  }
  
  /// 复制并更新用户信息
  UserModel copyWith({
    String? id,
    String? phone,
    String? nickname,
    String? avatar,
    int? gender,
    String? birthday,
    String? email,
    bool? isVerified,
    int? level,
    int? points,
    int? balance,
    DateTime? createdAt,
    DateTime? lastLoginAt,
    int? status,
    String? referralCode,
    String? referrerId,
    List<String>? tags,
    UserPreferences? preferences,
    UserStatistics? statistics,
  }) {
    return UserModel(
      id: id ?? this.id,
      phone: phone ?? this.phone,
      nickname: nickname ?? this.nickname,
      avatar: avatar ?? this.avatar,
      gender: gender ?? this.gender,
      birthday: birthday ?? this.birthday,
      email: email ?? this.email,
      isVerified: isVerified ?? this.isVerified,
      level: level ?? this.level,
      points: points ?? this.points,
      balance: balance ?? this.balance,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      status: status ?? this.status,
      referralCode: referralCode ?? this.referralCode,
      referrerId: referrerId ?? this.referrerId,
      tags: tags ?? this.tags,
      preferences: preferences ?? this.preferences,
      statistics: statistics ?? this.statistics,
    );
  }
  
  @override
  String toString() {
    return 'UserModel{id: $id, phone: $phone, nickname: $nickname, level: $level}';
  }
}

/// 用户偏好设置
@JsonSerializable()
class UserPreferences {
  /// 是否接收推送通知
  @JsonKey(name: 'pushNotification')
  final bool pushNotification;
  
  /// 是否接收短信通知
  @JsonKey(name: 'smsNotification')
  final bool smsNotification;
  
  /// 是否接收邮件通知
  @JsonKey(name: 'emailNotification')
  final bool emailNotification;
  
  /// 是否接收营销信息
  @JsonKey(name: 'marketingNotification')
  final bool marketingNotification;
  
  /// 语言设置
  @JsonKey(name: 'language')
  final String language;
  
  /// 主题设置 (light, dark, auto)
  @JsonKey(name: 'theme')
  final String theme;
  
  /// 默认服务地址ID
  @JsonKey(name: 'defaultAddressId')
  final String? defaultAddressId;
  
  /// 常用服务类型
  @JsonKey(name: 'preferredServices')
  final List<String>? preferredServices;
  
  const UserPreferences({
    this.pushNotification = true,
    this.smsNotification = true,
    this.emailNotification = false,
    this.marketingNotification = false,
    this.language = 'zh-CN',
    this.theme = 'auto',
    this.defaultAddressId,
    this.preferredServices,
  });
  
  factory UserPreferences.fromJson(Map<String, dynamic> json) => _$UserPreferencesFromJson(json);
  
  Map<String, dynamic> toJson() => _$UserPreferencesToJson(this);
  
  UserPreferences copyWith({
    bool? pushNotification,
    bool? smsNotification,
    bool? emailNotification,
    bool? marketingNotification,
    String? language,
    String? theme,
    String? defaultAddressId,
    List<String>? preferredServices,
  }) {
    return UserPreferences(
      pushNotification: pushNotification ?? this.pushNotification,
      smsNotification: smsNotification ?? this.smsNotification,
      emailNotification: emailNotification ?? this.emailNotification,
      marketingNotification: marketingNotification ?? this.marketingNotification,
      language: language ?? this.language,
      theme: theme ?? this.theme,
      defaultAddressId: defaultAddressId ?? this.defaultAddressId,
      preferredServices: preferredServices ?? this.preferredServices,
    );
  }
}

/// 用户统计信息
@JsonSerializable()
class UserStatistics {
  /// 总订单数
  @JsonKey(name: 'totalOrders')
  final int totalOrders;
  
  /// 已完成订单数
  @JsonKey(name: 'completedOrders')
  final int completedOrders;
  
  /// 取消订单数
  @JsonKey(name: 'cancelledOrders')
  final int cancelledOrders;
  
  /// 总消费金额（分）
  @JsonKey(name: 'totalSpent')
  final int totalSpent;
  
  /// 总节省金额（分）
  @JsonKey(name: 'totalSaved')
  final int totalSaved;
  
  /// 平均评分
  @JsonKey(name: 'averageRating')
  final double averageRating;
  
  /// 收藏技师数
  @JsonKey(name: 'favoriteTechnicians')
  final int favoriteTechnicians;
  
  /// 使用优惠券数
  @JsonKey(name: 'usedCoupons')
  final int usedCoupons;
  
  /// 推荐成功数
  @JsonKey(name: 'referralCount')
  final int referralCount;
  
  const UserStatistics({
    this.totalOrders = 0,
    this.completedOrders = 0,
    this.cancelledOrders = 0,
    this.totalSpent = 0,
    this.totalSaved = 0,
    this.averageRating = 0.0,
    this.favoriteTechnicians = 0,
    this.usedCoupons = 0,
    this.referralCount = 0,
  });
  
  factory UserStatistics.fromJson(Map<String, dynamic> json) => _$UserStatisticsFromJson(json);
  
  Map<String, dynamic> toJson() => _$UserStatisticsToJson(this);
  
  /// 获取总消费金额（元）
  double get totalSpentYuan => totalSpent / 100.0;
  
  /// 获取总节省金额（元）
  double get totalSavedYuan => totalSaved / 100.0;
  
  /// 获取订单完成率
  double get completionRate {
    if (totalOrders == 0) return 0.0;
    return completedOrders / totalOrders;
  }
  
  /// 获取订单取消率
  double get cancellationRate {
    if (totalOrders == 0) return 0.0;
    return cancelledOrders / totalOrders;
  }
  
  UserStatistics copyWith({
    int? totalOrders,
    int? completedOrders,
    int? cancelledOrders,
    int? totalSpent,
    int? totalSaved,
    double? averageRating,
    int? favoriteTechnicians,
    int? usedCoupons,
    int? referralCount,
  }) {
    return UserStatistics(
      totalOrders: totalOrders ?? this.totalOrders,
      completedOrders: completedOrders ?? this.completedOrders,
      cancelledOrders: cancelledOrders ?? this.cancelledOrders,
      totalSpent: totalSpent ?? this.totalSpent,
      totalSaved: totalSaved ?? this.totalSaved,
      averageRating: averageRating ?? this.averageRating,
      favoriteTechnicians: favoriteTechnicians ?? this.favoriteTechnicians,
      usedCoupons: usedCoupons ?? this.usedCoupons,
      referralCount: referralCount ?? this.referralCount,
    );
  }
}