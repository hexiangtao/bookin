import 'package:flutter/material.dart';
import 'package:bookin/api/technician.dart';

class TechnicianAuthDetailPage extends StatefulWidget {
  final AuthInfo authInfo;

  const TechnicianAuthDetailPage({super.key, required this.authInfo});

  @override
  State<TechnicianAuthDetailPage> createState() => _TechnicianAuthDetailPageState();
}

class _TechnicianAuthDetailPageState extends State<TechnicianAuthDetailPage> {
  String _getAuthTypeName(int authType) {
    switch (authType) {
      case 1: return '健康证';
      case 2: return '技师证';
      case 3: return '营业资格证';
      default: return '未知类型';
    }
  }

  String _getAuthStatusText(int status) {
    switch (status) {
      case 0: return '待审核';
      case 1: return '已通过';
      case 2: return '已拒绝';
      default: return '未知状态';
    }
  }

  Color _getAuthStatusColor(int status) {
    switch (status) {
      case 0: return Colors.orange;
      case 1: return Colors.green;
      case 2: return Colors.red;
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = widget.authInfo;
    return Scaffold(
      appBar: AppBar(
        title: const Text('认证详情'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '认证类型: ${_getAuthTypeName(auth.authType)}',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const Divider(),
                _buildDetailRow('证书编号', auth.certNumber),
                _buildDetailRow('发证日期', auth.issueDate),
                if (auth.expireDate != null && auth.expireDate!.isNotEmpty)
                  _buildDetailRow('过期日期', auth.expireDate!),
                _buildDetailRow(
                  '认证状态',
                  _getAuthStatusText(auth.status),
                  valueColor: _getAuthStatusColor(auth.status),
                ),
                if (auth.rejectReason != null && auth.rejectReason!.isNotEmpty)
                  _buildDetailRow('拒绝原因', auth.rejectReason!),
                const SizedBox(height: 16),
                Text('证书图片', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8.0,
                  runSpacing: 8.0,
                  children: auth.images.map((imageUrl) {
                    return Image.network(imageUrl, width: 100, height: 100, fit: BoxFit.cover);
                  }).toList(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text('$label:', style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(color: valueColor ?? Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}
