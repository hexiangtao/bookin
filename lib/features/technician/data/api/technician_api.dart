import 'package:bookin/features/shared/services/base_api.dart';
import 'package:flutter/material.dart'; // Import for BuildContext

// Data model for Technician Schedule
class TechnicianSchedule {
  final int weekDay;
  final String startTime;
  final String endTime;
  final bool available;

  TechnicianSchedule({
    required this.weekDay,
    required this.startTime,
    required this.endTime,
    required this.available,
  });

  factory TechnicianSchedule.fromJson(Map<String, dynamic> json) {
    return TechnicianSchedule(
      weekDay: json['weekDay'] as int,
      startTime: json['startTime'] as String,
      endTime: json['endTime'] as String,
      available: json['available'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'weekDay': weekDay,
      'startTime': startTime,
      'endTime': endTime,
      'available': available,
    };
  }
}

// Data model for Technician Info (Profile)
class TechnicianInfo {
  final String id;
  final String nickname;
  final int gender;
  final String phone;
  final String? birthday;
  final String? experience;
  final String? tags;
  final String? description;
  final String? wechat;
  final String? avatar;
  final String? workStatus;

  TechnicianInfo({
    required this.id,
    required this.nickname,
    required this.gender,
    required this.phone,
    this.birthday,
    this.experience,
    this.tags,
    this.description,
    this.wechat,
    this.avatar,
    this.workStatus,
  });

  factory TechnicianInfo.fromJson(Map<String, dynamic> json) {
    return TechnicianInfo(
      id: json['id'].toString(),
      nickname: json['nickname'] as String,
      gender: json['gender'] as int,
      phone: json['phone'].toString(),
      birthday: json['birthday'] as String?,
      experience: json['experience'] as String?,
      tags: json['tags'] as String?,
      description: json['description'] as String?,
      wechat: json['wechat'] as String?,
      avatar: json['avatar'] as String?,
      workStatus: json['workStatus'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nickname': nickname,
      'gender': gender,
      'phone': phone,
      'birthday': birthday,
      'experience': experience,
      'tags': tags,
      'description': description,
      'wechat': wechat,
      'avatar': avatar,
      'workStatus': workStatus,
    };
  }
}

// Data model for Technician Order (simplified for now)
class TechnicianOrder {
  final String orderId;
  final int status;
  final String customerName;
  final String customerPhone;
  final String projectName;
  final String serviceTime;
  final String address;
  final int actualPrice;
  final int technicianOperate;
  final String? technicianOperateTime;
  final Map<String, dynamic>? refundInfo;

  TechnicianOrder({
    required this.orderId,
    required this.status,
    required this.customerName,
    required this.customerPhone,
    required this.projectName,
    required this.serviceTime,
    required this.address,
    required this.actualPrice,
    required this.technicianOperate,
    this.technicianOperateTime,
    this.refundInfo,
  });

  factory TechnicianOrder.fromJson(Map<String, dynamic> json) {
    return TechnicianOrder(
      orderId: json['orderId'] as String,
      status: json['status'] as int,
      customerName: json['customerName'] as String,
      customerPhone: json['customerPhone'] as String,
      projectName: json['projectName'] as String,
      serviceTime: json['serviceTime'] as String,
      address: json['address'] as String,
      actualPrice: json['actualPrice'] as int,
      technicianOperate: json['technicianOperate'] as int? ?? -1, // Default to -1 if not present
      technicianOperateTime: json['technicianOperateTime'] as String?,
      refundInfo: json['refundInfo'] as Map<String, dynamic>?,
    );
  }
}

// Data model for Technician Auth Status
class TechnicianAuthStatus {
  final int status; // e.g., 0-pending, 1-approved, 2-rejected
  final String? message;
  final List<AuthInfo>? auths;

  TechnicianAuthStatus({
    required this.status,
    this.message,
    this.auths,
  });

  factory TechnicianAuthStatus.fromJson(Map<String, dynamic> json) {
    return TechnicianAuthStatus(
      status: json['status'] as int,
      message: json['message'] as String?,
      auths: (json['auths'] as List?)?.map((e) => AuthInfo.fromJson(e)).toList(),
    );
  }
}

// Data model for Auth Info
class AuthInfo {
  final int authId;
  final int authType;
  final String certNumber;
  final String issueDate;
  final String? expireDate;
  final List<String> images;
  final int status; // 0-pending, 1-approved, 2-rejected
  final String? rejectReason;

  AuthInfo({
    required this.authId,
    required this.authType,
    required this.certNumber,
    required this.issueDate,
    this.expireDate,
    required this.images,
    required this.status,
    this.rejectReason,
  });

  factory AuthInfo.fromJson(Map<String, dynamic> json) {
    return AuthInfo(
      authId: json['authId'] as int,
      authType: json['authType'] as int,
      certNumber: json['certNumber'] as String,
      issueDate: json['issueDate'] as String,
      expireDate: json['expireDate'] as String?,
      images: (json['images'] as List).map((e) => e as String).toList(),
      status: json['status'] as int,
      rejectReason: json['rejectReason'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'authId': authId,
      'authType': authType,
      'certNumber': certNumber,
      'issueDate': issueDate,
      'expireDate': expireDate,
      'images': images,
    };
  }
}

// Data model for Technician Dashboard
class TechnicianDashboard {
  final int totalOrders;
  final int completedOrders;
  final int pendingOrders;
  final double totalEarnings;
  final double pendingWithdrawal;
  final int unreadMessages;
  final int unreadNotifications;

  TechnicianDashboard({
    required this.totalOrders,
    required this.completedOrders,
    required this.pendingOrders,
    required this.totalEarnings,
    required this.pendingWithdrawal,
    required this.unreadMessages,
    required this.unreadNotifications,
  });

  factory TechnicianDashboard.fromJson(Map<String, dynamic> json) {
    return TechnicianDashboard(
      totalOrders: json['totalOrders'] as int,
      completedOrders: json['completedOrders'] as int,
      pendingOrders: json['pendingOrders'] as int,
      totalEarnings: (json['totalEarnings'] as num).toDouble(),
      pendingWithdrawal: (json['pendingWithdrawal'] as num).toDouble(),
      unreadMessages: json['unreadMessages'] as int,
      unreadNotifications: json['unreadNotifications'] as int,
    );
  }
}

// Data model for Withdrawal Account
class WithdrawalAccount {
  final String id;
  final String accountType;
  final String accountName;
  final String accountNumber;
  final String? bankName;
  final String? bankCode;
  final String phone;
  final String? qrCodeUrl;
  final bool isDefault;

  WithdrawalAccount({
    required this.id,
    required this.accountType,
    required this.accountName,
    required this.accountNumber,
    this.bankName,
    this.bankCode,
    required this.phone,
    this.qrCodeUrl,
    required this.isDefault,
  });

  factory WithdrawalAccount.fromJson(Map<String, dynamic> json) {
    return WithdrawalAccount(
      id: json['id'] as String,
      accountType: json['accountType'] as String,
      accountName: json['accountName'] as String,
      accountNumber: json['accountNumber'] as String,
      bankName: json['bankName'] as String?,
      bankCode: json['bankCode'] as String?,
      phone: json['phone'] as String,
      qrCodeUrl: json['qrCodeUrl'] as String?,
      isDefault: json['isDefault'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'accountType': accountType,
      'accountName': accountName,
      'accountNumber': accountNumber,
      'bankName': bankName,
      'bankCode': bankCode,
      'phone': phone,
      'qrCodeUrl': qrCodeUrl,
      'isDefault': isDefault,
    };
  }
}

class TechnicianApi {
  /// Get technician schedule data.
  Future<ApiResponse<List<TechnicianSchedule>>> getSchedule(BuildContext context, int weekDay) async {
    if (weekDay < 0 || weekDay > 6) {
      return ApiResponse.error('无效的weekDay参数');
    }
    return BaseApi.get(
      context,
      '/technician/schedule/$weekDay',
      fromJsonT: (json) => (json as List).map((e) => TechnicianSchedule.fromJson(e)).toList(),
    );
  }

  /// Save/update technician schedule data.
  Future<ApiResponse<void>> saveSchedule(BuildContext context, List<TechnicianSchedule> schedules) async {
    if (schedules.isEmpty) {
      return ApiResponse.error('排班数据不能为空');
    }
    return BaseApi.post(
      context,
      '/technician/schedule',
      {'schedules': schedules.map((e) => e.toJson()).toList()},
    );
  }

  /// Batch set schedule status.
  Future<ApiResponse<void>> batchSetSchedule(BuildContext context, {
    required int weekDay,
    required bool available,
    List<String>? timeSlots,
  }) async {
    if (weekDay < 0 || weekDay > 6) {
      return ApiResponse.error('weekDay必须在0-6之间');
    }
    return BaseApi.post(
      context,
      '/technician/schedule/batch',
      {'weekDay': weekDay, 'available': available, 'timeSlots': timeSlots},
    );
  }

  /// Get technician information.
  Future<ApiResponse<TechnicianInfo>> getTechnicianInfo(BuildContext context) async {
    return BaseApi.get(
      context,
      '/technician/profile',
      fromJsonT: (json) => TechnicianInfo.fromJson(json),
    );
  }

  /// Update technician work status.
  Future<ApiResponse<void>> updateWorkStatus(BuildContext context, String status) async {
    final validStatuses = ['available', 'busy', 'rest'];
    if (!validStatuses.contains(status)) {
      return ApiResponse.error('无效的工作状态');
    }
    return BaseApi.post(context, '/technician/work-status', {'status': status});
  }

  /// Get technician order list.
  Future<ApiResponse<List<TechnicianOrder>>> getOrders(BuildContext context, {
    String? status,
    int page = 1,
    int pageSize = 10,
  }) async {
    final Map<String, dynamic> params = {
      'page': page,
      'pageSize': pageSize,
    };
    if (status != null) params['status'] = status;

    return BaseApi.post(
      context,
      '/technician/orders',
      params,
      fromJsonT: (json) => (json['list'] as List).map((e) => TechnicianOrder.fromJson(e)).toList(),
    );
  }

  /// Get technician order detail.
  Future<ApiResponse<TechnicianOrder>> getOrderDetail(BuildContext context, String orderId) async {
    if (orderId.isEmpty) {
      return ApiResponse.error('订单ID不能为空');
    }
    return BaseApi.get(
      context,
      '/technician/order-detail/$orderId',
      fromJsonT: (json) => TechnicianOrder.fromJson(json),
    );
  }

  /// Technician order operation (accept, depart, arrive, start service, complete service).
  Future<ApiResponse<void>> updateOrderStatus(BuildContext context, {
    required String orderId,
    required int operateType,
    required String longitude,
    required String latitude,
    String? remark,
    List<String>? photoUrls,
  }) async {
    final validOperateTypes = [10, 20, 30, 40, 50];
    if (!validOperateTypes.contains(operateType)) {
      return ApiResponse.error('无效的操作类型');
    }
    return BaseApi.put(
      context,
      '/technician/orders/action',
      {
        'orderId': orderId,
        'operateType': operateType,
        'longitude': longitude,
        'latitude': latitude,
        'remark': remark,
        'photoUrls': photoUrls,
      },
    );
  }

  /// Get technician service cities list.
  Future<ApiResponse<List<String>>> getServiceCities(BuildContext context) async {
    return BaseApi.get(
      context,
      '/technician/setting/service-city',
      fromJsonT: (json) => (json as List).map((e) => e as String).toList(),
    );
  }

  /// Save technician service cities setting.
  Future<ApiResponse<void>> saveServiceCities(BuildContext context, List<String> cityCodes) async {
    if (cityCodes.isEmpty) {
      return ApiResponse.error('城市代码列表不能为空');
    }
    return BaseApi.post(context, '/technician/setting/service-city', {'cityCodes': cityCodes});
  }

  /// Get technician service projects list.
  Future<ApiResponse<List<dynamic>>> getServiceProjects(BuildContext context) async {
    return BaseApi.get(
      context,
      '/technician/setting/service-projects',
      fromJsonT: (json) => json as List, // Assuming a list of generic objects
    );
  }

  /// Save service projects setting.
  Future<ApiResponse<void>> saveServiceProjects(BuildContext context, List<String> projectIds) async {
    if (projectIds.isEmpty) {
      return ApiResponse.error('服务项目ID列表不能为空');
    }
    return BaseApi.post(context, '/technician/setting/service-projects', {'projectIds': projectIds});
  }

  /// Get service management overview data.
  Future<ApiResponse<Map<String, dynamic>>> getServiceOverview(BuildContext context) async {
    return BaseApi.get(
      context,
      '/technician/service/overview',
      fromJsonT: (json) => json as Map<String, dynamic>,
    );
  }

  /// Update service status (available/in service/resting).
  Future<ApiResponse<void>> updateServiceStatus(BuildContext context, int status) async {
    final validStatuses = [0, 1, 2];
    if (!validStatuses.contains(status)) {
      return ApiResponse.error('无效的服务状态，必须为0(可预约)、1(服务中)、2(休息中)');
    }
    return BaseApi.post(context, '/technician/service/status', {'status': status});
  }

  /// Get technician authentication status.
  Future<ApiResponse<TechnicianAuthStatus>> getAuthStatus(BuildContext context) async {
    return BaseApi.get(
      context,
      '/technician/auth/status',
      fromJsonT: (json) => TechnicianAuthStatus.fromJson(json),
    );
  }

  /// Save authentication information.
  Future<ApiResponse<void>> saveAuthInfo(BuildContext context, AuthInfo data) async {
    if (data.certNumber.isEmpty || data.issueDate.isEmpty || data.images.isEmpty) {
      return ApiResponse.error('证书编号、发证日期和图片不能为空');
    }
    return BaseApi.post(context, '/technician/auth/save', data.toJson());
  }

  /// Get dashboard data.
  Future<ApiResponse<TechnicianDashboard>> getDashboard(BuildContext context) async {
    return BaseApi.get(
      context,
      '/technician/dashboard',
      fromJsonT: (json) => TechnicianDashboard.fromJson(json),
    );
  }

  /// Update location information.
  Future<ApiResponse<void>> updateLocation(BuildContext context, double latitude, double longitude) async {
    return BaseApi.post(context, '/technician/location', {'latitude': latitude, 'longitude': longitude});
  }

  /// Mark notification as read.
  Future<ApiResponse<void>> markNotificationRead(BuildContext context, String noticeId) async {
    if (noticeId.isEmpty) {
      return ApiResponse.error('通知ID不能为空');
    }
    return BaseApi.post(context, '/technician/notifications/$noticeId/read', {});
  }

  /// Get technician gallery.
  Future<ApiResponse<List<String>>> getGallery(BuildContext context) async {
    return BaseApi.get(
      context,
      '/technician/gallery',
      fromJsonT: (json) => (json as List).map((e) => e as String).toList(),
    );
  }

  /// Save photo to gallery.
  Future<ApiResponse<void>> saveGalleryPhoto(BuildContext context, String url, {bool isCover = false}) async {
    if (url.isEmpty) {
      return ApiResponse.error('照片URL不能为空');
    }
    return BaseApi.post(context, '/technician/gallery', {'url': url, 'isCover': isCover});
  }

  /// Delete gallery photo.
  Future<ApiResponse<void>> deleteGalleryPhoto(BuildContext context, String photoId) async {
    if (photoId.isEmpty) {
      return ApiResponse.error('照片ID不能为空');
    }
    return BaseApi.delete(context, '/technician/gallery/$photoId');
  }

  /// Set gallery cover.
  Future<ApiResponse<void>> setGalleryCover(BuildContext context, String photoId) async {
    if (photoId.isEmpty) {
      return ApiResponse.error('照片ID不能为空');
    }
    return BaseApi.post(context, '/technician/gallery/$photoId/cover', {});
  }

  /// Update technician avatar.
  Future<ApiResponse<void>> updateAvatar(BuildContext context, String avatarUrl) async {
    if (avatarUrl.isEmpty) {
      return ApiResponse.error('头像URL不能为空');
    }
    return BaseApi.post(context, '/technician/profile/avatar', {'avatar': avatarUrl});
  }

  /// Get technician profile details.
  Future<ApiResponse<TechnicianInfo>> getProfileDetail(BuildContext context) async {
    return BaseApi.get(
      context,
      '/technician/profile/detail',
      fromJsonT: (json) => TechnicianInfo.fromJson(json),
    );
  }

  /// Update technician profile.
  Future<ApiResponse<void>> updateProfile(BuildContext context, TechnicianInfo data) async {
    return BaseApi.post(context, '/technician/profile/update', data.toJson());
  }

  /// Get withdrawal accounts list.
  Future<ApiResponse<List<WithdrawalAccount>>> getWithdrawalAccounts(BuildContext context) async {
    return BaseApi.get(
      context,
      '/technician/withdrawal-accounts',
      fromJsonT: (json) => (json as List).map((e) => WithdrawalAccount.fromJson(e)).toList(),
    );
  }

  /// Create withdrawal account.
  Future<ApiResponse<void>> createWithdrawalAccount(BuildContext context, WithdrawalAccount data) async {
    if (data.accountName.isEmpty || data.accountNumber.isEmpty || data.phone.isEmpty) {
      return ApiResponse.error('账户姓名、账号和手机号不能为空');
    }
    return BaseApi.post(context, '/technician/withdrawal-accounts', data.toJson());
  }

  /// Update withdrawal account.
  Future<ApiResponse<void>> updateWithdrawalAccount(BuildContext context, WithdrawalAccount data) async {
    if (data.id.isEmpty || data.accountName.isEmpty || data.accountNumber.isEmpty || data.phone.isEmpty) {
      return ApiResponse.error('账号ID、账户姓名、账号和手机号不能为空');
    }
    return BaseApi.put(context, '/technician/withdrawal-accounts/${data.id}', data.toJson());
  }

  /// Delete withdrawal account.
  Future<ApiResponse<void>> deleteWithdrawalAccount(BuildContext context, String id) async {
    if (id.isEmpty) {
      return ApiResponse.error('账号ID不能为空');
    }
    return BaseApi.delete(context, '/technician/withdrawal-accounts/$id');
  }

  /// Set default withdrawal account.
  Future<ApiResponse<void>> setDefaultWithdrawalAccount(BuildContext context, String id) async {
    if (id.isEmpty) {
      return ApiResponse.error('账号ID不能为空');
    }
    return BaseApi.put(context, '/technician/withdrawal-accounts/$id/default', {});
  }

  /// Approve order refund.
  Future<ApiResponse<void>> approveRefund(BuildContext context, String orderId, {String? remark}) async {
    if (orderId.isEmpty) {
      return ApiResponse.error('订单ID不能为空');
    }
    return BaseApi.post(context, '/technician/refund/approve', {'orderId': orderId, 'remark': remark});
  }

  /// Reject order refund.
  Future<ApiResponse<void>> rejectRefund(BuildContext context, String orderId, {String? remark}) async {
    if (orderId.isEmpty) {
      return ApiResponse.error('订单ID不能为空');
    }
    return BaseApi.post(context, '/technician/refund/reject', {'orderId': orderId, 'remark': remark});
  }

  /// Block customer.
  Future<ApiResponse<void>> blockCustomer(BuildContext context, String orderId) async {
    if (orderId.isEmpty) {
      return ApiResponse.error('订单ID不能为空');
    }
    return BaseApi.post(context, '/technician/block-customer', {'orderId': orderId});
  }
}