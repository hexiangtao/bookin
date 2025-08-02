/// Order status codes
enum OrderStatus {
  WAITING_PAYMENT, // 10
  PAYMENT_TIMEOUT, // 15
  WAITING_SERVICE, // 20
  WAITING_REVIEW, // 30
  COMPLETED, // 40
  CANCELED, // 50
  REFUNDING, // 60
  REFUNDED, // 70
  UNKNOWN,
}

extension OrderStatusExtension on OrderStatus {
  int get code {
    switch (this) {
      case OrderStatus.WAITING_PAYMENT: return 10;
      case OrderStatus.PAYMENT_TIMEOUT: return 15;
      case OrderStatus.WAITING_SERVICE: return 20;
      case OrderStatus.WAITING_REVIEW: return 30;
      case OrderStatus.COMPLETED: return 40;
      case OrderStatus.CANCELED: return 50;
      case OrderStatus.REFUNDING: return 60;
      case OrderStatus.REFUNDED: return 70;
      case OrderStatus.UNKNOWN: return -1; // Or throw an error
    }
  }

  String get title {
    switch (this) {
      case OrderStatus.WAITING_PAYMENT: return '等待支付';
      case OrderStatus.PAYMENT_TIMEOUT: return '支付超时';
      case OrderStatus.WAITING_SERVICE: return '支付成功';
      case OrderStatus.WAITING_REVIEW: return '待评价';
      case OrderStatus.COMPLETED: return '已完成';
      case OrderStatus.CANCELED: return '已取消';
      case OrderStatus.REFUNDING: return '退款中';
      case OrderStatus.REFUNDED: return '已退款';
      case OrderStatus.UNKNOWN: return '订单状态未知';
    }
  }

  String get cssClass {
    switch (this) {
      case OrderStatus.WAITING_PAYMENT: return 'pending-section';
      case OrderStatus.PAYMENT_TIMEOUT: return 'timeout-section';
      case OrderStatus.WAITING_SERVICE:
      case OrderStatus.WAITING_REVIEW:
      case OrderStatus.COMPLETED: return 'success-section';
      case OrderStatus.CANCELED: return 'cancel-section';
      case OrderStatus.REFUNDING:
      case OrderStatus.REFUNDED: return 'refund-section';
      case OrderStatus.UNKNOWN: return 'default-section';
    }
  }

  String get icon {
    switch (this) {
      case OrderStatus.WAITING_PAYMENT: return 'clock-fill';
      case OrderStatus.PAYMENT_TIMEOUT: return 'error-circle-fill';
      case OrderStatus.WAITING_SERVICE:
      case OrderStatus.WAITING_REVIEW:
      case OrderStatus.COMPLETED:
      case OrderStatus.REFUNDED: return 'checkmark-circle';
      case OrderStatus.CANCELED: return 'close-circle-fill';
      case OrderStatus.REFUNDING: return 'reload';
      case OrderStatus.UNKNOWN: return 'help-circle';
    }
  }

  static OrderStatus fromCode(int code) {
    switch (code) {
      case 10: return OrderStatus.WAITING_PAYMENT;
      case 15: return OrderStatus.PAYMENT_TIMEOUT;
      case 20: return OrderStatus.WAITING_SERVICE;
      case 30: return OrderStatus.WAITING_REVIEW;
      case 40: return OrderStatus.COMPLETED;
      case 50: return OrderStatus.CANCELED;
      case 60: return OrderStatus.REFUNDING;
      case 70: return OrderStatus.REFUNDED;
      default: return OrderStatus.UNKNOWN;
    }
  }
}

/// Check if order can be reviewed
bool canReviewOrder(OrderStatus status, bool reviewed) {
  return status == OrderStatus.WAITING_REVIEW && !reviewed;
}

/// Get payment method text
String getPaymentMethodText(String method) {
  switch (method) {
    case 'balance': return '余额支付';
    case 'wechat': return '微信支付';
    case 'alipay': return '支付宝支付';
    default: return '线上支付';
  }
}

// New Order Status Definitions based on backend OrderStatusEnum
enum NewOrderStatus {
  PENDING_PAYMENT, // 10
  WAIT_ACCEPT, // 20
  PENDING_SERVICE, // 30
  SERVICE, // 40
  COMPLETED, // 50
  CANCELLED, // 60
  REFUNDING, // 70
  REFUNDED, // 80
  UNKNOWN,
}

extension NewOrderStatusExtension on NewOrderStatus {
  int get code {
    switch (this) {
      case NewOrderStatus.PENDING_PAYMENT: return 10;
      case NewOrderStatus.WAIT_ACCEPT: return 20;
      case NewOrderStatus.PENDING_SERVICE: return 30;
      case NewOrderStatus.SERVICE: return 40;
      case NewOrderStatus.COMPLETED: return 50;
      case NewOrderStatus.CANCELLED: return 60;
      case NewOrderStatus.REFUNDING: return 70;
      case NewOrderStatus.REFUNDED: return 80;
      case NewOrderStatus.UNKNOWN: return -1;
    }
  }

  String get value {
    switch (this) {
      case NewOrderStatus.PENDING_PAYMENT: return "pending_payment";
      case NewOrderStatus.WAIT_ACCEPT: return "pending_payment"; // Backend enum has value: "pending_payment", ideally "wait_accept"
      case NewOrderStatus.PENDING_SERVICE: return "pending_service";
      case NewOrderStatus.SERVICE: return "in_service";
      case NewOrderStatus.COMPLETED: return "completed";
      case NewOrderStatus.CANCELLED: return "cancelled";
      case NewOrderStatus.REFUNDING: return "refunding";
      case NewOrderStatus.REFUNDED: return "refunded";
      case NewOrderStatus.UNKNOWN: return "unknown";
    }
  }

  String get description {
    switch (this) {
      case NewOrderStatus.PENDING_PAYMENT: return "待支付";
      case NewOrderStatus.WAIT_ACCEPT: return "待接单";
      case NewOrderStatus.PENDING_SERVICE: return "待服务";
      case NewOrderStatus.SERVICE: return "服务中";
      case NewOrderStatus.COMPLETED: return "已完成";
      case NewOrderStatus.CANCELLED: return "已取消";
      case NewOrderStatus.REFUNDING: return "退款中";
      case NewOrderStatus.REFUNDED: return "已退款";
      case NewOrderStatus.UNKNOWN: return "未知状态";
    }
  }

  String get cssClass {
    switch (this) {
      case NewOrderStatus.PENDING_PAYMENT: return 'pending-section';
      case NewOrderStatus.WAIT_ACCEPT: return 'service-section';
      case NewOrderStatus.PENDING_SERVICE: return 'service-section';
      case NewOrderStatus.SERVICE: return 'service-section';
      case NewOrderStatus.COMPLETED: return 'success-section';
      case NewOrderStatus.CANCELLED: return 'cancel-section';
      case NewOrderStatus.REFUNDING: return 'refund-section';
      case NewOrderStatus.REFUNDED: return 'refund-section';
      case NewOrderStatus.UNKNOWN: return 'default-section';
    }
  }

  String get icon {
    switch (this) {
      case NewOrderStatus.PENDING_PAYMENT: return 'clock-fill';
      case NewOrderStatus.WAIT_ACCEPT: return 'notification-fill';
      case NewOrderStatus.PENDING_SERVICE: return 'notification-fill';
      case NewOrderStatus.SERVICE: return 'settings-fill';
      case NewOrderStatus.COMPLETED: return 'checkmark-circle';
      case NewOrderStatus.CANCELLED: return 'close-circle-fill';
      case NewOrderStatus.REFUNDING: return 'reload';
      case NewOrderStatus.REFUNDED: return 'checkmark-circle';
      case NewOrderStatus.UNKNOWN: return 'help-circle';
    }
  }

  static NewOrderStatus fromCode(int code) {
    switch (code) {
      case 10: return NewOrderStatus.PENDING_PAYMENT;
      case 20: return NewOrderStatus.WAIT_ACCEPT;
      case 30: return NewOrderStatus.PENDING_SERVICE;
      case 40: return NewOrderStatus.SERVICE;
      case 50: return NewOrderStatus.COMPLETED;
      case 60: return NewOrderStatus.CANCELLED;
      case 70: return NewOrderStatus.REFUNDING;
      case 80: return NewOrderStatus.REFUNDED;
      default: return NewOrderStatus.UNKNOWN;
    }
  }

  static NewOrderStatus fromValue(String value) {
    switch (value) {
      case "pending_payment": return NewOrderStatus.PENDING_PAYMENT;
      case "wait_accept": return NewOrderStatus.WAIT_ACCEPT;
      case "pending_service": return NewOrderStatus.PENDING_SERVICE;
      case "in_service": return NewOrderStatus.SERVICE;
      case "completed": return NewOrderStatus.COMPLETED;
      case "cancelled": return NewOrderStatus.CANCELLED;
      case "refunding": return NewOrderStatus.REFUNDING;
      case "refunded": return NewOrderStatus.REFUNDED;
      default: return NewOrderStatus.UNKNOWN;
    }
  }
}

/// Payment Methods
enum PaymentMethod {
  BALANCE,
  WECHAT,
  ALIPAY,
  UNKNOWN,
}

extension PaymentMethodExtension on PaymentMethod {
  String get value {
    switch (this) {
      case PaymentMethod.BALANCE: return 'balance';
      case PaymentMethod.WECHAT: return 'wechat';
      case PaymentMethod.ALIPAY: return 'alipay';
      case PaymentMethod.UNKNOWN: return 'unknown';
    }
  }

  String get description {
    switch (this) {
      case PaymentMethod.BALANCE: return '余额支付';
      case PaymentMethod.WECHAT: return '微信支付';
      case PaymentMethod.ALIPAY: return '支付宝支付';
      case PaymentMethod.UNKNOWN: return '未知支付方式';
    }
  }

  static PaymentMethod fromValue(String value) {
    switch (value) {
      case 'balance': return PaymentMethod.BALANCE;
      case 'wechat': return PaymentMethod.WECHAT;
      case 'alipay': return PaymentMethod.ALIPAY;
      default: return PaymentMethod.UNKNOWN;
    }
  }
}

/// Travel Modes
enum TravelMode {
  TECH, // 技师上门
  PUBLIC, // 用户前往
  WALKING, // 步行前往
  BIKING, // 骑行前往
  DRIVING, // 驾车前往
  UNKNOWN,
}

extension TravelModeExtension on TravelMode {
  String get value {
    switch (this) {
      case TravelMode.TECH: return 'tech';
      case TravelMode.PUBLIC: return 'public';
      case TravelMode.WALKING: return 'walking';
      case TravelMode.BIKING: return 'biking';
      case TravelMode.DRIVING: return 'driving';
      case TravelMode.UNKNOWN: return 'unknown';
    }
  }

  String get description {
    switch (this) {
      case TravelMode.TECH: return '技师上门';
      case TravelMode.PUBLIC: return '用户前往';
      case TravelMode.WALKING: return '步行前往';
      case TravelMode.BIKING: return '骑行前往';
      case TravelMode.DRIVING: return '驾车前往';
      case TravelMode.UNKNOWN: return '未知出行方式';
    }
  }

  static TravelMode fromValue(String value) {
    switch (value) {
      case 'tech': return TravelMode.TECH;
      case 'public': return TravelMode.PUBLIC;
      case 'walking': return TravelMode.WALKING;
      case 'biking': return TravelMode.BIKING;
      case 'driving': return TravelMode.DRIVING;
      default: return TravelMode.UNKNOWN;
    }
  }
}

// Review Dimensions
class ReviewDimension {
  final String key;
  final String name;

  ReviewDimension({required this.key, required this.name});
}

final Map<String, ReviewDimension> reviewDimensions = {
  'attitude': ReviewDimension(key: 'attitude', name: '服务态度'),
  'skill': ReviewDimension(key: 'skill', name: '专业技能'),
  'environment': ReviewDimension(key: 'environment', name: '环境卫生'),
  'value': ReviewDimension(key: 'value', name: '性价比'),
};

// Quick Tags
const List<String> quickTags = [
  '服务专业',
  '技师热情',
  '按摩手法好',
  '环境舒适',
  '性价比高',
  '准时守约',
];

// Placeholder for SERVICE_PROJECTS, COUPONS, TECHNICIANS if needed for local mock data
// These would typically come from API responses in a real app.

// Example structure for SERVICE_PROJECTS (if needed for local mock/defaults)
/*
class ServiceProject {
  final String id;
  final String name;
  final String icon;
  final String tips;
  final int original;
  final int price;
  final int num;
  final String tag;
  final int timer;
  final int buycount;

  ServiceProject({
    required this.id, required this.name, required this.icon, required this.tips,
    required this.original, required this.price, required this.num, required this.tag,
    required this.timer, required this.buycount,
  });
}

final List<ServiceProject> serviceProjects = [
  ServiceProject(id: 'project_1', name: '古法推拿', icon: '/static/project/a.png', tips: '传统手法，舒筋活络', original: 198, price: 198, num: 1000, tag: '热门', timer: 60, buycount: 1),
  // ... other projects
];
*/
