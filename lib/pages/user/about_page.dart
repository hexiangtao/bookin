import 'package:flutter/material.dart';
import 'package:bookin/api/system.dart';
import 'package:bookin/pages/user/user_agreement_page.dart';
import 'package:bookin/pages/user/privacy_page.dart'; // Import privacy page

class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  final SystemApi _systemApi = SystemApi();
  SystemConfig? _systemConfig;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchSystemConfig();
  }

  Future<void> _fetchSystemConfig() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final response = await _systemApi.getSystemConfig(context); // Pass context
      if (response.success) {
        _systemConfig = response.data;
      } else {
        _errorMessage = response.message;
      }
    } catch (e) {
      _errorMessage = '加载系统配置失败: ${e.toString()}';
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
        title: const Text('关于我们'),
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
                        onPressed: _fetchSystemConfig,
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
                      if (_systemConfig?.appLogoUrl != null)
                        Image.network(
                          _systemConfig!.appLogoUrl,
                          height: 100,
                        ),
                      const SizedBox(height: 16),
                      Text(
                        _systemConfig?.appName ?? '岚媛到家',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '版本: 1.0.0', // Placeholder, ideally from package_info_plus
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 24),
                      Text(
                        '${_systemConfig?.appName ?? '我们'}致力于提供高品质的上门服务，让您的生活更便捷、更舒适。我们拥有一支专业的技师团队，严格筛选，持证上岗，为您提供安全、放心的服务。',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 24),
                      ListTile(
                        leading: const Icon(Icons.phone),
                        title: const Text('客服电话'),
                        subtitle: Text(_systemConfig?.customerServicePhone ?? '暂无'),
                        onTap: () {
                          // Implement call functionality
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.wechat),
                        title: const Text('客服微信'),
                        subtitle: Text(_systemConfig?.customerServiceWechat ?? '暂无'),
                        onTap: () {
                          // Implement copy to clipboard or open WeChat
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.policy),
                        title: const Text('隐私政策'),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const PrivacyPage()),
                          );
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.description),
                        title: const Text('用户协议'),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const UserAgreementPage()),
                          );
                        },
                      ),
                    ],
                  ),
                ),
    );
  }
}
