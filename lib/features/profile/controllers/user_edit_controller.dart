import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/models/user_model.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/services/user_service.dart';
import '../../../core/config/app_config.dart';
import '../../../core/utils/toast_util.dart';
import '../services/avatar_upload_service.dart';
import 'profile_controller.dart';

class UserEditController extends GetxController {
  // 用户信息
  final Rx<UserModel?> userInfo = Rx<UserModel?>(null);
  
  // 加载状态
  final RxBool isLoading = false.obs;
  final RxBool isSaving = false.obs;
  
  // 编辑状态
  final RxBool hasChanges = false.obs;
  
  // 表单控制器
  final TextEditingController nicknameController = TextEditingController();
  final TextEditingController bioController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  
  // 响应式表单数据
  final RxString nickname = ''.obs;
  final RxString bio = ''.obs;
  
  // 头像相关
  final Rx<File?> selectedAvatar = Rx<File?>(null);
  final RxString avatarUrl = ''.obs;
  
  // 性别选择
  final RxInt selectedGender = 0.obs; // 0: 未设置, 1: 男, 2: 女
  
  // 生日选择
  final Rx<DateTime?> selectedBirthday = Rx<DateTime?>(null);
  
  // 隐私设置
  final RxBool showPhone = true.obs;
  final RxBool showEmail = true.obs;
  final RxBool allowSearch = true.obs;
  
  // 通知设置
  final RxBool pushNotification = true.obs;
  final RxBool smsNotification = true.obs;
  final RxBool emailNotification = false.obs;
  final RxBool marketingNotification = false.obs;
  
  // 服务实例
  final UserService _userService = UserService.instance;
  late final AvatarUploadService _avatarUploadService;
  final ImagePicker _imagePicker = ImagePicker();
  
  @override
  void onInit() {
    super.onInit();
    _avatarUploadService = Get.find<AvatarUploadService>();
    _loadUserInfo();
    _setupTextControllerListeners();
    _loadPrivacySettings();
    _loadNotificationSettings();
  }
  
  @override
  void onClose() {
    nicknameController.dispose();
    bioController.dispose();
    emailController.dispose();
    super.onClose();
  }
  
  /// 加载用户信息
  Future<void> _loadUserInfo() async {
    isLoading.value = true;
    try {
      // 先从本地缓存获取
      final cachedUser = StorageService().getUserInfo();
      if (cachedUser != null) {
        _updateUserInfo(cachedUser);
      }
      
      // 从服务器获取最新信息
      final result = await _userService.getUserInfo(refresh: true);
      if (result['success'] == true && result['data'] != null) {
        final data = result['data'] as Map<String, dynamic>;
        if (data['userInfo'] != null) {
          final user = UserModel.fromJson(data['userInfo']);
          _updateUserInfo(user);
        }
      }
    } catch (e) {
      ToastUtil.showError('加载用户信息失败: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }
  
  /// 更新用户信息到界面
  void _updateUserInfo(UserModel user) {
    userInfo.value = user;
    nicknameController.text = user.nickname;
    nickname.value = user.nickname;
    bioController.text = user.bio ?? '';
    bio.value = user.bio ?? '';
    emailController.text = user.email ?? '';
    avatarUrl.value = user.avatar ?? '';
    selectedGender.value = user.gender;
    
    // 解析生日
    if (user.birthday != null && user.birthday!.isNotEmpty) {
      try {
        selectedBirthday.value = DateTime.parse(user.birthday!);
      } catch (e) {
        print('解析生日失败: ${e.toString()}');
      }
    }
    
    // 更新隐私和通知设置
    if (user.preferences != null) {
      pushNotification.value = user.preferences!.pushNotification;
      smsNotification.value = user.preferences!.smsNotification;
      emailNotification.value = user.preferences!.emailNotification;
      marketingNotification.value = user.preferences!.marketingNotification;
    }
    
    hasChanges.value = false;
  }
  
  /// 设置文本控制器监听器
  void _setupTextControllerListeners() {
    nicknameController.addListener(() {
      nickname.value = nicknameController.text;
      _checkForChanges();
    });
    
    bioController.addListener(() {
      bio.value = bioController.text;
      _checkForChanges();
    });
    
    emailController.addListener(() {
      _checkForChanges();
    });
  }
  
  /// 检查是否有变更
  void _checkForChanges() {
    if (userInfo.value == null) return;
    
    final user = userInfo.value!;
    bool changed = false;
    
    if (nicknameController.text != user.nickname) changed = true;
    if (emailController.text != (user.email ?? '')) changed = true;
    if (selectedGender.value != user.gender) changed = true;
    if (selectedAvatar.value != null) changed = true;
    
    // 检查生日变更
    final currentBirthday = selectedBirthday.value;
    final originalBirthday = user.birthday != null && user.birthday!.isNotEmpty 
        ? DateTime.tryParse(user.birthday!) : null;
    if (currentBirthday != originalBirthday) changed = true;
    
    hasChanges.value = changed;
  }
  
  /// 选择头像
  Future<void> selectAvatar() async {
    try {
      final result = await Get.bottomSheet(
        Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                '选择头像',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: _buildAvatarOption(
                      icon: Icons.camera_alt,
                      title: '拍照',
                      onTap: () => Get.back(result: ImageSource.camera),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildAvatarOption(
                      icon: Icons.photo_library,
                      title: '相册',
                      onTap: () => Get.back(result: ImageSource.gallery),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
        backgroundColor: Colors.transparent,
      );
      
      if (result != null) {
        await _pickAndUploadAvatar(result);
      }
    } catch (e) {
      ToastUtil.showError('选择头像失败: ${e.toString()}');
    }
  }
  
  /// 选择并上传头像
  Future<void> _pickAndUploadAvatar(ImageSource source) async {
    try {
      isLoading.value = true;
      
      // 选择图片
      final XFile? image = await _imagePicker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 80,
      );
      
      if (image != null) {
        final imageFile = File(image.path);
        
        // 验证图片文件
        await _avatarUploadService.validateImageFile(imageFile);
        
        // 压缩图片（如果需要）
        final compressedFile = await _avatarUploadService.compressImage(imageFile);
        
        // 上传头像
        final uploadedAvatarUrl = await _avatarUploadService.uploadAvatar(compressedFile);
        
        // 更新本地状态
        selectedAvatar.value = compressedFile;
        avatarUrl.value = uploadedAvatarUrl;
        _checkForChanges();
        
        ToastUtil.showSuccess('头像上传成功');
        if (AppConfig.enableApiLog) {
          print('📸 头像上传成功: $uploadedAvatarUrl');
        }
      }
    } catch (e) {
      if (AppConfig.enableApiLog) {
        print('❌ 头像上传失败: $e');
      }
      ToastUtil.showError('头像上传失败: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }
  
  /// 构建头像选择选项
  Widget _buildAvatarOption({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 32,
              color: Colors.grey[600],
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  /// 选择性别
  void selectGender(int gender) {
    selectedGender.value = gender;
    _checkForChanges();
  }
  
  /// 选择生日
  Future<void> selectBirthday() async {
    final DateTime? picked = await showDatePicker(
      context: Get.context!,
      initialDate: selectedBirthday.value ?? DateTime.now().subtract(const Duration(days: 365 * 20)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      locale: const Locale('zh', 'CN'),
    );
    
    if (picked != null) {
      selectedBirthday.value = picked;
      _checkForChanges();
    }
  }
  
  /// 表单验证
  String? _validateForm() {
    // 昵称验证
    final nickname = nicknameController.text.trim();
    if (nickname.isEmpty) {
      return '请输入昵称';
    }
    if (nickname.length < 2 || nickname.length > 20) {
      return '昵称长度应在2-20个字符之间';
    }
    
    // 检查昵称是否包含特殊字符
    final nicknameRegex = RegExp(r'^[\u4e00-\u9fa5a-zA-Z0-9_\-]+$');
    if (!nicknameRegex.hasMatch(nickname)) {
      return '昵称只能包含中文、英文、数字、下划线和短横线';
    }
    
    // 邮箱验证
    final email = emailController.text.trim();
    if (email.isNotEmpty) {
      final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
      if (!emailRegex.hasMatch(email)) {
        return '请输入正确的邮箱格式';
      }
      if (email.length > 100) {
        return '邮箱长度不能超过100个字符';
      }
    }
    
    // 生日验证
    if (selectedBirthday.value != null) {
      final now = DateTime.now();
      final birthday = selectedBirthday.value!;
      
      // 检查生日不能是未来日期
      if (birthday.isAfter(now)) {
        return '生日不能是未来日期';
      }
      
      // 检查年龄不能超过150岁
      final age = now.year - birthday.year;
      if (age > 150) {
        return '请输入正确的生日';
      }
      
      // 检查年龄不能小于0岁
      if (age < 0) {
        return '请输入正确的生日';
      }
    }
    
    return null;
  }
  
  /// 保存用户信息
  Future<void> saveUserInfo() async {
    if (!hasChanges.value) {
      ToastUtil.showInfo('没有需要保存的更改');
      return;
    }
    
    final validationError = _validateForm();
    if (validationError != null) {
      ToastUtil.showError(validationError);
      return;
    }
    
    isSaving.value = true;
    try {
      final updateData = <String, dynamic>{};
      
      // 基本信息
      updateData['nickname'] = nicknameController.text.trim();
      updateData['email'] = emailController.text.trim();
      updateData['gender'] = selectedGender.value;
      
      // 生日
      if (selectedBirthday.value != null) {
        updateData['birthday'] = selectedBirthday.value!.toIso8601String().split('T')[0];
      }
      
      // 头像上传
      if (selectedAvatar.value != null && avatarUrl.value.isNotEmpty) {
        updateData['avatar'] = avatarUrl.value;
      }
      
      // 隐私设置
      updateData['preferences'] = {
        'pushNotification': pushNotification.value,
        'smsNotification': smsNotification.value,
        'emailNotification': emailNotification.value,
        'marketingNotification': marketingNotification.value,
      };
      
      final result = await _userService.updateUserInfo(updateData);
      
      if (result['success'] == true) {
        // 更新成功后，刷新本地用户信息
        await _refreshLocalUserInfo();
        
        ToastUtil.showSuccess('保存成功');
        hasChanges.value = false;
        selectedAvatar.value = null;
        
        // 通知其他页面用户信息已更新
        _notifyUserInfoUpdated();
        
        // 返回上一页
        Get.back();
      } else {
        ToastUtil.showError(result['message'] ?? '保存失败');
      }
    } catch (e) {
      ToastUtil.showError('保存失败: ${e.toString()}');
    } finally {
      isSaving.value = false;
    }
  }
  
  /// 刷新本地用户信息
  Future<void> _refreshLocalUserInfo() async {
    try {
      // 从服务器获取最新的用户信息
      final result = await _userService.getUserInfo(refresh: true);
      if (result['success'] == true && result['data'] != null) {
        final data = result['data'] as Map<String, dynamic>;
        if (data['userInfo'] != null) {
          final updatedUser = UserModel.fromJson(data['userInfo']);
          _updateUserInfo(updatedUser);
        }
      }
    } catch (e) {
      print('刷新本地用户信息失败: ${e.toString()}');
    }
  }
  
  /// 通知其他页面用户信息已更新
  void _notifyUserInfoUpdated() {
    // 通过GetX的事件总线通知其他页面
    try {
      if (Get.isRegistered<ProfileController>()) {
        Get.find<ProfileController>().silentUpdateUserInfo();
      }
    } catch (e) {
      print('通知用户信息更新失败: ${e.toString()}');
    }
  }
  
  /// 重置表单
  void resetForm() {
    if (userInfo.value != null) {
      _updateUserInfo(userInfo.value!);
      selectedAvatar.value = null;
    }
  }
  
  /// 获取性别显示文本
  String getGenderText(int gender) {
    switch (gender) {
      case 1:
        return '男';
      case 2:
        return '女';
      default:
        return '未设置';
    }
  }
  
  /// 获取生日显示文本
  String getBirthdayText() {
    if (selectedBirthday.value != null) {
      final birthday = selectedBirthday.value!;
      return '${birthday.year}-${birthday.month.toString().padLeft(2, '0')}-${birthday.day.toString().padLeft(2, '0')}';
    }
    return '未设置';
  }
  
  /// 更新隐私设置
  void updatePrivacySetting(String key, bool value) {
    switch (key) {
      case 'showPhone':
        showPhone.value = value;
        break;
      case 'showEmail':
        showEmail.value = value;
        break;
    }
    hasChanges.value = true;
    _savePrivacySettings();
  }

  /// 更新通知设置
  void updateNotificationSetting(String key, bool value) {
    switch (key) {
      case 'pushNotification':
        pushNotification.value = value;
        break;
      case 'smsNotification':
        smsNotification.value = value;
        break;
      case 'emailNotification':
        emailNotification.value = value;
        break;
      case 'marketingNotification':
        marketingNotification.value = value;
        break;
    }
    hasChanges.value = true;
    _saveNotificationSettings();
  }

  /// 保存隐私设置到本地
  Future<void> _savePrivacySettings() async {
    try {
      final settings = {
        'showPhone': showPhone.value,
        'showEmail': showEmail.value,
      };
      await StorageService().saveSetting('privacy_settings', settings);
      if (AppConfig.enableApiLog) {
        print('💾 Privacy settings saved: $settings');
      }
    } catch (e) {
      if (AppConfig.enableApiLog) {
        print('❌ Save privacy settings error: $e');
      }
    }
  }

  /// 保存通知设置到本地
  Future<void> _saveNotificationSettings() async {
    try {
      final settings = {
        'pushNotification': pushNotification.value,
        'smsNotification': smsNotification.value,
        'emailNotification': emailNotification.value,
        'marketingNotification': marketingNotification.value,
      };
      await StorageService().saveSetting('notification_settings', settings);
      if (AppConfig.enableApiLog) {
        print('💾 Notification settings saved: $settings');
      }
    } catch (e) {
      if (AppConfig.enableApiLog) {
        print('❌ Save notification settings error: $e');
      }
    }
  }

  /// 加载隐私设置
  void _loadPrivacySettings() {
    try {
      final settings = StorageService().getSetting<Map<String, dynamic>>('privacy_settings');
      if (settings != null) {
        showPhone.value = settings['showPhone'] ?? true;
        showEmail.value = settings['showEmail'] ?? true;
        if (AppConfig.enableApiLog) {
          print('📱 Privacy settings loaded: $settings');
        }
      }
    } catch (e) {
      if (AppConfig.enableApiLog) {
        print('❌ Load privacy settings error: $e');
      }
    }
  }

  /// 加载通知设置
  void _loadNotificationSettings() {
    try {
      final settings = StorageService().getSetting<Map<String, dynamic>>('notification_settings');
      if (settings != null) {
        pushNotification.value = settings['pushNotification'] ?? true;
        smsNotification.value = settings['smsNotification'] ?? true;
        emailNotification.value = settings['emailNotification'] ?? false;
        marketingNotification.value = settings['marketingNotification'] ?? false;
        if (AppConfig.enableApiLog) {
          print('📱 Notification settings loaded: $settings');
        }
      }
    } catch (e) {
      if (AppConfig.enableApiLog) {
        print('❌ Load notification settings error: $e');
      }
    }
  }
}