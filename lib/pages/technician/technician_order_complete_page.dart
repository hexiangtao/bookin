import 'package:flutter/material.dart';
import 'package:bookin/api/technician.dart';
import 'package:bookin/api/order_operations.dart';
import 'package:bookin/api/order_constants.dart';
import 'package:bookin/utils/upload_service.dart';
// import 'package:bookin/utils/location_service.dart'; // Assuming location service is available

class TechnicianOrderCompletePage extends StatefulWidget {
  final String orderId;

  const TechnicianOrderCompletePage({super.key, required this.orderId});

  @override
  State<TechnicianOrderCompletePage> createState() => _TechnicianOrderCompletePageState();
}

class _TechnicianOrderCompletePageState extends State<TechnicianOrderCompletePage> {

  final UploadService _uploadService = UploadService();

  final TextEditingController _remarkController = TextEditingController();
  final List<String> _photoUrls = [];

  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _remarkController.dispose();
    super.dispose();
  }

  Future<void> _completeService() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // In a real app, you'd get the actual location here
      // final position = await locationService.getLocation(context); // Pass context
      // final location = {'latitude': position.latitude.toString(), 'longitude': position.longitude.toString()};
      final location = {'latitude': '0.0', 'longitude': '0.0'}; // Placeholder location

      // Assuming executeOrderOperation handles the API call and UI feedback
      // This is a simplified call, actual implementation might need more parameters
      await executeOrderOperation(
        context, // Pass context
        order: Order(orderId: widget.orderId, status: NewOrderStatus.SERVICE.code, technicianOperate: TechnicianOperate.START_SERVICE.code), // Mock order for operation
        operateType: TechnicianOperate.COMPLETE_SERVICE,
        location: location,
        remark: _remarkController.text,
        photoUrls: _photoUrls,
      );

      _showSnackBar('服务完成提交成功！');
      Navigator.pop(context, true); // Pop with true to indicate success
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
        _photoUrls.addAll(uploaded);
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
        title: const Text('完成服务'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('订单号: ${widget.orderId}', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _remarkController,
                    maxLines: 5,
                    decoration: const InputDecoration(
                      labelText: '服务备注 (可选)',
                      hintText: '请填写服务过程中的备注信息...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text('上传服务照片 (可选)', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8.0,
                    runSpacing: 8.0,
                    children: [
                      ..._photoUrls.map((url) => Image.network(url, width: 80, height: 80, fit: BoxFit.cover)).toList(),
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
                    onPressed: _completeService,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: const Text('确认完成服务'),
                  ),
                ],
              ),
            ),
    );
  }
}
