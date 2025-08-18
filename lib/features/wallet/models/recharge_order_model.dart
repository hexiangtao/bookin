class RechargeOrderModel {
  final String rechargeOrderNo;
  final int amount; // 充值金额，单位：分
  final int giftAmount; // 赠送金额，单位：分
  final String paymentMethod; // 支付方式：wechat, alipay
  final int status; // 订单状态：0-待支付, 1-支付成功, 2-取消
  final DateTime createTime;
  final Map<String, dynamic>? paymentParams; // 支付参数

  RechargeOrderModel({
    required this.rechargeOrderNo,
    required this.amount,
    required this.giftAmount,
    required this.paymentMethod,
    required this.status,
    required this.createTime,
    this.paymentParams,
  });

  factory RechargeOrderModel.fromJson(Map<String, dynamic> json) {
    return RechargeOrderModel(
      rechargeOrderNo: json['rechargeOrderNo'] ?? '',
      amount: json['amount'] ?? 0,
      giftAmount: json['giftAmount'] ?? 0,
      paymentMethod: json['paymentMethod'] ?? '',
      status: json['status'] ?? 0,
      createTime: DateTime.tryParse(json['createTime'] ?? '') ?? DateTime.now(),
      paymentParams: json['paymentParams'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'rechargeOrderNo': rechargeOrderNo,
      'amount': amount,
      'giftAmount': giftAmount,
      'paymentMethod': paymentMethod,
      'status': status,
      'createTime': createTime.toIso8601String(),
      'paymentParams': paymentParams,
    };
  }

  // 获取充值金额（元）
  double get amountInYuan => amount / 100.0;

  // 获取赠送金额（元）
  double get giftAmountInYuan => giftAmount / 100.0;

  // 获取总金额（元）
  double get totalAmountInYuan => (amount + giftAmount) / 100.0;

  // 格式化显示充值金额
  String get formattedAmount {
    return '¥${amountInYuan.toStringAsFixed(2)}';
  }

  // 格式化显示总金额
  String get formattedTotalAmount {
    return '¥${totalAmountInYuan.toStringAsFixed(2)}';
  }

  // 获取订单状态文本
  String get statusText {
    switch (status) {
      case 0:
        return '待支付';
      case 1:
        return '支付成功';
      case 2:
        return '已取消';
      default:
        return '未知状态';
    }
  }

  // 获取支付方式文本
  String get paymentMethodText {
    switch (paymentMethod.toLowerCase()) {
      case 'wechat':
        return '微信支付';
      case 'alipay':
        return '支付宝';
      default:
        return '未知支付方式';
    }
  }

  // 是否为待支付状态
  bool get isPending => status == 0;

  // 是否支付成功
  bool get isSuccess => status == 1;

  // 是否已取消
  bool get isCancelled => status == 2;

  // 是否有赠送金额
  bool get hasGift => giftAmount > 0;

  RechargeOrderModel copyWith({
    String? rechargeOrderNo,
    int? amount,
    int? giftAmount,
    String? paymentMethod,
    int? status,
    DateTime? createTime,
    Map<String, dynamic>? paymentParams,
  }) {
    return RechargeOrderModel(
      rechargeOrderNo: rechargeOrderNo ?? this.rechargeOrderNo,
      amount: amount ?? this.amount,
      giftAmount: giftAmount ?? this.giftAmount,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      status: status ?? this.status,
      createTime: createTime ?? this.createTime,
      paymentParams: paymentParams ?? this.paymentParams,
    );
  }
}