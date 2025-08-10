import 'package:flutter/material.dart';
import 'package:bookin/features/user/data/api/address_api.dart';
// import 'package:bookin/features/shared/data/api/region_api.dart'; // For region selection
import 'package:bookin/features/shared/services/base_api.dart'; // For ApiResponse

class AddressEditPage extends StatefulWidget {
  final Address? address; // Null for adding new, provided for editing existing

  const AddressEditPage({super.key, this.address});

  @override
  State<AddressEditPage> createState() => _AddressEditPageState();
}

class _AddressEditPageState extends State<AddressEditPage> {
  final _formKey = GlobalKey<FormState>();
  final AddressApi _addressApi = AddressApi();


  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _detailAddressController;

  String? _selectedProvinceId;
  String? _selectedCityId;
  String? _selectedDistrictId;

  bool _isDefault = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.address?.name);
    _phoneController = TextEditingController(text: widget.address?.phone);
    _detailAddressController = TextEditingController(text: widget.address?.address);
    _isDefault = widget.address?.isDefault ?? false;

    // For existing address, try to pre-fill region data if available
    // This would typically involve fetching region names from IDs if only IDs are stored
    // For simplicity, we'll assume the full address string is sufficient for now.
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _detailAddressController.dispose();
    super.dispose();
  }

  Future<void> _saveAddress() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final addressReq = AddressReq(
        id: widget.address?.id, // Only include ID if editing
        name: _nameController.text,
        phone: _phoneController.text,
        address: _detailAddressController.text, // Combine with selected region later
        isDefault: _isDefault,
      );

      try {
        final ApiResponse<Address> response;
        if (widget.address == null) {
          response = await _addressApi.addAddress(context, addressReq); // Pass context
        } else {
          response = await _addressApi.updateAddress(context, addressReq); // Pass context
        }

        if (response.success) {
          _showSnackBar('地址保存成功！');
          Navigator.pop(context, true); // Pop with true to indicate success
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
        title: Text(widget.address == null ? '新增地址' : '编辑地址'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: '收货人姓名',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '请输入收货人姓名';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: '手机号码',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '请输入手机号码';
                        } else if (value.length != 11) {
                          return '请输入11位手机号码';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    // Placeholder for Province/City/District selection
                    ListTile(
                      title: const Text('所在地区'),
                      subtitle: Text(
                        _selectedProvinceId == null
                            ? '请选择省/市/区'
                            : '已选择地区: $_selectedProvinceId $_selectedCityId $_selectedDistrictId', // Replace with actual names
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () {
                        // Implement region picker here
                        _showSnackBar('地区选择器待实现');
                      },
                      shape: RoundedRectangleBorder(side: BorderSide(color: Colors.grey[400]!)),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _detailAddressController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: '详细地址 (街道、门牌号等)',
                        alignLabelWithHint: true,
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '请输入详细地址';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Checkbox(
                          value: _isDefault,
                          onChanged: (bool? newValue) {
                            setState(() {
                              _isDefault = newValue ?? false;
                            });
                          },
                        ),
                        const Text('设为默认地址'),
                      ],
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: _saveAddress,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      child: const Text('保存地址'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}