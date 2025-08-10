class ApiEndpoints {
  // 基础路径 - 与H5项目保持一致，直接使用路径
  
  // 首页相关
  static const String banners = '/home/banners';
  static const String hotProjects = '/home/projects';
  static const String featuredTechnicians = '/home/featured-technicians';
  
  // 技师相关 - 与H5项目路径保持一致
  static const String technicians = '/teacher/list';
  static const String technicianDetail = '/teacher/detail/{id}';
  static const String technicianReviews = '/teacher/reviews/{id}';
  static const String technicianProjects = '/teacher/projects/{id}';
  
  // 项目相关
  static const String projects = '/project/list';
  static const String projectDetail = '/project/detail/{id}';
  static const String projectRecommend = '/project/recommend';
  static const String projectCategories = '/project/categories';
  
  // 订单相关
  static const String orders = '/order/list';
  static const String orderDetail = '/order/detail/{id}';
  static const String createOrder = '/order/create';
  static const String cancelOrder = '/order/cancel/{id}';
  
  // 用户相关
  static const String userProfile = '/user/profile';
  static const String userOrders = '/user/orders';
  static const String userFavorites = '/user/favorites';
  
  // 认证相关
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String refreshToken = '/auth/refresh';
  
  // 搜索相关
  static const String search = '/search';
  static const String searchSuggestions = '/search/suggestions';
  
  // 地址相关
  static const String addresses = '/address/list';
  static const String cities = '/region/cities';
  static const String districts = '/region/districts';
  
  // 支付相关
  static const String payment = '/payment';
  static const String paymentMethods = '/payment/methods';
  
  // 评价相关
  static const String reviews = '/comment/list';
  static const String createReview = '/comment/create';
  
  // 优惠券相关
  static const String coupons = '/coupon/list';
  static const String userCoupons = '/user/coupons';
  
  // 通知相关
  static const String notifications = '/notification/list';
  static const String markNotificationRead = '/notification/read/{id}';
  
  // 帮助相关
  static const String helpCategories = '/help/categories';
  static const String helpArticles = '/help/articles';
  
  // 反馈相关
  static const String feedback = '/feedback/create';
  
  // 系统配置
  static const String systemConfig = '/system/config';
  static const String appVersion = '/system/version';
}