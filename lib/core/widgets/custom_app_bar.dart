import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBack;
  final Color? backgroundColor;
  final Color? titleColor;
  final List<Widget>? actions;
  final VoidCallback? onBackPressed;
  final double? elevation;
  final Widget? leading;
  final bool centerTitle;
  final TextStyle? titleStyle;
  final SystemUiOverlayStyle? systemOverlayStyle;

  const CustomAppBar({
    super.key,
    required this.title,
    this.showBack = true,
    this.backgroundColor,
    this.titleColor,
    this.actions,
    this.onBackPressed,
    this.elevation,
    this.leading,
    this.centerTitle = true,
    this.titleStyle,
    this.systemOverlayStyle,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        title,
        style: titleStyle ??
            TextStyle(
              color: titleColor ?? const Color(0xFF333333),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
      ),
      backgroundColor: backgroundColor ?? Colors.white,
      elevation: elevation ?? 0,
      centerTitle: centerTitle,
      leading: leading ??
          (showBack
              ? IconButton(
                  icon: const Icon(
                    Icons.arrow_back_ios,
                    color: Color(0xFF333333),
                    size: 20,
                  ),
                  onPressed: onBackPressed ?? () => Get.back(),
                )
              : null),
      actions: actions,
      systemOverlayStyle: systemOverlayStyle ??
          SystemUiOverlayStyle(
            statusBarColor: backgroundColor ?? Colors.white,
            statusBarIconBrightness: Brightness.dark,
            statusBarBrightness: Brightness.light,
          ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}