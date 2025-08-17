class CouponModel {
  final int id;
  final String name;
  final String description;
  final String type; // 'discount', 'cash', 'percentage'
  final double value; // 优惠金额或折扣比例
  final double? minAmount; // 最低消费金额
  final DateTime startTime;
  final DateTime endTime;
  final int totalCount;
  final int usedCount;
  final bool isReceived;
  final bool isUsed;
  final String? imageUrl;
  final List<String>? applicableCategories;

  CouponModel({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.value,
    this.minAmount,
    required this.startTime,
    required this.endTime,
    required this.totalCount,
    required this.usedCount,
    required this.isReceived,
    required this.isUsed,
    this.imageUrl,
    this.applicableCategories,
  });

  factory CouponModel.fromJson(Map<String, dynamic> json) {
    return CouponModel(
      id: int.tryParse(json['id'].toString()) ?? 0,
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      type: json['type']?.toString() ?? 'discount',
      // 兼容H5项目的字段名：amount 和 value
      value: double.tryParse((json['amount'] ?? json['value'] ?? 0).toString()) ?? 0.0,
      // 兼容H5项目的字段名：minConsume 和 min_amount
      minAmount: json['minConsume'] != null ? double.tryParse(json['minConsume'].toString()) : 
                 json['min_amount'] != null ? double.tryParse(json['min_amount'].toString()) : null,
      // 兼容H5项目的字段名：beginTime 和 start_time
      startTime: DateTime.tryParse(json['beginTime']?.toString() ?? json['start_time']?.toString() ?? '') ?? DateTime.now(),
      // 兼容H5项目的字段名：expireTime 和 end_time
      endTime: DateTime.tryParse(json['expireTime']?.toString() ?? json['end_time']?.toString() ?? '') ?? DateTime.now().add(const Duration(days: 30)),
      totalCount: int.tryParse(json['total_count']?.toString() ?? json['totalCount']?.toString() ?? '0') ?? 0,
      usedCount: int.tryParse(json['used_count']?.toString() ?? json['usedCount']?.toString() ?? '0') ?? 0,
      isReceived: json['is_received'] == true || json['is_received'] == 'true' || json['isReceived'] == true || json['isReceived'] == 'true',
      isUsed: json['is_used'] == true || json['is_used'] == 'true' || json['isUsed'] == true || json['isUsed'] == 'true',
      imageUrl: json['image_url']?.toString() ?? json['imageUrl']?.toString(),
      applicableCategories: json['applicable_categories'] != null 
          ? List<String>.from(json['applicable_categories'].map((e) => e.toString())) 
          : json['applicableCategories'] != null
          ? List<String>.from(json['applicableCategories'].map((e) => e.toString()))
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'type': type,
      'value': value,
      'min_amount': minAmount,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime.toIso8601String(),
      'total_count': totalCount,
      'used_count': usedCount,
      'is_received': isReceived,
      'is_used': isUsed,
      'image_url': imageUrl,
      'applicable_categories': applicableCategories,
    };
  }

  bool get isExpired {
    return DateTime.now().isAfter(endTime);
  }

  bool get isValid {
    return !isExpired && !isUsed && totalCount > usedCount;
  }

  bool get canReceive {
    return isValid && !isReceived;
  }

  String get displayValue {
    switch (type) {
      case 'cash':
        return '¥${(value / 100).toStringAsFixed(0)}';
      case 'percentage':
        return '${(value * 10).toInt()}折';
      case 'discount':
      default:
        return '¥${(value / 100).toStringAsFixed(0)}';
    }
  }

  String get displayCondition {
    if (minAmount != null && minAmount! > 0) {
      return '满¥${(minAmount! / 100).toStringAsFixed(0)}可用';
    }
    return '无门槛';
  }
}