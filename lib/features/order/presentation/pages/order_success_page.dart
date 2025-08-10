import 'package:flutter/material.dart';

class OrderSuccessPage extends StatelessWidget {
  final String orderId;

  const OrderSuccessPage({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('订单成功'),
        automaticallyImplyLeading: false, // Hide back button
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.check_circle_outline,
                color: Colors.green,
                size: 100,
              ),
              const SizedBox(height: 20),
              const Text(
                '您的订单已成功提交！',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                '订单号: $orderId',
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  // Navigate back to home or order list
                  Navigator.popUntil(context, ModalRoute.withName('/')); // Go back to home
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text('返回首页'),
              ),
              const SizedBox(height: 10),
              OutlinedButton(
                onPressed: () {
                  // Navigate to order detail page
                  // Navigator.push(context, MaterialPageRoute(builder: (context) => OrderDetailPage(orderId: orderId)));
                },
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text('查看订单详情'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
