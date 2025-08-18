class TransactionRecordModel {
  final String id;
  final String type; // 交易类型：recharge-充值, consume-消费, refund-退款, gift-赠送
  final int amount; // 交易金额，单位：分
  final String title; // 交易标题
  final String description; // 交易描述
  final DateTime createTime; // 交易时间
  final String? orderNo; // 关联订单号
  final String? businessType; // 业务类型
  final Map<String, dynamic>? extra; // 额外信息

  TransactionRecordModel({
    required this.id,
    required this.type,
    required this.amount,
    required this.title,
    required this.description,
    required this.createTime,
    this.orderNo,
    this.businessType,
    this.extra,
  });

  factory TransactionRecordModel.fromJson(Map<String, dynamic> json) {
    return TransactionRecordModel(
      id: json['id'] ?? '',
      type: json['type'] ?? '',
      amount: json['amount'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      createTime: DateTime.tryParse(json['createTime'] ?? '') ?? DateTime.now(),
      orderNo: json['orderNo'],
      businessType: json['businessType'],
      extra: json['extra'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'amount': amount,
      'title': title,
      'description': description,
      'createTime': createTime.toIso8601String(),
      'orderNo': orderNo,
      'businessType': businessType,
      'extra': extra,
    };
  }

  // 获取交易金额（元）
  double get amountInYuan => amount / 100.0;

  // 格式化显示金额
  String get formattedAmount {
    final prefix = isIncome ? '+' : '-';
    return '$prefix¥${amountInYuan.abs().toStringAsFixed(2)}';
  }

  // 是否为收入
  bool get isIncome {
    return type == 'recharge' || type == 'refund' || type == 'gift';
  }

  // 是否为支出
  bool get isExpense {
    return type == 'consume';
  }

  // 获取交易类型文本
  String get typeText {
    switch (type) {
      case 'recharge':
        return '充值';
      case 'consume':
        return '消费';
      case 'refund':
        return '退款';
      case 'gift':
        return '赠送';
      default:
        return '未知';
    }
  }

  // 获取交易类型图标
  String get typeIcon {
    switch (type) {
      case 'recharge':
        return 'assets/icons/recharge.svg';
      case 'consume':
        return 'assets/icons/consume.svg';
      case 'refund':
        return 'assets/icons/refund.svg';
      case 'gift':
        return 'assets/icons/gift.svg';
      default:
        return 'assets/icons/transaction.svg';
    }
  }

  // 获取交易类型颜色
  String get typeColor {
    switch (type) {
      case 'recharge':
        return '#ff5e7a'; // 充值-红色
      case 'consume':
        return '#4c8dff'; // 消费-蓝色
      case 'refund':
        return '#ffa541'; // 退款-橙色
      case 'gift':
        return '#8e74ff'; // 赠送-紫色
      default:
        return '#909399'; // 默认-灰色
    }
  }

  // 格式化时间显示
  String get formattedTime {
    final now = DateTime.now();
    final difference = now.difference(createTime);
    
    if (difference.inDays == 0) {
      // 今天
      return '今天 ${createTime.hour.toString().padLeft(2, '0')}:${createTime.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays == 1) {
      // 昨天
      return '昨天 ${createTime.hour.toString().padLeft(2, '0')}:${createTime.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays < 7) {
      // 一周内
      final weekdays = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];
      final weekday = weekdays[createTime.weekday - 1];
      return '$weekday ${createTime.hour.toString().padLeft(2, '0')}:${createTime.minute.toString().padLeft(2, '0')}';
    } else {
      // 超过一周
      return '${createTime.month.toString().padLeft(2, '0')}-${createTime.day.toString().padLeft(2, '0')} ${createTime.hour.toString().padLeft(2, '0')}:${createTime.minute.toString().padLeft(2, '0')}';
    }
  }

  TransactionRecordModel copyWith({
    String? id,
    String? type,
    int? amount,
    String? title,
    String? description,
    DateTime? createTime,
    String? orderNo,
    String? businessType,
    Map<String, dynamic>? extra,
  }) {
    return TransactionRecordModel(
      id: id ?? this.id,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      title: title ?? this.title,
      description: description ?? this.description,
      createTime: createTime ?? this.createTime,
      orderNo: orderNo ?? this.orderNo,
      businessType: businessType ?? this.businessType,
      extra: extra ?? this.extra,
    );
  }
}