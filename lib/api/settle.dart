import 'package:bookin/api/base.dart';
import 'package:flutter/material.dart'; // Import for BuildContext

// Data model for technician application submission
class SubmitApplicationReq {
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

  SubmitApplicationReq({
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

class SettleApi {
  /// Get city list for technician settlement.
  Future<ApiResponse<List<String>>> getCityList(BuildContext context) async {
    return BaseApi.get(
      context,
      '/settle/cities',
      fromJsonT: (json) => (json as List).map((e) => e as String).toList(),
    );
  }

  /// Submit technician application.
  Future<ApiResponse<void>> submitApplication(BuildContext context, SubmitApplicationReq data) async {
    return BaseApi.post(context, '/settle/apply', data.toJson());
  }

  /// Upload image (specific to settle module, might be a general utility).
  /// Note: The original JS uses `uni.uploadFile` directly, which is Uni-App specific.
  /// In Flutter, you'd use `BaseApi.upload` or a dedicated file upload utility.
  Future<ApiResponse<String>> uploadImage(BuildContext context, String filePath) async {
    // Assuming a generic upload endpoint and that the backend returns the URL directly
    return BaseApi.upload(context, '/common/upload', filePath, 'file', {});
  }
}