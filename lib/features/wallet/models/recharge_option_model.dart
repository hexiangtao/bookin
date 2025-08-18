class RechargeOptionModel {
  final int value; // 充值金额，单位：分
  final int gift; // 赠送金额，单位：分
  final bool isPopular; // 是否为热门选项
  final String? description; // 描述信息

  RechargeOptionModel({
    required this.value,
    required this.gift,
    this.isPopular = false,
    this.description,
  });

  factory RechargeOptionModel.fromJson(Map<String, dynamic> json) {
    return RechargeOptionModel(
      value: json['value'] ?? 0,
      gift: json['gift'] ?? 0,
      isPopular: json['isPopular'] ?? false,
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'value': value,
      'gift': gift,
      'isPopular': isPopular,
      'description': description,
    };
  }

  // 获取充值金额（元）
  double get valueInYuan => value / 100.0;

  // 获取赠送金额（元）
  double get giftInYuan => gift / 100.0;

  // 获取总金额（元）
  double get totalInYuan => (value + gift) / 100.0;

  // 格式化显示充值金额
  String get formattedValue {
    return '¥${valueInYuan.toStringAsFixed(0)}';
  }

  // 格式化显示赠送金额
  String get formattedGift {
    if (gift > 0) {
      return '送¥${giftInYuan.toStringAsFixed(0)}';
    }
    return '';
  }

  // 格式化显示总金额
  String get formattedTotal {
    return '¥${totalInYuan.toStringAsFixed(2)}';
  }

  // 是否有赠送
  bool get hasGift => gift > 0;

  RechargeOptionModel copyWith({
    int? value,
    int? gift,
    bool? isPopular,
    String? description,
  }) {
    return RechargeOptionModel(
      value: value ?? this.value,
      gift: gift ?? this.gift,
      isPopular: isPopular ?? this.isPopular,
      description: description ?? this.description,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RechargeOptionModel &&
        other.value == value &&
        other.gift == gift &&
        other.isPopular == isPopular &&
        other.description == description;
  }

  @override
  int get hashCode {
    return value.hashCode ^
        gift.hashCode ^
        isPopular.hashCode ^
        description.hashCode;
  }
}