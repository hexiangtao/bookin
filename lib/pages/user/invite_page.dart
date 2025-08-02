import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bookin/api/user.dart';
import 'package:bookin/providers/user_provider.dart';

class InvitePage extends StatefulWidget {
  const InvitePage({super.key});

  @override
  State<InvitePage> createState() => _InvitePageState();
}

class _InvitePageState extends State<InvitePage> {
  final UserApi _userApi = UserApi();
  String? _inviteCode;
  String? _qrCodeUrl;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchInviteInfo();
  }

  Future<void> _fetchInviteInfo() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      // Ensure user info is loaded in the provider
      if (userProvider.userInfo == null) {
        await userProvider.fetchUserInfo(context);
      }
      
      _inviteCode = userProvider.userInfo?.inviteCode;

      if (_inviteCode != null && _inviteCode!.isNotEmpty) {
        final qrCodeResponse = await _userApi.getInviteQRCode(context, _inviteCode!); // Pass context
        if (qrCodeResponse.success) {
          _qrCodeUrl = qrCodeResponse.data;
        } else {
          _errorMessage = qrCodeResponse.message;
        }
      } else {
        _errorMessage = '邀请码不存在或未加载';
      }
    } catch (e) {
      _errorMessage = '加载邀请信息失败: ${e.toString()}';
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
        title: const Text('邀请有礼'),
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
                        onPressed: _fetchInviteInfo,
                        child: const Text('重试'),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        '我的邀请码',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        _inviteCode ?? '暂无邀请码',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 20),
                      if (_qrCodeUrl != null)
                        Image.network(
                          _qrCodeUrl!,
                          width: 200,
                          height: 200,
                          fit: BoxFit.contain,
                        )
                      else
                        Container(
                          width: 200,
                          height: 200,
                          color: Colors.grey[200],
                          child: const Center(child: Text('二维码加载失败')),
                        ),
                      const SizedBox(height: 20),
                      Text(
                        '分享您的邀请码或二维码，邀请好友注册，即可获得奖励！',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 30),
                      ElevatedButton(
                        onPressed: () {
                          // Implement share functionality
                          _showSnackBar('分享功能待实现');
                        },
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 50),
                        ),
                        child: const Text('立即分享'),
                      ),
                    ],
                  ),
                ),
    );
  }
}
