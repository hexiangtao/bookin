import 'package:flutter/material.dart';
import 'package:bookin/features/technician/data/api/technician_api.dart';
import 'package:bookin/shared/services/upload_service.dart';

class TechnicianProfileEditPage extends StatefulWidget {
  const TechnicianProfileEditPage({super.key});

  @override
  State<TechnicianProfileEditPage> createState() => _TechnicianProfileEditPageState();
}

class _TechnicianProfileEditPageState extends State<TechnicianProfileEditPage> {
  final TechnicianApi _technicianApi = TechnicianApi();
  final UploadService _uploadService = UploadService();

  TechnicianInfo? _technicianInfo;
  bool _isLoading = true;
  String? _errorMessage;


  final TextEditingController _nicknameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _wechatController = TextEditingController();
  final TextEditingController _experienceController = TextEditingController();
  final TextEditingController _tagsController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  String? _selectedGender; // For gender selection
  DateTime? _selectedBirthday; // For birthday selection

  String? _avatarUrl; // To store the new avatar URL after upload

  @override
  void initState() {
    super.initState();
    _fetchTechnicianInfo();
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    _phoneController.dispose();
    _wechatController.dispose();
    _experienceController.dispose();
    _tagsController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _fetchTechnicianInfo() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final response = await _technicianApi.getProfileDetail(context); // Pass context
      if (response.success) {
        _technicianInfo = response.data;
        _nicknameController.text = _technicianInfo?.nickname ?? '';
        _phoneController.text = _technicianInfo?.phone ?? '';
        _wechatController.text = _technicianInfo?.wechat ?? '';
        _experienceController.text = _technicianInfo?.experience ?? '';
        _tagsController.text = _technicianInfo?.tags ?? '';
        _descriptionController.text = _technicianInfo?.description ?? '';
        _selectedGender = _technicianInfo?.gender == 1 ? '男' : (_technicianInfo?.gender == 2 ? '女' : null);
        if (_technicianInfo?.birthday != null) {
          _selectedBirthday = DateTime.tryParse(_technicianInfo!.birthday!);
        }
        _avatarUrl = _technicianInfo?.avatar;
      } else {
        _errorMessage = response.message;
      }
    } catch (e) {
      _errorMessage = '加载技师信息失败: ${e.toString()}';
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _updateProfile() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final updatedTechnicianInfo = TechnicianInfo(
        id: _technicianInfo?.id ?? '',
        nickname: _nicknameController.text,
        phone: _phoneController.text,
        wechat: _wechatController.text,
        experience: _experienceController.text,
        tags: _tagsController.text,
        description: _descriptionController.text,
        avatar: _avatarUrl,
        gender: _selectedGender == '男' ? 1 : (_selectedGender == '女' ? 2 : 0),
        birthday: _selectedBirthday?.toIso8601String().split('T')[0],
      );

      final response = await _technicianApi.updateProfile(context, updatedTechnicianInfo); // Pass context
      if (response.success) {
        _showSnackBar('资料更新成功');
        _fetchTechnicianInfo(); // Refresh data after update
      } else {
        _showSnackBar('更新失败: ${response.message}');
      }
    } catch (e) {
      _showSnackBar('更新失败: ${e.toString()}');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _pickAndUploadAvatar() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final List<String> uploaded = await _uploadService.chooseAndUploadImages(context); // Pass context
      if (uploaded.isNotEmpty) {
        setState(() {
          _avatarUrl = uploaded.first;
        });
        _showSnackBar('头像上传成功');
      } else {
        _showSnackBar('未选择图片或上传失败');
      }
    } catch (e) {
      _showSnackBar('头像上传失败: ${e.toString()}');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _selectBirthday(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedBirthday ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedBirthday) {
      setState(() {
        _selectedBirthday = picked;
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
        title: const Text('编辑个人资料'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                        child: GestureDetector(
                          onTap: _pickAndUploadAvatar,
                          child: CircleAvatar(
                            radius: 60,
                            backgroundImage: _avatarUrl != null
                                ? NetworkImage(_avatarUrl!)
                                : null,
                            child: _avatarUrl == null
                                ? const Icon(Icons.camera_alt, size: 60)
                                : null,
                          ),
                        ),
                      ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _nicknameController,
                    decoration: const InputDecoration(
                      labelText: '昵称',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _selectedGender,
                    decoration: const InputDecoration(
                      labelText: '性别',
                      border: OutlineInputBorder(),
                    ),
                    items: const <String>['男', '女'].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedGender = newValue;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: () => _selectBirthday(context),
                    child: AbsorbPointer(
                      child: TextFormField(
                        controller: TextEditingController(text: _selectedBirthday != null ? "${_selectedBirthday!.year}-${_selectedBirthday!.month.toString().padLeft(2, '0')}-${_selectedBirthday!.day.toString().padLeft(2, '0')}" : ''),
                        decoration: const InputDecoration(
                          labelText: '生日',
                          border: OutlineInputBorder(),
                          suffixIcon: Icon(Icons.calendar_today),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _wechatController,
                    decoration: const InputDecoration(
                      labelText: '微信号',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _experienceController,
                    decoration: const InputDecoration(
                      labelText: '工作年限',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _tagsController,
                    decoration: const InputDecoration(
                      labelText: '擅长领域 (逗号分隔)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _descriptionController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: '个人简介',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: _updateProfile,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: const Text('保存'),
                  ),
                ],
              ),
            ),
    );
  }
}