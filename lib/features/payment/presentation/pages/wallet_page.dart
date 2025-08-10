import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bookin/features/payment/data/api/wallet_api.dart';
import 'package:bookin/features/payment/presentation/pages/recharge_page.dart';
import 'package:bookin/features/payment/presentation/pages/withdraw_page.dart';
import 'package:bookin/features/payment/presentation/pages/wallet_transaction_page.dart';
import 'package:bookin/shared/providers/user_provider.dart'; // Import UserProvider

class WalletPage extends StatefulWidget {
  const WalletPage({super.key});

  @override
  State<WalletPage> createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage> {
  final WalletApi _walletApi = WalletApi();
  // WalletInfo? _walletInfo; // This will now come from UserProvider
  List<WalletTransaction> _transactions = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchWalletData();
  }

  Future<void> _fetchWalletData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      // WalletInfo will be fetched via UserProvider, so we only fetch transactions here
      final transactionsResponse = await _walletApi.getWalletTransactions(context); // Pass context

      if (transactionsResponse.success) {
        _transactions = transactionsResponse.data ?? [];
      } else {
        _errorMessage = transactionsResponse.message;
      }
    } catch (e) {
      _errorMessage = '加载钱包数据失败: ${e.toString()}';
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        final userInfo = userProvider.userInfo;
        // If user info is not available, show loading or error
        if (userInfo == null && !userProvider.isLoggedIn) {
          return const Center(child: CircularProgressIndicator()); // Or a login prompt
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('我的钱包'),
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
                            onPressed: _fetchWalletData,
                            child: const Text('重试'),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _fetchWalletData,
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Wallet Balance Section
                            Card(
                              margin: const EdgeInsets.all(16.0),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('账户余额', style: TextStyle(fontSize: 16, color: Colors.grey)),
                                    const SizedBox(height: 8),
                                    Text(
                                      '¥${(userInfo?.balance ?? 0.0).toStringAsFixed(2)}',
                                      style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 16),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                                      children: [
                                        ElevatedButton(
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(builder: (context) => const RechargePage()),
                                            );
                                          },
                                          child: const Text('充值'),
                                        ),
                                        ElevatedButton(
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(builder: (context) => const WithdrawPage()),
                                            );
                                          },
                                          child: const Text('提现'),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            // Quick Entry Section
                            Container(
                              margin: const EdgeInsets.all(16.0),
                              padding: const EdgeInsets.all(16.0),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.1),
                                    spreadRadius: 1,
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    '快捷入口',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                                    children: [
                                      _buildQuickEntryItem(
                                        icon: Icons.account_balance_wallet,
                                        label: '充值记录',
                                        color: Colors.blue,
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => const WalletTransactionPage(initialType: 'recharge'),
                                            ),
                                          );
                                        },
                                      ),
                                      _buildQuickEntryItem(
                                        icon: Icons.shopping_cart,
                                        label: '消费明细',
                                        color: Colors.orange,
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => const WalletTransactionPage(initialType: 'consume'),
                                            ),
                                          );
                                        },
                                      ),
                                      _buildQuickEntryItem(
                                        icon: Icons.refresh,
                                        label: '退款记录',
                                        color: Colors.green,
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => const WalletTransactionPage(initialType: 'refund'),
                                            ),
                                          );
                                        },
                                      ),
                                      _buildQuickEntryItem(
                                        icon: Icons.local_offer,
                                        label: '我的优惠券',
                                        color: Colors.purple,
                                        onTap: () {
                                          // Navigator.push(
                                          //   context,
                                          //   MaterialPageRoute(
                                          //     builder: (context) => const CouponListPage(),
                                          //   ),
                                          // );
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            // Transaction History Section
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('交易明细', style: Theme.of(context).textTheme.titleLarge),
                                  TextButton(
                                    onPressed: () {
                                      // Navigator.push(
                                      //   context,
                                      //   MaterialPageRoute(
                                      //     builder: (context) => const WalletTransactionPage(),
                                      //   ),
                                      // );
                                    },
                                    child: const Text('查看全部'),
                                  ),
                                ],
                              ),
                            ),
                            _transactions.isEmpty
                                ? const Center(child: Padding(padding: EdgeInsets.all(16.0), child: Text('暂无交易记录')))
                                : ListView.builder(
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(),
                                    itemCount: _transactions.length,
                                    itemBuilder: (context, index) {
                                      final transaction = _transactions[index];
                                      return Card(
                                        margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                                        child: ListTile(
                                          title: Text(transaction.description),
                                          subtitle: Text(transaction.transactionTime),
                                          trailing: Text(
                                            '${transaction.type == 'recharge' ? '+' : '-'}¥${(transaction.amount / 100).toStringAsFixed(2)}',
                                            style: TextStyle(
                                              color: transaction.type == 'recharge' ? Colors.green : Colors.red,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                          ],
                        ),
                      ),
                    ),
        );
      },
    );
  }

  Widget _buildQuickEntryItem({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 70,
        child: Column(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.2),
                    spreadRadius: 1,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                icon,
                color: color,
                size: 24,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
