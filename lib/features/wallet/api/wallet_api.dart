import 'package:dio/dio.dart';
import '../../../core/services/api_client.dart';
import '../../../core/models/base_model.dart';
import '../../../core/utils/validation_helper.dart';
import '../models/wallet_balance_model.dart';
import '../models/recharge_option_model.dart';
import '../models/recharge_order_model.dart';
import '../models/transaction_record_model.dart';

class WalletApi {
  final ApiClient _apiClient;

  WalletApi(this._apiClient);

  /// 获取钱包余额
  Future<ApiResponse<WalletBalanceModel>> getWalletBalance() async {
    try {
      final response = await _apiClient.get('/wallet/balance');
      
      if (response.data['code'] == '0') {
        final balance = WalletBalanceModel.fromJson(response.data['data']);
        return ApiResponse.success(data: balance);
      } else {
        return ApiResponse.error(message: response.data['message'] ?? '获取余额失败');
      }
    } on DioException catch (e) {
      return ApiResponse.error(message: e.message ?? '网络请求失败');
    } catch (e) {
      return ApiResponse.error(message: '获取余额异常: $e');
    }
  }

  /// 获取充值选项
  Future<ApiResponse<List<RechargeOptionModel>>> getRechargeOptions() async {
    try {
      final response = await _apiClient.get('/wallet/recharge/options');
      
      if (response.data['code'] == '0') {
        final List<dynamic> data = response.data['data'] ?? [];
        
        // 验证充值选项数据
        final validationResult = ValidationHelper.validateRechargeOptions(data);
        if (!validationResult.isValid) {
          return ApiResponse.error(message: validationResult.errorMessage ?? '充值选项数据验证失败');
        }
        
        final options = data.map((json) => RechargeOptionModel.fromJson(json)).toList();
        return ApiResponse.success(data: options);
      } else {
        return ApiResponse.error(message: response.data['message'] ?? '获取充值选项失败');
      }
    } on DioException catch (e) {
      return ApiResponse.error(message: e.message ?? '网络请求失败');
    } catch (e) {
      return ApiResponse.error(message: '获取充值选项异常: $e');
    }
  }

  /// 创建充值订单
  Future<ApiResponse<RechargeOrderModel>> createRechargeOrder({
    required int amount,
    required String paymentMethod,
    int? giftAmount,
  }) async {
    try {
      final response = await _apiClient.post('/wallet/recharge/create', data: {
        'amount': amount,
        'paymentMethod': paymentMethod,
        'giftAmount': giftAmount,
      });
      
      if (response.data['code'] == '0') {
        final order = RechargeOrderModel.fromJson(response.data['data']);
        return ApiResponse.success(data: order);
      } else {
        return ApiResponse.error(message: response.data['message'] ?? '创建充值订单失败');
      }
    } on DioException catch (e) {
      return ApiResponse.error(message: e.message ?? '网络请求失败');
    } catch (e) {
      return ApiResponse.error(message: '创建充值订单异常: $e');
    }
  }

  /// 查询充值订单状态
  Future<ApiResponse<RechargeOrderModel>> getRechargeOrderStatus(String orderNo) async {
    try {
      final response = await _apiClient.get('/wallet/recharge/status', queryParameters: {
        'orderNo': orderNo,
      });
      
      if (response.data['code'] == '0') {
        final order = RechargeOrderModel.fromJson(response.data['data']);
        return ApiResponse.success(data: order);
      } else {
        return ApiResponse.error(message: response.data['message'] ?? '查询订单状态失败');
      }
    } on DioException catch (e) {
      return ApiResponse.error(message: e.message ?? '网络请求失败');
    } catch (e) {
      return ApiResponse.error(message: '查询订单状态异常: $e');
    }
  }

  /// 获取交易记录
  Future<ApiResponse<List<TransactionRecordModel>>> getTransactionRecords({
    String? type,
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final response = await _apiClient.get('/wallet/transactions', queryParameters: {
        'type': type,
        'page': page,
        'pageSize': pageSize,
      });
      
      if (response.data['code'] == '0') {
        final List<dynamic> data = response.data['data'] ?? [];
        final records = data.map((json) => TransactionRecordModel.fromJson(json)).toList();
        return ApiResponse.success(data: records);
      } else {
        return ApiResponse.error(message: response.data['message'] ?? '获取交易记录失败');
      }
    } on DioException catch (e) {
      return ApiResponse.error(message: e.message ?? '网络请求失败');
    } catch (e) {
      return ApiResponse.error(message: '获取交易记录异常: $e');
    }
  }

  /// 获取充值记录
  Future<ApiResponse<List<TransactionRecordModel>>> getRechargeRecords({
    int page = 1,
    int pageSize = 20,
  }) async {
    return getTransactionRecords(type: 'recharge', page: page, pageSize: pageSize);
  }

  /// 获取消费记录
  Future<ApiResponse<List<TransactionRecordModel>>> getConsumeRecords({
    int page = 1,
    int pageSize = 20,
  }) async {
    return getTransactionRecords(type: 'consume', page: page, pageSize: pageSize);
  }

  /// 获取退款记录
  Future<ApiResponse<List<TransactionRecordModel>>> getRefundRecords({
    int page = 1,
    int pageSize = 20,
  }) async {
    return getTransactionRecords(type: 'refund', page: page, pageSize: pageSize);
  }

  /// 取消充值订单
  Future<ApiResponse<bool>> cancelRechargeOrder(String orderNo) async {
    try {
      final response = await _apiClient.post('/wallet/recharge/cancel', data: {
        'orderNo': orderNo,
      });
      
      if (response.data['code'] == '0') {
        return ApiResponse.success(data: true);
      } else {
        return ApiResponse.error(message: response.data['message'] ?? '取消订单失败');
      }
    } on DioException catch (e) {
      return ApiResponse.error(message: e.message ?? '网络请求失败');
    } catch (e) {
      return ApiResponse.error(message: '取消订单异常: $e');
    }
  }

  /// 验证自定义充值金额
  Future<ApiResponse<bool>> validateCustomAmount(int amount) async {
    try {
      final response = await _apiClient.post('/wallet/recharge/validate', data: {
        'amount': amount,
      });
      
      if (response.data['code'] == '0') {
        return ApiResponse.success(data: true);
      } else {
        return ApiResponse.error(message: response.data['message'] ?? '金额验证失败');
      }
    } on DioException catch (e) {
      return ApiResponse.error(message: e.message ?? '网络请求失败');
    } catch (e) {
      return ApiResponse.error(message: '金额验证异常: $e');
    }
  }
}