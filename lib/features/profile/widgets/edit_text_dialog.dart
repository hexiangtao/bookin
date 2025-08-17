import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';

class EditTextDialog extends StatefulWidget {
  final String title;
  final String initialValue;
  final String hintText;
  final int maxLength;
  final int maxLines;
  final String? Function(String?)? validator;
  final Function(String) onConfirm;

  const EditTextDialog({
    super.key,
    required this.title,
    required this.initialValue,
    required this.hintText,
    required this.maxLength,
    this.maxLines = 1,
    this.validator,
    required this.onConfirm,
  });

  @override
  State<EditTextDialog> createState() => _EditTextDialogState();
}

class _EditTextDialogState extends State<EditTextDialog> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  String? _errorText;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
    _focusNode = FocusNode();
    
    // 延迟聚焦，确保对话框完全显示后再聚焦
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
      // 选中所有文本
      _controller.selection = TextSelection(
        baseOffset: 0,
        extentOffset: _controller.text.length,
      );
    });
    
    // 监听文本变化，实时验证
    _controller.addListener(_validateText);
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _validateText() {
    if (widget.validator != null) {
      setState(() {
        _errorText = widget.validator!(_controller.text);
      });
    }
  }

  void _handleConfirm() async {
    final text = _controller.text.trim();
    
    // 最终验证
    if (widget.validator != null) {
      final error = widget.validator!(text);
      if (error != null) {
        setState(() {
          _errorText = error;
        });
        return;
      }
    }
    
    // 检查是否有变化
    if (text == widget.initialValue.trim()) {
      Get.back();
      return;
    }
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      widget.onConfirm(text);
      Get.back();
    } catch (e) {
      setState(() {
        _errorText = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 标题
            Row(
              children: [
                Expanded(
                  child: Text(
                    widget.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => Get.back(),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    child: Icon(
                      Icons.close,
                      size: 20,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            // 输入框
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _errorText != null 
                      ? Colors.red.withOpacity(0.5)
                      : Colors.grey[200]!,
                ),
              ),
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                maxLength: widget.maxLength,
                maxLines: widget.maxLines,
                decoration: InputDecoration(
                  hintText: widget.hintText,
                  hintStyle: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 16,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(16),
                  counterText: '',
                ),
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
            ),
            
            // 字数统计和错误提示
            const SizedBox(height: 8),
            Row(
              children: [
                if (_errorText != null)
                  Expanded(
                    child: Text(
                      _errorText!,
                      style: const TextStyle(
                        color: Colors.red,
                        fontSize: 12,
                      ),
                    ),
                  )
                else
                  const Spacer(),
                Text(
                  '${_controller.text.length}/${widget.maxLength}',
                  style: TextStyle(
                    color: _controller.text.length > widget.maxLength * 0.9
                        ? Colors.orange
                        : Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // 按钮
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: _isLoading ? null : () => Get.back(),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(color: Colors.grey[300]!),
                      ),
                    ),
                    child: Text(
                      '取消',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading || _errorText != null
                        ? null
                        : _handleConfirm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text(
                            '确定',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// 显示编辑昵称对话框
Future<void> showEditNicknameDialog({
  required String initialValue,
  required Function(String) onConfirm,
}) {
  return Get.dialog(
    EditTextDialog(
      title: '编辑昵称',
      initialValue: initialValue,
      hintText: '请输入昵称',
      maxLength: 20,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return '昵称不能为空';
        }
        if (value.trim().length < 2) {
          return '昵称至少需要2个字符';
        }
        if (value.trim().length > 20) {
          return '昵称不能超过20个字符';
        }
        // 检查特殊字符
        if (RegExp(r'[<>"&\'']').hasMatch(value)) {
          return '昵称不能包含特殊字符';
        }
        return null;
      },
      onConfirm: onConfirm,
    ),
    barrierDismissible: false,
  );
}

/// 显示编辑个人简介对话框
Future<void> showEditBioDialog({
  required String initialValue,
  required Function(String) onConfirm,
}) {
  return Get.dialog(
    EditTextDialog(
      title: '编辑个人简介',
      initialValue: initialValue,
      hintText: '介绍一下自己吧...',
      maxLength: 200,
      maxLines: 4,
      validator: (value) {
        if (value != null && value.trim().length > 200) {
          return '个人简介不能超过200个字符';
        }
        // 检查特殊字符
        if (value != null && RegExp(r'[<>"&\'']').hasMatch(value)) {
          return '个人简介不能包含特殊字符';
        }
        return null;
      },
      onConfirm: onConfirm,
    ),
    barrierDismissible: false,
  );
}