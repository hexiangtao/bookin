import 'package:flutter/material.dart';
import 'package:bookin/api/technician.dart';
import 'package:bookin/utils/upload_service.dart';

class TechnicianProfileGalleryPage extends StatefulWidget {
  const TechnicianProfileGalleryPage({super.key});

  @override
  State<TechnicianProfileGalleryPage> createState() => _TechnicianProfileGalleryPageState();
}

class _TechnicianProfileGalleryPageState extends State<TechnicianProfileGalleryPage> {
  final TechnicianApi _technicianApi = TechnicianApi();
  final UploadService _uploadService = UploadService();

  List<String> _galleryImages = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchGalleryImages();
  }

  Future<void> _fetchGalleryImages() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final response = await _technicianApi.getGallery(context); // Pass context
      if (response.success) {
        _galleryImages = response.data ?? [];
      } else {
        _errorMessage = response.message;
      }
    } catch (e) {
      _errorMessage = '加载相册失败: ${e.toString()}';
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _pickAndUploadImage() async {
    try {
      final List<String> uploaded = await _uploadService.chooseAndUploadImages(context); // Pass context
      if (uploaded.isNotEmpty) {
        final response = await _technicianApi.saveGalleryPhoto(context, uploaded.first); // Pass context
        if (response.success) {
          _showSnackBar('图片上传成功');
          _fetchGalleryImages(); // Refresh gallery
        } else {
          _showSnackBar('保存失败: ${response.message}');
        }
      } else {
        _showSnackBar('未选择图片或上传失败');
      }
    } catch (e) {
      _showSnackBar('图片上传失败: ${e.toString()}');
    }
  }

  Future<void> _deleteImage(String imageUrl) async {
    // Assuming the API takes the image URL or ID to delete
    // For simplicity, we'll pass the URL as ID for now.
    setState(() {
      _isLoading = true;
    });
    try {
      final response = await _technicianApi.deleteGalleryPhoto(context, imageUrl); // Pass context
      if (response.success) {
        _showSnackBar('图片删除成功');
        _fetchGalleryImages(); // Refresh gallery
      } else {
        _showSnackBar('删除失败: ${response.message}');
      }
    } catch (e) {
      _showSnackBar('删除失败: ${e.toString()}');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _setCover(String imageUrl) async {
    setState(() {
      _isLoading = true;
    });
    try {
      final response = await _technicianApi.setGalleryCover(context, imageUrl); // Pass context
      if (response.success) {
        _showSnackBar('封面设置成功');
        _fetchGalleryImages(); // Refresh gallery
      } else {
        _showSnackBar('设置失败: ${response.message}');
      }
    } catch (e) {
      _showSnackBar('设置失败: ${e.toString()}');
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
        title: const Text('个人相册'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_a_photo),
            onPressed: _pickAndUploadImage,
          ),
        ],
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
                        onPressed: _fetchGalleryImages,
                        child: const Text('重试'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _fetchGalleryImages,
                  child: _galleryImages.isEmpty
                      ? const Center(child: Text('暂无照片，点击右上角添加'))
                      : GridView.builder(
                          padding: const EdgeInsets.all(8.0),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 8.0,
                            mainAxisSpacing: 8.0,
                          ),
                          itemCount: _galleryImages.length,
                          itemBuilder: (context, index) {
                            final imageUrl = _galleryImages[index];
                            return GridTile(
                              child: GestureDetector(
                                onTap: () {
                                  // View full image or show options
                                  showModalBottomSheet(
                                    context: context,
                                    builder: (context) => Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        ListTile(
                                          leading: const Icon(Icons.delete),
                                          title: const Text('删除照片'),
                                          onTap: () {
                                            Navigator.pop(context);
                                            _deleteImage(imageUrl);
                                          },
                                        ),
                                        ListTile(
                                          leading: const Icon(Icons.star),
                                          title: const Text('设为封面'),
                                          onTap: () {
                                            Navigator.pop(context);
                                            _setCover(imageUrl);
                                          },
                                        ),
                                      ],
                                    ),
                                  );
                                },
                                child: Image.network(imageUrl, fit: BoxFit.cover),
                              ),
                            );
                          },
                        ),
                ),
    );
  }
}