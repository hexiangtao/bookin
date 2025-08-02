import 'package:flutter/material.dart';
import 'package:bookin/api/comment.dart';
import 'package:bookin/utils/upload_service.dart';

class CommentSubmitPage extends StatefulWidget {
  final String orderId;
  final String targetId; // Project or Technician ID
  final String targetType; // 'project' or 'tech'

  const CommentSubmitPage({
    super.key,
    required this.orderId,
    required this.targetId,
    required this.targetType,
  });

  @override
  State<CommentSubmitPage> createState() => _CommentSubmitPageState();
}

class _CommentSubmitPageState extends State<CommentSubmitPage> {
  final CommentApi _commentApi = CommentApi();
  final UploadService _uploadService = UploadService();

  int _rating = 5; // Default rating
  final TextEditingController _contentController = TextEditingController();
  final List<String> _imageUrls = [];

  bool _isLoading = false;

  Future<void> _submitComment() async {
    if (_contentController.text.isEmpty) {
      _showSnackBar('评论内容不能为空');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final submitCommentReq = SubmitCommentReq(
        orderId: widget.orderId,
        targetId: widget.targetId,
        targetType: widget.targetType,
        rating: _rating,
        content: _contentController.text,
        images: _imageUrls,
      );

      final response = await _commentApi.submitComment(context, submitCommentReq); // Pass context
      if (response.success) {
        _showSnackBar('评论提交成功！');
        Navigator.pop(context, true); // Pop with true to indicate success
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
        title: const Text('发表评价'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('评分', style: Theme.of(context).textTheme.titleMedium),
                  Row(
                    children: List.generate(5, (index) {
                      return IconButton(
                        icon: Icon(
                          index < _rating ? Icons.star : Icons.star_border,
                          color: Colors.amber,
                          size: 30,
                        ),
                        onPressed: () {
                          setState(() {
                            _rating = index + 1;
                          });
                        },
                      );
                    }),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _contentController,
                    maxLines: 5,
                    decoration: const InputDecoration(
                      labelText: '评论内容',
                      hintText: '请写下您的评价...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text('上传图片', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8.0,
                    runSpacing: 8.0,
                    children: [
                      ..._imageUrls.map((url) => Image.network(url, width: 80, height: 80, fit: BoxFit.cover)).toList(),
                      GestureDetector(
                        onTap: _pickAndUploadImages,
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
                    onPressed: _submitComment,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: const Text('提交评价'),
                  ),
                ],
              ),
            ),
    );
  }
}