class PaymentMethodModel {
  final String id;
  final String name;
  final String type; // wechat, alipay
  final String icon;
  final bool isEnabled;
  final String? description;
  final Map<String, dynamic>? config;

  PaymentMethodModel({
    required this.id,
    required this.name,
    required this.type,
    required this.icon,
    this.isEnabled = true,
    this.description,
    this.config,
  });

  factory PaymentMethodModel.fromJson(Map<String, dynamic> json) {
    return PaymentMethodModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      type: json['type'] ?? '',
      icon: json['icon'] ?? '',
      isEnabled: json['isEnabled'] ?? true,
      description: json['description'],
      config: json['config'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'icon': icon,
      'isEnabled': isEnabled,
      'description': description,
      'config': config,
    };
  }

  // 获取支付方式图标路径
  String get iconPath {
    switch (type.toLowerCase()) {
      case 'wechat':
        return 'assets/icons/wechat_pay.svg';
      case 'alipay':
        return 'assets/icons/alipay.svg';
      default:
        return icon;
    }
  }

  // 获取支付方式背景颜色
  String get backgroundColor {
    switch (type.toLowerCase()) {
      case 'wechat':
        return '#44c35a'; // 微信绿
      case 'alipay':
        return '#1890ff'; // 支付宝蓝
      default:
        return '#909399'; // 默认灰色
    }
  }

  // 获取支付方式渐变色
  List<String> get gradientColors {
    switch (type.toLowerCase()) {
      case 'wechat':
        return ['#44c35a', '#09BB07'];
      case 'alipay':
        return ['#1890ff', '#1677FF'];
      default:
        return ['#909399', '#606266'];
    }
  }

  // 是否为微信支付
  bool get isWechat => type.toLowerCase() == 'wechat';

  // 是否为支付宝
  bool get isAlipay => type.toLowerCase() == 'alipay';

  PaymentMethodModel copyWith({
    String? id,
    String? name,
    String? type,
    String? icon,
    bool? isEnabled,
    String? description,
    Map<String, dynamic>? config,
  }) {
    return PaymentMethodModel(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      icon: icon ?? this.icon,
      isEnabled: isEnabled ?? this.isEnabled,
      description: description ?? this.description,
      config: config ?? this.config,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PaymentMethodModel &&
        other.id == id &&
        other.name == name &&
        other.type == type &&
        other.icon == icon &&
        other.isEnabled == isEnabled &&
        other.description == description;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        type.hashCode ^
        icon.hashCode ^
        isEnabled.hashCode ^
        description.hashCode;
  }

  // 预定义的支付方式
  static List<PaymentMethodModel> get defaultPaymentMethods => [
    PaymentMethodModel(
      id: 'wechat',
      name: '微信支付',
      type: 'wechat',
      icon: 'assets/icons/wechat_pay.svg',
      description: '使用微信支付安全快捷',
    ),
    PaymentMethodModel(
      id: 'alipay',
      name: '支付宝',
      type: 'alipay',
      icon: 'assets/icons/alipay.svg',
      description: '使用支付宝支付安全可靠',
    ),
  ];
}