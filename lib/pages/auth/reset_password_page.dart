import 'package:flutter/material.dart';
import 'package:bookin/api/user.dart';
import 'package:provider/provider.dart';
import 'package:bookin/providers/app_provider.dart';

class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({super.key});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final UserApi _userApi = UserApi();

  // Removed _isSendingCode and _countdown as global loading/messages will handle this

  @override
  void dispose() {
    _phoneController.dispose();
    _codeController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _sendCode() async {
    if (_phoneController.text.isEmpty || _phoneController.text.length != 11) {
      Provider.of<AppProvider>(context, listen: false).setGlobalMessage('请输入正确的手机号码');
      return;
    }

    try {
      // BaseApi will handle showing/hiding loading and error messages
      final response = await _userApi.sendCode(context, _phoneController.text);
      if (response.success) {
        Provider.of<AppProvider>(context, listen: false).setGlobalMessage('验证码发送成功');
        // You might still want a local countdown for UX, but it's separate from global loading
      } 
      // Error messages are handled by BaseApi and AppProvider
    } catch (e) {
      // Error already handled by BaseApi and AppProvider
    }
  }

  Future<void> _resetPassword() async {
    if (_phoneController.text.isEmpty ||
        _codeController.text.isEmpty ||
        _newPasswordController.text.isEmpty ||
        _confirmPasswordController.text.isEmpty) {
      Provider.of<AppProvider>(context, listen: false).setGlobalMessage('所有字段都不能为空');
      return;
    }

    if (_newPasswordController.text != _confirmPasswordController.text) {
      Provider.of<AppProvider>(context, listen: false).setGlobalMessage('两次输入的密码不一致');
      return;
    }

    try {
      // Assuming a reset password API exists in UserApi
      // For now, using a placeholder as it wasn't explicitly in user.js
      // You would call something like: await _userApi.resetPassword(context, phone, code, newPassword);
      Provider.of<AppProvider>(context, listen: false).setGlobalMessage('重置密码功能待实现');
      // final response = await _userApi.resetPassword(
      //   context,
      //   _phoneController.text,
      //   _codeController.text,
      //   _newPasswordController.text,
      // );
      // if (response.success) {
      //   Provider.of<AppProvider>(context, listen: false).setGlobalMessage('密码重置成功！');
      //   Navigator.pop(context); // Go back to login page
      // } else {
      //   Provider.of<AppProvider>(context, listen: false).setGlobalMessage('重置失败: ${response.message}');
      // }
    } catch (e) {
      // Error already handled by BaseApi and AppProvider
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('重置密码'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: '手机号',
                hintText: '请输入手机号',
              ),
            ),
            const SizedBox(height: 16.0),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _codeController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: '验证码',
                      hintText: '请输入验证码',
                    ),
                  ),
                ),
                const SizedBox(width: 16.0),
                ElevatedButton(
                  onPressed: _sendCode, // Removed _isSendingCode check
                  child: const Text('发送验证码'), // Removed countdown text
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: _newPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: '新密码',
                hintText: '请输入新密码',
              ),
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: _confirmPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: '确认密码',
                hintText: '请再次输入新密码',
              ),
            ),
            const SizedBox(height: 32.0),
            ElevatedButton(
              onPressed: _resetPassword,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12.0),
              ),
              child: const Text('重置密码'),
            ),
          ],
        ),
      ),
    );
  }
}
