import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../controllers/user_edit_controller.dart';
import '../widgets/edit_text_dialog.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/custom_app_bar.dart';

class UserEditPage extends StatelessWidget {
  const UserEditPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<UserEditController>();
    
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: CustomAppBar(
        title: '编辑资料',
        showBack: true,
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          Obx(() => Container(
            margin: const EdgeInsets.only(right: 16, top: 8, bottom: 8),
            child: ElevatedButton(
              onPressed: controller.hasChanges.value && !controller.isSaving.value
                  ? controller.saveUserInfo
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: controller.hasChanges.value
                    ? AppColors.primary
                    : Colors.grey[300],
                foregroundColor: controller.hasChanges.value
                    ? Colors.white
                    : Colors.grey[500],
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                minimumSize: const Size(60, 32),
              ),
              child: controller.isSaving.value
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text(
                      '保存',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          )),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        
        return SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 8),
              
              // 头像区域
              _buildAvatarSection(controller),
              const SizedBox(height: 16),
              
              // 基本信息区域
              _buildBasicInfoSection(controller),
              const SizedBox(height: 16),
              
              // 隐私设置区域
              _buildPrivacySection(controller),
              const SizedBox(height: 16),
              
              // 通知设置区域
              _buildNotificationSection(controller),
              const SizedBox(height: 40),
            ],
          ),
        );
      }),
    );
  }
  
  /// 构建头像区域
  Widget _buildAvatarSection(UserEditController controller) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: controller.selectAvatar,
            child: Stack(
              children: [
                Obx(() {
                  Widget avatarWidget;
                  
                  if (controller.selectedAvatar.value != null) {
                    // 显示选中的本地图片
                    avatarWidget = CircleAvatar(
                      radius: 60,
                      backgroundImage: FileImage(controller.selectedAvatar.value!),
                    );
                  } else if (controller.avatarUrl.value.isNotEmpty) {
                    // 显示网络头像
                    avatarWidget = CircleAvatar(
                      radius: 60,
                      backgroundImage: CachedNetworkImageProvider(
                        controller.avatarUrl.value,
                      ),
                    );
                  } else {
                    // 显示默认头像
                    avatarWidget = CircleAvatar(
                      radius: 60,
                      backgroundColor: AppColors.primary.withOpacity(0.08),
                      child: Icon(
                        Icons.person_outline,
                        size: 60,
                        color: AppColors.primary.withOpacity(0.6),
                      ),
                    );
                  }
                  
                  return Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.primary.withOpacity(0.1),
                        width: 3,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: avatarWidget,
                  );
                }),
                Positioned(
                  right: 4,
                  bottom: 4,
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white,
                        width: 3,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.camera_alt_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '点击更换头像',
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '支持JPG、PNG格式，文件大小不超过5MB',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }
  
  /// 构建基本信息区域
  Widget _buildBasicInfoSection(UserEditController controller) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 20,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  '基本信息',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          
          // 昵称
          _buildFormItem(
            label: '昵称',
            child: Obx(() => Text(
              controller.nickname.value.isEmpty 
                  ? '请输入昵称'
                  : controller.nickname.value,
              style: TextStyle(
                fontSize: 16,
                color: controller.nickname.value.isEmpty 
                    ? Colors.grey[500]
                    : Colors.black87,
              ),
            )),
            trailing: const Icon(
              Icons.chevron_right,
              color: Colors.grey,
            ),
            onTap: () => _showEditNicknameDialog(controller),
          ),
          
          _buildDivider(),
          
          // 手机号（只读）
          Obx(() => _buildFormItem(
            label: '手机号',
            child: Text(
              controller.userInfo.value?.phone ?? '',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                '已验证',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.green,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          )),
          
          _buildDivider(),
          
          // 邮箱
          _buildFormItem(
            label: '邮箱',
            child: TextField(
              controller: controller.emailController,
              decoration: const InputDecoration(
                hintText: '请输入邮箱地址',
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black87,
              ),
              keyboardType: TextInputType.emailAddress,
            ),
          ),
          
          _buildDivider(),
          
          // 性别
          Obx(() => _buildFormItem(
            label: '性别',
            child: Text(
              controller.getGenderText(controller.selectedGender.value),
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
            trailing: const Icon(
              Icons.chevron_right,
              color: Colors.grey,
            ),
            onTap: () => _showGenderPicker(controller),
          )),
          
          _buildDivider(),
          
          // 生日
          Obx(() => _buildFormItem(
            label: '生日',
            child: Text(
              controller.getBirthdayText(),
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
            trailing: const Icon(
              Icons.chevron_right,
              color: Colors.grey,
            ),
            onTap: controller.selectBirthday,
          )),
          
          _buildDivider(),
          
          // 个人简介
          _buildFormItem(
            label: '个人简介',
            child: Obx(() => Text(
              controller.bio.value.isEmpty 
                  ? '介绍一下自己吧...'
                  : controller.bio.value,
              style: TextStyle(
                fontSize: 16,
                color: controller.bio.value.isEmpty 
                    ? Colors.grey[500]
                    : Colors.black87,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            )),
            trailing: const Icon(
              Icons.chevron_right,
              color: Colors.grey,
            ),
            onTap: () => _showEditBioDialog(controller),
          ),
          
          const SizedBox(height: 8),
        ],
      ),
    );
  }
  
  /// 构建隐私设置区域
  Widget _buildPrivacySection(UserEditController controller) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 20,
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  '隐私设置',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          
          Obx(() => _buildSwitchItem(
            label: '显示手机号',
            subtitle: '其他用户可以看到您的手机号',
            value: controller.showPhone.value,
            onChanged: (value) => controller.showPhone.value = value,
          )),
          
          _buildDivider(),
          
          Obx(() => _buildSwitchItem(
            label: '显示邮箱',
            subtitle: '其他用户可以看到您的邮箱地址',
            value: controller.showEmail.value,
            onChanged: (value) => controller.showEmail.value = value,
          )),
          
          _buildDivider(),
          
          Obx(() => _buildSwitchItem(
            label: '允许搜索',
            subtitle: '其他用户可以通过手机号搜索到您',
            value: controller.allowSearch.value,
            onChanged: (value) => controller.allowSearch.value = value,
          )),
          
          const SizedBox(height: 20),
        ],
      ),
    );
  }
  
  /// 构建通知设置区域
  Widget _buildNotificationSection(UserEditController controller) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 20,
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  '通知设置',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          
          Obx(() => _buildSwitchItem(
            label: '推送通知',
            subtitle: '接收应用推送消息',
            value: controller.pushNotification.value,
            onChanged: (value) => controller.pushNotification.value = value,
          )),
          
          _buildDivider(),
          
          Obx(() => _buildSwitchItem(
            label: '短信通知',
            subtitle: '接收重要信息的短信提醒',
            value: controller.smsNotification.value,
            onChanged: (value) => controller.smsNotification.value = value,
          )),
          
          _buildDivider(),
          
          Obx(() => _buildSwitchItem(
            label: '邮件通知',
            subtitle: '接收邮件提醒',
            value: controller.emailNotification.value,
            onChanged: (value) => controller.emailNotification.value = value,
          )),
          
          _buildDivider(),
          
          Obx(() => _buildSwitchItem(
            label: '营销信息',
            subtitle: '接收优惠活动等营销信息',
            value: controller.marketingNotification.value,
            onChanged: (value) => controller.marketingNotification.value = value,
          )),
          
          const SizedBox(height: 20),
        ],
      ),
    );
  }
  
  /// 构建表单项
  Widget _buildFormItem({
    required String label,
    required Widget child,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
          child: Row(
            children: [
              SizedBox(
                width: 85,
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  alignment: Alignment.centerLeft,
                  child: child,
                ),
              ),
              if (trailing != null) ...[
                const SizedBox(width: 12),
                trailing,
              ],
            ],
          ),
        ),
      ),
    );
  }
  
  /// 构建开关项
  Widget _buildSwitchItem({
    required String label,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Transform.scale(
            scale: 0.9,
            child: Switch(
              value: value,
              onChanged: onChanged,
              activeColor: AppColors.primary,
              activeTrackColor: AppColors.primary.withOpacity(0.3),
              inactiveThumbColor: Colors.grey[400],
              inactiveTrackColor: Colors.grey[200],
            ),
          ),
        ],
      ),
    );
  }
  
  /// 构建分割线
  Widget _buildDivider() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      height: 0.5,
      color: Colors.grey[150],
    );
  }
  
  /// 显示性别选择器
  void _showGenderPicker(UserEditController controller) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 48,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              '选择性别',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 24),
            ...[0, 1, 2].map((gender) => _buildGenderOption(
              controller,
              gender,
              controller.getGenderText(gender),
            )),
            const SizedBox(height: 24),
          ],
        ),
      ),
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
    );
  }
  
  /// 构建性别选项
  Widget _buildGenderOption(
    UserEditController controller,
    int gender,
    String text,
  ) {
    return Obx(() => Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          controller.selectGender(gender);
          Get.back();
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: double.infinity,
          margin: const EdgeInsets.symmetric(vertical: 4),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          decoration: BoxDecoration(
            color: controller.selectedGender.value == gender
                ? AppColors.primary.withOpacity(0.08)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            border: controller.selectedGender.value == gender ? Border.all(
              color: AppColors.primary.withOpacity(0.3),
              width: 1.5,
            ) : null,
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  text,
                  style: TextStyle(
                    fontSize: 17,
                    color: controller.selectedGender.value == gender
                        ? AppColors.primary
                        : Colors.black87,
                    fontWeight: controller.selectedGender.value == gender
                        ? FontWeight.w600
                        : FontWeight.w500,
                  ),
                ),
              ),
              if (controller.selectedGender.value == gender)
                Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
            ],
          ),
        ),
      ),
    ));
  }
  
  /// 显示编辑昵称对话框
  void _showEditNicknameDialog(UserEditController controller) {
    showEditNicknameDialog(
      initialValue: controller.nicknameController.text,
      onConfirm: (value) {
        controller.nicknameController.text = value;
      },
    );
  }
  
  /// 显示编辑个人简介对话框
  void _showEditBioDialog(UserEditController controller) {
    showEditBioDialog(
      initialValue: controller.bioController.text,
      onConfirm: (value) {
        controller.bioController.text = value;
      },
    );
  }
}