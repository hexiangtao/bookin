import 'package:flutter/material.dart';
// Assuming a Message model and API for fetching messages
// import 'package:bookin/api/message.dart'; // You would need to create this API file

class TechnicianMessagesPage extends StatefulWidget {
  const TechnicianMessagesPage({super.key});

  @override
  State<TechnicianMessagesPage> createState() => _TechnicianMessagesPageState();
}

class _TechnicianMessagesPageState extends State<TechnicianMessagesPage> {
  // final MessageApi _messageApi = MessageApi(); // Initialize your MessageApi
  // List<Message> _messages = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchMessages();
  }

  Future<void> _fetchMessages() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      // Replace with actual API call to fetch messages
      // final response = await _messageApi.getMessages(context); // Pass context
      // if (response.success) {
      //   _messages = response.data ?? [];
      // } else {
      //   _errorMessage = response.message;
      // }
      await Future.delayed(const Duration(seconds: 1)); // Simulate network delay
      // Mock data
      // _messages = List.generate(10, (index) => Message(id: 'msg_$index', title: '消息标题 $index', content: '这是第 $index 条消息内容。', time: '2023-01-01'));
    } catch (e) {
      _errorMessage = '加载消息失败: ${e.toString()}';
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
        title: const Text('消息中心'),
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
                        onPressed: _fetchMessages,
                        child: const Text('重试'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _fetchMessages,
                  child: ListView.builder(
                    itemCount: 5, // _messages.length,
                    itemBuilder: (context, index) {
                      // final message = _messages[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                        child: ListTile(
                          title: Text('消息标题 ${index + 1}'), // message.title
                          subtitle: Text('这是第 ${index + 1} 条消息内容。'), // message.content
                          trailing: Text('2023-01-01'), // message.time
                          onTap: () {
                            // Navigate to message detail
                          },
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
