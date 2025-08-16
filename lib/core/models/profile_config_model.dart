import 'package:json_annotation/json_annotation.dart';

part 'profile_config_model.g.dart';

/// 快捷功能配置
@JsonSerializable()
class QuickFunctionConfig {
  @JsonKey(name: 'key')
  final String key;
  
  @JsonKey(name: 'title')
  final String title;
  
  @JsonKey(name: 'icon')
  final String icon;
  
  @JsonKey(name: 'url')
  final String url;
  
  @JsonKey(name: 'enabled')
  final bool enabled;
  
  const QuickFunctionConfig({
    required this.key,
    required this.title,
    required this.icon,
    required this.url,
    this.enabled = true,
  });
  
  factory QuickFunctionConfig.fromJson(Map<String, dynamic> json) => 
      _$QuickFunctionConfigFromJson(json);
  
  Map<String, dynamic> toJson() => _$QuickFunctionConfigToJson(this);
}

/// 工具配置项
@JsonSerializable()
class ToolConfigItem {
  @JsonKey(name: 'key')
  final String key;
  
  @JsonKey(name: 'title')
  final String title;
  
  @JsonKey(name: 'icon')
  final String icon;
  
  @JsonKey(name: 'url')
  final String url;
  
  @JsonKey(name: 'enabled')
  final bool enabled;
  
  @JsonKey(name: 'order')
  final int order;
  
  const ToolConfigItem({
    required this.key,
    required this.title,
    required this.icon,
    required this.url,
    this.enabled = true,
    this.order = 0,
  });
  
  factory ToolConfigItem.fromJson(Map<String, dynamic> json) => 
      _$ToolConfigItemFromJson(json);
  
  Map<String, dynamic> toJson() => _$ToolConfigItemToJson(this);
}

/// 布局配置
@JsonSerializable()
class LayoutConfig {
  @JsonKey(name: 'type')
  final String type;
  
  @JsonKey(name: 'showOrderStatus')
  final bool showOrderStatus;
  
  const LayoutConfig({
    this.type = 'card',
    this.showOrderStatus = false,
  });
  
  factory LayoutConfig.fromJson(Map<String, dynamic> json) => 
      _$LayoutConfigFromJson(json);
  
  Map<String, dynamic> toJson() => _$LayoutConfigToJson(this);
}

/// 订单状态项
@JsonSerializable()
class OrderStatusItem {
  @JsonKey(name: 'key')
  final String key;
  
  @JsonKey(name: 'title')
  final String title;
  
  @JsonKey(name: 'count')
  final int count;
  
  @JsonKey(name: 'url')
  final String url;
  
  const OrderStatusItem({
    required this.key,
    required this.title,
    this.count = 0,
    required this.url,
  });
  
  factory OrderStatusItem.fromJson(Map<String, dynamic> json) => 
      _$OrderStatusItemFromJson(json);
  
  Map<String, dynamic> toJson() => _$OrderStatusItemToJson(this);
}

/// 模块配置
@JsonSerializable()
class ModuleConfigs {
  @JsonKey(name: 'showWallet')
  final bool showWallet;
  
  @JsonKey(name: 'showMembership')
  final bool showMembership;
  
  @JsonKey(name: 'showInviteFriends')
  final bool showInviteFriends;
  
  @JsonKey(name: 'showQuickFunctions')
  final bool showQuickFunctions;
  
  @JsonKey(name: 'showToolsSection')
  final bool showToolsSection;
  
  const ModuleConfigs({
    this.showWallet = true,
    this.showMembership = true,
    this.showInviteFriends = true,
    this.showQuickFunctions = true,
    this.showToolsSection = true,
  });
  
  factory ModuleConfigs.fromJson(Map<String, dynamic> json) => 
      _$ModuleConfigsFromJson(json);
  
  Map<String, dynamic> toJson() => _$ModuleConfigsToJson(this);
}

/// 用户信息配置（扩展原有UserModel）
@JsonSerializable()
class UserInfoConfig {
  @JsonKey(name: 'id')
  final int id;
  
  @JsonKey(name: 'avatar')
  final String? avatar;
  
  @JsonKey(name: 'nickname')
  final String nickname;
  
  @JsonKey(name: 'phone')
  final String phone;
  
  @JsonKey(name: 'balance')
  final int balance;
  
  @JsonKey(name: 'points')
  final int points;
  
  @JsonKey(name: 'level')
  final int level;
  
  @JsonKey(name: 'levelName')
  final String levelName;
  
  @JsonKey(name: 'openid')
  final String? openid;
  
  @JsonKey(name: 'needBindWx')
  final bool needBindWx;
  
  @JsonKey(name: 'cityCode')
  final String? cityCode;
  
  @JsonKey(name: 'cityName')
  final String? cityName;
  
  @JsonKey(name: 'isTechnician')
  final bool isTechnician;
  
  @JsonKey(name: 'isAdmin')
  final bool isAdmin;
  
  @JsonKey(name: 'vipStatus')
  final int vipStatus;
  
  @JsonKey(name: 'vipDiscountPercent')
  final String vipDiscountPercent;
  
  @JsonKey(name: 'vipStatusDesc')
  final String vipStatusDesc;
  
  @JsonKey(name: 'expireDate')
  final String? expireDate;
  
  @JsonKey(name: 'servicePhone')
  final String? servicePhone;
  
  @JsonKey(name: 'layoutConfig')
  final LayoutConfig? layoutConfig;
  
  @JsonKey(name: 'orderStatusItems')
  final List<OrderStatusItem> orderStatusItems;
  
  @JsonKey(name: 'quickFunctionConfigs')
  final List<QuickFunctionConfig> quickFunctionConfigs;
  
  @JsonKey(name: 'toolConfigItems')
  final List<ToolConfigItem> toolConfigItems;
  
  @JsonKey(name: 'moduleConfigs')
  final ModuleConfigs moduleConfigs;
  
  const UserInfoConfig({
    required this.id,
    this.avatar,
    required this.nickname,
    required this.phone,
    this.balance = 0,
    this.points = 0,
    this.level = 1,
    this.levelName = '普通',
    this.openid,
    this.needBindWx = false,
    this.cityCode,
    this.cityName,
    this.isTechnician = false,
    this.isAdmin = false,
    this.vipStatus = 0,
    this.vipDiscountPercent = '100',
    this.vipStatusDesc = '普通用户',
    this.expireDate,
    this.servicePhone,
    this.layoutConfig,
    this.orderStatusItems = const [],
    this.quickFunctionConfigs = const [],
    this.toolConfigItems = const [],
    required this.moduleConfigs,
  });
  
  factory UserInfoConfig.fromJson(Map<String, dynamic> json) => 
      _$UserInfoConfigFromJson(json);
  
  Map<String, dynamic> toJson() => _$UserInfoConfigToJson(this);
  
  /// 获取余额（元）
  double get balanceYuan => balance / 100.0;
  
  /// 获取启用的快捷功能
  List<QuickFunctionConfig> get enabledQuickFunctions => 
      quickFunctionConfigs.where((config) => config.enabled).toList();
  
  /// 获取启用的工具项（按order排序）
  List<ToolConfigItem> get enabledToolItems {
    final items = toolConfigItems.where((item) => item.enabled).toList();
    items.sort((a, b) => a.order.compareTo(b.order));
    return items;
  }
}

/// 订单统计
@JsonSerializable()
class OrderCount {
  @JsonKey(name: 'all')
  final int all;
  
  @JsonKey(name: 'unpaid')
  final int unpaid;
  
  @JsonKey(name: 'unserved')
  final int unserved;
  
  @JsonKey(name: 'uncomment')
  final int uncomment;
  
  const OrderCount({
    this.all = 0,
    this.unpaid = 0,
    this.unserved = 0,
    this.uncomment = 0,
  });
  
  factory OrderCount.fromJson(Map<String, dynamic> json) => 
      _$OrderCountFromJson(json);
  
  Map<String, dynamic> toJson() => _$OrderCountToJson(this);
}

/// 完整的用户信息响应数据
@JsonSerializable()
class UserInfoResponse {
  @JsonKey(name: 'userInfo')
  final UserInfoConfig userInfo;
  
  @JsonKey(name: 'orderCount')
  final OrderCount orderCount;
  
  @JsonKey(name: 'couponCount')
  final int couponCount;
  
  const UserInfoResponse({
    required this.userInfo,
    required this.orderCount,
    this.couponCount = 0,
  });
  
  factory UserInfoResponse.fromJson(Map<String, dynamic> json) => 
      _$UserInfoResponseFromJson(json);
  
  Map<String, dynamic> toJson() => _$UserInfoResponseToJson(this);
}