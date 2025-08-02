import 'package:flutter/material.dart';
import 'package:bookin/api/search.dart';
import 'package:bookin/pages/project/project_detail_page.dart';
import 'package:bookin/pages/teacher/teacher_detail_page.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final SearchApi _searchApi = SearchApi();
  final TextEditingController _searchController = TextEditingController();

  List<HotKeyword> _hotKeywords = [];
  List<SearchHistoryItem> _searchHistory = [];
  List<SearchSuggestion> _suggestions = [];
  List<SearchResultItem> _searchResults = [];

  bool _isLoading = false;
  String? _errorMessage;

  String _currentSearchType = 'all'; // 'all', 'project', 'technician'
  String _currentSortBy = 'default'; // 'default', 'price', 'rating', 'sales'
  int _currentPage = 1;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    _fetchInitialData();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchInitialData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final hotKeywordsResponse = await _searchApi.getHotKeywords(context); // Pass context
      final searchHistoryResponse = await _searchApi.getSearchHistory(context); // Pass context

      if (hotKeywordsResponse.success) {
        _hotKeywords = hotKeywordsResponse.data ?? [];
      } else {
        _errorMessage = hotKeywordsResponse.message;
      }

      if (searchHistoryResponse.success) {
        _searchHistory = searchHistoryResponse.data ?? [];
      } else {
        _errorMessage = searchHistoryResponse.message;
      }
    } catch (e) {
      _errorMessage = '加载初始数据失败: ${e.toString()}';
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _onSearchChanged() {
    if (_searchController.text.isEmpty) {
      setState(() {
        _suggestions.clear();
        _searchResults.clear();
        _hasMore = true;
        _currentPage = 1;
      });
      _fetchInitialData(); // Reload hot keywords and history when search is empty
    } else {
      _fetchSuggestions(_searchController.text);
    }
  }

  Future<void> _fetchSuggestions(String keyword) async {
    try {
      final response = await _searchApi.getSuggestions(context, keyword); // Pass context
      if (response.success) {
        setState(() {
          _suggestions = response.data ?? [];
        });
      } else {
        // Handle error, maybe show a small toast
      }
    } catch (e) {
      // Handle error
    }
  }

  Future<void> _performSearch({String? keyword, String? type, String? sortBy, bool loadMore = false}) async {
    final String currentKeyword = keyword ?? _searchController.text;
    if (currentKeyword.isEmpty) return;

    if (!loadMore) {
      setState(() {
        _searchResults.clear();
        _currentPage = 1;
        _hasMore = true;
      });
    }

    if (!_hasMore && loadMore) return; // No more data to load

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await _searchApi.search(
        context, // Pass context
        keyword: currentKeyword,
        type: type ?? _currentSearchType,
        sortBy: sortBy ?? _currentSortBy,
        page: _currentPage,
        pageSize: 10,
      );

      if (response.success) {
        setState(() {
          _searchResults.addAll(response.data?.list ?? []);
          _hasMore = response.data?.pagination['hasMore'] ?? false;
          _currentPage++;
          // Save keyword to history after successful search
          _searchApi.saveKeyword(context, currentKeyword); // Pass context
          _fetchInitialData(); // Refresh history
        });
      } else {
        _showSnackBar(response.message);
      }
    } catch (e) {
      _showSnackBar('搜索失败: ${e.toString()}');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _clearSearchHistory() async {
    try {
      final response = await _searchApi.clearSearchHistory(context); // Pass context
      if (response.success) {
        _showSnackBar('搜索历史已清除');
        _fetchInitialData(); // Refresh history
      } else {
        _showSnackBar('清除失败: ${response.message}');
      }
    } catch (e) {
      _showSnackBar('清除失败: ${e.toString()}');
    }
  }

  Future<void> _deleteSearchHistoryItem(String id) async {
    try {
      final response = await _searchApi.deleteSearchHistory(context, id); // Pass context
      if (response.success) {
        _showSnackBar('删除成功');
        _fetchInitialData(); // Refresh history
      } else {
        _showSnackBar('删除失败: ${response.message}');
      }
    } catch (e) {
      _showSnackBar('删除失败: ${e.toString()}');
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
        title: const Text('搜索'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: '搜索项目或技师',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25.0),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[200],
              ),
              onSubmitted: (value) => _performSearch(keyword: value),
            ),
          ),
          if (_searchController.text.isEmpty) // Show hot keywords and history when search bar is empty
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Hot Keywords
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text('热门搜索', style: Theme.of(context).textTheme.titleMedium),
                    ),
                    Wrap(
                      spacing: 8.0,
                      runSpacing: 4.0,
                      children: _hotKeywords.map((keyword) {
                        return ActionChip(
                          label: Text(keyword.keyword),
                          onPressed: () {
                            _searchController.text = keyword.keyword;
                            _performSearch(keyword: keyword.keyword);
                          },
                        );
                      }).toList(),
                    ),
                    const Divider(),

                    // Search History
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('搜索历史', style: Theme.of(context).textTheme.titleMedium),
                          if (_searchHistory.isNotEmpty)
                            TextButton(
                              onPressed: _clearSearchHistory,
                              child: const Text('清空'),
                            ),
                        ],
                      ),
                    ),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _searchHistory.length,
                      itemBuilder: (context, index) {
                        final historyItem = _searchHistory[index];
                        return ListTile(
                          title: Text(historyItem.keyword),
                          trailing: IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => _deleteSearchHistoryItem(historyItem.id.toString()),
                          ),
                          onTap: () {
                            _searchController.text = historyItem.keyword;
                            _performSearch(keyword: historyItem.keyword);
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
            )
          else if (_suggestions.isNotEmpty) // Show suggestions when typing
            Expanded(
              child: ListView.builder(
                itemCount: _suggestions.length,
                itemBuilder: (context, index) {
                  final suggestion = _suggestions[index];
                  return ListTile(
                    title: Text(suggestion.keyword),
                    onTap: () {
                      _searchController.text = suggestion.keyword;
                      _performSearch(keyword: suggestion.keyword);
                    },
                  );
                },
              ),
            )
          else if (_searchResults.isNotEmpty) // Show search results
            Expanded(
              child: Column(
                children: [
                  // Filter and Sort options
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        DropdownButton<String>(
                          value: _currentSearchType,
                          onChanged: (String? newValue) {
                            setState(() {
                              _currentSearchType = newValue!;
                              _performSearch(type: newValue);
                            });
                          },
                          items: const <String>['all', 'project', 'technician']
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value == 'all' ? '全部' : (value == 'project' ? '项目' : '技师')),
                            );
                          }).toList(),
                        ),
                        DropdownButton<String>(
                          value: _currentSortBy,
                          onChanged: (String? newValue) {
                            setState(() {
                              _currentSortBy = newValue!;
                              _performSearch(sortBy: newValue);
                            });
                          },
                          items: const <String>['default', 'price', 'rating', 'sales']
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value == 'default' ? '默认' : (value == 'price' ? '价格' : (value == 'rating' ? '评分' : '销量'))),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: NotificationListener<ScrollNotification>(
                      onNotification: (ScrollNotification scrollInfo) {
                        if (!_isLoading && _hasMore && scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
                          _performSearch(loadMore: true);
                          return true;
                        }
                        return false;
                      },
                      child: ListView.builder(
                        itemCount: _searchResults.length + (_hasMore ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index == _searchResults.length) {
                            return const Center(child: CircularProgressIndicator());
                          }
                          final result = _searchResults[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                            child: ListTile(
                              leading: result.type == 'project'
                                  ? (result.cover != null 
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(4.0),
                                        child: Image.network(
                                          result.cover!,
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
                                    : const Icon(Icons.image))
                                  : (result.avatar != null 
                                       ? CircleAvatar(
                                           backgroundColor: Colors.grey[300],
                                           child: ClipOval(
                                             child: Image.network(
                                               result.avatar!,
                                               width: 40,
                                               height: 40,
                                               fit: BoxFit.cover,
                                               errorBuilder: (context, error, stackTrace) {
                                                 return const Icon(Icons.person, color: Colors.grey);
                                               },
                                               loadingBuilder: (context, child, loadingProgress) {
                                                 if (loadingProgress == null) return child;
                                                 return const SizedBox(
                                                   width: 20,
                                                   height: 20,
                                                   child: CircularProgressIndicator(strokeWidth: 2),
                                                 );
                                               },
                                             ),
                                           ),
                                         )
                                       : const Icon(Icons.person)),
                              title: Text(result.name),
                              subtitle: Text(
                                result.type == 'project'
                                    ? '¥${(result.price! / 100).toStringAsFixed(2)} | 已售: ${result.soldCount}'
                                    : '评分: ${result.rating} | 经验: ${result.experience}年',
                              ),
                              trailing: const Icon(Icons.arrow_forward_ios),
                              onTap: () {
                                if (result.type == 'project') {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ProjectDetailPage(projectId: result.id),
                                    ),
                                  );
                                } else if (result.type == 'technician') {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => TeacherDetailPage(teacherId: result.id),
                                    ),
                                  );
                                }
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            )
          else if (!_isLoading && _searchController.text.isNotEmpty && _searchResults.isEmpty)
            const Center(child: Text('无搜索结果')),
          if (_isLoading && _searchResults.isEmpty && _suggestions.isEmpty)
            const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}