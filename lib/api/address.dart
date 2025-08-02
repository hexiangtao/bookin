import 'package:bookin/api/base.dart';
import 'package:flutter/material.dart'; // Import for BuildContext

// Data model for Address (assuming a simplified structure for now)
class Address {
  final String id;
  final String name;
  final String phone;
  final String address;
  final bool isDefault;

  Address({
    required this.id,
    required this.name,
    required this.phone,
    required this.address,
    this.isDefault = false,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      id: json['id'] as String,
      name: json['name'] as String,
      phone: json['phone'] as String,
      address: json['address'] as String,
      isDefault: json['isDefault'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'address': address,
      'isDefault': isDefault,
    };
  }
}

// Data model for Address Request (for add/update)
class AddressReq {
  final String? id; // Optional for add, required for update
  final String name;
  final String phone;
  final String address;
  final bool? isDefault; // Optional
  final String? phoneCode; // Optional: when phone changes
  final bool? forceSave; // Optional: to skip duplicate check

  AddressReq({
    this.id,
    required this.name,
    required this.phone,
    required this.address,
    this.isDefault,
    this.phoneCode,
    this.forceSave,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'phone': phone,
      'address': address,
    };
  }
}

class AddressApi {
  /// Get current user's address list
  Future<ApiResponse<List<Address>>> getAddressList(BuildContext context) async {
    return BaseApi.get(
      context,
      '/user/address/list',
      fromJsonT: (json) => (json as List).map((e) => Address.fromJson(e)).toList(),
    );
  }

  /// Get address details by ID
  Future<ApiResponse<Address>> getAddressDetail(BuildContext context, String id) async {
    if (id.isEmpty) {
      return ApiResponse.error('地址ID不能为空');
    }
    return BaseApi.get(
      context,
      '/user/address/$id',
      fromJsonT: (json) => Address.fromJson(json),
    );
  }

  /// Add a new address
  Future<ApiResponse<Address>> addAddress(BuildContext context, AddressReq addressReq) async {
    return BaseApi.post(
      context,
      '/user/address/add',
      addressReq.toJson(),
      fromJsonT: (json) => Address.fromJson(json),
    );
  }

  /// Update an existing address
  Future<ApiResponse<Address>> updateAddress(BuildContext context, AddressReq addressReq) async {
    if (addressReq.id == null || addressReq.id!.isEmpty) {
      return ApiResponse.error('更新地址时ID不能为空');
    }
    return BaseApi.put(
      context,
      '/user/address/update',
      addressReq.toJson(),
      fromJsonT: (json) => Address.fromJson(json),
    );
  }

  /// Save address (add or update)
  Future<ApiResponse<Address>> saveAddress(BuildContext context, AddressReq addressReq) async {
    return BaseApi.post(
      context,
      '/user/address/save',
      addressReq.toJson(),
      fromJsonT: (json) => Address.fromJson(json),
    );
  }

  /// Delete an address
  Future<ApiResponse<void>> deleteAddress(BuildContext context, String id) async {
    if (id.isEmpty) {
      return ApiResponse.error('删除地址时ID不能为空');
    }
    return BaseApi.delete(context, '/user/address/$id');
  }

  /// Set default address
  Future<ApiResponse<void>> setDefaultAddress(BuildContext context, String id) async {
    if (id.isEmpty) {
      return ApiResponse.error('设置默认地址时ID不能为空');
    }
    return BaseApi.post(context, '/user/address/default/$id', {});
  }

  /// Get default address
  Future<ApiResponse<Address?>> getDefaultAddress(BuildContext context) async {
    return BaseApi.get(
      context,
      '/user/address/default',
      fromJsonT: (json) => json != null ? Address.fromJson(json) : null,
    );
  }
}