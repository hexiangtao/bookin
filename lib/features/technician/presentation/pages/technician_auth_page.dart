import 'package:flutter/material.dart';
import 'package:bookin/features/technician/data/api/technician_api.dart';
import 'package:bookin/shared/services/upload_service.dart';
import 'package:bookin/features/technician/presentation/pages/technician_auth_detail_page.dart'; // Import auth detail page

class TechnicianAuthPage extends StatefulWidget {
  const TechnicianAuthPage({super.key});

  @override
  State<TechnicianAuthPage> createState() => _TechnicianAuthPageState();
}

class _TechnicianAuthPageState extends State<TechnicianAuthPage> {
  final TechnicianApi _technicianApi = TechnicianApi();
  final UploadService _uploadService = UploadService();

  TechnicianAuthStatus? _authStatus;
  bool _isLoading = true;
  String? _errorMessage;

  // Form controllers for new/editing auth info
  final TextEditingController _certNumberController = TextEditingController();
  DateTime? _issueDate;
  DateTime? _expireDate;
  List<String> _images = [];
  int? _selectedAuthType; // 1-健康证, 2-技师证, 3-营业资格证

  @override
  void initState() {
    super.initState();
    _fetchAuthStatus();
  }

  @override
  void dispose() {
    _certNumberController.dispose();
    super.dispose();
  }

  Future<void> _fetchAuthStatus() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final response = await _technicianApi.getAuthStatus(context); // Pass context
      if (response.success) {
        _authStatus = response.data;
        // Pre-fill form if editing existing auth
        if (_authStatus != null && _authStatus!.auths != null && _authStatus!.auths!.isNotEmpty) {
          final firstAuth = _authStatus!.auths!.first; // Assuming editing the first one for simplicity
          _certNumberController.text = firstAuth.certNumber;
          _issueDate = DateTime.tryParse(firstAuth.issueDate);
          _expireDate = DateTime.tryParse(firstAuth.expireDate ?? '');
          _images = List.from(firstAuth.images);
          _selectedAuthType = firstAuth.authType;
        }
      } else {
        _errorMessage = response.message;
      }
    } catch (e) {
      _errorMessage = '加载认证状态失败: ${e.toString()}';
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveAuthInfo() async {
    if (_selectedAuthType == null || _certNumberController.text.isEmpty || _issueDate == null || _images.isEmpty) {
      _showSnackBar('请填写所有必填项并上传图片');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final authInfo = AuthInfo(
        authId: _authStatus?.auths?.isNotEmpty == true ? _authStatus!.auths!.first.authId : 0, // 0 for new
        authType: _selectedAuthType!,
        certNumber: _certNumberController.text,
        issueDate: _issueDate!.toIso8601String().split('T')[0],
        expireDate: _expireDate?.toIso8601String().split('T')[0],
        images: _images,
        status: 0, // 0 for pending status
      );

      final response = await _technicianApi.saveAuthInfo(context, authInfo); // Pass context
      if (response.success) {
        _showSnackBar('认证信息保存成功！');
        _fetchAuthStatus(); // Refresh status
      } else {
        _showSnackBar('保存失败: ${response.message}');
      }
    } catch (e) {
      _showSnackBar('保存失败: ${e.toString()}');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _pickAndUploadImages() async {
    try {
      final List<String> uploaded = await _uploadService.chooseAndUploadImages(context); // Pass context
      setState(() {
        _images.addAll(uploaded);
      });
    } catch (e) {
      _showSnackBar('图片上传失败: ${e.toString()}');
    }
  }

  Future<void> _selectDate(BuildContext context, bool isIssueDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        if (isIssueDate) {
          _issueDate = picked;
        } else {
          _expireDate = picked;
        }
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
        title: const Text('认证中心'),
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
                        onPressed: _fetchAuthStatus,
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
                      Card(
                        margin: const EdgeInsets.only(bottom: 16.0),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('认证状态', style: Theme.of(context).textTheme.titleLarge),
                              const Divider(),
                              Text('当前状态: ${_authStatus?.status == 0 ? '待审核' : (_authStatus?.status == 1 ? '已认证' : '未通过')}'),
                              if (_authStatus?.message != null)
                                Text('消息: ${_authStatus!.message!}'),
                              if (_authStatus?.auths != null && _authStatus!.auths!.isNotEmpty)
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: _authStatus!.auths!.map((auth) => ListTile(
                                    title: Text(
                                      '${auth.authType == 1 ? '健康证' : (auth.authType == 2 ? '技师证' : '营业资格证')} - ${auth.certNumber}',
                                    ),
                                    subtitle: Text('状态: ${auth.status == 0 ? '待审核' : (auth.status == 1 ? '已通过' : '已拒绝')}'),
                                    trailing: const Icon(Icons.arrow_forward_ios),
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => TechnicianAuthDetailPage(authInfo: auth),
                                        ),
                                      );
                                    },
                                  )).toList(),
                                ),
                            ],
                          ),
                        ),
                      ),
                      Text('提交认证信息', style: Theme.of(context).textTheme.titleLarge),
                      const Divider(),
                      DropdownButtonFormField<int>(
                        value: _selectedAuthType,
                        decoration: const InputDecoration(
                          labelText: '认证类型',
                          border: OutlineInputBorder(),
                        ),
                        items: const <DropdownMenuItem<int>>[
                          DropdownMenuItem<int>(value: 1, child: Text('健康证')),
                          DropdownMenuItem<int>(value: 2, child: Text('技师证')),
                          DropdownMenuItem<int>(value: 3, child: Text('营业资格证')),
                        ],
                        onChanged: (int? newValue) {
                          setState(() {
                            _selectedAuthType = newValue;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _certNumberController,
                        decoration: const InputDecoration(
                          labelText: '证书编号',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      GestureDetector(
                        onTap: () => _selectDate(context, true),
                        child: AbsorbPointer(
                          child: TextFormField(
                            controller: TextEditingController(text: _issueDate != null ? "${_issueDate!.year}-${_issueDate!.month.toString().padLeft(2, '0')}-${_issueDate!.day.toString().padLeft(2, '0')}" : ''),
                            decoration: const InputDecoration(
                              labelText: '发证日期',
                              border: OutlineInputBorder(),
                              suffixIcon: Icon(Icons.calendar_today),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      GestureDetector(
                        onTap: () => _selectDate(context, false),
                        child: AbsorbPointer(
                          child: TextFormField(
                            controller: TextEditingController(text: _expireDate != null ? "${_expireDate!.year}-${_expireDate!.month.toString().padLeft(2, '0')}-${_expireDate!.day.toString().padLeft(2, '0')}" : ''),
                            decoration: const InputDecoration(
                              labelText: '过期日期 (可选)',
                              border: OutlineInputBorder(),
                              suffixIcon: Icon(Icons.calendar_today),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text('证书图片', style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8.0,
                        runSpacing: 8.0,
                        children: [
                          ..._images.map((url) => Image.network(url, width: 80, height: 80, fit: BoxFit.cover)).toList(),
                          GestureDetector(
                            onTap: () => _pickAndUploadImages(),
                            child: Container(
                              width: 80,
                              height: 80,
                              color: Colors.grey[200],
                              child: const Icon(Icons.add_a_photo, size: 40, color: Colors.grey),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      ElevatedButton(
                        onPressed: _saveAuthInfo,
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 50),
                        ),
                        child: const Text('提交认证'),
                      ),
                    ],
                  ),
                ),
    );
  }
}
