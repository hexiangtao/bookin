import 'package:flutter/material.dart';
import 'package:bookin/features/technician/data/api/technician_api.dart';
import 'package:bookin/features/payment/presentation/pages/withdrawal_account_edit_page.dart'; // Import edit page

class WithdrawalAccountsPage extends StatefulWidget {
  const WithdrawalAccountsPage({super.key});

  @override
  State<WithdrawalAccountsPage> createState() => _WithdrawalAccountsPageState();
}

class _WithdrawalAccountsPageState extends State<WithdrawalAccountsPage> {
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
      final response = await _technicianApi.getWithdrawalAccounts(context); // Pass context
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

  Future<void> _deleteAccount(String id) async {
    setState(() {
      _isLoading = true;
    });
    try {
      final response = await _technicianApi.deleteWithdrawalAccount(context, id); // Pass context
      if (response.success) {
        _showSnackBar('账号删除成功');
        _fetchAccounts(); // Refresh list
      } else {
        _showSnackBar('删除失败: ${response.message}');
      }
    } catch (e) {
      _showSnackBar('删除失败: ${e.toString()}');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _setDefaultAccount(String id) async {
    setState(() {
      _isLoading = true;
    });
    try {
      final response = await _technicianApi.setDefaultWithdrawalAccount(context, id); // Pass context
      if (response.success) {
        _showSnackBar('默认账号设置成功');
        _fetchAccounts(); // Refresh list to update default status
      } else {
        _showSnackBar('设置失败: ${response.message}');
      }
    } catch (e) {
      _showSnackBar('设置失败: ${e.toString()}');
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
        title: const Text('提现管理'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const WithdrawalAccountEditPage()),
              );
              if (result == true) {
                _fetchAccounts(); // Refresh list if account was added/edited
              }
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(_errorMessage!),
                      ElevatedButton(
                        onPressed: _fetchAccounts,
                        child: const Text('重试'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _fetchAccounts,
                  child: _accounts.isEmpty
                      ? const Center(child: Padding(padding: EdgeInsets.all(16.0), child: Text('暂无提现账号，点击右上角添加')))
                      : ListView.builder(
                          itemCount: _accounts.length,
                          itemBuilder: (context, index) {
                            final account = _accounts[index];
                            return Card(
                              margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                              child: ListTile(
                                title: Text(account.accountName),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('账号: ${account.accountNumber}'),
                                    if (account.bankName != null && account.bankName!.isNotEmpty)
                                      Text('银行: ${account.bankName}'),
                                    Text('类型: ${account.accountType}'),
                                    if (account.isDefault)
                                      const Padding(
                                        padding: EdgeInsets.only(top: 4.0),
                                        child: Chip(
                                          label: Text('默认账号', style: TextStyle(fontSize: 10)),
                                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                        ),
                                      ),
                                  ],
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit),
                                      onPressed: () async {
                                        final result = await Navigator.push(
                                          context,
                                          MaterialPageRoute(builder: (context) => WithdrawalAccountEditPage(account: account)),
                                        );
                                        if (result == true) {
                                          _fetchAccounts(); // Refresh list if account was added/edited
                                        }
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete),
                                      onPressed: () => _deleteAccount(account.id),
                                    ),
                                    if (!account.isDefault)
                                      IconButton(
                                        icon: const Icon(Icons.star_border),
                                        tooltip: '设为默认',
                                        onPressed: () => _setDefaultAccount(account.id),
                                      ),
                                  ],
                                ),
                                onTap: () {
                                  // Handle account selection or view details
                                },
                              ),
                            );
                          },
                        ),
                ),
    );
  }
}
