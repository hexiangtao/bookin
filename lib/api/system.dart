import 'package:bookin/api/base.dart';
import 'package:flutter/material.dart'; // Import for BuildContext

// Data model for system configuration
class SystemConfig {
  final String appName;
  final String appLogoUrl;
  final String customerServicePhone;
  final String customerServiceWechat;
  final String privacyPolicyUrl;
  final String userAgreementUrl;

  SystemConfig({
    required this.appName,
    required this.appLogoUrl,
    required this.customerServicePhone,
    required this.customerServiceWechat,
    required this.privacyPolicyUrl,
    required this.userAgreementUrl,
  });

  factory SystemConfig.fromJson(Map<String, dynamic> json) {
    return SystemConfig(
      appName: json['appName'] as String,
      appLogoUrl: json['appLogoUrl'] as String,
      customerServicePhone: json['customerServicePhone'] as String,
      customerServiceWechat: json['customerServiceWechat'] as String,
      privacyPolicyUrl: json['privacyPolicyUrl'] as String,
      userAgreementUrl: json['userAgreementUrl'] as String,
    );
  }
}

// Data model for customer service information
class CustomerServiceInfo {
  final String phone;
  final String wechat;
  final String? workingHours;

  CustomerServiceInfo({
    required this.phone,
    required this.wechat,
    this.workingHours,
  });

  factory CustomerServiceInfo.fromJson(Map<String, dynamic> json) {
    return CustomerServiceInfo(
      phone: json['phone'] as String,
      wechat: json['wechat'] as String,
      workingHours: json['workingHours'] as String?,
    );
  }
}

// Data model for app version information
class AppVersionInfo {
  final String versionName;
  final int versionCode;
  final String updateLog;
  final String downloadUrl;
  final bool forceUpdate;

  AppVersionInfo({
    required this.versionName,
    required this.versionCode,
    required this.updateLog,
    required this.downloadUrl,
    required this.forceUpdate,
  });

  factory AppVersionInfo.fromJson(Map<String, dynamic> json) {
    return AppVersionInfo(
      versionName: json['versionName'] as String,
      versionCode: json['versionCode'] as int,
      updateLog: json['updateLog'] as String,
      downloadUrl: json['downloadUrl'] as String,
      forceUpdate: json['forceUpdate'] as bool,
    );
  }
}

// Data model for a notice/announcement
class Notice {
  final String id;
  final String title;
  final String content;
  final String publishDate;

  Notice({
    required this.id,
    required this.title,
    required this.content,
    required this.publishDate,
  });

  factory Notice.fromJson(Map<String, dynamic> json) {
    return Notice(
      id: json['id'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      publishDate: json['publishDate'] as String,
    );
  }
}

class SystemApi {
  /// Get system configuration information.
  Future<ApiResponse<SystemConfig>> getSystemConfig(BuildContext context) async {
    return BaseApi.get(
      context,
      '/system/config',
      fromJsonT: (json) => SystemConfig.fromJson(json),
    );
  }

  /// Get customer service information.
  Future<ApiResponse<CustomerServiceInfo>> getCustomerService(BuildContext context) async {
    return BaseApi.get(
      context,
      '/app/config',
      fromJsonT: (json) => CustomerServiceInfo.fromJson(json),
    );
  }

  /// Get application version information.
  Future<ApiResponse<AppVersionInfo>> getAppVersion(BuildContext context) async {
    return BaseApi.get(
      context,
      '/system/version',
      fromJsonT: (json) => AppVersionInfo.fromJson(json),
    );
  }

  /// Get notices/announcements.
  Future<ApiResponse<List<Notice>>> getNotices(BuildContext context) async {
    return BaseApi.get(
      context,
      '/system/notices',
      fromJsonT: (json) => (json as List).map((e) => Notice.fromJson(e)).toList(),
    );
  }
}