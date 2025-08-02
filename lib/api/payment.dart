import 'package:bookin/api/base.dart';
import 'package:bookin/api/order.dart';
import 'package:bookin/api/order_constants.dart';
import 'package:flutter/material.dart'; // Import for BuildContext

// This class mirrors the PaymentService logic from payment.js
// UI-related functions (showToast, showLoading, etc.) are omitted
// as they belong in the Flutter UI layer.
class PaymentService {
  // Data properties that would typically be managed by a state management solution
  // in Flutter (e.g., Provider, Riverpod, BLoC).
  // For now, they are kept as simple class members.
  double userBalance = 0.0; // In currency units (e.g., Yuan), not cents
  int payChecked = 1; // 0: Balance, 1: WeChat, 2: Alipay

  // Order and context would be passed in or managed by state.
  // For simplicity, we'll assume they are available when methods are called.
  // Order? _order; // Placeholder for order data
  // dynamic _context; // Placeholder for UI context

  // void init(Order order, dynamic context) {
  //   _order = order;
  //   _context = context;
  //   // Default to balance payment if sufficient balance
  //   if (userBalance >= (order.actualPrice / 100)) {
  //     payChecked = 0;
  //   } else {
  //     payChecked = 1; // Default to WeChat pay if insufficient balance
  //   }
  // }

  bool isBalancePaymentDisabled(double orderPrice) {
    return userBalance < orderPrice;
  }

  String getPaymentMethodText(int currentPayChecked, OrderStatus orderStatus, double orderPrice) {
    if (orderStatus == OrderStatus.WAITING_PAYMENT) {
      if (currentPayChecked == 0) return '余额支付 (¥${userBalance.toStringAsFixed(2)})';
      if (currentPayChecked == 1) return '微信支付';
      if (currentPayChecked == 2) return '支付宝支付';
    }
    // This part might need actual order.paymentMethod if it's already paid
    return '线上支付';
  }

  Future<void> loadUserBalance(BuildContext context) async {
    try {
      final response = await OrderApi().getUserBalance(context);
      if (response.success && response.data != null && response.data!['balance'] != null) {
        userBalance = (response.data!['balance'] as num).toDouble() / 100.0; // Convert cents to currency
        // Auto-adjust payment method based on balance
        // if (_order?.status == OrderStatus.WAITING_PAYMENT.code) {
        //   if (isBalancePaymentDisabled(_order!.actualPrice / 100) && payChecked == 0) {
        //     payChecked = 1; // Switch to WeChat pay if balance insufficient
        //   }
        // }
      } else {
        print('获取用户余额失败: ${response.message}');
      }
    } catch (error) {
      print('加载用户余额异常: $error');
    }
  }

  void changePay(int type, double orderPrice) {
    if (type == 0 && isBalancePaymentDisabled(orderPrice)) {
      // This toast logic should be in UI
      // showErrorToast('余额不足，请选择其他支付方式');
      return;
    }
    payChecked = type;
  }

  Future<ApiResponse<PaymentCreateResponse>> goToPay(BuildContext context, String orderId, double orderPrice) async {
    if (orderId.isEmpty) {
      return ApiResponse.error('订单ID不存在');
    }

    // Assuming order status check is done before calling this method in UI
    // if (_order?.status != OrderStatus.WAITING_PAYMENT.code) {
    //   return ApiResponse.error('此订单无需支付');
    // }

    String paymentMethodName = '';
    if (payChecked == 0) {
      paymentMethodName = 'balance';
    } else if (payChecked == 1) {
      paymentMethodName = 'wechat';
    } else if (payChecked == 2) {
      paymentMethodName = 'alipay';
    } else {
      return ApiResponse.error('请选择有效的支付方式');
    }

    if (paymentMethodName == 'balance' && isBalancePaymentDisabled(orderPrice)) {
      return ApiResponse.error('余额不足，无法使用余额支付');
    }

    // UI loading indicator should be handled in the UI layer

    Map<String, dynamic> apiExtras = {};

    if (paymentMethodName == 'wechat') {
      // WeChat OpenID retrieval logic (platform-specific, might use flutter_wechat_sdk or similar)
      // For now, this is a placeholder.
      // try {
      //   final openid = await getOpenid(state: 'order_${orderId}_wechatpay_${DateTime.now().millisecondsSinceEpoch}');
      //   if (openid != null) {
      //     apiExtras['openid'] = openid;
      //     print('Using openid for WeChat payment: $openid');
      //   }
      // } catch (e) {
      //   print('Failed to get WeChat openid: $e');
      //   return ApiResponse.error('获取微信授权失败，请稍后重试');
      // }
    }

    try {
      final paymentCreateResp = await OrderApi().createPayment(context, orderId, paymentMethodName, extras: apiExtras);
      // UI loading indicator should be handled in the UI layer

      if (paymentCreateResp.success && paymentCreateResp.data != null) {
        final payData = paymentCreateResp.data!;

        // Handle different payment methods
        if (payData.payMethod == 'balance') {
          if (payData.isBalancePaySuccess) {
            // paymentSuccess('余额支付成功'); // UI toast
            return ApiResponse.success(payData, message: '余额支付成功');
          } else {
            // showErrorToast(paymentCreateResp.message); // UI toast
            await loadUserBalance(context); // Reload balance if failed
            return ApiResponse.error(paymentCreateResp.message);
          }
        } else if (payData.payMethod == 'wechat') {
          if (payData.prepayInfo != null) {
            // WeChat Pay SDK integration (platform-specific)
            // This part requires a Flutter plugin for WeChat Pay.
            // Example: await FlutterWechatPay.pay(prepayInfo: payData.prepayInfo!);
            // For now, just return the response.
            return ApiResponse.success(payData, message: '微信支付参数已获取');
          } else {
            return ApiResponse.error('获取微信支付参数失败');
          }
        } else if (payData.payMethod == 'alipay') {
          if (payData.paymentUrl != null) {
            // Alipay SDK integration or opening URL in browser (platform-specific)
            // This part requires a Flutter plugin for Alipay or url_launcher.
            // Example: await launch(payData.paymentUrl!); // Using url_launcher
            // For now, just return the response.
            return ApiResponse.success(payData, message: '支付宝支付参数已获取');
          } else {
            return ApiResponse.error('获取支付宝支付参数失败');
          }
        } else {
          return ApiResponse.error('未知的支付方式返回: ${payData.payMethod}');
        }
      } else {
        return ApiResponse.error(paymentCreateResp.message);
      }
    } catch (error) {
      print('支付初始化异常: $error');
      // UI loading indicator should be handled in the UI layer
      return ApiResponse.error('支付初始化失败，请稍后重试');
    }
  }

  // Helper for showing success/error toasts (should be in UI layer)
  // void showSuccessToast(String message) { /* ... */ }
  // void showErrorToast(String message) { /* ... */ }
}

final paymentService = PaymentService();