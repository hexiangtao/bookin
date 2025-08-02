import 'package:flutter/material.dart';
import 'package:bookin/api/feedback.dart';
import 'package:bookin/utils/upload_service.dart';

class FeedbackPage extends StatefulWidget {
  const FeedbackPage({super.key});

  @override
  State<FeedbackPage> createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  final FeedbackApi _feedbackApi = FeedbackApi();
  final UploadService _uploadService = UploadService();

  final TextEditingController _contentController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  List<FeedbackType> _feedbackTypes = [];
  FeedbackType? _selectedFeedbackType;
  List<String> _imageUrls = [];

  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchFeedbackTypes();
  }

  @override
  void dispose() {
    _contentController.dispose();
    _contactController.dispose();
    super.dispose();
  }

  Future<void> _fetchFeedbackTypes() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final response = await _feedbackApi.getTypes(context); // Pass context
      if (response.success) {
        _feedbackTypes = response.data ?? [];
        if (_feedbackTypes.isNotEmpty) {
          _selectedFeedbackType = _feedbackTypes.first;
        }
      } else {
        _errorMessage = response.message;
      }
    } catch (e) {
      _errorMessage = '加载反馈类型失败: ${e.toString()}';
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _submitFeedback() async {
    if (_selectedFeedbackType == null || _contentController.text.isEmpty || _contactController.text.isEmpty) {
      _showSnackBar('请填写所有必填项');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final submitFeedbackReq = SubmitFeedbackReq(
        typeCode: _selectedFeedbackType!.code,
        typeName: _selectedFeedbackType!.name,
        content: _contentController.text,
        contact: _contactController.text,
        userId: 'current_user_id', // Replace with actual user ID
        images: _imageUrls,
      );

      final response = await _feedbackApi.submit(context, submitFeedbackReq); // Pass context
      if (response.success) {
        _showSnackBar('反馈提交成功！');
        Navigator.pop(context); // Go back after submission
      } else {
        _showSnackBar('提交失败: ${response.message}');
      }
    } catch (e) {
      _showSnackBar('提交失败: ${e.toString()}');
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
        _imageUrls.addAll(uploaded);
      });
    } catch (e) {
      _showSnackBar('图片上传失败: ${e.toString()}');
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
        title: const Text('意见反馈'),
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
                        onPressed: _fetchFeedbackTypes,
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
                      DropdownButtonFormField<FeedbackType>(
                        value: _selectedFeedbackType,
                        decoration: const InputDecoration(
                          labelText: '反馈类型',
                          border: OutlineInputBorder(),
                        ),
                        items: _feedbackTypes.map((type) {
                          return DropdownMenuItem<FeedbackType>(
                            value: type,
                            child: Text(type.name),
                          );
                        }).toList(),
                        onChanged: (FeedbackType? newValue) {
                          setState(() {
                            _selectedFeedbackType = newValue;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _contentController,
                        maxLines: 5,
                        decoration: const InputDecoration(
                          labelText: '反馈内容',
                          hintText: '请详细描述您的问题或建议...',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text('上传图片 (可选)', style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8.0,
                        runSpacing: 8.0,
                        children: [
                          ..._imageUrls.map((url) => Image.network(url, width: 80, height: 80, fit: BoxFit.cover)).toList(),
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
                      const SizedBox(height: 16),
                      TextField(
                        controller: _contactController,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                          labelText: '联系方式 (手机号/微信)',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 32),
                      ElevatedButton(
                        onPressed: _submitFeedback,
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 50),
                        ),
                        child: const Text('提交反馈'),
                      ),
                    ],
                  ),
                ),
    );
  }
}