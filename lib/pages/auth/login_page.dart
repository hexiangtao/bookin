import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bookin/api/user.dart';
import 'package:bookin/pages/auth/reset_password_page.dart';
import 'package:bookin/pages/main_page.dart';
import 'package:bookin/providers/user_provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();
  final UserApi _userApi = UserApi();

  bool _isAgreementChecked = true;
  bool _isSendingCode = false;
  int _countdown = 0;
  String _codeButtonText = '获取验证码';

  @override
  void dispose() {
    _phoneController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  bool get _canSendCode {
    return _phoneController.text.length == 11 && _countdown == 0 && !_isSendingCode;
  }

  bool get _canLogin {
    return _phoneController.text.length == 11 && 
           _codeController.text.length >= 4 && 
           _isAgreementChecked;
  }

  void _startCountdown() {
    setState(() {
      _countdown = 60;
      _codeButtonText = '${_countdown}s';
    });

    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) {
        setState(() {
          _countdown--;
          if (_countdown > 0) {
            _codeButtonText = '${_countdown}s';
          } else {
            _codeButtonText = '获取验证码';
          }
        });
      }
      return _countdown > 0;
    });
  }

  Future<void> _sendCode() async {
    if (!_canSendCode) return;

    setState(() {
      _isSendingCode = true;
    });

    try {
      final response = await _userApi.sendCode(context, _phoneController.text);
      if (response.success) {
        _startCountdown();
        _showSnackBar('验证码发送成功', isError: false);
      } 
    } catch (e) {
      _showSnackBar('验证码发送失败，请重试');
    } finally {
      if (mounted) {
        setState(() {
          _isSendingCode = false;
        });
      }
    }
  }

  Future<void> _login() async {
    if (!_canLogin) return;

    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      await userProvider.login(context, _phoneController.text, _codeController.text);

      _showSnackBar('登录成功', isError: false);
      
      if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const MainPage()),
        (Route<dynamic> route) => false,
      );
      }
    } catch (e) {
      _showSnackBar('登录失败，请检查手机号和验证码');
    }
  }

  void _showSnackBar(String message, {bool isError = true}) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isError ? Colors.red : Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _showTerms() {
    _showSnackBar('用户协议功能待开发', isError: false);
  }

  void _showPrivacy() {
    _showSnackBar('隐私政策功能待开发', isError: false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          '手机号登录',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
      ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
          children: [
                  const SizedBox(height: 40),
                  
                  // 页面标题
                  const Text(
                    '手机号登录',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  
                  const SizedBox(height: 50),
                  
                  // 手机号输入框
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF7F8FA),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.transparent,
                        width: 1,
                      ),
                    ),
                    child: TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
                      maxLength: 11,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                      decoration: InputDecoration(
                hintText: '请输入手机号',
                        hintStyle: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 16,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                        counterText: '',
                        suffixIcon: _phoneController.text.isNotEmpty
                            ? IconButton(
                                icon: Icon(Icons.clear, color: Colors.grey[400], size: 20),
                                onPressed: () {
                                  setState(() {
                                    _phoneController.clear();
                                  });
                                },
                              )
                            : null,
                      ),
                      onChanged: (value) {
                        setState(() {});
                      },
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // 验证码输入框
            Row(
              children: [
                Expanded(
                        flex: 3,
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFF7F8FA),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.transparent,
                              width: 1,
                            ),
                          ),
                  child: TextField(
                    controller: _codeController,
                    keyboardType: TextInputType.number,
                            maxLength: 4,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.black87,
                            ),
                            decoration: InputDecoration(
                      hintText: '请输入验证码',
                              hintStyle: TextStyle(
                                color: Colors.grey[400],
                                fontSize: 16,
                              ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 16,
                              ),
                              counterText: '',
                            ),
                            onChanged: (value) {
                              setState(() {});
                            },
                          ),
                        ),
                      ),
                      
                      const SizedBox(width: 12),
                      
                      // 获取验证码按钮
                      Container(
                        height: 52,
                        decoration: BoxDecoration(
                          color: _canSendCode ? const Color(0xFFFF5777) : Colors.grey[300],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: _canSendCode ? _sendCode : null,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Center(
                                child: Text(
                                  _codeButtonText,
                                  style: TextStyle(
                                    color: _canSendCode ? Colors.white : Colors.grey[600],
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                    ),
                  ),
                ),
                  ),
                ),
              ],
            ),
                  
                  const SizedBox(height: 40),
                  
                  // 登录按钮
                  Container(
                    width: double.infinity,
                    height: 52,
                    decoration: BoxDecoration(
                      gradient: _canLogin
                          ? const LinearGradient(
                              colors: [Color(0xFFFF5777), Color(0xFFFF8CA0)],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            )
                          : null,
                      color: _canLogin ? null : Colors.grey[300],
                      borderRadius: BorderRadius.circular(26),
                      boxShadow: _canLogin
                          ? [
                              BoxShadow(
                                color: const Color(0xFFFF5777).withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ]
                          : null,
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(26),
                        onTap: _canLogin ? _login : null,
                        child: Center(
                          child: Text(
                            '登录',
                            style: TextStyle(
                              color: _canLogin ? Colors.white : Colors.grey[600],
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
            ),
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // 密码登录链接
                  Center(
                    child: GestureDetector(
                      onTap: () {
                  Navigator.push(
                    context,
                          MaterialPageRoute(
                            builder: (context) => const ResetPasswordPage(),
                          ),
                  );
                },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Text(
                          '忘记密码？',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                            decoration: TextDecoration.underline,
                          ),
              ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 60),
                ],
              ),
            ),
          ),
          
          // 底部固定区域
          Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                // 自动注册提示
                Text(
                  '未注册手机号验证后将自动注册',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 16),
                
                // 协议勾选
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _isAgreementChecked = !_isAgreementChecked;
                        });
                      },
                      child: Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: _isAgreementChecked ? const Color(0xFFFF5777) : Colors.transparent,
                          border: Border.all(
                            color: _isAgreementChecked ? const Color(0xFFFF5777) : Colors.grey[400]!,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: _isAgreementChecked
                            ? const Icon(
                                Icons.check,
                                size: 14,
                                color: Colors.white,
                              )
                            : null,
                      ),
                    ),
                    
                    const SizedBox(width: 8),
                    
                    Flexible(
                      child: Text.rich(
                        TextSpan(
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[700],
                          ),
                          children: [
                            const TextSpan(text: '我已阅读并同意'),
                            WidgetSpan(
                              child: GestureDetector(
                                onTap: _showTerms,
                                child: const Text(
                                  '《用户协议》',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFFFF9933),
                                  ),
                                ),
                              ),
                            ),
                            const TextSpan(text: '、'),
                            WidgetSpan(
                              child: GestureDetector(
                                onTap: _showPrivacy,
                                child: const Text(
                                  '《隐私政策》',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFFFF9933),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
            ),
          ],
        ),
          ),
        ],
      ),
    );
  }
}