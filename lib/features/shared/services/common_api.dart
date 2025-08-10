import 'package:bookin/features/shared/services/base_api.dart';
import 'package:flutter/material.dart'; // Import for BuildContext

// Data model for a city
class City {
  final String name;
  final String initial;

  City({
    required this.name,
    required this.initial,
  });

  factory City.fromJson(Map<String, dynamic> json) {
    return City(
      name: json['name'] as String,
      initial: json['initial'] as String,
    );
  }
}

// Data model for city list response
class CityListResponse {
  final List<String> hotCities;
  final List<City> cityList;

  CityListResponse({
    required this.hotCities,
    required this.cityList,
  });

  factory CityListResponse.fromJson(Map<String, dynamic> json) {
    return CityListResponse(
      hotCities: (json['hotCities'] as List).map((e) => e as String).toList(),
      cityList: (json['cityList'] as List).map((e) => City.fromJson(e)).toList(),
    );
  }
}

// Data model for service type filter option
class ServiceType {
  final int id;
  final String name;

  ServiceType({
    required this.id,
    required this.name,
  });

  factory ServiceType.fromJson(Map<String, dynamic> json) {
    return ServiceType(
      id: json['id'] as int,
      name: json['name'] as String,
    );
  }
}

// Data model for price range filter option
class PriceRange {
  final String name;
  final int min;
  final int max;

  PriceRange({
    required this.name,
    required this.min,
    required this.max,
  });

  factory PriceRange.fromJson(Map<String, dynamic> json) {
    return PriceRange(
      name: json['name'] as String,
      min: json['min'] as int,
      max: json['max'] as int,
    );
  }
}

// Data model for rating filter option
class RatingOption {
  final String name;
  final double value;

  RatingOption({
    required this.name,
    required this.value,
  });

  factory RatingOption.fromJson(Map<String, dynamic> json) {
    return RatingOption(
      name: json['name'] as String,
      value: (json['value'] as num).toDouble(),
    );
  }
}

// Data model for filter options response
class FilterOptionsResponse {
  final List<ServiceType> serviceTypes;
  final List<PriceRange> priceRanges;
  final List<RatingOption> ratings;

  FilterOptionsResponse({
    required this.serviceTypes,
    required this.priceRanges,
    required this.ratings,
  });

  factory FilterOptionsResponse.fromJson(Map<String, dynamic> json) {
    return FilterOptionsResponse(
      serviceTypes: (json['serviceTypes'] as List).map((e) => ServiceType.fromJson(e)).toList(),
      priceRanges: (json['priceRanges'] as List).map((e) => PriceRange.fromJson(e)).toList(),
      ratings: (json['ratings'] as List).map((e) => RatingOption.fromJson(e)).toList(),
    );
  }
}

class CommonApi {
  /// Get list of cities (hot cities and full list).
  Future<ApiResponse<CityListResponse>> getCityList(BuildContext context) async {
    return BaseApi.get(
      context,
      '/common/cities',
      fromJsonT: (json) => CityListResponse.fromJson(json),
    );
  }

  /// Get filter options data (service types, price ranges, ratings).
  Future<ApiResponse<FilterOptionsResponse>> getFilterOptions(BuildContext context) async {
    return BaseApi.get(
      context,
      '/common/filter-options',
      fromJsonT: (json) => FilterOptionsResponse.fromJson(json),
    );
  }
}