import 'package:flutter/material.dart';
import 'package:bookin/features/shared/services/system_api.dart'; // Assuming system API handles notices

class TechnicianNotificationsPage extends StatefulWidget {
  const TechnicianNotificationsPage({super.key});

  @override
  State<TechnicianNotificationsPage> createState() => _TechnicianNotificationsPageState();
}

class _TechnicianNotificationsPageState extends State<TechnicianNotificationsPage> {
  final SystemApi _systemApi = SystemApi();
  List<Notice> _notices = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchNotices();
  }

  Future<void> _fetchNotices() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final response = await _systemApi.getNotices(context); // Pass context
      if (response.success) {
        _notices = response.data ?? [];
      } else {
        _errorMessage = response.message;
      }
    } catch (e) {
      _errorMessage = '加载通知失败: ${e.toString()}';
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
        title: const Text('通知公告'),
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
                        onPressed: _fetchNotices,
                        child: const Text('重试'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _fetchNotices,
                  child: _notices.isEmpty
                      ? const Center(child: Text('暂无通知公告'))
                      : ListView.builder(
                          itemCount: _notices.length,
                          itemBuilder: (context, index) {
                            final notice = _notices[index];
                            return Card(
                              margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                              child: ListTile(
                                title: Text(notice.title),
                                subtitle: Text(notice.content),
                                trailing: Text(notice.publishDate),
                                onTap: () {
                                  // Navigate to notice detail or mark as read
                                },
                              ),
                            );
                          },
                        ),
                ),
    );
  }
}