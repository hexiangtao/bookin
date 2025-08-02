import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bookin/api/user.dart';
import 'package:bookin/utils/upload_service.dart'; // For avatar upload
import 'package:bookin/providers/user_provider.dart'; // Import UserProvider

class ProfileEditPage extends StatefulWidget {
  const ProfileEditPage({super.key});

  @override
  State<ProfileEditPage> createState() => _ProfileEditPageState();
}

class _ProfileEditPageState extends State<ProfileEditPage> {
  final UploadService _uploadService = UploadService();

  late TextEditingController _nicknameController;
  late TextEditingController _wechatController;
  String? _selectedGender; // For gender selection
  DateTime? _selectedBirthday; // For birthday selection

  String? _avatarUrl; // To store the new avatar URL after upload

  bool _isLoading = false; // Manage local loading state for actions

  @override
  void initState() {
    super.initState();
    // Initialize controllers with current user info from provider
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    _nicknameController = TextEditingController(text: userProvider.userInfo?.nickname);
    _wechatController = TextEditingController(text: userProvider.userInfo?.wechat);
    _selectedGender = userProvider.userInfo?.gender == 1 ? '男' : (userProvider.userInfo?.gender == 2 ? '女' : null);
    if (userProvider.userInfo?.birthday != null) {
      _selectedBirthday = DateTime.tryParse(userProvider.userInfo!.birthday!);
    }
    _avatarUrl = userProvider.userInfo?.avatar;
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    _wechatController.dispose();
    super.dispose();
  }

  Future<void> _updateProfile() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final currentUserId = userProvider.userInfo?.id; // Get current user ID
      final currentPhone = userProvider.userInfo?.phone; // Get current user phone

      if (currentUserId == null || currentPhone == null) {
        _showSnackBar('用户信息缺失，无法更新');
        return;
      }

      final updatedUserInfo = UserInfo(
        id: currentUserId,
        phone: currentPhone,
        nickname: _nicknameController.text,
        avatar: _avatarUrl, // Use the new avatar URL if uploaded
        gender: _selectedGender == '男' ? 1 : (_selectedGender == '女' ? 2 : 0),
        birthday: _selectedBirthday?.toIso8601String().split('T')[0],
        wechat: _wechatController.text,
      );

      await userProvider.updateUserInfo(context, updatedUserInfo);
      _showSnackBar('资料更新成功');
      Navigator.pop(context); // Go back after successful update
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
      final List<String> uploaded = await _uploadService.chooseAndUploadImages(context);
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
        title: const Text('编辑资料'),
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