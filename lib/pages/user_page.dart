import 'package:flutter/material.dart';
import 'package:bookin/api/user.dart';

class UserPage extends StatefulWidget {
  const UserPage({super.key});

  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  final UserApi _userApi = UserApi();
  UserInfo? _userInfo;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchUserInfo();
  }

  Future<void> _fetchUserInfo() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final response = await _userApi.getInfo(context);
      if (response.success) {
        _userInfo = response.data;
      } else {
        _errorMessage = response.message;
      }
    } catch (e) {
      _errorMessage = '加载用户信息失败: ${e.toString()}';
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('我的'),
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
                        onPressed: _fetchUserInfo,
                        child: const Text('重试'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _fetchUserInfo,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(
                      children: [
                        // User Info Section
                        Card(
                          margin: const EdgeInsets.all(8.0),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                CircleAvatar(
                                  radius: 40,
                                  backgroundImage: _userInfo?.avatar != null
                                      ? NetworkImage(_userInfo!.avatar!)
                                      : null,
                                  child: _userInfo?.avatar == null
                                      ? const Icon(Icons.person, size: 40)
                                      : null,
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  _userInfo?.nickname ?? '未登录',
                                  style: Theme.of(context).textTheme.headlineSmall,
                                ),
                                Text(
                                  _userInfo?.phone ?? '',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                                const SizedBox(height: 10),
                                ElevatedButton(
                                  onPressed: () {
                                    // Navigate to profile edit page
                                  },
                                  child: const Text('编辑资料'),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Other sections (e.g., Wallet, Coupons, Addresses, Settings)
                        Card(
                          margin: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              ListTile(
                                leading: const Icon(Icons.account_balance_wallet),
                                title: const Text('我的钱包'),
                                trailing: Text('¥${(_userInfo?.balance ?? 0.0).toStringAsFixed(2)}'),
                                onTap: () {
                                  // Navigate to wallet page
                                },
                              ),
                              ListTile(
                                leading: const Icon(Icons.card_giftcard),
                                title: const Text('我的优惠券'),
                                onTap: () {
                                  // Navigate to coupons page
                                },
                              ),
                              ListTile(
                                leading: const Icon(Icons.location_on),
                                title: const Text('我的地址'),
                                onTap: () {
                                  // Navigate to address list page
                                },
                              ),
                              ListTile(
                                leading: const Icon(Icons.favorite),
                                title: const Text('我的收藏'),
                                onTap: () {
                                  // Navigate to favorites page
                                },
                              ),
                              ListTile(
                                leading: const Icon(Icons.history),
                                title: const Text('消费记录'),
                                onTap: () {
                                  // Navigate to records page
                                },
                              ),
                            ],
                          ),
                        ),

                        // Logout Button
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ElevatedButton(
                            onPressed: () async {
                              // Implement logout logic
                              // await _userApi.logout();
                              // Navigate to login page
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.redAccent,
                              minimumSize: const Size(double.infinity, 50),
                            ),
                            child: const Text('退出登录', style: TextStyle(color: Colors.white)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }
}