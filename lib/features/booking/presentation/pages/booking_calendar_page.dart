import 'package:flutter/material.dart';
import 'package:bookin/api/booking.dart';
import 'package:bookin/pages/booking/create_booking_page.dart'; // Import create booking page

class BookingCalendarPage extends StatefulWidget {
  final String techId;
  final String projectId;

  const BookingCalendarPage({super.key, required this.techId, required this.projectId});

  @override
  State<BookingCalendarPage> createState() => _BookingCalendarPageState();
}

class _BookingCalendarPageState extends State<BookingCalendarPage> {
  final BookingApi _bookingApi = BookingApi();
  BookingAvailability? _availability;
  bool _isLoading = true;
  String? _errorMessage;
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _fetchAvailability();
  }

  Future<void> _fetchAvailability() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final response = await _bookingApi.checkAvailability(
        context,
        techId: widget.techId,
        projectId: widget.projectId,
        date: _selectedDate.toIso8601String().split('T')[0],
      );
      if (response.success) {
        _availability = response.data;
      } else {
        _errorMessage = response.message;
      }
    } catch (e) {
      _errorMessage = '加载可用时间失败: ${e.toString()}';
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
      _fetchAvailability();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('选择预约时间'),
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
                        onPressed: _fetchAvailability,
                        child: const Text('重试'),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Date Selection
                      ListTile(
                        title: Text('选择日期: ${_selectedDate.toLocal().toString().split(' ')[0]}'),
                        trailing: const Icon(Icons.calendar_today),
                        onTap: () => _selectDate(context),
                      ),
                      const Divider(),

                      // Available Dates (if provided by API)
                      if (_availability?.availableDates != null && _availability!.availableDates.isNotEmpty)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('可用日期', style: Theme.of(context).textTheme.titleMedium),
                            Wrap(
                              spacing: 8.0,
                              runSpacing: 4.0,
                              children: _availability!.availableDates.map((dateItem) {
                                return ChoiceChip(
                                  label: Text(dateItem.date),
                                  selected: dateItem.date == _selectedDate.toIso8601String().split('T')[0],
                                  onSelected: (selected) {
                                    if (selected) {
                                      setState(() {
                                        _selectedDate = DateTime.parse(dateItem.date);
                                      });
                                      _fetchAvailability();
                                    }
                                  },
                                );
                              }).toList(),
                            ),
                            const Divider(),
                          ],
                        ),

                      // Time Slots
                      Text('可选时间段', style: Theme.of(context).textTheme.titleMedium),
                      if (_availability?.timeSlots != null && _availability!.timeSlots.isNotEmpty)
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 8.0,
                            mainAxisSpacing: 8.0,
                            childAspectRatio: 2.5,
                          ),
                          itemCount: _availability!.timeSlots.length,
                          itemBuilder: (context, index) {
                            final slot = _availability!.timeSlots[index];
                            return ChoiceChip(
                              label: Text(slot.startTime),
                              selected: false, // Implement selection logic if needed
                              onSelected: slot.isAvailable
                                  ? (selected) {
                                      // Handle time slot selection
                                      // Navigate to order creation page with selected date and time
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => CreateBookingPage(
                                            techId: widget.techId,
                                            projectId: widget.projectId,
                                            date: _selectedDate.toIso8601String().split('T')[0],
                                            startTime: slot.startTime,
                                          ),
                                        ),
                                      );
                                    }
                                  : null,
                              selectedColor: Colors.blueAccent,
                              disabledColor: Colors.grey[300],
                              labelStyle: TextStyle(
                                color: slot.isAvailable ? Colors.black : Colors.grey,
                              ),
                              backgroundColor: slot.isAvailable ? Colors.white : Colors.grey[200],
                            );
                          },
                        )
                      else
                        const Center(child: Text('该日期暂无可用时间段')),
                    ],
                  ),
                ),
    );
  }
}