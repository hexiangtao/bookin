import 'package:flutter/material.dart';
import 'package:bookin/api/user.dart';

class FavoriteListPage extends StatefulWidget {
  const FavoriteListPage({super.key});

  @override
  State<FavoriteListPage> createState() => _FavoriteListPageState();
}

class _FavoriteListPageState extends State<FavoriteListPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final UserApi _userApi = UserApi();
  final List<CollectItem> _favorites = [];
  bool _isLoading = true;
  String? _errorMessage;
  int _currentPage = 1;
  bool _hasMore = true;

  // Map tab index to favorite type: 'service' or 'tech'
  final List<String> _typeMap = ['service', 'tech'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _typeMap.length, vsync: this);
    _tabController.addListener(_handleTabSelection);
    _fetchFavorites();
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabSelection);
    _tabController.dispose();
    super.dispose();
  }

  void _handleTabSelection() {
    if (_tabController.indexIsChanging) {
      setState(() {
        _favorites.clear();
        _currentPage = 1;
        _hasMore = true;
        _isLoading = true;
        _errorMessage = null;
      });
      _fetchFavorites();
    }
  }

  Future<void> _fetchFavorites() async {
    if (!_hasMore || _isLoading) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // The backend API `getFavoriteList` might return all types, so we filter locally.
      // If the backend supports filtering by type, update this call.
      final response = await _userApi.getFavoriteList(
        context, // Pass context
        pageIndex: _currentPage,
        pageSize: 10,
      );

      if (response.success) {
        setState(() {
          final String currentType = _typeMap[_tabController.index];
          _favorites.addAll(response.data?.where((item) => item.type == currentType).toList() ?? []);
          _hasMore = response.data?.isNotEmpty ?? false; // Assuming data.isNotEmpty implies hasMore
          _currentPage++;
        });
      } else {
        _errorMessage = response.message;
      }
    } catch (e) {
      _errorMessage = '加载收藏列表失败: ${e.toString()}';
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteFavorite(String id) async {
    setState(() {
      _isLoading = true;
    });
    try {
      final response = await _userApi.deleteCollect(context, id); // Pass context
      if (response.success) {
        _showSnackBar('收藏已删除');
        // Refresh the list after deletion
        setState(() {
          _favorites.clear();
          _currentPage = 1;
          _hasMore = true;
        });
        _fetchFavorites();
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
        title: const Text('我的收藏'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: '服务'),
            Tab(text: '技师'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: _typeMap.map((type) {
          return _isLoading && _favorites.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : _errorMessage != null
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(_errorMessage!),
                          ElevatedButton(
                            onPressed: _fetchFavorites,
                            child: const Text('重试'),
                          ),
                        ],
                      ),
                    )
                  : NotificationListener<ScrollNotification>(
                      onNotification: (ScrollNotification scrollInfo) {
                        if (!_isLoading && _hasMore && scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
                          _fetchFavorites();
                          return true;
                        }
                        return false;
                      },
                      child: ListView.builder(
                        itemCount: _favorites.length + (_hasMore ? 1 : 0), // Add 1 for loading indicator
                        itemBuilder: (context, index) {
                          if (index == _favorites.length) {
                            return const Center(child: CircularProgressIndicator());
                          }
                          final favorite = _favorites[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                            child: ListTile(
                              leading: favorite.image.isNotEmpty
                                  ? ClipRRect(
                                    borderRadius: BorderRadius.circular(4.0),
                                    child: Image.network(
                                      favorite.image,
                                      width: 50,
                                      height: 50,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        return Container(
                                          width: 50,
                                          height: 50,
                                          color: Colors.grey[300],
                                          child: const Icon(Icons.error, color: Colors.grey),
                                        );
                                      },
                                      loadingBuilder: (context, child, loadingProgress) {
                                        if (loadingProgress == null) return child;
                                        return Container(
                                          width: 50,
                                          height: 50,
                                          color: Colors.grey[300],
                                          child: const Center(
                                            child: SizedBox(
                                              width: 20,
                                              height: 20,
                                              child: CircularProgressIndicator(strokeWidth: 2),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  )
                                  : const Icon(Icons.image),
                              title: Text(favorite.title),
                              subtitle: Text(
                                favorite.type == 'service'
                                    ? '价格: ¥${(favorite.price / 100).toStringAsFixed(2)}'
                                    : '评分: ${favorite.rating} | 经验: ${favorite.experience}',
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () => _deleteFavorite(favorite.id),
                              ),
                              onTap: () {
                                // Navigate to detail page based on type
                                if (favorite.type == 'service') {
                                  // Navigator.push(context, MaterialPageRoute(builder: (context) => ProjectDetailPage(projectId: favorite.id)));
                                } else if (favorite.type == 'tech') {
                                  // Navigator.push(context, MaterialPageRoute(builder: (context) => TeacherDetailPage(teacherId: favorite.id)));
                                }
                              },
                            ),
                          );
                        },
                      ),
                    );
        }).toList(),
      ),
    );
  }
}
