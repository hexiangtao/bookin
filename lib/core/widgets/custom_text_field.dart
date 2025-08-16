import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

enum TextFieldType {
  normal,
  password,
  phone,
  email,
  number,
  search,
}

class CustomTextField extends StatefulWidget {
  final String? label;
  final String? hintText;
  final String? helperText;
  final String? errorText;
  final TextEditingController? controller;
  final TextFieldType type;
  final bool isRequired;
  final bool isReadOnly;
  final bool isEnabled;
  final int? maxLines;
  final int? minLines;
  final int? maxLength;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onTap;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final String? prefixText;
  final String? suffixText;
  final EdgeInsetsGeometry? contentPadding;
  final InputBorder? border;
  final Color? fillColor;
  final bool filled;
  final TextStyle? textStyle;
  final TextStyle? hintStyle;
  final TextStyle? labelStyle;
  final List<TextInputFormatter>? inputFormatters;
  final FocusNode? focusNode;
  final bool autofocus;
  final TextCapitalization textCapitalization;

  const CustomTextField({
    super.key,
    this.label,
    this.hintText,
    this.helperText,
    this.errorText,
    this.controller,
    this.type = TextFieldType.normal,
    this.isRequired = false,
    this.isReadOnly = false,
    this.isEnabled = true,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.textInputAction,
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.prefixIcon,
    this.suffixIcon,
    this.prefixText,
    this.suffixText,
    this.contentPadding,
    this.border,
    this.fillColor,
    this.filled = true,
    this.textStyle,
    this.hintStyle,
    this.labelStyle,
    this.inputFormatters,
    this.focusNode,
    this.autofocus = false,
    this.textCapitalization = TextCapitalization.none,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _obscureText = true;
  late FocusNode _focusNode;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...
          _buildLabel(),
        _buildTextField(),
        if (widget.helperText != null || widget.errorText != null) ...
          _buildHelperText(),
      ],
    );
  }

  List<Widget> _buildLabel() {
    return [
      RichText(
        text: TextSpan(
          text: widget.label!,
          style: widget.labelStyle ?? AppTextStyles.label,
          children: [
            if (widget.isRequired)
              const TextSpan(
                text: ' *',
                style: TextStyle(color: AppColors.error),
              ),
          ],
        ),
      ),
      const SizedBox(height: 8),
    ];
  }

  Widget _buildTextField() {
    return TextField(
      controller: widget.controller,
      focusNode: _focusNode,
      obscureText: widget.type == TextFieldType.password ? _obscureText : false,
      readOnly: widget.isReadOnly,
      enabled: widget.isEnabled,
      maxLines: widget.type == TextFieldType.password ? 1 : widget.maxLines,
      minLines: widget.minLines,
      maxLength: widget.maxLength,
      textInputAction: widget.textInputAction ?? _getDefaultTextInputAction(),
      keyboardType: _getKeyboardType(),
      textCapitalization: widget.textCapitalization,
      inputFormatters: widget.inputFormatters ?? _getDefaultInputFormatters(),
      autofocus: widget.autofocus,
      style: widget.textStyle ?? AppTextStyles.bodyMedium,
      onChanged: widget.onChanged,
      onSubmitted: widget.onSubmitted,
      onTap: widget.onTap,
      decoration: InputDecoration(
        hintText: widget.hintText,
        hintStyle: widget.hintStyle ?? AppTextStyles.hint,
        prefixIcon: widget.prefixIcon ?? _getDefaultPrefixIcon(),
        suffixIcon: widget.suffixIcon ?? _getDefaultSuffixIcon(),
        prefixText: widget.prefixText,
        suffixText: widget.suffixText,
        contentPadding: widget.contentPadding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        filled: widget.filled,
        fillColor: widget.fillColor ?? (widget.isEnabled ? AppColors.surface : AppColors.surfaceVariant),
        border: widget.border ?? _getDefaultBorder(),
        enabledBorder: _getEnabledBorder(),
        focusedBorder: _getFocusedBorder(),
        errorBorder: _getErrorBorder(),
        focusedErrorBorder: _getFocusedErrorBorder(),
        disabledBorder: _getDisabledBorder(),
        errorText: widget.errorText,
        errorStyle: AppTextStyles.error,
        counterText: widget.maxLength != null ? null : '',
      ),
    );
  }

  List<Widget> _buildHelperText() {
    return [
      const SizedBox(height: 4),
      Text(
        widget.errorText ?? widget.helperText!,
        style: widget.errorText != null
            ? AppTextStyles.error
            : AppTextStyles.bodySmall.copyWith(color: AppColors.textTertiary),
      ),
    ];
  }

  TextInputType _getKeyboardType() {
    switch (widget.type) {
      case TextFieldType.phone:
        return TextInputType.phone;
      case TextFieldType.email:
        return TextInputType.emailAddress;
      case TextFieldType.number:
        return TextInputType.number;
      default:
        return TextInputType.text;
    }
  }

  TextInputAction _getDefaultTextInputAction() {
    if (widget.maxLines != null && widget.maxLines! > 1) {
      return TextInputAction.newline;
    }
    return TextInputAction.done;
  }

  List<TextInputFormatter>? _getDefaultInputFormatters() {
    switch (widget.type) {
      case TextFieldType.phone:
        return [FilteringTextInputFormatter.digitsOnly];
      case TextFieldType.number:
        return [FilteringTextInputFormatter.digitsOnly];
      default:
        return null;
    }
  }

  Widget? _getDefaultPrefixIcon() {
    switch (widget.type) {
      case TextFieldType.phone:
        return const Icon(Icons.phone, color: AppColors.textTertiary);
      case TextFieldType.email:
        return const Icon(Icons.email, color: AppColors.textTertiary);
      case TextFieldType.search:
        return const Icon(Icons.search, color: AppColors.textTertiary);
      default:
        return null;
    }
  }

  Widget? _getDefaultSuffixIcon() {
    if (widget.type == TextFieldType.password) {
      return IconButton(
        icon: Icon(
          _obscureText ? Icons.visibility : Icons.visibility_off,
          color: AppColors.textTertiary,
        ),
        onPressed: () {
          setState(() {
            _obscureText = !_obscureText;
          });
        },
      );
    }
    return null;
  }

  InputBorder _getDefaultBorder() {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: AppColors.border),
    );
  }

  InputBorder _getEnabledBorder() {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: AppColors.border),
    );
  }

  InputBorder _getFocusedBorder() {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: AppColors.primary, width: 2),
    );
  }

  InputBorder _getErrorBorder() {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: AppColors.error),
    );
  }

  InputBorder _getFocusedErrorBorder() {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: AppColors.error, width: 2),
    );
  }

  InputBorder _getDisabledBorder() {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: AppColors.borderLight),
    );
  }
}

// 便捷构造函数
class PhoneTextField extends CustomTextField {
  const PhoneTextField({
    super.key,
    super.label,
    super.hintText = '请输入手机号',
    super.controller,
    super.isRequired = false,
    super.onChanged,
    super.onSubmitted,
    super.errorText,
  }) : super(type: TextFieldType.phone);
}

class PasswordTextField extends CustomTextField {
  const PasswordTextField({
    super.key,
    super.label,
    super.hintText = '请输入密码',
    super.controller,
    super.isRequired = false,
    super.onChanged,
    super.onSubmitted,
    super.errorText,
  }) : super(type: TextFieldType.password);
}

class EmailTextField extends CustomTextField {
  const EmailTextField({
    super.key,
    super.label,
    super.hintText = '请输入邮箱',
    super.controller,
    super.isRequired = false,
    super.onChanged,
    super.onSubmitted,
    super.errorText,
  }) : super(type: TextFieldType.email);
}

class SearchTextField extends CustomTextField {
  const SearchTextField({
    super.key,
    super.hintText = '搜索',
    super.controller,
    super.onChanged,
    super.onSubmitted,
    super.suffixIcon,
  }) : super(type: TextFieldType.search);
}