import 'package:flutter/material.dart';
import 'package:bookin/api/address.dart';
import 'package:bookin/pages/user/address_edit_page.dart';

class AddressSelectionPage extends StatefulWidget {
  const AddressSelectionPage({super.key});

  @override
  State<AddressSelectionPage> createState() => _AddressSelectionPageState();
}

class _AddressSelectionPageState extends State<AddressSelectionPage> {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('选择服务地址'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AddressEditPage()),
              );
              if (result == true) {
                _fetchAddresses(); // Refresh list if address was added
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
                                onTap: () {
                                  Navigator.pop(context, address); // Return selected address
                                },
                              ),
                            );
                          },
                        ),
                ),
    );
  }
}