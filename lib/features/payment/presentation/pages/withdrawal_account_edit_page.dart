import 'package:flutter/material.dart';
import 'package:bookin/features/technician/data/api/technician_api.dart';
import 'package:bookin/features/shared/services/base_api.dart';

class WithdrawalAccountEditPage extends StatefulWidget {
  final WithdrawalAccount? account; // Null for adding new, provided for editing existing

  const WithdrawalAccountEditPage({super.key, this.account});

  @override
  State<WithdrawalAccountEditPage> createState() => _WithdrawalAccountEditPageState();
}

class _WithdrawalAccountEditPageState extends State<WithdrawalAccountEditPage> {
  final _formKey = GlobalKey<FormState>();
  final TechnicianApi _technicianApi = TechnicianApi();

  late TextEditingController _accountNameController;
  late TextEditingController _accountNumberController;
  late TextEditingController _phoneController;
  late TextEditingController _bankNameController;
  late TextEditingController _bankCodeController;
  late TextEditingController _qrCodeUrlController;

  String? _selectedAccountType; // 'bank', 'alipay', 'wechat'
  bool _isDefault = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _accountNameController = TextEditingController(text: widget.account?.accountName);
    _accountNumberController = TextEditingController(text: widget.account?.accountNumber);
    _phoneController = TextEditingController(text: widget.account?.phone);
    _bankNameController = TextEditingController(text: widget.account?.bankName);
    _bankCodeController = TextEditingController(text: widget.account?.bankCode);
    _qrCodeUrlController = TextEditingController(text: widget.account?.qrCodeUrl);

    _selectedAccountType = widget.account?.accountType;
    _isDefault = widget.account?.isDefault ?? false;
  }

  @override
  void dispose() {
    _accountNameController.dispose();
    _accountNumberController.dispose();
    _phoneController.dispose();
    _bankNameController.dispose();
    _bankCodeController.dispose();
    _qrCodeUrlController.dispose();
    super.dispose();
  }

  Future<void> _saveAccount() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final accountReq = WithdrawalAccount(
        id: widget.account?.id ?? '',
        accountType: _selectedAccountType!,
        accountName: _accountNameController.text,
        accountNumber: _accountNumberController.text,
        phone: _phoneController.text,
        bankName: _bankNameController.text.isNotEmpty ? _bankNameController.text : null,
        bankCode: _bankCodeController.text.isNotEmpty ? _bankCodeController.text : null,
        qrCodeUrl: _qrCodeUrlController.text.isNotEmpty ? _qrCodeUrlController.text : null,
        isDefault: _isDefault,
      );

      try {
        final ApiResponse<void> response;
        if (widget.account == null) {
          response = await _technicianApi.createWithdrawalAccount(context, accountReq); // Pass context
        } else {
          response = await _technicianApi.updateWithdrawalAccount(context, accountReq); // Pass context
        }

        if (response.success) {
          _showSnackBar('提现账号保存成功！');
          Navigator.pop(context, true); // Pop with true to indicate success
        } else {
          _showSnackBar('保存失败: ${response.message}');
        }
      } catch (e) {
        _showSnackBar('保存失败: ${e.toString()}');
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.account == null ? '添加提现账号' : '编辑提现账号'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DropdownButtonFormField<String>(
                      value: _selectedAccountType,
                      decoration: const InputDecoration(
                        labelText: '账号类型',
                        border: OutlineInputBorder(),
                      ),
                      items: const <String>['bank', 'alipay', 'wechat'].map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text({'bank': '银行卡', 'alipay': '支付宝', 'wechat': '微信'}[value]!),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedAccountType = newValue;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '请选择账号类型';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _accountNameController,
                      decoration: const InputDecoration(
                        labelText: '账户持有人姓名',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '请输入账户持有人姓名';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _accountNumberController,
                      decoration: InputDecoration(
                        labelText: _selectedAccountType == 'bank' ? '银行卡号' : '账号',
                        border: const OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '请输入账号';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    if (_selectedAccountType == 'bank') ...[
                      TextFormField(
                        controller: _bankNameController,
                        decoration: const InputDecoration(
                          labelText: '银行名称',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (_selectedAccountType == 'bank' && (value == null || value.isEmpty)) {
                            return '请输入银行名称';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _bankCodeController,
                        decoration: const InputDecoration(
                          labelText: '银行编码',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (_selectedAccountType == 'bank' && (value == null || value.isEmpty)) {
                            return '请输入银行编码';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                    ],
                    TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: '预留手机号',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '请输入预留手机号';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    if (_selectedAccountType == 'alipay' || _selectedAccountType == 'wechat')
                      TextFormField(
                        controller: _qrCodeUrlController,
                        decoration: const InputDecoration(
                          labelText: '收款二维码URL (可选)',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Checkbox(
                          value: _isDefault,
                          onChanged: (bool? newValue) {
                            setState(() {
                              _isDefault = newValue ?? false;
                            });
                          },
                        ),
                        const Text('设为默认账号'),
                      ],
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: _saveAccount,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      child: const Text('保存账号'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
