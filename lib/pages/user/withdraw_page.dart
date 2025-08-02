import 'package:flutter/material.dart';
import 'package:bookin/api/wallet.dart';
import 'package:bookin/api/technician.dart';
import 'package:bookin/pages/user/withdrawal_account_selection_page.dart';

class WithdrawPage extends StatefulWidget {
  const WithdrawPage({super.key});

  @override
  State<WithdrawPage> createState() => _WithdrawPageState();
}

class _WithdrawPageState extends State<WithdrawPage> {

  final TextEditingController _amountController = TextEditingController();
  WithdrawalAccount? _selectedAccount;

  bool _isLoading = false;


  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _selectWithdrawalAccount() async {
    final result = await Navigator.push<WithdrawalAccount>(
      context,
      MaterialPageRoute(
        builder: (context) => const WithdrawalAccountSelectionPage(),
      ),
    );
    
    if (result != null) {
      setState(() {
        _selectedAccount = result;
      });
    }
  }

  Future<void> _submitWithdrawal() async {
    final double? amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) {
      _showSnackBar('请输入有效的提现金额');
      return;
    }

    if (_selectedAccount == null) {
      _showSnackBar('请选择提现账号');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));
      // TODO: Implement actual withdrawal API call
      // final response = await _walletApi.withdraw(
      //   context, 
      //   amount.toInt() * 100, 
      //   _selectedAccount!.id
      // );
      // if (response.success) {
      //   _showSnackBar('提现申请成功！');
      //   Navigator.pop(context);
      // } else {
      //   _showSnackBar('提现失败: ${response.message}');
      // }
      _showSnackBar('提现申请已提交，请等待审核！');
      Navigator.pop(context);
    } catch (e) {
      _showSnackBar('提现失败: ${e.toString()}');
    } finally {
      setState(() {
        _isLoading = false;
      });
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
        title: const Text('提现'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('提现金额', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: '提现金额 (元)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text('提现账号', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16.0),
                      leading: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: _selectedAccount != null 
                              ? Theme.of(context).primaryColor.withOpacity(0.1)
                              : Colors.grey.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Icon(
                          _selectedAccount != null 
                              ? _getAccountIcon(_selectedAccount!.accountType)
                              : Icons.account_balance_wallet_outlined,
                          color: _selectedAccount != null 
                              ? Theme.of(context).primaryColor
                              : Colors.grey,
                          size: 24,
                        ),
                      ),
                      title: Text(
                        _selectedAccount?.accountName ?? '选择提现账号',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: _selectedAccount != null ? Colors.black : Colors.grey[600],
                        ),
                      ),
                      subtitle: _selectedAccount != null
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 4),
                                Text(
                                  '账号: ${_maskAccountNumber(_selectedAccount!.accountNumber)}',
                                  style: const TextStyle(fontSize: 14),
                                ),
                                if (_selectedAccount!.bankName != null && _selectedAccount!.bankName!.isNotEmpty)
                                  Text(
                                    '银行: ${_selectedAccount!.bankName}',
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                Text(
                                  '类型: ${_selectedAccount!.accountType}',
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ],
                            )
                          : const Text(
                              '银行卡/支付宝/微信',
                              style: TextStyle(fontSize: 14),
                            ),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: _selectWithdrawalAccount,
                    ),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: _submitWithdrawal,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: const Text('提交提现申请'),
                  ),
                ],
              ),
            ),
    );
  }

  IconData _getAccountIcon(String accountType) {
    switch (accountType.toLowerCase()) {
      case '银行卡':
      case 'bank':
        return Icons.account_balance;
      case '支付宝':
      case 'alipay':
        return Icons.account_balance_wallet;
      case '微信':
      case 'wechat':
        return Icons.chat;
      default:
        return Icons.account_balance_wallet;
    }
  }

  String _maskAccountNumber(String accountNumber) {
    if (accountNumber.length <= 4) {
      return accountNumber;
    }
    final start = accountNumber.substring(0, 4);
    final end = accountNumber.substring(accountNumber.length - 4);
    return '$start****$end';
  }
}