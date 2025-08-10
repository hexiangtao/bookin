import 'package:flutter/material.dart';
import 'package:bookin/features/user/data/api/address_api.dart';
import 'package:bookin/features/user/presentation/pages/address_edit_page.dart'; // Import address edit page

class AddressListPage extends StatefulWidget {
  const AddressListPage({super.key});

  @override
  State<AddressListPage> createState() => _AddressListPageState();
}

class _AddressListPageState extends State<AddressListPage> {
  final AddressApi _addressApi = AddressApi();
  List<Address> _addresses = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchAddresses();
  }

  Future<void> _fetchAddresses() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final response = await _addressApi.getAddressList(context); // Pass context
      if (response.success) {
        _addresses = response.data ?? [];
      } else {
        _errorMessage = response.message;
      }
    } catch (e) {
      _errorMessage = '加载地址列表失败: ${e.toString()}';
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteAddress(String id) async {
    setState(() {
      _isLoading = true;
    });
    try {
      final response = await _addressApi.deleteAddress(context, id); // Pass context
      if (response.success) {
        _showSnackBar('地址删除成功');
        _fetchAddresses(); // Refresh list
      } else {
        _showSnackBar('删除失败: ${response.message}');
      }
    } catch (e) {
      _showSnackBar('删除失败: ${e.toString()}');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _setDefaultAddress(String id) async {
    setState(() {
      _isLoading = true;
    });
    try {
      final response = await _addressApi.setDefaultAddress(context, id); // Pass context
      if (response.success) {
        _showSnackBar('默认地址设置成功');
        _fetchAddresses(); // Refresh list to update default status
      } else {
        _showSnackBar('设置失败: ${response.message}');
      }
    } catch (e) {
      _showSnackBar('设置失败: ${e.toString()}');
    } finally {
      setState(() {
        _isLoading = false;
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
        title: const Text('我的地址'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AddressEditPage()),
              );
              if (result == true) {
                _fetchAddresses(); // Refresh list if address was added/edited
              }
            },
          ),
        ],
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
                        onPressed: _fetchAddresses,
                        child: const Text('重试'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _fetchAddresses,
                  child: _addresses.isEmpty
                      ? const Center(child: Padding(padding: EdgeInsets.all(16.0), child: Text('暂无地址，点击右上角添加')))
                      : ListView.builder(
                          itemCount: _addresses.length,
                          itemBuilder: (context, index) {
                            final address = _addresses[index];
                            return Card(
                              margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                              child: ListTile(
                                title: Text(address.name),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(address.phone),
                                    Text(address.address),
                                    if (address.isDefault)
                                      const Padding(
                                        padding: EdgeInsets.only(top: 4.0),
                                        child: Chip(
                                          label: Text('默认地址', style: TextStyle(fontSize: 10)),
                                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                        ),
                                      ),
                                  ],
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit),
                                      onPressed: () async {
                                        final result = await Navigator.push(
                                          context,
                                          MaterialPageRoute(builder: (context) => AddressEditPage(address: address)),
                                        );
                                        if (result == true) {
                                          _fetchAddresses(); // Refresh list if address was added/edited
                                        }
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete),
                                      onPressed: () => _deleteAddress(address.id),
                                    ),
                                    if (!address.isDefault)
                                      IconButton(
                                        icon: const Icon(Icons.star_border),
                                        tooltip: '设为默认',
                                        onPressed: () => _setDefaultAddress(address.id),
                                      ),
                                  ],
                                ),
                                onTap: () {
                                  // Handle address selection or view details
                                },
                              ),
                            );
                          },
                        ),
                ),
    );
  }
}
