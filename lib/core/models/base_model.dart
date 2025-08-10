import 'package:json_annotation/json_annotation.dart';

part 'base_model.g.dart';

/// 基础数据模型抽象类
abstract class BaseModel {
  /// 从JSON创建模型实例
  factory BaseModel.fromJson(Map<String, dynamic> json) {
    throw UnimplementedError('fromJson must be implemented');
  }
  
  /// 将模型转换为JSON
  Map<String, dynamic> toJson();
  
  /// 模型验证
  bool isValid() => true;
  
  /// 获取模型的唯一标识
  String? get id => null;
  
  /// 模型创建时间
  DateTime? get createdAt => null;
  
  /// 模型更新时间
  DateTime? get updatedAt => null;
}

/// API响应基础结构
@JsonSerializable(genericArgumentFactories: true)
class ApiResponse<T> {
  /// 响应状态码
  @JsonKey(name: 'code')
  final int code;
  
  /// 响应消息
  @JsonKey(name: 'message')
  final String message;
  
  /// 响应数据
  @JsonKey(name: 'data')
  final T? data;
  
  /// 请求是否成功
  @JsonKey(name: 'success')
  final bool success;
  
  /// 时间戳
  @JsonKey(name: 'timestamp')
  final int? timestamp;
  
  /// 请求ID
  @JsonKey(name: 'requestId')
  final String? requestId;
  
  const ApiResponse({
    required this.code,
    required this.message,
    this.data,
    required this.success,
    this.timestamp,
    this.requestId,
  });
  
  /// 创建成功响应
  factory ApiResponse.success({
    T? data,
    String message = 'Success',
    int code = 200,
    String? requestId,
  }) {
    return ApiResponse<T>(
      code: code,
      message: message,
      data: data,
      success: true,
      timestamp: DateTime.now().millisecondsSinceEpoch,
      requestId: requestId,
    );
  }
  
  /// 创建失败响应
  factory ApiResponse.error({
    required String message,
    int code = 500,
    T? data,
    String? requestId,
  }) {
    return ApiResponse<T>(
      code: code,
      message: message,
      data: data,
      success: false,
      timestamp: DateTime.now().millisecondsSinceEpoch,
      requestId: requestId,
    );
  }
  
  /// 从JSON创建
  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) {
    return ApiResponse<T>(
      code: json['code'] as int? ?? 0,
      message: json['message'] as String? ?? '',
      data: json['data'] == null ? null : fromJsonT(json['data']),
      success: json['success'] as bool? ?? false,
      timestamp: json['timestamp'] as int?,
      requestId: json['requestId'] as String?,
    );
  }
  
  /// 转换为JSON
  Map<String, dynamic> toJson(Object? Function(T value) toJsonT) {
    return {
      'code': code,
      'message': message,
      'data': data == null ? null : toJsonT(data as T),
      'success': success,
      'timestamp': timestamp,
      'requestId': requestId,
    };
  }
  
  /// 是否为成功响应
  bool get isSuccess => success && code >= 200 && code < 300;
  
  /// 是否为错误响应
  bool get isError => !success || code < 200 || code >= 300;
  
  /// 获取错误信息
  String get errorMessage => isError ? message : '';
  
  @override
  String toString() {
    return 'ApiResponse{code: $code, message: $message, success: $success, data: $data}';
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ApiResponse<T> &&
        other.code == code &&
        other.message == message &&
        other.success == success &&
        other.data == data;
  }
  
  @override
  int get hashCode {
    return code.hashCode ^
        message.hashCode ^
        success.hashCode ^
        data.hashCode;
  }
}

/// 分页响应数据结构
@JsonSerializable(genericArgumentFactories: true)
class PageResponse<T> {
  /// 当前页码
  @JsonKey(name: 'page')
  final int page;
  
  /// 每页大小
  @JsonKey(name: 'pageSize')
  final int pageSize;
  
  /// 总记录数
  @JsonKey(name: 'total')
  final int total;
  
  /// 总页数
  @JsonKey(name: 'totalPages')
  final int totalPages;
  
  /// 数据列表
  @JsonKey(name: 'list')
  final List<T> list;
  
  /// 是否有下一页
  @JsonKey(name: 'hasNext')
  final bool hasNext;
  
  /// 是否有上一页
  @JsonKey(name: 'hasPrev')
  final bool hasPrev;
  
  const PageResponse({
    required this.page,
    required this.pageSize,
    required this.total,
    required this.totalPages,
    required this.list,
    required this.hasNext,
    required this.hasPrev,
  });
  
  /// 创建空的分页响应
  factory PageResponse.empty() {
    return PageResponse<T>(
      page: 1,
      pageSize: 0,
      total: 0,
      totalPages: 0,
      list: const [],
      hasNext: false,
      hasPrev: false,
    );
  }
  
  /// 从JSON创建
  factory PageResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) {
    final list = (json['list'] as List<dynamic>? ?? [])
        .map((item) => fromJsonT(item))
        .toList();
    
    return PageResponse<T>(
      page: json['page'] as int? ?? 1,
      pageSize: json['pageSize'] as int? ?? 0,
      total: json['total'] as int? ?? 0,
      totalPages: json['totalPages'] as int? ?? 0,
      list: list,
      hasNext: json['hasNext'] as bool? ?? false,
      hasPrev: json['hasPrev'] as bool? ?? false,
    );
  }
  
  /// 转换为JSON
  Map<String, dynamic> toJson(Object? Function(T value) toJsonT) {
    return {
      'page': page,
      'pageSize': pageSize,
      'total': total,
      'totalPages': totalPages,
      'list': list.map((item) => toJsonT(item)).toList(),
      'hasNext': hasNext,
      'hasPrev': hasPrev,
    };
  }
  
  /// 是否为空
  bool get isEmpty => list.isEmpty;
  
  /// 是否不为空
  bool get isNotEmpty => list.isNotEmpty;
  
  /// 数据数量
  int get length => list.length;
  
  /// 是否为第一页
  bool get isFirstPage => page <= 1;
  
  /// 是否为最后一页
  bool get isLastPage => page >= totalPages;
  
  @override
  String toString() {
    return 'PageResponse{page: $page, pageSize: $pageSize, total: $total, totalPages: $totalPages, listLength: ${list.length}}';
  }
}

/// 列表响应数据结构（不分页）
@JsonSerializable(genericArgumentFactories: true)
class ListResponse<T> {
  /// 数据列表
  @JsonKey(name: 'list')
  final List<T> list;
  
  /// 总数量
  @JsonKey(name: 'total')
  final int? total;
  
  const ListResponse({
    required this.list,
    this.total,
  });
  
  /// 创建空的列表响应
  factory ListResponse.empty() {
    return ListResponse<T>(list: const [], total: 0);
  }
  
  /// 从JSON创建
  factory ListResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) {
    final list = (json['list'] as List<dynamic>? ?? [])
        .map((item) => fromJsonT(item))
        .toList();
    
    return ListResponse<T>(
      list: list,
      total: json['total'] as int?,
    );
  }
  
  /// 转换为JSON
  Map<String, dynamic> toJson(Object? Function(T value) toJsonT) {
    return {
      'list': list.map((item) => toJsonT(item)).toList(),
      'total': total,
    };
  }
  
  /// 是否为空
  bool get isEmpty => list.isEmpty;
  
  /// 是否不为空
  bool get isNotEmpty => list.isNotEmpty;
  
  /// 数据数量
  int get length => list.length;
  
  @override
  String toString() {
    return 'ListResponse{listLength: ${list.length}, total: $total}';
  }
}