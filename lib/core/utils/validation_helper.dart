import 'dart:math';

/// 数据验证辅助工具类
class ValidationHelper {
  /// 验证充值金额
  static ValidationResult validateRechargeAmount(double amount) {
    if (amount <= 0) {
      return ValidationResult(
        isValid: false,
        errorMessage: '充值金额必须大于0',
      );
    }
    
    if (amount < 1) {
      return ValidationResult(
        isValid: false,
        errorMessage: '充值金额不能少于1元',
      );
    }
    
    if (amount > 50000) {
      return ValidationResult(
        isValid: false,
        errorMessage: '单次充值金额不能超过50,000元',
      );
    }
    
    // 检查小数位数
    String amountStr = amount.toString();
    if (amountStr.contains('.')) {
      List<String> parts = amountStr.split('.');
      if (parts[1].length > 2) {
        return ValidationResult(
          isValid: false,
          errorMessage: '充值金额最多支持2位小数',
        );
      }
    }
    
    return ValidationResult(isValid: true);
  }

  /// 验证自定义充值金额输入
  static ValidationResult validateCustomAmountInput(String input) {
    if (input.isEmpty) {
      return ValidationResult(
        isValid: false,
        errorMessage: '请输入充值金额',
      );
    }
    
    // 检查是否包含非法字符
    if (!RegExp(r'^\d+(\.\d{0,2})?$').hasMatch(input)) {
      return ValidationResult(
        isValid: false,
        errorMessage: '请输入有效的金额格式',
      );
    }
    
    double? amount = double.tryParse(input);
    if (amount == null) {
      return ValidationResult(
        isValid: false,
        errorMessage: '请输入有效的数字',
      );
    }
    
    return validateRechargeAmount(amount);
  }

  /// 验证钱包余额数据
  static ValidationResult validateWalletBalance(dynamic balanceData) {
    if (balanceData == null) {
      return ValidationResult(
        isValid: false,
        errorMessage: '余额数据不能为空',
      );
    }
    
    if (balanceData is! Map<String, dynamic>) {
      return ValidationResult(
        isValid: false,
        errorMessage: '余额数据格式错误',
      );
    }
    
    // 检查必需字段
    if (!balanceData.containsKey('balance')) {
      return ValidationResult(
        isValid: false,
        errorMessage: '缺少余额字段',
      );
    }
    
    dynamic balance = balanceData['balance'];
    if (balance is! num) {
      return ValidationResult(
        isValid: false,
        errorMessage: '余额必须是数字类型',
      );
    }
    
    if (balance < 0) {
      return ValidationResult(
        isValid: false,
        errorMessage: '余额不能为负数',
      );
    }
    
    return ValidationResult(isValid: true);
  }

  /// 验证充值选项数据
  static ValidationResult validateRechargeOptions(List<dynamic>? options) {
    if (options == null || options.isEmpty) {
      return ValidationResult(
        isValid: false,
        errorMessage: '充值选项不能为空',
      );
    }
    
    for (int i = 0; i < options.length; i++) {
      dynamic option = options[i];
      
      if (option is! Map<String, dynamic>) {
        return ValidationResult(
          isValid: false,
          errorMessage: '充值选项 ${i + 1} 格式错误',
        );
      }
      
      // 检查必需字段 - 修正为API实际返回的字段名
      if (!option.containsKey('value')) {
        return ValidationResult(
          isValid: false,
          errorMessage: '充值选项 ${i + 1} 缺少value字段',
        );
      }
      
      if (!option.containsKey('gift')) {
        return ValidationResult(
          isValid: false,
          errorMessage: '充值选项 ${i + 1} 缺少gift字段',
        );
      }
      
      dynamic value = option['value'];
      if (value is! num || value <= 0) {
        return ValidationResult(
          isValid: false,
          errorMessage: '充值选项 ${i + 1} 充值金额无效',
        );
      }
      
      dynamic gift = option['gift'];
      if (gift is! num || gift < 0) {
        return ValidationResult(
          isValid: false,
          errorMessage: '充值选项 ${i + 1} 赠送金额无效',
        );
      }
    }
    
    return ValidationResult(isValid: true);
  }

  /// 验证网络响应数据
  static ValidationResult validateApiResponse(dynamic response) {
    if (response == null) {
      return ValidationResult(
        isValid: false,
        errorMessage: '服务器响应为空',
      );
    }
    
    if (response is! Map<String, dynamic>) {
      return ValidationResult(
        isValid: false,
        errorMessage: '服务器响应格式错误',
      );
    }
    
    // 检查状态码
    if (response.containsKey('code')) {
      dynamic code = response['code'];
      if (code is num && code != 200 && code != 0) {
        String message = response['message'] ?? '请求失败';
        return ValidationResult(
          isValid: false,
          errorMessage: message,
        );
      }
    }
    
    return ValidationResult(isValid: true);
  }

  /// 安全检查：防止XSS攻击
  static String sanitizeInput(String input) {
    return input
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&#x27;')
        .replaceAll('&', '&amp;');
  }

  /// 检查输入长度
  static ValidationResult validateInputLength(String input, int maxLength, {String? fieldName}) {
    if (input.length > maxLength) {
      return ValidationResult(
        isValid: false,
        errorMessage: '${fieldName ?? '输入'}长度不能超过$maxLength个字符',
      );
    }
    return ValidationResult(isValid: true);
  }

  /// 验证数字范围
  static ValidationResult validateNumberRange(num value, num min, num max, {String? fieldName}) {
    if (value < min || value > max) {
      return ValidationResult(
        isValid: false,
        errorMessage: '${fieldName ?? '数值'}必须在$min到$max之间',
      );
    }
    return ValidationResult(isValid: true);
  }

  /// 生成安全的随机ID
  static String generateSecureId() {
    const chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    Random random = Random.secure();
    return List.generate(16, (index) => chars[random.nextInt(chars.length)]).join();
  }

  /// 验证金额精度
  static ValidationResult validateAmountPrecision(double amount, int maxDecimalPlaces) {
    String amountStr = amount.toString();
    if (amountStr.contains('.')) {
      List<String> parts = amountStr.split('.');
      if (parts[1].length > maxDecimalPlaces) {
        return ValidationResult(
          isValid: false,
          errorMessage: '金额最多支持${maxDecimalPlaces}位小数',
        );
      }
    }
    return ValidationResult(isValid: true);
  }

  /// 检查是否为有效的货币格式
  static bool isValidCurrencyFormat(String input) {
    return RegExp(r'^\d+(\.\d{1,2})?$').hasMatch(input);
  }

  /// 格式化金额显示
  static String formatAmount(double amount) {
    return amount.toStringAsFixed(2);
  }

  /// 检查数据完整性
  static ValidationResult validateDataIntegrity(Map<String, dynamic> data, List<String> requiredFields) {
    for (String field in requiredFields) {
      if (!data.containsKey(field) || data[field] == null) {
        return ValidationResult(
          isValid: false,
          errorMessage: '缺少必需字段: $field',
        );
      }
    }
    return ValidationResult(isValid: true);
  }
}

/// 验证结果类
class ValidationResult {
  final bool isValid;
  final String? errorMessage;

  ValidationResult({
    required this.isValid,
    this.errorMessage,
  });

  @override
  String toString() {
    return 'ValidationResult(isValid: $isValid, errorMessage: $errorMessage)';
  }
}