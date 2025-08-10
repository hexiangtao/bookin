import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:bookin/features/shared/services/base_api.dart';

class UploadService {
  final ImagePicker _picker = ImagePicker();

  /// Choose images from gallery or camera and upload them.
  /// Options like `count`, `sizeType`, `sourceType`, `showLoading`, `onProgress`
  /// are mapped to `image_picker` and `BaseApi.upload` capabilities.
  Future<List<String>> chooseAndUploadImages(
    BuildContext context, {
    int imageQuality = 80,
    double? maxWidth,
    double? maxHeight,
    List<ImageSource> sourceTypes = const [ImageSource.camera, ImageSource.gallery],
    // For progress, you'd typically pass a callback or use a StreamController
    // Function(double progress, int completed, int total)? onProgress,
  }) async {
    final List<XFile> pickedFiles = [];
    if (sourceTypes.contains(ImageSource.camera) && sourceTypes.contains(ImageSource.gallery)) {
      // Allow user to choose source
      final XFile? file = await _picker.pickImage(source: ImageSource.gallery, imageQuality: imageQuality, maxWidth: maxWidth, maxHeight: maxHeight);
      if (file != null) pickedFiles.add(file);
    } else if (sourceTypes.contains(ImageSource.camera)) {
      final XFile? file = await _picker.pickImage(source: ImageSource.camera, imageQuality: imageQuality, maxWidth: maxWidth, maxHeight: maxHeight);
      if (file != null) pickedFiles.add(file);
    } else if (sourceTypes.contains(ImageSource.gallery)) {
      final XFile? file = await _picker.pickImage(source: ImageSource.gallery, imageQuality: imageQuality, maxWidth: maxWidth, maxHeight: maxHeight);
      if (file != null) pickedFiles.add(file);
    }

    final List<String> uploadedUrls = [];
    for (final XFile file in pickedFiles) {
      // Check if context is still mounted before async operation
      if (!context.mounted) break;
      
      // Assuming a generic upload endpoint and that the backend returns the URL directly
      // You might need to adjust the path and name based on your backend API.
      final response = await BaseApi.upload(context, '/common/upload', file.path, 'file', {});
      if (response.success && response.data != null) {
        uploadedUrls.add(response.data!);
      } else {
        // Handle individual upload failures, e.g., show a toast
        debugPrint('Failed to upload ${file.name}: ${response.message}');
      }
    }
    return uploadedUrls;
  }

  // You can add more specific upload methods here, e.g., uploadVideo, uploadFile
}

final uploadService = UploadService();
