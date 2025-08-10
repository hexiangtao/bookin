import 'package:flutter/material.dart';

class AppProvider with ChangeNotifier {
  bool _isAppLoading = false;
  String? _globalMessage;

  bool get isAppLoading => _isAppLoading;
  String? get globalMessage => _globalMessage;

  void setAppLoading(bool isLoading) {
    _isAppLoading = isLoading;
    notifyListeners();
  }

  void setGlobalMessage(String? message) {
    _globalMessage = message;
    notifyListeners();
  }

  // Example: A method to show a global loading indicator
  void showGlobalLoading() {
    setAppLoading(true);
    setGlobalMessage('加载中...');
  }

  // Example: A method to hide the global loading indicator
  void hideGlobalLoading() {
    setAppLoading(false);
    setGlobalMessage(null);
  }

  // Example: A method to show a global error message
  void showGlobalError(String message) {
    setAppLoading(false);
    setGlobalMessage(message);
  }
}
