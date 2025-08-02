import 'package:geolocator/geolocator.dart';

class LocationService {
  /// Get the current location.
  /// Options like `forceLocation` and `showLoading` are UI/platform-specific
  /// and are handled at the UI layer or by the plugin itself.
  Future<Position> getLocation({
    bool forceLocation = false, // Not directly used by geolocator, but kept for conceptual mapping
    bool showLoading = false, // UI concern, not handled here
  }) async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the 
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
        'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition();
  }

  /// Format location error messages.
  String formatLocationError(dynamic error) {
    if (error is LocationServiceDisabledException) {
      return '定位服务未开启，请检查设备设置。';
    } else if (error is PermissionDeniedException) {
      return '定位权限被拒绝，请在设置中授予权限。';
    } else if (error is Exception) {
      return '获取位置失败: ${error.toString()}';
    }
    return '获取位置失败: 未知错误';
  }
}

final locationService = LocationService();
