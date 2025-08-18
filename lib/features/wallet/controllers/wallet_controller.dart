import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import '../../../core/utils/loading_utils.dart';
import '../../../core/utils/toast_utils.dart';
import '../../../core/utils/storage_utils.dart';
import '../../../core/utils/validation_helper.dart';
import '../api/wallet_api.dart';
import '../models/wallet_balance_model.dart';
import '../models/recharge_option_model.dart';
import '../models/recharge_order_model.dart';
import '../models/transaction_record_model.dart';
import '../models/payment_method_model.dart';

class WalletController extends GetxController {
  final WalletApi _walletApi = Get.find<WalletApi>();
  
  // 钱包余额信息
  final Rx<WalletBalanceModel?> _walletBalance = Rx<WalletBalanceModel?>(null);
  WalletBalanceModel? get walletBalance => _walletBalance.value;
  
  // 充值选项
  final RxList<RechargeOptionModel> _rechargeOptions = <RechargeOptionModel>[].obs;
  List<RechargeOptionModel> get rechargeOptions => _rechargeOptions;
  
  // 支付方式
  final RxList<PaymentMethodModel> _paymentMethods = <PaymentMethodModel>[].obs;
  List<PaymentMethodModel> get paymentMethods => _paymentMethods;
  
  // 选中的充值金额
  final Rx<RechargeOptionModel?> _selectedRechargeOption = Rx<RechargeOptionModel?>(null);
  RechargeOptionModel? get selectedRechargeOption => _selectedRechargeOption.value;
  
  // 自定义充值金额
  final RxDouble _customAmount = 0.0.obs;
  double get customAmount => _customAmount.value;
  
  // 选中的支付方式
  final Rx<PaymentMethodModel?> _selectedPaymentMethod = Rx<PaymentMethodModel?>(null);
  PaymentMethodModel? get selectedPaymentMethod => _selectedPaymentMethod.value;
  
  // 是否显示充值区域
  final RxBool _showRechargeSection = true.obs;
  bool get showRechargeSection => _showRechargeSection.value;
  
  // 加载状态
  final RxBool _isLoading = false.obs;
  bool get isLoading => _isLoading.value;
  
  final RxBool _isLoadingOptions = false.obs;
  bool get isLoadingOptions => _isLoadingOptions.value;
  
  final RxBool _isRecharging = false.obs;
  bool get isRecharging => _isRecharging.value;
  
  // 错误状态
  final RxBool _hasError = false.obs;
  bool get hasError => _hasError.value;
  
  final RxString _errorMessage = ''.obs;
  String get errorMessage => _errorMessage.value;
  
  final RxBool _hasRechargeError = false.obs;
  bool get hasRechargeError => _hasRechargeError.value;
  
  final RxString _rechargeErrorMessage = ''.obs;
  String get rechargeErrorMessage => _rechargeErrorMessage.value;
  
  // 兼容性属性
  bool get isLoadingRechargeOptions => _isLoadingOptions.value;
  
  // 自定义金额输入控制器
  final TextEditingController customAmountController = TextEditingController();
  
  // 当前充值订单
  RechargeOrderModel? _currentRechargeOrder;
  
  // 订单状态查询定时器
  Timer? _orderStatusTimer;
  
  @override
  void onInit() {
    super.onInit();
    _initializePaymentMethods();
    _loadWalletData();
    _checkPendingOrder();
  }
  
  @override
  void onClose() {
    customAmountController.dispose();
    _orderStatusTimer?.cancel();
    super.onClose();
  }
  
  /// 初始化支付方式
  void _initializePaymentMethods() {
    _paymentMethods.value = PaymentMethodModel.defaultPaymentMethods;
    if (_paymentMethods.isNotEmpty) {
      _selectedPaymentMethod.value = _paymentMethods.first;
    }
  }
  
  /// 加载钱包数据
  Future<void> _loadWalletData() async {
    await Future.wait([
      fetchBalance(),
      fetchRechargeOptions(),
    ]);
  }
  
  /// 获取钱包余额（新方法名）
  Future<void> fetchBalance() async {
    await getUserBalance();
  }
  
  /// 检查是否有待处理的充值订单
  Future<void> _checkPendingOrder() async {
    final orderNo = StorageUtils.getString('lastRechargeOrderNo');
    if (orderNo != null && orderNo.isNotEmpty) {
      await checkRechargeStatus(orderNo);
    }
  }
  
  /// 获取用户余额
  Future<void> getUserBalance() async {
    if (_isLoading.value) return;
    
    _isLoading.value = true;
    _hasError.value = false;
    _errorMessage.value = '';
    
    try {
      final response = await _walletApi.getWalletBalance();
      if (response.success && response.data != null) {
        // 验证余额数据
        ValidationResult balanceResult = ValidationHelper.validateWalletBalance(response.data!.toJson());
        if (!balanceResult.isValid) {
          throw Exception(balanceResult.errorMessage);
        }
        
        _walletBalance.value = response.data;
        _hasError.value = false;
      } else {
        _hasError.value = true;
        _errorMessage.value = response.message ?? '获取余额失败';
        ToastUtils.showError(_errorMessage.value);
      }
    } on DioException catch (e) {
      _hasError.value = true;
      _errorMessage.value = _getNetworkErrorMessage(e);
      ToastUtils.showError(_errorMessage.value);
    } catch (e) {
      _hasError.value = true;
      _errorMessage.value = '获取余额异常: $e';
      ToastUtils.showError(_errorMessage.value);
    } finally {
      _isLoading.value = false;
    }
  }
  
  /// 获取充值选项
  Future<void> fetchRechargeOptions() async {
    if (_isLoadingOptions.value) return;
    
    _isLoadingOptions.value = true;
    _hasRechargeError.value = false;
    _rechargeErrorMessage.value = '';
    update(['recharge_section']); // 通知UI开始加载
    
    try {
      final response = await _walletApi.getRechargeOptions();
      if (response.success && response.data != null) {
        if (response.data!.isEmpty) {
          ToastUtils.showWarning('暂无可用的充值选项');
        }
        
        _rechargeOptions.value = response.data!;
        _hasRechargeError.value = false;
      } else {
        _hasRechargeError.value = true;
        _rechargeErrorMessage.value = response.message ?? '获取充值选项失败';
        _handleApiError(_rechargeErrorMessage.value);
        _rechargeOptions.value = [];
      }
    } on DioException catch (e) {
      _hasRechargeError.value = true;
      _rechargeErrorMessage.value = _getNetworkErrorMessage(e);
      _handleNetworkError(e);
      _rechargeOptions.value = [];
    } catch (e) {
      _hasRechargeError.value = true;
      _rechargeErrorMessage.value = '获取充值选项异常: $e';
      _handleUnknownError(e, '获取充值选项');
      _rechargeOptions.value = [];
    } finally {
      _isLoadingOptions.value = false;
      update(['recharge_section']); // 通知UI更新完成
    }
  }
  
  /// 处理API错误
  void _handleApiError(String message) {
    if (message.contains('网络')) {
      ToastUtils.showError('网络连接异常，请检查网络设置');
    } else if (message.contains('服务器')) {
      ToastUtils.showError('服务暂时不可用，请稍后重试');
    } else {
      ToastUtils.showError(message);
    }
  }
  
  /// 处理网络错误
  void _handleNetworkError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        ToastUtils.showError('网络连接超时，请重试');
        break;
      case DioExceptionType.connectionError:
        ToastUtils.showError('网络连接失败，请检查网络设置');
        break;
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        if (statusCode == 401) {
          ToastUtils.showError('登录已过期，请重新登录');
        } else if (statusCode == 403) {
          ToastUtils.showError('没有访问权限');
        } else if (statusCode == 404) {
          ToastUtils.showError('请求的资源不存在');
        } else if (statusCode != null && statusCode >= 500) {
          ToastUtils.showError('服务器异常，请稍后重试');
        } else {
          ToastUtils.showError('请求失败，请重试');
        }
        break;
      default:
        ToastUtils.showError('网络异常，请重试');
    }
  }
  
  /// 处理未知错误
  void _handleUnknownError(dynamic error, String operation) {
    print('$operation异常: $error');
    ToastUtils.showError('操作失败，请重试');
  }
  
  /// 获取网络错误消息
  String _getNetworkErrorMessage(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return '网络连接超时，请重试';
      case DioExceptionType.connectionError:
        return '网络连接失败，请检查网络设置';
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        if (statusCode == 401) {
          return '登录已过期，请重新登录';
        } else if (statusCode == 403) {
          return '没有访问权限';
        } else if (statusCode == 404) {
          return '请求的资源不存在';
        } else if (statusCode != null && statusCode >= 500) {
          return '服务器异常，请稍后重试';
        } else {
          return '请求失败，请重试';
        }
      default:
        return '网络异常，请重试';
    }
  }
  
  /// 选择充值金额
  void selectRechargeOption(RechargeOptionModel option) {
    _selectedRechargeOption.value = option;
    _customAmount.value = 0.0;
    customAmountController.clear();
    update(['recharge_section']); // 只更新充值区域
  }
  
  /// 设置自定义充值金额
  void setCustomAmount(double amount) {
    // 验证金额
    ValidationResult result = ValidationHelper.validateRechargeAmount(amount);
    if (!result.isValid) {
      ToastUtils.showError(result.errorMessage!);
      return;
    }
    
    _customAmount.value = amount;
    _selectedRechargeOption.value = null;
    update(['recharge_section']); // 只更新充值区域
  }

  /// 验证并设置自定义金额输入
  void setCustomAmountFromInput(String input) {
    // 清理和验证输入
    String sanitizedInput = ValidationHelper.sanitizeInput(input.trim());
    
    ValidationResult result = ValidationHelper.validateCustomAmountInput(sanitizedInput);
    if (!result.isValid) {
      ToastUtils.showError(result.errorMessage!);
      return;
    }
    
    double amount = double.parse(sanitizedInput);
    setCustomAmount(amount);
  }
  
  /// 处理自定义金额输入
  void onCustomAmountChanged(String value) {
    final amount = double.tryParse(value) ?? 0.0;
    if (amount >= 1 && amount <= 50000) {
      setCustomAmount(amount);
    } else if (amount > 50000) {
      customAmountController.text = '50000';
      setCustomAmount(50000);
      ToastUtils.showWarning('单次充值金额不能超过50000元');
    }
  }
  
  /// 选择支付方式
  void selectPaymentMethod(PaymentMethodModel method) {
    _selectedPaymentMethod.value = method;
  }
  
  /// 显示/隐藏充值区域
  void toggleRechargeSection() {
    _showRechargeSection.value = !_showRechargeSection.value;
  }
  
  /// 显示充值区域
  void showRecharge() {
    _showRechargeSection.value = true;
  }
  
  /// 隐藏充值区域
  void hideRecharge() {
    _showRechargeSection.value = false;
  }
  
  /// 获取当前选中的充值金额（分）
  int get selectedAmountInCents {
    if (_selectedRechargeOption.value != null) {
      return _selectedRechargeOption.value!.value;
    } else if (_customAmount.value > 0) {
      return (_customAmount.value * 100).round();
    }
    return 0;
  }
  
  /// 获取当前选中的充值金额（元）
  double get selectedAmount {
    return selectedAmountInCents / 100.0;
  }
  
  /// 获取当前选中的赠送金额（分）
  int get selectedGiftAmountInCents {
    if (_selectedRechargeOption.value != null) {
      return _selectedRechargeOption.value!.gift;
    }
    return 0;
  }
  
  /// 获取当前选中的总金额（元）
  double get selectedTotalAmount {
    return (selectedAmountInCents + selectedGiftAmountInCents) / 100.0;
  }
  
  /// 格式化显示总金额
  String get formattedTotalAmount {
    return '¥${selectedTotalAmount.toStringAsFixed(2)}';
  }
  
  /// 验证充值参数
  bool _validateRechargeParams() {
    if (selectedAmountInCents <= 0) {
      ToastUtils.showWarning('请选择充值金额');
      return false;
    }
    
    if (_selectedPaymentMethod.value == null) {
      ToastUtils.showWarning('请选择支付方式');
      return false;
    }
    
    if (selectedAmountInCents < 100) { // 最低1元
      ToastUtils.showWarning('充值金额不能少于1元');
      return false;
    }
    
    if (selectedAmountInCents > 5000000) { // 最高50000元
      ToastUtils.showWarning('充值金额不能超过50000元');
      return false;
    }
    
    return true;
  }
  
  /// 执行充值
  Future<void> doRecharge() async {
    if (!_validateRechargeParams()) return;
    if (_isRecharging.value) return;
    
    _isRecharging.value = true;
    LoadingUtils.showLoading(message: '正在创建订单...');
    
    try {
      final response = await _walletApi.createRechargeOrder(
        amount: selectedAmountInCents,
        paymentMethod: _selectedPaymentMethod.value!.type,
        giftAmount: selectedGiftAmountInCents,
      );
      
      LoadingUtils.hideLoading();
      
      if (response.success && response.data != null) {
        _currentRechargeOrder = response.data;
        
        // 保存订单号到本地存储
        if (_currentRechargeOrder!.rechargeOrderNo.isNotEmpty) {
          StorageUtils.setString('lastRechargeOrderNo', _currentRechargeOrder!.rechargeOrderNo);
        }
        
        // 处理支付
        await _handlePayment(_currentRechargeOrder!);
      } else {
        ToastUtils.showError(response.message ?? '创建充值订单失败');
      }
    } catch (e) {
        LoadingUtils.hideLoading();
      ToastUtils.showError('充值处理异常: $e');
    } finally {
      _isRecharging.value = false;
    }
  }
  
  /// 处理支付
  Future<void> _handlePayment(RechargeOrderModel order) async {
    if (order.paymentParams == null) {
      ToastUtils.showError('支付参数异常');
      return;
    }
    
    try {
      if (order.paymentMethod.toLowerCase() == 'alipay') {
        await _handleAlipayPayment(order);
      } else if (order.paymentMethod.toLowerCase() == 'wechat') {
        await _handleWechatPayment(order);
      } else {
        ToastUtils.showError('不支持的支付方式');
      }
    } catch (e) {
      ToastUtils.showError('支付处理异常: $e');
    }
  }
  
  /// 处理支付宝支付
  Future<void> _handleAlipayPayment(RechargeOrderModel order) async {
    // TODO: 集成支付宝SDK
    ToastUtils.showInfo('支付宝支付功能开发中...');
    
    // 模拟支付成功，开始查询订单状态
    Future.delayed(const Duration(seconds: 2), () {
      if (order.rechargeOrderNo.isNotEmpty) {
        checkRechargeStatus(order.rechargeOrderNo);
      }
    });
  }
  
  /// 处理微信支付
  Future<void> _handleWechatPayment(RechargeOrderModel order) async {
    // TODO: 集成微信支付SDK
    ToastUtils.showInfo('微信支付功能开发中...');
    
    // 模拟支付成功，开始查询订单状态
    Future.delayed(const Duration(seconds: 2), () {
      if (order.rechargeOrderNo.isNotEmpty) {
        checkRechargeStatus(order.rechargeOrderNo);
      }
    });
  }
  
  /// 查询充值订单状态
  Future<void> checkRechargeStatus(String orderNo, {int retryCount = 0, int maxRetries = 5}) async {
    try {
      final response = await _walletApi.getRechargeOrderStatus(orderNo);
      
      if (response.success && response.data != null) {
        final order = response.data!;
        
        if (order.isSuccess) {
          // 支付成功
          StorageUtils.remove('lastRechargeOrderNo');
          ToastUtils.showSuccess('充值成功');
          
          // 重新获取余额
          await getUserBalance();
          
          // 隐藏充值区域
          hideRecharge();
          
          return;
        } else if (order.isCancelled) {
          // 订单已取消
          StorageUtils.remove('lastRechargeOrderNo');
          return;
        } else if (order.isPending && retryCount < maxRetries) {
          // 待支付状态，继续查询
          final waitTime = (retryCount + 1) * 1000;
          
          _orderStatusTimer?.cancel();
          _orderStatusTimer = Timer(Duration(milliseconds: waitTime), () {
            checkRechargeStatus(orderNo, retryCount: retryCount + 1, maxRetries: maxRetries);
          });
        } else if (retryCount >= maxRetries) {
          // 达到最大重试次数，保留订单号
          print('已查询${maxRetries + 1}次，保留订单号，下次返回页面继续查询');
        }
      } else if (retryCount < maxRetries) {
        // 查询失败但未达到最大重试次数，继续重试
        _orderStatusTimer?.cancel();
        _orderStatusTimer = Timer(const Duration(seconds: 3), () {
          checkRechargeStatus(orderNo, retryCount: retryCount + 1, maxRetries: maxRetries);
        });
      }
    } catch (e) {
      if (retryCount < maxRetries) {
        // 发生异常但未达到最大重试次数，继续重试
        _orderStatusTimer?.cancel();
        _orderStatusTimer = Timer(const Duration(seconds: 3), () {
          checkRechargeStatus(orderNo, retryCount: retryCount + 1, maxRetries: maxRetries);
        });
      }
    }
  }
  
  /// 跳转到充值记录页面
  void toRechargeRecords() {
    Get.toNamed('/wallet/records', arguments: {'type': 'recharge'});
  }
  
  /// 跳转到消费明细页面
  void toConsumeRecords() {
    Get.toNamed('/wallet/records', arguments: {'type': 'consume'});
  }
  
  /// 跳转到退款记录页面
  void toRefundRecords() {
    Get.toNamed('/wallet/records', arguments: {'type': 'refund'});
  }
  
  /// 跳转到优惠券页面
  void toCoupons() {
    Get.toNamed('/coupons');
  }
  
  /// 刷新页面数据
  Future<void> refreshData() async {
    await _loadWalletData();
  }
  
  /// 是否可以进行支付
  bool get canProceedPayment {
    if (_selectedRechargeOption.value != null) {
      return _selectedPaymentMethod.value != null;
    }
    if (_customAmount.value > 0) {
      return _selectedPaymentMethod.value != null;
    }
    return false;
  }
  
  /// 是否正在处理支付
  bool get isProcessingPayment => _isLoading.value;
  
  /// 选择支付方式
  void selectPayment(int index) {
    if (index >= 0 && index < _paymentMethods.length) {
      _selectedPaymentMethod.value = _paymentMethods[index];
    }
  }
  
  /// 获取选中的支付方式索引
  int get selectedPaymentIndex {
    if (_selectedPaymentMethod.value == null) return -1;
    return _paymentMethods.indexOf(_selectedPaymentMethod.value!);
  }
  
  /// 自定义金额错误信息
  String? get customAmountError {
    if (_customAmount.value <= 0) return null;
    if (_customAmount.value < 1) return '最低充值金额为1元';
    if (_customAmount.value > 50000) return '最高充值金额为50000元';
    return null;
  }
  
  /// 自定义金额输入处理
  void onCustomMoneyInput(String value) {
    final amount = double.tryParse(value) ?? 0.0;
    _customAmount.value = amount;
    if (amount > 0) {
      _selectedRechargeOption.value = null;
    }
  }
  
  /// 获取选中的充值选项索引
  int get selectedRechargeIndex {
    if (_selectedRechargeOption.value == null) return -1;
    return _rechargeOptions.indexOf(_selectedRechargeOption.value!);
  }



  /// 选择充值金额
  void selectMoney(int index) {
    if (index >= 0 && index < _rechargeOptions.length) {
      _selectedRechargeOption.value = _rechargeOptions[index];
      _customAmount.value = 0.0;
    }
  }
}