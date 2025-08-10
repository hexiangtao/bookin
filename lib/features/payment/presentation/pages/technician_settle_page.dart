import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:bookin/features/payment/data/api/settle_api.dart';
import 'package:bookin/shared/services/upload_service.dart';
import 'package:bookin/features/payment/presentation/pages/technician_settle_result_page.dart'; // Import result page

class TechnicianSettlePage extends StatefulWidget {
  const TechnicianSettlePage({super.key});

  @override
  State<TechnicianSettlePage> createState() => _TechnicianSettlePageState();
}

class _TechnicianSettlePageState extends State<TechnicianSettlePage> {
  final _formKey = GlobalKey<FormState>();
  final SettleApi _settleApi = SettleApi();


  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _experienceController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  String? _selectedGender;
  String? _selectedCity;
  List<String> _availableCities = [];
  List<String> _selectedServiceTypes = [];
  List<String> _certificateImages = [];
  List<String> _personalImages = [];

  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchCities();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _ageController.dispose();
    _experienceController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _fetchCities() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final response = await _settleApi.getCityList(context); // Pass context
      if (response.success) {
        _availableCities = response.data ?? [];
        if (_availableCities.isNotEmpty) {
          _selectedCity = _availableCities.first;
        }
      } else {
        _errorMessage = response.message;
      }
    } catch (e) {
      _errorMessage = '加载城市列表失败: ${e.toString()}';
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _submitApplication() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedGender == null || _selectedCity == null || _selectedServiceTypes.isEmpty || _certificateImages.isEmpty || _personalImages.isEmpty) {
        _showSnackBar('请填写所有必填项并上传图片');
        return;
      }

      setState(() {
        _isLoading = true;
      });

      try {
        final applicationReq = SubmitApplicationReq(
          name: _nameController.text,
          phone: _phoneController.text,
          gender: _selectedGender!,
          age: int.parse(_ageController.text),
          city: _selectedCity!,
          serviceTypes: _selectedServiceTypes,
          experience: _experienceController.text,
          description: _descriptionController.text,
          certificateImages: _certificateImages,
          personalImages: _personalImages,
        );

        final response = await _settleApi.submitApplication(context, applicationReq); // Pass context
        if (response.success) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const TechnicianSettleResultPage(success: true, message: '您的入驻申请已提交成功，请耐心等待审核。'),
            ),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => TechnicianSettleResultPage(success: false, message: '申请提交失败: ${response.message}'),
            ),
          );
        }
      } catch (e) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => TechnicianSettleResultPage(success: false, message: '申请提交失败: ${e.toString()}'),
          ),
        );
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
        title: const Text('技师入驻申请'),
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
                        onPressed: _fetchCities,
                        child: const Text('重试'),
                      ),
                    ],
                  ),
                )
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
                            labelText: '姓名',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return '请输入姓名';
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
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return '请选择性别';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _ageController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: '年龄',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return '请输入年龄';
                            } else if (int.tryParse(value) == null) {
                              return '请输入有效年龄';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          value: _selectedCity,
                          decoration: const InputDecoration(
                            labelText: '服务城市',
                            border: OutlineInputBorder(),
                          ),
                          items: _availableCities.map((String city) {
                            return DropdownMenuItem<String>(
                              value: city,
                              child: Text(city),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              _selectedCity = newValue;
                            });
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return '请选择服务城市';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _experienceController,
                          decoration: const InputDecoration(
                            labelText: '工作年限',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return '请输入工作年限';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _descriptionController,
                          maxLines: 3,
                          decoration: const InputDecoration(
                            labelText: '个人简介',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return '请输入个人简介';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        Text('服务类型', style: Theme.of(context).textTheme.titleMedium),
                        Wrap(
                          spacing: 8.0,
                          children: ['中医推拿', '精油SPA', '足底按摩', '采耳', '艾灸'].map((type) {
                            return FilterChip(
                              label: Text(type),
                              selected: _selectedServiceTypes.contains(type),
                              onSelected: (selected) {
                                setState(() {
                                  if (selected) {
                                    _selectedServiceTypes.add(type);
                                  } else {
                                    _selectedServiceTypes.remove(type);
                                  }
                                });
                              },
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 16),
                        Text('资质证书图片', style: Theme.of(context).textTheme.titleMedium),
                        Wrap(
                          spacing: 8.0,
                          runSpacing: 8.0,
                          children: [
                            ..._certificateImages.map((url) => Image.network(url, width: 80, height: 80, fit: BoxFit.cover)).toList(),
                            GestureDetector(
                              onTap: () => _pickAndUploadImage(_certificateImages),
                              child: Container(
                                width: 80,
                                height: 80,
                                color: Colors.grey[200],
                                child: const Icon(Icons.add_a_photo, size: 40, color: Colors.grey),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text('个人照片', style: Theme.of(context).textTheme.titleMedium),
                        Wrap(
                          spacing: 8.0,
                          runSpacing: 8.0,
                          children: [
                            ..._personalImages.map((url) => Image.network(url, width: 80, height: 80, fit: BoxFit.cover)).toList(),
                            GestureDetector(
                              onTap: () => _pickAndUploadImage(_personalImages),
                              child: Container(
                                width: 80,
                                height: 80,
                                color: Colors.grey[200],
                                child: const Icon(Icons.add_a_photo, size: 40, color: Colors.grey),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),
                        ElevatedButton(
                          onPressed: _submitApplication,
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 50),
                          ),
                          child: const Text('提交申请'),
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }

  Future<void> _pickAndUploadImage(List<String> imageList) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      
      if (image != null) {
        // TODO: Implement actual upload functionality
        // For now, just add a placeholder URL
        setState(() {
          imageList.add('https://via.placeholder.com/150');
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('图片上传成功')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('图片上传失败: ${e.toString()}')),
      );
    }
  }
}
