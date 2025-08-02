import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bookin/utils/constants.dart';
import 'package:bookin/pages/main_page.dart';
import 'package:bookin/pages/auth/login_page.dart';
import 'package:bookin/pages/splash_page.dart';
import 'package:bookin/providers/user_provider.dart';
import 'package:bookin/providers/app_provider.dart';
import 'package:bookin/widgets/global_overlay.dart'; // Import GlobalOverlay

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => UserProvider()),
        ChangeNotifierProvider(create: (context) => AppProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.APP_NAME,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const SplashPage(), // Set SplashPage as the initial home
      routes: {
        '/home': (context) => const MainPage(),
        '/login': (context) => const LoginPage(),
        // Define other routes as needed
      },
      builder: (context, child) {
        return GlobalOverlay(child: child!); // Wrap the entire app with GlobalOverlay
      },
    );
  }
}