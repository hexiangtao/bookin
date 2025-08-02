import 'package:flutter/material.dart';

class TechnicianHelpPage extends StatelessWidget {
  const TechnicianHelpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('帮助中心'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '常见问题',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            _buildQuestionAnswer(
              'Q: 如何接单？',
              'A: 在订单管理页面，您可以查看待接订单，点击“接单”按钮即可接受订单。请确保您已开启接单模式。',
            ),
            _buildQuestionAnswer(
              'Q: 如何修改排班？',
              'A: 在排班管理页面，您可以选择日期并设置您的可用时间段。设置完成后请点击保存。',
            ),
            _buildQuestionAnswer(
              'Q: 如何提现？',
              'A: 在提现管理页面，您可以绑定您的银行卡或支付宝/微信账号，然后提交提现申请。提现通常会在1-3个工作日内到账。',
            ),
            _buildQuestionAnswer(
              'Q: 忘记密码怎么办？',
              'A: 您可以在登录页面点击“忘记密码”，通过手机验证码重置密码。',
            ),
            const SizedBox(height: 24),
            Text(
              '联系客服',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.phone),
              title: const Text('客服电话'),
              subtitle: const Text('400-123-4567'), // Replace with actual customer service phone
              onTap: () {
                // Implement call functionality
              },
            ),
            ListTile(
              leading: const Icon(Icons.wechat),
              title: const Text('客服微信'),
              subtitle: const Text('daojia_service'), // Replace with actual customer service WeChat ID
              onTap: () {
                // Implement copy to clipboard or open WeChat
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionAnswer(String question, String answer) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 4),
          Text(answer),
        ],
      ),
    );
  }
}
