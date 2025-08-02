import 'package:flutter/material.dart';
import 'package:bookin/api/system.dart';

class UserAgreementPage extends StatefulWidget {
  const UserAgreementPage({super.key});

  @override
  State<UserAgreementPage> createState() => _UserAgreementPageState();
}

class _UserAgreementPageState extends State<UserAgreementPage> {
  final SystemApi _systemApi = SystemApi();
  String _agreementContent = '加载中...';
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchUserAgreement();
  }

  Future<void> _fetchUserAgreement() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      // Assuming there's an API endpoint for user agreement content
      // For now, using a placeholder or fetching from system config if it contains a URL
      final response = await _systemApi.getSystemConfig(context); // Pass context
      if (response.success && response.data != null) {
        // Assuming systemConfig.userAgreementUrl points to a text file or a webview URL
        // For simplicity, let's assume the content is directly in systemConfig for now
        _agreementContent = response.data!.userAgreementUrl; // This should be actual content, not URL
        // If it's a URL, you'd use a WebView or fetch content from that URL
        // For demonstration, using a static string.
        _agreementContent = """
## 用户协议

欢迎使用岚媛到家服务！

本协议是您与岚媛到家之间就您使用岚媛到家服务所订立的协议。在您注册成为岚媛到家用户之前，请务必仔细阅读本协议的全部内容，特别是免责条款、隐私政策等。

**1. 服务内容**

岚媛到家通过移动应用程序、网站等方式，为您提供上门按摩、家政服务、美容美甲等一系列便捷的到家服务。具体服务内容以平台实时展示为准。

**2. 用户注册**

您在使用本服务前需要注册一个岚媛到家账号。您应当提供真实、准确、完整、有效的注册信息，并对您注册信息的真实性、合法性、有效性承担全部责任。

**3. 用户行为规范**

您在使用本服务过程中，应遵守法律法规、本协议及相关规则，不得从事任何违法违规行为，包括但不限于：
* 发布、传播违法信息；
* 侵犯他人合法权益；
* 干扰平台正常运营。

**4. 隐私保护**

岚媛到家非常重视您的个人信息保护。我们将按照隐私政策的规定收集、使用、存储和保护您的个人信息。请您仔细阅读《隐私政策》以了解详细信息。

**5. 费用与支付**

您使用本服务可能需要支付相关费用。具体费用标准以平台公示为准。您应按照平台要求及时支付费用。

**6. 知识产权**

本服务所包含的所有内容（包括但不限于文字、图片、音频、视频、软件等）的知识产权均归岚媛到家或相关权利人所有。

**7. 协议变更**

岚媛到家有权根据业务发展需要，对本协议进行修改。修改后的协议将在平台公布，并自公布之日起生效。您继续使用本服务，即表示您接受修改后的协议。

**8. 法律适用与争议解决**

本协议的订立、执行和解释及争议的解决均适用中华人民共和国法律。因本协议引起的或与本协议有关的任何争议，双方应友好协商解决；协商不成的，任何一方均可向有管辖权的人民法院提起诉讼。

**9. 联系我们**

如果您对本协议有任何疑问，请通过以下方式联系我们：
客服电话：${response.data!.customerServicePhone}
客服微信：${response.data!.customerServiceWechat}

**最后更新日期：2023年10月26日**
""";
      } else {
        _errorMessage = response.message;
      }
    } catch (e) {
      _errorMessage = '加载用户协议失败: ${e.toString()}';
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
        title: const Text('用户协议'),
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
                        onPressed: _fetchUserAgreement,
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
                      Text(
                        _agreementContent,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ],
                  ),
                ),
    );
  }
}