import 'package:bookin/api/base.dart';
import 'package:flutter/material.dart'; // Import for BuildContext

// Data model for a simple region (province, city, or district)
class RegionSimple {
  final String label;
  final String value;

  RegionSimple({
    required this.label,
    required this.value,
  });

  factory RegionSimple.fromJson(Map<String, dynamic> json) {
    return RegionSimple(
      label: json['label'] as String,
      value: json['value'] as String,
    );
  }
}

// Data model for full region hierarchy (if getAllRegions returns this)
class RegionAll {
  // Define structure based on actual API response for /region/all
  // This is a placeholder, adjust as needed.
  final List<RegionSimple> provinces;
  // ... potentially nested cities and districts

  RegionAll({
    required this.provinces,
  });

  factory RegionAll.fromJson(Map<String, dynamic> json) {
    return RegionAll(
      provinces: (json['provinces'] as List).map((e) => RegionSimple.fromJson(e)).toList(),
    );
  }
}

// Data model for region names response
class RegionName {
  final String provinceName;
  final String cityName;
  final String districtName;

  RegionName({
    required this.provinceName,
    required this.cityName,
    required this.districtName,
  });

  factory RegionName.fromJson(Map<String, dynamic> json) {
    return RegionName(
      provinceName: json['provinceName'] as String,
      cityName: json['cityName'] as String,
      districtName: json['districtName'] as String,
    );
  }
}

// Data model for u-picker component format (if needed)
class RegionPickerData {
  // Define structure based on actual API response for /region/picker-data
  // This is a placeholder, adjust as needed.
  final List<dynamic> data; // Example: List of provinces, each with nested cities/districts

  RegionPickerData({
    required this.data,
  });

  factory RegionPickerData.fromJson(Map<String, dynamic> json) {
    return RegionPickerData(
      data: json['data'] as List,
    );
  }
}

class RegionApi {
  /// Get all provinces (simple info).
  Future<ApiResponse<List<RegionSimple>>> getProvinces(BuildContext context) async {
    return BaseApi.get(
      context,
      '/region/provinces',
      fromJsonT: (json) => (json as List).map((e) => RegionSimple.fromJson(e)).toList(),
    );
  }

  /// Get cities list by province ID (simple info).
  Future<ApiResponse<List<RegionSimple>>> getCitiesByProvinceId(BuildContext context, String provinceId) async {
    return BaseApi.get(
      context,
      '/region/cities',
      queryParameters: {'provinceId': provinceId},
      fromJsonT: (json) => (json as List).map((e) => RegionSimple.fromJson(e)).toList(),
    );
  }

  /// Get districts list by city ID (simple info).
  Future<ApiResponse<List<RegionSimple>>> getDistrictsByCityId(BuildContext context, String cityId) async {
    return BaseApi.get(
      context,
      '/region/districts',
      queryParameters: {'cityId': cityId},
      fromJsonT: (json) => (json as List).map((e) => RegionSimple.fromJson(e)).toList(),
    );
  }

  /// Get full province-city-district hierarchy data (may be used for one-time loading).
  Future<ApiResponse<RegionAll>> getAllRegions(BuildContext context) async {
    return BaseApi.get(
      context,
      '/region/all',
      fromJsonT: (json) => RegionAll.fromJson(json),
    );
  }

  /// Get province, city, district names by IDs.
  Future<ApiResponse<RegionName>> getRegionNames(
    BuildContext context, String provinceId, String cityId, String districtId
  ) async {
    return BaseApi.get(
      context,
      '/region/names',
      queryParameters: {'provinceId': provinceId, 'cityId': cityId, 'districtId': districtId},
      fromJsonT: (json) => RegionName.fromJson(json),
    );
  }

  /// Get data formatted for u-picker component.
  Future<ApiResponse<RegionPickerData>> getPickerData(BuildContext context) async {
    return BaseApi.get(
      context,
      '/region/picker-data',
      fromJsonT: (json) => RegionPickerData.fromJson(json),
    );
  }

  // The following methods (getCityColumn, getDistrictColumn) are for local data manipulation
  // and would typically be implemented in a utility or UI helper class, not directly in API.
  // They are included here for completeness based on the original JS file.

  /// Get city column data for dynamic picker updates (local data).
  List<RegionSimple> getCityColumn(String provinceId) {
    // This data would typically be loaded from a local asset or a previous API call
    // For demonstration, using hardcoded data from original JS.
    final Map<String, List<Map<String, String>>> citiesData = {
      '110000': [{'label': '北京市', 'value': '110100'}],
      '310000': [{'label': '上海市', 'value': '310100'}],
      '440000': [
        {'label': '广州市', 'value': '440100'},
        {'label': '深圳市', 'value': '440300'},
      ],
      // ... more data
    };
    return (citiesData[provinceId] ?? []).map((e) => RegionSimple.fromJson(e)).toList();
  }

  /// Get district column data for dynamic picker updates (local data).
  List<RegionSimple> getDistrictColumn(String cityId) {
    // This data would typically be loaded from a local asset or a previous API call
    // For demonstration, using hardcoded data from original JS.
    final Map<String, List<Map<String, String>>> districtsData = {
      '110100': [
        {'label': '东城区', 'value': '110101'},
        {'label': '西城区', 'value': '110102'},
      ],
      '310100': [
        {'label': '黄浦区', 'value': '310101'},
        {'label': '徐汇区', 'value': '310104'},
      ],
      // ... more data
    };
    return (districtsData[cityId] ?? []).map((e) => RegionSimple.fromJson(e)).toList();
  }
}