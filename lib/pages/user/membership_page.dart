import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bookin/api/membership.dart';
import 'package:bookin/providers/user_provider.dart'; // Import UserProvider

class MembershipPage extends StatefulWidget {
  const MembershipPage({super.key});

  @override
  State<MembershipPage> createState() => _MembershipPageState();
}

class _MembershipPageState extends State<MembershipPage> {

  // MembershipInfo? _membershipInfo; // This will now come from UserProvider
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchMembershipInfo();
  }

  Future<void> _fetchMembershipInfo() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      // Membership info is primarily from UserProvider's UserInfo.isMember, memberLevel etc.
      // If there's additional membership-specific info not in UserInfo, fetch it here.
      // For now, we'll just rely on UserProvider for basic membership status.
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      if (userProvider.userInfo == null) {
        await userProvider.fetchUserInfo(context); // Ensure user info is loaded
      }

      // If there's a separate API for detailed membership info, call it here:
      // final response = await _membershipApi.getMembershipInfo(context); // Pass context
      // if (response.success) {
      //   _membershipInfo = response.data;
      // } else {
      //   _errorMessage = response.message;
      // }

    } catch (e) {
      _errorMessage = '加载会员信息失败: ${e.toString()}';
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
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        final userInfo = userProvider.userInfo;

        if (_isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (_errorMessage != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(_errorMessage!),
                ElevatedButton(
                  onPressed: _fetchMembershipInfo,
                  child: const Text('重试'),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: _fetchMembershipInfo,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    margin: EdgeInsets.zero,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            userInfo?.isMember == true ? '您是尊贵的会员' : '您还不是会员',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          const SizedBox(height: 8),
                          if (userInfo?.isMember == true)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('会员等级: ${userInfo?.memberLevel ?? '普通会员'}'),
                                Text('到期日期: ${userInfo?.memberLevel != null ? '2024-12-31' : '-'}'), // Placeholder for expire date
                                Text('会员积分: ${userInfo?.points ?? 0}'),
                              ],
                            )
                          else
                            const Text('开通会员享受更多优惠和服务！'),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              // Navigate to membership upgrade/purchase page
                              _showSnackBar('开通/管理会员功能待实现');
                            },
                            child: Text(userInfo?.isMember == true ? '管理会员' : '立即开通会员'),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Add more sections for membership benefits, history, etc.
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
