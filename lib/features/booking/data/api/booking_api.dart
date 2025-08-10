import 'package:bookin/features/shared/services/base_api.dart';
import 'package:flutter/material.dart'; // Import for BuildContext

// Data model for a single time slot
class TimeSlot {
  final String startTime;
  final String endTime;
  final bool isAvailable;
  final int remainingSpots;

  TimeSlot({
    required this.startTime,
    required this.endTime,
    required this.isAvailable,
    required this.remainingSpots,
  });

  factory TimeSlot.fromJson(Map<String, dynamic> json) {
    return TimeSlot(
      startTime: json['startTime'] as String,
      endTime: json['endTime'] as String,
      isAvailable: json['isAvailable'] as bool,
      remainingSpots: json['remainingSpots'] as int,
    );
  }
}

// Data model for available dates
class AvailableDate {
  final String date;
  final bool isAvailable;
  final bool hasTimeSlots;

  AvailableDate({
    required this.date,
    required this.isAvailable,
    required this.hasTimeSlots,
  });

  factory AvailableDate.fromJson(Map<String, dynamic> json) {
    return AvailableDate(
      date: json['date'] as String,
      isAvailable: json['isAvailable'] as bool,
      hasTimeSlots: json['hasTimeSlots'] as bool,
    );
  }
}

// Data model for booking availability check response
class BookingAvailability {
  final String techId;
  final String projectId;
  final String date;
  final List<TimeSlot> timeSlots;
  final List<AvailableDate> availableDates;

  BookingAvailability({
    required this.techId,
    required this.projectId,
    required this.date,
    required this.timeSlots,
    required this.availableDates,
  });

  factory BookingAvailability.fromJson(Map<String, dynamic> json) {
    return BookingAvailability(
      techId: json['techId'] as String,
      projectId: json['projectId'] as String,
      date: json['date'] as String,
      timeSlots: (json['timeSlots'] as List)
          .map((e) => TimeSlot.fromJson(e))
          .toList(),
      availableDates: (json['availableDates'] as List)
          .map((e) => AvailableDate.fromJson(e))
          .toList(),
    );
  }
}

// Data model for creating a booking request
class CreateBookingReq {
  final String techId;
  final String projectId;
  final String date;
  final String startTime;
  final String addressId;
  final String? couponId;
  final String? remarks;

  CreateBookingReq({
    required this.techId,
    required this.projectId,
    required this.date,
    required this.startTime,
    required this.addressId,
    this.couponId,
    this.remarks,
  });

  Map<String, dynamic> toJson() {
    return {
      'techId': techId,
      'projectId': projectId,
      'date': date,
      'startTime': startTime,
      'addressId': addressId,
      if (couponId != null) 'couponId': couponId,
      if (remarks != null) 'remarks': remarks,
    };
  }
}

// Data model for a booking item in a list
class BookingListItem {
  final String bookingId;
  final String orderId;
  final String techId;
  final String techName;
  final String techAvatar;
  final String projectId;
  final String projectName;
  final String projectCover;
  final int price;
  final String date;
  final String startTime;
  final int status;
  final String statusText;
  final String createTime;

  BookingListItem({
    required this.bookingId,
    required this.orderId,
    required this.techId,
    required this.techName,
    required this.techAvatar,
    required this.projectId,
    required this.projectName,
    required this.projectCover,
    required this.price,
    required this.date,
    required this.startTime,
    required this.status,
    required this.statusText,
    required this.createTime,
  });

  factory BookingListItem.fromJson(Map<String, dynamic> json) {
    return BookingListItem(
      bookingId: json['bookingId'] as String,
      orderId: json['orderId'] as String,
      techId: json['techId'] as String,
      techName: json['techName'] as String,
      techAvatar: json['techAvatar'] as String,
      projectId: json['projectId'] as String,
      projectName: json['projectName'] as String,
      projectCover: json['projectCover'] as String,
      price: json['price'] as int,
      date: json['date'] as String,
      startTime: json['startTime'] as String,
      status: json['status'] as int,
      statusText: json['statusText'] as String,
      createTime: json['createTime'] as String,
    );
  }
}

// Data model for booking detail
class BookingDetail {
  final String bookingId;
  final String orderId;
  final String userId;
  final String techId;
  final Map<String, dynamic> techInfo;
  final String projectId;
  final Map<String, dynamic> projectInfo;
  final String date;
  final String startTime;
  final Map<String, dynamic> addressInfo;
  final Map<String, dynamic>? couponInfo;
  final int originalPrice;
  final int discountPrice;
  final int actualPrice;
  final int status;
  final String statusText;
  final String? remarks;
  final String createTime;
  final String? payTime;
  final String? serviceTime;
  final String? completeTime;
  final String? cancelTime;
  final String? refundTime;
  final String? expireTime;

  BookingDetail({
    required this.bookingId,
    required this.orderId,
    required this.userId,
    required this.techId,
    required this.techInfo,
    required this.projectId,
    required this.projectInfo,
    required this.date,
    required this.startTime,
    required this.addressInfo,
    this.couponInfo,
    required this.originalPrice,
    required this.discountPrice,
    required this.actualPrice,
    required this.status,
    required this.statusText,
    this.remarks,
    required this.createTime,
    this.payTime,
    this.serviceTime,
    this.completeTime,
    this.cancelTime,
    this.refundTime,
    this.expireTime,
  });

  factory BookingDetail.fromJson(Map<String, dynamic> json) {
    return BookingDetail(
      bookingId: json['bookingId'] as String,
      orderId: json['orderId'] as String,
      userId: json['userId'] as String,
      techId: json['techId'] as String,
      techInfo: json['techInfo'] as Map<String, dynamic>,
      projectId: json['projectId'] as String,
      projectInfo: json['projectInfo'] as Map<String, dynamic>,
      date: json['date'] as String,
      startTime: json['startTime'] as String,
      addressInfo: json['addressInfo'] as Map<String, dynamic>,
      couponInfo: json['couponInfo'] as Map<String, dynamic>?,
      originalPrice: json['originalPrice'] as int,
      discountPrice: json['discountPrice'] as int,
      actualPrice: json['actualPrice'] as int,
      status: json['status'] as int,
      statusText: json['statusText'] as String,
      remarks: json['remarks'] as String?,
      createTime: json['createTime'] as String,
      payTime: json['payTime'] as String?,
      serviceTime: json['serviceTime'] as String?,
      completeTime: json['completeTime'] as String?,
      cancelTime: json['cancelTime'] as String?,
      refundTime: json['refundTime'] as String?,
      expireTime: json['expireTime'] as String?,
    );
  }
}

class BookingApi {
  /// Get available time slots for a technician on a specific date.
  /// The original JS heavily used mock data for this. This assumes a real API endpoint.
  Future<ApiResponse<List<String>>> getAvailableTime(BuildContext context, String techId, String date) async {
    return BaseApi.get(
      context,
      '/booking/available-time',
      queryParameters: {'techId': techId, 'date': date},
      fromJsonT: (json) => (json as List).map((e) => e as String).toList(),
    );
  }

  /// Check if a specific time slot is available.
  /// The original JS heavily used mock data for this. This assumes a real API endpoint.
  Future<ApiResponse<bool>> checkTimeAvailable(BuildContext context, String techId, String date, String time) async {
    return BaseApi.get(
      context,
      '/booking/check-time',
      queryParameters: {'techId': techId, 'date': date, 'time': time},
      fromJsonT: (json) => json['available'] as bool,
    );
  }

  /// Check technician availability for a project on a given date.
  /// The original JS heavily used mock data for this. This assumes a real API endpoint.
  Future<ApiResponse<BookingAvailability>> checkAvailability(BuildContext context, {
    required String techId,
    required String projectId,
    required String date,
  }) async {
    return BaseApi.get(
      context,
      '/booking/check-availability',
      queryParameters: {'techId': techId, 'projectId': projectId, 'date': date},
      fromJsonT: (json) => BookingAvailability.fromJson(json),
    );
  }

  /// Create a new booking.
  Future<ApiResponse<Map<String, dynamic>>> createBooking(BuildContext context, CreateBookingReq data) async {
    return BaseApi.post(
      context,
      '/booking/create',
      data.toJson(),
      fromJsonT: (json) => json as Map<String, dynamic>, // Assuming a generic success response with booking/order IDs
    );
  }

  /// Cancel a booking.
  Future<ApiResponse<void>> cancelBooking(BuildContext context, String bookingId, String cancelReason) async {
    return BaseApi.post(context, '/booking/cancel', {'bookingId': bookingId, 'cancelReason': cancelReason});
  }

  /// Get booking details by ID.
  Future<ApiResponse<BookingDetail>> getBookingDetail(BuildContext context, String bookingId) async {
    return BaseApi.get(
      context,
      '/booking/detail/$bookingId',
      fromJsonT: (json) => BookingDetail.fromJson(json),
    );
  }

  /// Get a list of bookings.
  Future<ApiResponse<List<BookingListItem>>> getBookingList(BuildContext context, {
    int? status, // 0-all, 1-pending payment, 2-pending service, etc.
    int page = 1,
    int pageSize = 10,
  }) async {
    final Map<String, dynamic> params = {
      'page': page,
      'pageSize': pageSize,
    };
    if (status != null) {
      params['status'] = status;
    }
    return BaseApi.get(
      context,
      '/booking/list',
      queryParameters: params,
      fromJsonT: (json) => (json['list'] as List).map((e) => BookingListItem.fromJson(e)).toList(),
    );
  }

  /// Remind technician about a booking.
  Future<ApiResponse<void>> remindTechnician(BuildContext context, String bookingId) async {
    return BaseApi.post(context, '/booking/remind', {'bookingId': bookingId});
  }

  /// Rebook a previous booking.
  Future<ApiResponse<Map<String, dynamic>>> rebookBooking(BuildContext context, String bookingId) async {
    return BaseApi.post(
      context,
      '/booking/rebook',
      {'bookingId': bookingId},
      fromJsonT: (json) => json as Map<String, dynamic>,
    );
  }
}