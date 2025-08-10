import 'package:flutter/material.dart';
import 'package:bookin/features/home/presentation/pages/home_page.dart';
import 'package:bookin/features/order/presentation/pages/order_list_page.dart';
import 'package:bookin/features/user/presentation/pages/user_page.dart';
import 'package:bookin/features/technician/presentation/pages/technician_service_cities_page.dart';
import 'package:bookin/features/technician/presentation/pages/technician_dashboard_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;
  
  final List<Widget> _pages = [
    const HomePage(),
    const OrderListPage(),
    const TechnicianDashboardPage(),
    const UserPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: '首页',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt),
            label: '订单',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.work),
            label: '技师',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: '我的',
          ),
        ],
      ),
    );
  }
}