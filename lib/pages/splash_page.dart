import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bookin/pages/auth/login_page.dart';
import 'package:bookin/pages/main_page.dart';
import 'package:bookin/providers/user_provider.dart';
import 'package:bookin/utils/storage_service.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatusAndNavigate();
  }

  Future<void> _checkLoginStatusAndNavigate() async {
    // Simulate some loading time
    await Future.delayed(const Duration(seconds: 2)); 

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    
    // First check if we have a token stored locally
    final token = await StorageService.getToken();
    
    if (token != null && token.isNotEmpty) {
      // We have a token, try to fetch user info to verify it's still valid
      try {
        await userProvider.fetchUserInfo(context);
        // If successful, navigate to MainPage
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const MainPage()),
          );
        }
        return;
      } catch (e) {
        // Token is expired or invalid, clear it and continue to login
        print('Token expired or invalid: $e');
        await StorageService.removeToken();
        await StorageService.removeUserInfo();
      }
    }
    
    // No valid token, navigate to LoginPage
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 20),
            Text('加载中...'),
          ],
        ),
      ),
    );
  }
}