// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_config_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

QuickFunctionConfig _$QuickFunctionConfigFromJson(Map<String, dynamic> json) =>
    QuickFunctionConfig(
      key: json['key'] as String,
      title: json['title'] as String,
      icon: json['icon'] as String,
      url: json['url'] as String,
      enabled: json['enabled'] as bool? ?? true,
    );

Map<String, dynamic> _$QuickFunctionConfigToJson(
  QuickFunctionConfig instance,
) => <String, dynamic>{
  'key': instance.key,
  'title': instance.title,
  'icon': instance.icon,
  'url': instance.url,
  'enabled': instance.enabled,
};

ToolConfigItem _$ToolConfigItemFromJson(Map<String, dynamic> json) =>
    ToolConfigItem(
      key: json['key'] as String,
      title: json['title'] as String,
      icon: json['icon'] as String,
      url: json['url'] as String,
      enabled: json['enabled'] as bool? ?? true,
      order: (json['order'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$ToolConfigItemToJson(ToolConfigItem instance) =>
    <String, dynamic>{
      'key': instance.key,
      'title': instance.title,
      'icon': instance.icon,
      'url': instance.url,
      'enabled': instance.enabled,
      'order': instance.order,
    };

LayoutConfig _$LayoutConfigFromJson(Map<String, dynamic> json) => LayoutConfig(
  type: json['type'] as String? ?? 'card',
  showOrderStatus: json['showOrderStatus'] as bool? ?? false,
);

Map<String, dynamic> _$LayoutConfigToJson(LayoutConfig instance) =>
    <String, dynamic>{
      'type': instance.type,
      'showOrderStatus': instance.showOrderStatus,
    };

OrderStatusItem _$OrderStatusItemFromJson(Map<String, dynamic> json) =>
    OrderStatusItem(
      key: json['key'] as String,
      title: json['title'] as String,
      count: (json['count'] as num?)?.toInt() ?? 0,
      url: json['url'] as String,
    );

Map<String, dynamic> _$OrderStatusItemToJson(OrderStatusItem instance) =>
    <String, dynamic>{
      'key': instance.key,
      'title': instance.title,
      'count': instance.count,
      'url': instance.url,
    };

ModuleConfigs _$ModuleConfigsFromJson(Map<String, dynamic> json) =>
    ModuleConfigs(
      showWallet: json['showWallet'] as bool? ?? true,
      showMembership: json['showMembership'] as bool? ?? true,
      showInviteFriends: json['showInviteFriends'] as bool? ?? true,
      showQuickFunctions: json['showQuickFunctions'] as bool? ?? true,
      showToolsSection: json['showToolsSection'] as bool? ?? true,
    );

Map<String, dynamic> _$ModuleConfigsToJson(ModuleConfigs instance) =>
    <String, dynamic>{
      'showWallet': instance.showWallet,
      'showMembership': instance.showMembership,
      'showInviteFriends': instance.showInviteFriends,
      'showQuickFunctions': instance.showQuickFunctions,
      'showToolsSection': instance.showToolsSection,
    };

UserInfoConfig _$UserInfoConfigFromJson(Map<String, dynamic> json) =>
    UserInfoConfig(
      id: (json['id'] as num).toInt(),
      avatar: json['avatar'] as String?,
      nickname: json['nickname'] as String,
      phone: json['phone'] as String,
      balance: (json['balance'] as num?)?.toInt() ?? 0,
      points: (json['points'] as num?)?.toInt() ?? 0,
      level: (json['level'] as num?)?.toInt() ?? 1,
      levelName: json['levelName'] as String? ?? '普通',
      openid: json['openid'] as String?,
      needBindWx: json['needBindWx'] as bool? ?? false,
      cityCode: json['cityCode'] as String?,
      cityName: json['cityName'] as String?,
      isTechnician: json['isTechnician'] as bool? ?? false,
      isAdmin: json['isAdmin'] as bool? ?? false,
      vipStatus: (json['vipStatus'] as num?)?.toInt() ?? 0,
      vipDiscountPercent: json['vipDiscountPercent'] as String? ?? '100',
      vipStatusDesc: json['vipStatusDesc'] as String? ?? '普通用户',
      expireDate: json['expireDate'] as String?,
      servicePhone: json['servicePhone'] as String?,
      layoutConfig: json['layoutConfig'] == null
          ? null
          : LayoutConfig.fromJson(json['layoutConfig'] as Map<String, dynamic>),
      orderStatusItems:
          (json['orderStatusItems'] as List<dynamic>?)
              ?.map((e) => OrderStatusItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      quickFunctionConfigs:
          (json['quickFunctionConfigs'] as List<dynamic>?)
              ?.map(
                (e) => QuickFunctionConfig.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          const [],
      toolConfigItems:
          (json['toolConfigItems'] as List<dynamic>?)
              ?.map((e) => ToolConfigItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      moduleConfigs: ModuleConfigs.fromJson(
        json['moduleConfigs'] as Map<String, dynamic>,
      ),
    );

Map<String, dynamic> _$UserInfoConfigToJson(UserInfoConfig instance) =>
    <String, dynamic>{
      'id': instance.id,
      'avatar': instance.avatar,
      'nickname': instance.nickname,
      'phone': instance.phone,
      'balance': instance.balance,
      'points': instance.points,
      'level': instance.level,
      'levelName': instance.levelName,
      'openid': instance.openid,
      'needBindWx': instance.needBindWx,
      'cityCode': instance.cityCode,
      'cityName': instance.cityName,
      'isTechnician': instance.isTechnician,
      'isAdmin': instance.isAdmin,
      'vipStatus': instance.vipStatus,
      'vipDiscountPercent': instance.vipDiscountPercent,
      'vipStatusDesc': instance.vipStatusDesc,
      'expireDate': instance.expireDate,
      'servicePhone': instance.servicePhone,
      'layoutConfig': instance.layoutConfig,
      'orderStatusItems': instance.orderStatusItems,
      'quickFunctionConfigs': instance.quickFunctionConfigs,
      'toolConfigItems': instance.toolConfigItems,
      'moduleConfigs': instance.moduleConfigs,
    };

OrderCount _$OrderCountFromJson(Map<String, dynamic> json) => OrderCount(
  all: (json['all'] as num?)?.toInt() ?? 0,
  unpaid: (json['unpaid'] as num?)?.toInt() ?? 0,
  unserved: (json['unserved'] as num?)?.toInt() ?? 0,
  uncomment: (json['uncomment'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$OrderCountToJson(OrderCount instance) =>
    <String, dynamic>{
      'all': instance.all,
      'unpaid': instance.unpaid,
      'unserved': instance.unserved,
      'uncomment': instance.uncomment,
    };

UserInfoResponse _$UserInfoResponseFromJson(
  Map<String, dynamic> json,
) => UserInfoResponse(
  userInfo: UserInfoConfig.fromJson(json['userInfo'] as Map<String, dynamic>),
  orderCount: OrderCount.fromJson(json['orderCount'] as Map<String, dynamic>),
  couponCount: (json['couponCount'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$UserInfoResponseToJson(UserInfoResponse instance) =>
    <String, dynamic>{
      'userInfo': instance.userInfo,
      'orderCount': instance.orderCount,
      'couponCount': instance.couponCount,
    };
