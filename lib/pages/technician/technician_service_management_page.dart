import 'package:flutter/material.dart';
import 'package:bookin/api/technician.dart';
import 'package:bookin/api/project.dart'; // Assuming Project model is defined here

class TechnicianServiceManagementPage extends StatefulWidget {
  const TechnicianServiceManagementPage({super.key});

  @override
  State<TechnicianServiceManagementPage> createState() => _TechnicianServiceManagementPageState();
}

class _TechnicianServiceManagementPageState extends State<TechnicianServiceManagementPage> {
  final TechnicianApi _technicianApi = TechnicianApi();
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
      // Fetch all available projects (assuming a general API for all projects)
      // For now, using a placeholder or assuming it comes from another API like ProjectApi.getRecommendProjects
      // In a real app, you might have a dedicated API for all projects.
      // The original JS `getServiceProjects` in technician.js returns a generic list, so we'll adapt.
      final allProjectsResponse = await _technicianApi.getServiceProjects(context); 
      
      if (allProjectsResponse.success) {
        // Assuming the API returns a list of maps, each representing a project
        _allProjects = (allProjectsResponse.data as List).map((e) => Project.fromJson(e as Map<String, dynamic>)).toList();
        // Filter out projects that are already selected by the technician
        _selectedProjectIds = _allProjects.where((project) => project.tag == 'selected').map((project) => project.id.toString()).toList(); // Assuming a 'selected' tag or similar from backend
      } else {
        _errorMessage = allProjectsResponse.message;
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
      final response = await _technicianApi.saveServiceProjects(context, _selectedProjectIds);
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