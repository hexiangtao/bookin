import 'package:flutter/material.dart';
import 'package:bookin/api/system.dart';

class PrivacyPage extends StatefulWidget {
  const PrivacyPage({super.key});

  @override
  State<PrivacyPage> createState() => _PrivacyPageState();
}

class _PrivacyPageState extends State<PrivacyPage> {
  final SystemApi _systemApi = SystemApi();
  String _privacyContent = '加载中...';
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchPrivacyPolicy();
  }

  Future<void> _fetchPrivacyPolicy() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      // Assuming systemConfig.privacyPolicyUrl points to a text file or a webview URL
      // For simplicity, let's assume the content is directly in systemConfig for now
      final response = await _systemApi.getSystemConfig(context); // Pass context
      if (response.success && response.data != null) {
        _privacyContent = response.data!.privacyPolicyUrl; // This should be actual content, not URL
        // If it's a URL, you'd use a WebView or fetch content from that URL
        // For demonstration, using a static string.
        _privacyContent = """
## 隐私政策

**生效日期：2023年10月26日**

**1. 引言**

岚媛到家（以下简称“我们”）深知个人信息对您的重要性，并会尽全力保护您的个人信息安全可靠。我们致力于维持您对我们的信任，恪守以下原则，保护您的个人信息：权责一致原则、目的明确原则、选择同意原则、最少够用原则、公开透明原则、确保安全原则、主体参与原则等。同时，我们承诺，我们将按业界成熟的安全标准，采取相应的安全保护措施来保护您的个人信息。

**2. 我们如何收集和使用您的个人信息**

个人信息是指以电子或者其他方式记录的与已识别或者可识别的自然人有关的各种信息，不包括匿名化处理后的信息。

我们将遵循合法、正当、必要的原则，收集和使用您在使用服务过程中主动提供的或因使用服务而产生的个人信息。

**2.1 您直接提供和我们自动采集的个人信息**

*   **注册信息**：当您注册岚媛到家账户时，您需要向我们提供手机号码、验证码等信息。
*   **身份认证信息**：为满足相关法律法规要求，您可能需要提供姓名、身份证号码、人脸识别信息等。
*   **服务信息**：当您使用我们的服务时，我们会收集您的订单信息、服务地址、联系方式、支付信息等。
*   **设备信息**：我们会根据您在软件安装及使用中授予的具体权限，接收并记录您所使用的设备相关信息（例如设备型号、操作系统版本、设备设置、唯一设备标识符等软硬件特征信息）、设备所在位置相关信息（例如IP地址、GPS位置以及能够提供相关信息的WLAN接入点、蓝牙和基站传感器信息）。
*   **日志信息**：当您使用我们的服务时，我们会自动收集您对我们服务的详细使用情况，作为有关网络日志保存。例如您的搜索查询内容、IP地址、浏览器的类型、电信运营商、使用的语言、访问日期和时间及您访问的网页记录等。

**2.2 我们从第三方获取您的个人信息**

我们可能从第三方（例如合作伙伴、社交媒体平台）获取您的个人信息，但我们会确保这些信息的来源合法，并会在收集前征得您的同意。

**2.3 我们如何使用您的个人信息**

我们收集和使用您的个人信息是为了向您提供服务、优化服务体验、保障服务安全、进行数据分析和研究等。

**3. 我们如何共享、转让、公开披露您的个人信息**

我们不会与任何公司、组织和个人共享您的个人信息，但以下情况除外：

*   在获取明确同意的情况下共享：获得您的明确同意后，我们会与其他方共享您的个人信息。
*   在法定情形下的共享：我们可能会根据法律法规规定、诉讼争议解决需要，或按行政、司法机关依法提出的要求，对外共享您的个人信息。
*   与关联公司共享：您的个人信息可能会与岚媛到家的关联公司共享。我们只会共享必要的个人信息，且受本隐私政策中所声明目的的约束。
*   与授权合作伙伴共享：我们可能与授权合作伙伴共享您的个人信息，以提供更好的客户服务和用户体验。例如，我们向提供支付服务的合作伙伴共享您的支付信息。

**3.2 转让**

我们不会将您的个人信息转让给任何公司、组织和个人，但以下情况除外：

*   在获取明确同意的情况下转让：获得您的明确同意后，我们会向其他方转让您的个人信息。
*   在涉及合并、收购或破产清算时，如涉及到个人信息转让，我们会在要求新的持有您个人信息的公司、组织继续受本隐私政策的约束，否则我们将要求该公司、组织和个人重新向您征求授权同意。

**3.3 公开披露**

我们仅会在以下情况下，公开披露您的个人信息：

*   获得您明确同意后；
*   基于法律的披露：在法律、法律程序、诉讼或政府主管部门强制性要求的情况下，我们可能会公开披露您的个人信息。

**4. 我们如何保护您的个人信息**

我们已使用符合业界标准的安全防护措施保护您提供的个人信息，防止数据遭到未经授权访问、公开披露、使用、修改、损坏或丢失。

**5. 您的权利**

您有权访问、更正、删除您的个人信息，也有权撤回同意、注销账户等。您可以通过本隐私政策提供的联系方式与我们联系，行使您的权利。

**6. 本隐私政策如何更新**

我们可能会适时对本隐私政策进行修订。当本隐私政策发生变更时，我们会在版本更新后在相关页面提示您最新的隐私政策。请您仔细阅读修订后的隐私政策内容。

**7. 联系我们**

如果您对本隐私政策有任何疑问、意见或建议，请通过以下方式与我们联系：
客服电话：${response.data!.customerServicePhone}
客服微信：${response.data!.customerServiceWechat}

""";
      } else {
        _errorMessage = response.message;
      }
    } catch (e) {
      _errorMessage = '加载隐私政策失败: ${e.toString()}';
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
        title: const Text('隐私政策'),
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
                        onPressed: _fetchPrivacyPolicy,
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
                        _privacyContent,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ],
                  ),
                ),
    );
  }
}