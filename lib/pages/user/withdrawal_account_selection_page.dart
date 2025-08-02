import 'package:flutter/material.dart';
import 'package:bookin/api/technician.dart';

class WithdrawalAccountSelectionPage extends StatefulWidget {
  const WithdrawalAccountSelectionPage({super.key});

  @override
  State<WithdrawalAccountSelectionPage> createState() => _WithdrawalAccountSelectionPageState();
}

class _WithdrawalAccountSelectionPageState extends State<WithdrawalAccountSelectionPage> {
  final TechnicianApi _technicianApi = TechnicianApi();
  List<WithdrawalAccount> _accounts = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchAccounts();
  }

  Future<void> _fetchAccounts() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final response = await _technicianApi.getWithdrawalAccounts(context);
      if (response.success) {
        _accounts = response.data ?? [];
      } else {
        _errorMessage = response.message;
      }
    } catch (e) {
      _errorMessage = '加载提现账号失败: ${e.toString()}';
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _selectAccount(WithdrawalAccount account) {
    Navigator.pop(context, account);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('选择提现账号'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(_errorMessage!),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _fetchAccounts,
                        child: const Text('重试'),
                      ),
                    ],
                  ),
                )
              : _accounts.isEmpty
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.account_balance_wallet_outlined,
                              size: 64,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 16),
                            Text(
                              '暂无提现账号',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              '请先添加提现账号',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16.0),
                      itemCount: _accounts.length,
                      itemBuilder: (context, index) {
                        final account = _accounts[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12.0),
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(16.0),
                            leading: Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: Theme.of(context).primaryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(24),
                              ),
                              child: Icon(
                                _getAccountIcon(account.accountType),
                                color: Theme.of(context).primaryColor,
                                size: 24,
                              ),
                            ),
                            title: Text(
                              account.accountName,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 4),
                                Text(
                                  '账号: ${_maskAccountNumber(account.accountNumber)}',
                                  style: const TextStyle(fontSize: 14),
                                ),
                                if (account.bankName != null && account.bankName!.isNotEmpty)
                                  Text(
                                    '银行: ${account.bankName}',
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                Text(
                                  '类型: ${account.accountType}',
                                  style: const TextStyle(fontSize: 14),
                                ),
                                if (account.isDefault)
                                  const Padding(
                                    padding: EdgeInsets.only(top: 4.0),
                                    child: Chip(
                                      label: Text(
                                        '默认账号',
                                        style: TextStyle(fontSize: 10),
                                      ),
                                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                    ),
                                  ),
                              ],
                            ),
                            trailing: const Icon(Icons.arrow_forward_ios),
                            onTap: () => _selectAccount(account),
                          ),
                        );
                      },
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