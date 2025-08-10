import 'package:flutter/material.dart';
import 'package:bookin/features/technician/data/api/technician_api.dart';

class TechnicianSchedulePage extends StatefulWidget {
  const TechnicianSchedulePage({super.key});

  @override
  State<TechnicianSchedulePage> createState() => _TechnicianSchedulePageState();
}

class _TechnicianSchedulePageState extends State<TechnicianSchedulePage> {
  final TechnicianApi _technicianApi = TechnicianApi();
  List<TechnicianSchedule> _schedules = [];
  bool _isLoading = true;
  String? _errorMessage;
  int _selectedWeekday = DateTime.now().weekday % 7; // 0 for Sunday, 1 for Monday, ..., 6 for Saturday

  @override
  void initState() {
    super.initState();
    _fetchSchedule(_selectedWeekday);
  }

  Future<void> _fetchSchedule(int weekday) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final response = await _technicianApi.getSchedule(context, weekday); // Pass context
      if (response.success) {
        _schedules = response.data ?? [];
      } else {
        _errorMessage = response.message;
      }
    } catch (e) {
      _errorMessage = '加载排班数据失败: ${e.toString()}';
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveSchedule() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final response = await _technicianApi.saveSchedule(context, _schedules); // Pass context
      if (response.success) {
        _showSnackBar('排班保存成功！');
      } else {
        _showSnackBar('保存失败: ${response.message}');
      }
    } catch (e) {
      _showSnackBar('保存失败: ${e.toString()}');
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

  String _getWeekdayName(int weekday) {
    switch (weekday) {
      case 0: return '周日';
      case 1: return '周一';
      case 2: return '周二';
      case 3: return '周三';
      case 4: return '周四';
      case 5: return '周五';
      case 6: return '周六';
      default: return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('排班管理'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: DropdownButton<int>(
              value: _selectedWeekday,
              onChanged: (int? newValue) {
                if (newValue != null) {
                  setState(() {
                    _selectedWeekday = newValue;
                  });
                  _fetchSchedule(newValue);
                }
              },
              items: List.generate(7, (index) {
                return DropdownMenuItem<int>(
                  value: index,
                  child: Text(_getWeekdayName(index)),
                );
              }),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(_errorMessage!),
                            ElevatedButton(
                              onPressed: () => _fetchSchedule(_selectedWeekday),
                              child: const Text('重试'),
                            ),
                          ],
                        ),
                      )
                    : _schedules.isEmpty
                        ? const Center(child: Text('暂无排班数据'))
                        : ListView.builder(
                            itemCount: _schedules.length,
                            itemBuilder: (context, index) {
                              final schedule = _schedules[index];
                              return Card(
                                margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                                child: SwitchListTile(
                                  title: Text('${schedule.startTime} - ${schedule.endTime}'),
                                  value: schedule.available,
                                  onChanged: (bool value) {
                                    setState(() {
                                      _schedules[index] = TechnicianSchedule(
                                        weekDay: schedule.weekDay,
                                        startTime: schedule.startTime,
                                        endTime: schedule.endTime,
                                        available: value,
                                      );
                                    });
                                  },
                                ),
                              );
                            },
                          ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: _saveSchedule,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text('保存排班'),
            ),
          ),
        ],
      ),
    );
  }
}
