import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../controllers/user_edit_controller.dart';
import '../widgets/edit_text_dialog.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/config/app_config.dart';
import '../../../shared/widgets/custom_app_bar.dart';

class UserEditPage extends StatelessWidget {
  const UserEditPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<UserEditController>();
    
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: '编辑资料',
        showBack: true,
        backgroundColor: AppColors.surface,
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
                    ? AppColors.secondary
                    : AppColors.surfaceVariant,
                foregroundColor: controller.hasChanges.value
                    ? AppColors.surface
                    : AppColors.textDisabled,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppConfig.defaultBorderRadius * 2.5),
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
              // 头像与基本信息区域 - 真正的嵌入式布局
              _buildAvatarWithInfoSection(controller),
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
  
  /// 构建头像与基本信息区域 - 真正的嵌入式布局
  Widget _buildAvatarWithInfoSection(UserEditController controller) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: AppConfig.defaultMargin),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // 基本信息卡片
          Container(
            margin: const EdgeInsets.only(top: 40), // 为头像留出空间
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppConfig.defaultBorderRadius * 2.5),
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadow,
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 顶部留空给头像
                const SizedBox(height: 40),
                
                // 标题栏
                Padding(
                  padding: EdgeInsets.fromLTRB(AppConfig.defaultPadding * 1.5, AppConfig.defaultPadding * 1.5, AppConfig.defaultPadding * 1.5, AppConfig.defaultPadding),
                  child: Row(
                    children: [
                      Container(
                        width: 4,
                        height: 20,
                        decoration: BoxDecoration(
                          color: AppColors.secondary,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '基本信息',
                        style: AppTextStyles.h3.copyWith(
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // 昵称
                Obx(() => _buildFormItem(
                  label: '昵称',
                  child: Text(
                    controller.nickname.value.isEmpty 
                        ? '请输入昵称' 
                        : controller.nickname.value,
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: controller.nickname.value.isEmpty 
                          ? AppColors.textTertiary 
                          : AppColors.textPrimary,
                    ),
                  ),
                  trailing: Icon(
                    Icons.chevron_right,
                    color: AppColors.textTertiary,
                  ),
                  onTap: () => _showEditNicknameDialog(controller),
                )),
                
                _buildDivider(),
                
                // 手机号
                Obx(() => _buildFormItem(
                  label: '手机号',
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          controller.userInfo.value?.phone?.isEmpty != false 
                              ? '请输入手机号' 
                              : controller.userInfo.value!.phone!,
                          style: AppTextStyles.bodyLarge.copyWith(
                            color: controller.userInfo.value?.phone?.isEmpty != false 
                                ? AppColors.textTertiary 
                                : AppColors.textPrimary,
                          ),
                        ),
                      ),
                      if (controller.userInfo.value?.phone?.isNotEmpty == true)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.success.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '已验证',
                            style: AppTextStyles.label.copyWith(
                              color: AppColors.success,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                    ],
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
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: AppColors.textPrimary,
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
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                  trailing: Icon(
                    Icons.chevron_right,
                    color: AppColors.textTertiary,
                  ),
                  onTap: () => _showGenderPicker(controller),
                )),
                
                _buildDivider(),
                
                // 生日
                Obx(() => _buildFormItem(
                  label: '生日',
                  child: Text(
                    controller.getBirthdayText(),
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                  trailing: Icon(
                    Icons.chevron_right,
                    color: AppColors.textTertiary,
                  ),
                  onTap: () => controller.selectBirthday(),
                )),
                
                _buildDivider(),
                
                // 个人简介
                Obx(() => _buildFormItem(
                  label: '个人简介',
                  child: Text(
                    controller.bio.value.isEmpty 
                        ? '请输入个人简介' 
                        : controller.bio.value,
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: controller.bio.value.isEmpty 
                          ? AppColors.textTertiary 
                          : AppColors.textPrimary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: Icon(
                    Icons.chevron_right,
                    color: AppColors.textTertiary,
                  ),
                  onTap: () => _showEditBioDialog(controller),
                )),
                
                const SizedBox(height: AppConfig.defaultPadding),
              ],
            ),
          ),
          
          // 头像 - 定位在卡片顶部中央
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Center(
              child: GestureDetector(
                onTap: controller.selectAvatar,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // 头像主体
                    Obx(() {
                      Widget avatarWidget;
                      
                      if (controller.selectedAvatar.value != null) {
                        // 显示选中的本地图片
                        avatarWidget = CircleAvatar(
                          radius: 40,
                          backgroundImage: FileImage(controller.selectedAvatar.value!),
                        );
                      } else if (controller.avatarUrl.value.isNotEmpty) {
                        // 显示网络头像
                        avatarWidget = CircleAvatar(
                          radius: 40,
                          backgroundImage: CachedNetworkImageProvider(
                            controller.avatarUrl.value,
                          ),
                        );
                      } else {
                        // 显示默认头像
                        avatarWidget = CircleAvatar(
                          radius: 40,
                          backgroundColor: AppColors.surface,
                          child: Icon(
                            Icons.person_outline,
                            size: 32,
                            color: AppColors.secondary.withOpacity(0.6),
                          ),
                        );
                      }
                      
                      return Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.surface,
                            width: 4,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.secondary.withOpacity(0.15),
                              blurRadius: 20,
                              offset: const Offset(0, 6),
                            ),
                            BoxShadow(
                              color: AppColors.secondary.withOpacity(0.08),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: avatarWidget,
                      );
                    }),
                    // 编辑按钮
                    Positioned(
                      right: 2,
                      bottom: 2,
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: AppColors.secondary,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.surface,
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.secondary.withOpacity(0.3),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.edit_rounded,
                          color: AppColors.surface,
                          size: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  

  
  /// 构建隐私设置区域
  Widget _buildPrivacySection(UserEditController controller) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: AppConfig.defaultMargin),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppConfig.defaultBorderRadius * 2.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(AppConfig.defaultPadding * 1.5, AppConfig.defaultPadding * 1.5, AppConfig.defaultPadding * 1.5, AppConfig.defaultPadding),
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 20,
                  decoration: BoxDecoration(
                    color: AppColors.warning,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '隐私设置',
                  style: AppTextStyles.h3.copyWith(
                    color: AppColors.textPrimary,
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
      margin: EdgeInsets.symmetric(horizontal: AppConfig.defaultMargin),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppConfig.defaultBorderRadius * 2.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(AppConfig.defaultPadding * 1.5, AppConfig.defaultPadding * 1.5, AppConfig.defaultPadding * 1.5, AppConfig.defaultPadding),
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 20,
                  decoration: BoxDecoration(
                    color: AppColors.success,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '通知设置',
                  style: AppTextStyles.h3.copyWith(
                    color: AppColors.textPrimary,
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
        borderRadius: BorderRadius.circular(AppConfig.defaultBorderRadius),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: AppConfig.defaultPadding * 1.5, vertical: AppConfig.defaultPadding * 1.125),
          child: Row(
            children: [
              SizedBox(
                width: 85,
                child: Text(
                  label,
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.textPrimary,
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
      padding: EdgeInsets.symmetric(horizontal: AppConfig.defaultPadding * 1.5, vertical: AppConfig.defaultPadding),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
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
              activeColor: AppColors.secondary,
                activeTrackColor: AppColors.secondary.withOpacity(0.3),
              inactiveThumbColor: AppColors.textTertiary,
              inactiveTrackColor: AppColors.surfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
  
  /// 构建分割线
  Widget _buildDivider() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: AppConfig.defaultPadding * 1.5),
      height: 0.5,
      color: AppColors.divider,
    );
  }
  
  /// 显示性别选择器
  void _showGenderPicker(UserEditController controller) {
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(AppConfig.defaultPadding * 1.25),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppConfig.defaultBorderRadius * 1.5)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 48,
              height: 5,
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              '选择性别',
              style: AppTextStyles.h2.copyWith(
                color: AppColors.textPrimary,
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
        borderRadius: BorderRadius.circular(AppConfig.defaultBorderRadius),
        child: Container(
          width: double.infinity,
          margin: const EdgeInsets.symmetric(vertical: 4),
          padding: EdgeInsets.symmetric(horizontal: AppConfig.defaultPadding * 1.25, vertical: AppConfig.defaultPadding * 1.125),
          decoration: BoxDecoration(
            color: controller.selectedGender.value == gender
                ? AppColors.secondary.withOpacity(0.08)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(AppConfig.defaultBorderRadius),
            border: controller.selectedGender.value == gender ? Border.all(
              color: AppColors.secondary.withOpacity(0.3),
              width: 1.5,
            ) : null,
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  text,
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: controller.selectedGender.value == gender
                        ? AppColors.secondary
                        : AppColors.textPrimary,
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
                    color: AppColors.secondary,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check,
                    color: AppColors.surface,
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
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          margin: EdgeInsets.all(AppConfig.defaultMargin),
          padding: EdgeInsets.all(AppConfig.defaultPadding * 1.5),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppConfig.defaultBorderRadius * 1.5),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadow,
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '编辑昵称',
                style: AppTextStyles.h2.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: controller.nicknameController,
                maxLength: 20,
                decoration: InputDecoration(
                  hintText: '请输入昵称',
                  hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textTertiary),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppConfig.defaultBorderRadius),
                    borderSide: BorderSide(color: AppColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppConfig.defaultBorderRadius),
                    borderSide: BorderSide(color: AppColors.secondary, width: 2),
                  ),
                  contentPadding: EdgeInsets.symmetric(horizontal: AppConfig.defaultPadding, vertical: AppConfig.defaultPadding * 0.875),
                ),
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.textPrimary,
                ),

              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Get.back(),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.textSecondary,
                      padding: EdgeInsets.symmetric(
                        horizontal: AppConfig.defaultPadding * 1.5,
                        vertical: AppConfig.defaultPadding,
                      ),
                    ),
                    child: Text(
                      '取消',
                      style: AppTextStyles.bodyLarge.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () {
                      Get.back();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondary,
                      foregroundColor: AppColors.surface,
                      elevation: 0,
                      padding: EdgeInsets.symmetric(
                        horizontal: AppConfig.defaultPadding * 1.5,
                        vertical: AppConfig.defaultPadding,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppConfig.defaultBorderRadius),
                      ),
                    ),
                    child: Text(
                      '确定',
                      style: AppTextStyles.bodyLarge.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  /// 显示编辑个人简介对话框
  void _showEditBioDialog(UserEditController controller) {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          margin: EdgeInsets.all(AppConfig.defaultMargin),
          padding: EdgeInsets.all(AppConfig.defaultPadding * 1.5),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppConfig.defaultBorderRadius * 1.5),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadow,
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '编辑个人简介',
                style: AppTextStyles.h2.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: controller.bioController,
                maxLines: 4,
                maxLength: 200,
                decoration: InputDecoration(
                  hintText: '请输入个人简介',
                  hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textTertiary),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppConfig.defaultBorderRadius),
                    borderSide: BorderSide(color: AppColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppConfig.defaultBorderRadius),
                      borderSide: BorderSide(color: AppColors.secondary, width: 2),
                    ),
                  contentPadding: EdgeInsets.all(AppConfig.defaultPadding),
                ),
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.textPrimary,
                ),

              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Get.back(),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.textSecondary,
                      padding: EdgeInsets.symmetric(
                        horizontal: AppConfig.defaultPadding * 1.5,
                        vertical: AppConfig.defaultPadding,
                      ),
                    ),
                    child: Text(
                      '取消',
                      style: AppTextStyles.bodyLarge.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () {
                      Get.back();
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.secondary,
                      foregroundColor: AppColors.surface,
                      elevation: 0,
                      padding: EdgeInsets.symmetric(
                        horizontal: AppConfig.defaultPadding * 1.5,
                        vertical: AppConfig.defaultPadding,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppConfig.defaultBorderRadius),
                      ),
                    ),
                    child: Text(
                      '确定',
                      style: AppTextStyles.bodyLarge.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}