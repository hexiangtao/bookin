import 'package:flutter/material.dart';
import 'package:bookin/features/technician/data/api/technician_api.dart';
import 'package:bookin/features/shared/services/common_api.dart'; // Import CommonApi

class TechnicianServiceCitiesPage extends StatefulWidget {
  const TechnicianServiceCitiesPage({super.key});

  @override
  State<TechnicianServiceCitiesPage> createState() => _TechnicianServiceCitiesPageState();
}

class _TechnicianServiceCitiesPageState extends State<TechnicianServiceCitiesPage> {
  final TechnicianApi _technicianApi = TechnicianApi();
  final CommonApi _commonApi = CommonApi(); // Initialize CommonApi
  List<String> _availableCities = [];
  List<String> _selectedCities = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchServiceCities();
  }

  Future<void> _fetchServiceCities() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      // Fetch all available cities using CommonApi
      final allCitiesResponse = await _commonApi.getCityList(context); // Pass context
      // Fetch currently selected service cities for this technician
      final selectedCitiesResponse = await _technicianApi.getServiceCities(context); // Pass context

      if (allCitiesResponse.success) {
        _availableCities = allCitiesResponse.data?.cityList.map((e) => e.name).toList() ?? []; // Extract city names
      } else {
        _errorMessage = allCitiesResponse.message;
      }

      if (selectedCitiesResponse.success) {
        // Assuming selectedCitiesResponse.data is a list of city names/codes
        _selectedCities = selectedCitiesResponse.data ?? [];
      } else {
        _errorMessage = selectedCitiesResponse.message;
      }
    } catch (e) {
      _errorMessage = '加载服务城市失败: ${e.toString()}';
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveServiceCities() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final response = await _technicianApi.saveServiceCities(context, _selectedCities); // Pass context
      if (response.success) {
        _showSnackBar('服务城市保存成功！');
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('服务城市管理'),
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
                        onPressed: _fetchServiceCities,
                        child: const Text('重试'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _fetchServiceCities,
                  child: Column(
                    children: [
                      Expanded(
                        child: _availableCities.isEmpty
                            ? const Center(child: Text('暂无城市数据'))
                            : ListView.builder(
                                itemCount: _availableCities.length,
                                itemBuilder: (context, index) {
                                  final city = _availableCities[index];
                                  return Card(
                                    margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                                    child: CheckboxListTile(
                                      title: Text(city),
                                      value: _selectedCities.contains(city),
                                      onChanged: (bool? value) {
                                        setState(() {
                                          if (value == true) {
                                            _selectedCities.add(city);
                                          } else {
                                            _selectedCities.remove(city);
                                          }
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
                          onPressed: _saveServiceCities,
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 50),
                          ),
                          child: const Text('保存服务城市'),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}
