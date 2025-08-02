import 'package:flutter/material.dart';
import 'package:bookin/api/wallet.dart';

class RechargePage extends StatefulWidget {
  const RechargePage({super.key});

  @override
  State<RechargePage> createState() => _RechargePageState();
}

class _RechargePageState extends State<RechargePage> {
  final WalletApi _walletApi = WalletApi();
  List<RechargeOption> _rechargeOptions = [];
  RechargeOption? _selectedOption;
  final TextEditingController _customAmountController = TextEditingController();
  int _selectedPayType = 2; // 1: Alipay, 2: WeChat (default to WeChat)

  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchRechargeOptions();
  }

  @override
  void dispose() {
    _customAmountController.dispose();
    super.dispose();
  }

  Future<void> _fetchRechargeOptions() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final response = await _walletApi.getRechargeOptions(context); // Pass context
      if (response.success) {
        _rechargeOptions = response.data ?? [];
        if (_rechargeOptions.isNotEmpty) {
          _selectedOption = _rechargeOptions.first;
        }
      } else {
        _errorMessage = response.message;
      }
    } catch (e) {
      _errorMessage = '加载充值选项失败: ${e.toString()}';
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _createRechargeOrder() async {
    if (_selectedOption == null && _customAmountController.text.isEmpty) {
      _showSnackBar('请选择充值金额或输入自定义金额');
      return;
    }

    int amountInCents;
    if (_selectedOption != null) {
      amountInCents = _selectedOption!.amount;
    } else {
      final customAmount = double.tryParse(_customAmountController.text);
      if (customAmount == null || customAmount <= 0) {
        _showSnackBar('请输入有效的充值金额');
        return;
      }
      amountInCents = (customAmount * 100).toInt();
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final createRechargeReq = CreateRechargeOrderReq(
        amount: amountInCents,
        payType: _selectedPayType,
      );

      final response = await _walletApi.createRechargeOrder(context, createRechargeReq); // Pass context
      if (response.success && response.data != null) {
        _showSnackBar('充值订单创建成功！');
        // Here you would typically handle the payment (e.g., launch WeChat Pay SDK)
        // For now, just show a success message and pop.
        Navigator.pop(context); 
      } else {
        _showSnackBar('创建订单失败: ${response.message}');
      }
    } catch (e) {
      _showSnackBar('创建订单失败: ${e.toString()}');
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
        title: const Text('充值'),
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
                        onPressed: _fetchRechargeOptions,
                        child: const Text('重试'),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('选择充值金额', style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 16),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16.0,
                          mainAxisSpacing: 16.0,
                          childAspectRatio: 2.5,
                        ),
                        itemCount: _rechargeOptions.length,
                        itemBuilder: (context, index) {
                          final option = _rechargeOptions[index];
                          return ChoiceChip(
                            label: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('¥${(option.amount / 100).toStringAsFixed(0)}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                                if (option.bonus > 0)
                                  Text('赠送¥${(option.bonus / 100).toStringAsFixed(0)}', style: const TextStyle(fontSize: 12, color: Colors.green)),
                              ],
                            ),
                            selected: _selectedOption?.id == option.id,
                            onSelected: (selected) {
                              setState(() {
                                _selectedOption = selected ? option : null;
                                _customAmountController.clear(); // Clear custom amount if option selected
                              });
                            },
                          );
                        },
                      ),
                      const SizedBox(height: 24),
                      Text('或输入自定义金额', style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _customAmountController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: '自定义金额 (元)',
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (value) {
                          setState(() {
                            _selectedOption = null; // Clear selected option if custom amount entered
                          });
                        },
                      ),
                      const SizedBox(height: 24),
                      Text('选择支付方式', style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 16),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          children: [
                            _buildPaymentOption(
                              payType: 2,
                              title: '微信支付',
                              subtitle: '推荐使用微信支付',
                              icon: Icons.chat,
                              iconColor: Colors.green,
                            ),
                            Divider(height: 1, color: Colors.grey[300]),
                            _buildPaymentOption(
                              payType: 1,
                              title: '支付宝',
                              subtitle: '安全便捷的支付方式',
                              icon: Icons.account_balance_wallet,
                              iconColor: Colors.blue,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),
                      ElevatedButton(
                        onPressed: _createRechargeOrder,
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 50),
                        ),
                        child: const Text('立即充值'),
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildPaymentOption({
    required int payType,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
  }) {
    final isSelected = _selectedPayType == payType;
    
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Icon(
          icon,
          color: iconColor,
          size: 24,
        ),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 12,
          color: Colors.grey[600],
        ),
      ),
      trailing: Radio<int>(
        value: payType,
        groupValue: _selectedPayType,
        onChanged: (value) {
          setState(() {
            _selectedPayType = value!;
          });
        },
        activeColor: Theme.of(context).primaryColor,
      ),
      onTap: () {
        setState(() {
          _selectedPayType = payType;
        });
      },
    );
  }
}