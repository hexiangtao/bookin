import 'package:flutter/material.dart';
import 'package:bookin/features/technician/data/api/technician_api.dart';
import 'package:bookin/features/teacher/data/api/project_api.dart'; // Import ProjectApi

class TechnicianServiceProjectsPage extends StatefulWidget {
  const TechnicianServiceProjectsPage({super.key});

  @override
  State<TechnicianServiceProjectsPage> createState() => _TechnicianServiceProjectsPageState();
}

class _TechnicianServiceProjectsPageState extends State<TechnicianServiceProjectsPage> {
  final TechnicianApi _technicianApi = TechnicianApi();
  final ProjectApi _projectApi = ProjectApi(); // Initialize ProjectApi
  List<Project> _allProjects = []; // All available projects
  List<String> _selectedProjectIds = []; // IDs of projects offered by this technician
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchServiceProjects();
  }

  Future<void> _fetchServiceProjects() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      // Fetch all available projects using ProjectApi
      final allProjectsResponse = await _projectApi.getRecommendProjects(context, limit: 100); // Pass context
      // Fetch currently selected service projects for this technician
      final selectedProjectsResponse = await _technicianApi.getServiceProjects(context); // Pass context

      if (allProjectsResponse.success) {
        _allProjects = allProjectsResponse.data ?? [];
      } else {
        _errorMessage = allProjectsResponse.message;
      }

      if (selectedProjectsResponse.success) {
        // Assuming selectedProjectsResponse.data is a list of project objects that the technician offers
        _selectedProjectIds = (selectedProjectsResponse.data as List)
            .map((e) => e['id'] as String) // Assuming each item has an 'id' field
            .toList();
      } else {
        _errorMessage = selectedProjectsResponse.message;
      }
    } catch (e) {
      _errorMessage = '加载服务项目失败: ${e.toString()}';
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveServiceProjects() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final response = await _technicianApi.saveServiceProjects(context, _selectedProjectIds); // Pass context
      if (response.success) {
        _showSnackBar('服务项目保存成功！');
        _fetchServiceProjects(); // Refresh list after saving
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
        title: const Text('服务项目管理'),
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
                        onPressed: _fetchServiceProjects,
                        child: const Text('重试'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _fetchServiceProjects,
                  child: Column(
                    children: [
                      Expanded(
                        child: _allProjects.isEmpty
                            ? const Center(child: Text('暂无可用服务项目'))
                            : ListView.builder(
                                itemCount: _allProjects.length,
                                itemBuilder: (context, index) {
                                  final project = _allProjects[index];
                                  return Card(
                                    margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                                    child: CheckboxListTile(
                                      title: Text(project.name),
                                      subtitle: Text('¥${(project.price / 100).toStringAsFixed(2)}'),
                                      value: _selectedProjectIds.contains(project.id.toString()),
                                      onChanged: (bool? value) {
                                        setState(() {
                                          if (value == true) {
                                            _selectedProjectIds.add(project.id.toString());
                                          } else {
                                            _selectedProjectIds.remove(project.id.toString());
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
                          onPressed: _saveServiceProjects,
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 50),
                          ),
                          child: const Text('保存服务项目'),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}