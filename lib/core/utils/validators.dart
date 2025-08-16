class Validators {
  // 手机号验证
  static bool isValidPhone(String phone) {
    if (phone.isEmpty) return false;
    
    // 中国大陆手机号正则表达式
    final phoneRegex = RegExp(r'^1[3-9]\d{9}$');
    return phoneRegex.hasMatch(phone);
  }
  
  // 邮箱验证
  static bool isValidEmail(String email) {
    if (email.isEmpty) return false;
    
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
    );
    return emailRegex.hasMatch(email);
  }
  
  // 密码验证（至少4位）
  static bool isValidPassword(String password) {
    return password.length >= 4;
  }
  
  // 验证码验证（4位数字）
  static bool isValidCode(String code) {
    if (code.length != 4) return false;
    
    final codeRegex = RegExp(r'^\d{4}$');
    return codeRegex.hasMatch(code);
  }
  
  // 身份证号验证
  static bool isValidIdCard(String idCard) {
    if (idCard.isEmpty) return false;
    
    // 18位身份证号正则表达式
    final idCardRegex = RegExp(r'^[1-9]\d{5}(18|19|20)\d{2}((0[1-9])|(1[0-2]))(([0-2][1-9])|10|20|30|31)\d{3}[0-9Xx]$');
    return idCardRegex.hasMatch(idCard);
  }
  
  // 姓名验证（2-20位中文字符）
  static bool isValidName(String name) {
    if (name.isEmpty) return false;
    
    final nameRegex = RegExp(r'^[\u4e00-\u9fa5]{2,20}$');
    return nameRegex.hasMatch(name);
  }
  
  // 银行卡号验证
  static bool isValidBankCard(String cardNumber) {
    if (cardNumber.isEmpty) return false;
    
    // 银行卡号通常为16-19位数字
    final bankCardRegex = RegExp(r'^\d{16,19}$');
    return bankCardRegex.hasMatch(cardNumber);
  }
  
  // 金额验证（最多两位小数）
  static bool isValidAmount(String amount) {
    if (amount.isEmpty) return false;
    
    final amountRegex = RegExp(r'^\d+(\.\d{1,2})?$');
    return amountRegex.hasMatch(amount);
  }
  
  // URL验证
  static bool isValidUrl(String url) {
    if (url.isEmpty) return false;
    
    try {
      final uri = Uri.parse(url);
      return uri.hasScheme && (uri.scheme == 'http' || uri.scheme == 'https');
    } catch (e) {
      return false;
    }
  }
  
  // 非空验证
  static bool isNotEmpty(String? value) {
    return value != null && value.trim().isNotEmpty;
  }
  
  // 长度验证
  static bool isValidLength(String value, int minLength, [int? maxLength]) {
    if (value.length < minLength) return false;
    if (maxLength != null && value.length > maxLength) return false;
    return true;
  }
}