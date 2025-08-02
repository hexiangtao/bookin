import 'package:flutter/material.dart';
import 'package:bookin/api/teacher.dart';

class TeacherListPage extends StatefulWidget {
  const TeacherListPage({super.key});

  @override
  State<TeacherListPage> createState() => _TeacherListPageState();
}

class _TeacherListPageState extends State<TeacherListPage> {
  final TeacherApi _teacherApi = TeacherApi();
  List<Teacher> _teachers = [];
  bool _isLoading = true;
  String? _errorMessage;
  final TextEditingController _searchController = TextEditingController();
  int _selectedTab = 0;
  String _selectedCity = '北京市';
  List<String> _cities = ['北京市', '上海市', '广州市', '深圳市', '杭州市', '南京市'];
  Map<String, List<String>> _cityGroups = {
    'A': ['安庆市', '安阳市', '鞍山市'],
    'B': ['北京市', '保定市', '包头市', '本溪市'],
    'C': ['重庆市', '成都市', '长沙市', '长春市', '常州市', '沧州市'],
    'D': ['大连市', '东莞市', '大庆市', '丹东市'],
    'F': ['佛山市', '福州市', '抚顺市', '阜阳市'],
    'G': ['广州市', '贵阳市', '桂林市', '赣州市'],
    'H': ['杭州市', '哈尔滨市', '合肥市', '海口市', '呼和浩特市'],
    'J': ['济南市', '金华市', '嘉兴市', '江门市', '九江市'],
    'K': ['昆明市', '开封市'],
    'L': ['兰州市', '洛阳市', '连云港市', '临沂市'],
    'N': ['南京市', '宁波市', '南昌市', '南宁市', '南通市'],
    'Q': ['青岛市', '泉州市', '秦皇岛市'],
    'S': ['上海市', '深圳市', '苏州市', '沈阳市', '石家庄市', '绍兴市'],
    'T': ['天津市', '太原市', '台州市', '唐山市'],
    'W': ['武汉市', '无锡市', '温州市', '潍坊市', '芜湖市'],
    'X': ['西安市', '厦门市', '徐州市', '襄阳市'],
    'Y': ['银川市', '扬州市', '烟台市', '盐城市'],
    'Z': ['郑州市', '珠海市', '中山市', '淄博市', '湛江市']
  };
  int _currentPage = 1;
  bool _hasMore = true;
  bool _isLoadingMore = false;


  @override
  void initState() {
    super.initState();
    _fetchTeachers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchTeachers() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _currentPage = 1;
      _hasMore = true;
    });

    try {
      final response = await _teacherApi.getTechList(
        context,
        page: _currentPage,
        pageSize: 10,
        keyword: _searchController.text.isNotEmpty ? _searchController.text : null,
        tab: _selectedTab,
        city: _selectedCity,
      );
      if (response.success) {
        _teachers = response.data ?? [];
        _currentPage = 2;
        _hasMore = _teachers.length >= 10; // 假设每页10条数据
      } else {
        _errorMessage = response.message;
      }
    } catch (e) {
      _errorMessage = '加载失败: $e';
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadMoreTeachers() async {
    if (_isLoadingMore || !_hasMore) return;

    setState(() {
      _isLoadingMore = true;
    });

    try {
      final response = await _teacherApi.getTechList(
        context,
        page: _currentPage,
        pageSize: 10,
        keyword: _searchController.text.isNotEmpty ? _searchController.text : null,
        tab: _selectedTab,
        city: _selectedCity,
      );
      if (response.success) {
        final moreTeachers = response.data ?? [];
        setState(() {
          _teachers.addAll(moreTeachers);
          _currentPage++;
          _hasMore = moreTeachers.length >= 10; // 假设每页10条数据
          _isLoadingMore = false;
        });
      } else {
        setState(() {
          _isLoadingMore = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoadingMore = false;
      });
      // 可以显示加载更多失败的提示
    }
  }

  Widget _buildTabItem(String title, int index) {
    final isSelected = _selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedTab = index;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isSelected ? const Color(0xFFFF6B6B) : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              color: isSelected ? const Color(0xFFFF6B6B) : const Color(0xFF666666),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          '技师列表',
          style: TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Column(
        children: [
          // 标签栏
          Container(
            color: Colors.white,
            child: Row(
              children: [
                _buildTabItem('全部', 0),
                _buildTabItem('免出行费', 1),
                _buildTabItem('可服务', 2),
              ],
            ),
          ),
          // 搜索和筛选栏
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // 城市选择器
                GestureDetector(
                  onTap: () {
                    _showCitySelector();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFFE0E0E0)),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _selectedCity,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF333333),
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.keyboard_arrow_down,
                          size: 16,
                          color: Color(0xFF666666),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // 搜索框
                Expanded(
                  child: Container(
                    height: 36,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: TextField(
                      controller: _searchController,
                      decoration: const InputDecoration(
                        hintText: '请输入技师姓名',
                        hintStyle: TextStyle(
                          color: Color(0xFF999999),
                          fontSize: 14,
                        ),
                        prefixIcon: Icon(
                          Icons.search,
                          color: Color(0xFF999999),
                          size: 18,
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // 筛选按钮
                GestureDetector(
                  onTap: () {
                    _showFilterDialog();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFFE0E0E0)),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          '筛选',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF333333),
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.tune,
                          size: 16,
                          color: Color(0xFF666666),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // 技师列表
          Expanded(
            child: RefreshIndicator(
              onRefresh: _fetchTeachers,
              child: _isLoading && _teachers.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : _errorMessage != null && _teachers.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(_errorMessage!),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: _fetchTeachers,
                                child: const Text('重试'),
                              ),
                            ],
                          ),
                        )
                      : NotificationListener<ScrollNotification>(
                          onNotification: (ScrollNotification scrollInfo) {
                            if (!_isLoadingMore &&
                                _hasMore &&
                                scrollInfo.metrics.pixels ==
                                    scrollInfo.metrics.maxScrollExtent) {
                              _loadMoreTeachers();
                            }
                            return false;
                          },
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                            itemCount: _teachers.length + (_hasMore ? 1 : 0),
                            itemBuilder: (context, index) {
                              if (index == _teachers.length) {
                                // 加载更多指示器
                                return Container(
                                  padding: const EdgeInsets.all(16),
                                  alignment: Alignment.center,
                                  child: _isLoadingMore
                                      ? const Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            SizedBox(
                                              width: 16,
                                              height: 16,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                valueColor: AlwaysStoppedAnimation<Color>(
                                                  Color(0xFFFF4A6A),
                                                ),
                                              ),
                                            ),
                                            SizedBox(width: 8),
                                            Text(
                                              '努力加载中...',
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Color(0xFF999999),
                                              ),
                                            ),
                                          ],
                                        )
                                      : const Text(
                                          '上拉加载更多',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Color(0xFF999999),
                                          ),
                                        ),
                                );
                              }
                              return _buildTeacherCard(_teachers[index]);
                            },
                          ),
                        ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTeacherCard(Teacher teacher) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 0,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 头像区域
          Stack(
            children: [
              Container(
                width: 80,
                height: 110,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: const Color(0xFFF5F5F5),
                ),
                child: teacher.avatar != null && teacher.avatar!.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          teacher.avatar!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(
                              Icons.person,
                              size: 40,
                              color: Colors.grey,
                            );
                          },
                        ),
                      )
                    : const Icon(
                        Icons.person,
                        size: 40,
                        color: Colors.grey,
                      ),
              ),
              // 优质技师标签
              if ((teacher.rating ?? 0) >= 4.5)
                Positioned(
                  top: -3,
                  left: -3,
                  child: Container(
                    width: 18,
                    height: 18,
                    decoration: const BoxDecoration(
                      color: Color(0xFFFF4A6A),
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Text(
                        '优',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 20),
          // 技师信息区域
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 姓名和认证标签行
                Row(
                  children: [
                    Text(
                      teacher.name ?? '未知技师',
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF333333),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // VIP认证标签
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFF4A6A), Color(0xFFFF7A9E)],
                        ),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        '官方推荐',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                // 服务次数
                Text(
                  '已服务：${teacher.serviceCount ?? 0}单',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF999999),
                  ),
                ),
                const SizedBox(height: 8),
                // 店铺信息和评价
                Row(
                  children: [
                    const Icon(
                      Icons.store,
                      size: 12,
                      color: Color(0xFF999999),
                    ),
                    const SizedBox(width: 4),
                    const Text(
                      '个人技师',
                      style: TextStyle(
                        fontSize: 11,
                        color: Color(0xFF999999),
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Icon(
                      Icons.chat_bubble_outline,
                      size: 12,
                      color: Color(0xFF999999),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${(teacher.serviceCount ?? 0) * 2}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF999999),
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Icon(
                      Icons.favorite_border,
                      size: 12,
                      color: Color(0xFF999999),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${(teacher.serviceCount ?? 0) ~/ 3}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF999999),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // 技师标签
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    _buildTechTag('专业按摩'),
                    _buildTechTag('服务贴心'),
                    _buildTechTag('手法娴熟'),
                  ],
                ),
              ],
            ),
          ),
          // 右侧预约信息
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // 距离信息
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.location_on,
                    size: 12,
                    color: Color(0xFFFF4A6A),
                  ),
                  const SizedBox(width: 2),
                  const Text(
                    '2.5km',
                    style: TextStyle(
                      fontSize: 11,
                      color: Color(0xFF333333),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 60),
              // 预约按钮
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFF7A9E), Color(0xFFFF4A6A)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Text(
                  '立即预约',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTechTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFFFF4A6A).withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 10,
          color: Color(0xFFFF4A6A),
        ),
      ),
    );
  }

  void _showCitySelector() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
        ),
        child: Column(
          children: [
            // 标题
            Container(
              padding: const EdgeInsets.all(30),
              child: const Text(
                '选择城市',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF333333),
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 当前定位城市
                    const Text(
                      '当前定位城市',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF999999),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      margin: const EdgeInsets.only(bottom: 30),
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            _selectedCity = '北京市';
                          });
                          Navigator.pop(context);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF0F4),
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(color: const Color(0xFFFF4A6A)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.location_on,
                                size: 12,
                                color: Color(0xFFFF4A6A),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '北京市',
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFFFF4A6A),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // 热门城市
                    const Text(
                      '热门城市',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF999999),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Wrap(
                      spacing: 20,
                      runSpacing: 20,
                      children: _cities.map((city) => InkWell(
                        onTap: () {
                          setState(() {
                            _selectedCity = city;
                          });
                          Navigator.pop(context);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF5F5F5),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Text(
                            city,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF333333),
                            ),
                          ),
                        ),
                      )).toList(),
                    ),
                    const SizedBox(height: 30),
                    // 城市分组列表
                    ..._cityGroups.entries.map((entry) => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          entry.key,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFFF4A6A),
                          ),
                        ),
                        const SizedBox(height: 15),
                        Wrap(
                          spacing: 20,
                          runSpacing: 20,
                          children: entry.value.map((city) => InkWell(
                            onTap: () {
                              setState(() {
                                _selectedCity = city;
                              });
                              Navigator.pop(context);
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF5F5F5),
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: Text(
                                city,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF333333),
                                ),
                              ),
                            ),
                          )).toList(),
                        ),
                        const SizedBox(height: 20),
                      ],
                    )).toList(),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
        ),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 服务类型
                    const Text(
                      '服务类型',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF333333),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Wrap(
                      spacing: 20,
                      runSpacing: 20,
                      children: ['全部', '按摩', '推拿', '足疗', '刮痧']
                          .map((type) => _buildFilterChip(type))
                          .toList(),
                    ),
                    const SizedBox(height: 30),
                    // 价格区间
                    const Text(
                      '价格区间',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF333333),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Wrap(
                      spacing: 20,
                      runSpacing: 20,
                      children: ['不限', '100-200', '200-300', '300-500', '500以上']
                          .map((price) => _buildFilterChip(price))
                          .toList(),
                    ),
                    const SizedBox(height: 30),
                    // 评分
                    const Text(
                      '评分',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF333333),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Wrap(
                      spacing: 20,
                      runSpacing: 20,
                      children: ['不限', '4.0以上', '4.5以上', '4.8以上', '5.0']
                          .map((rating) => _buildFilterChip(rating))
                          .toList(),
                    ),
                  ],
                ),
              ),
            ),
            // 底部按钮
            Container(
              padding: const EdgeInsets.all(30),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 40,
                      margin: const EdgeInsets.only(right: 20),
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        style: OutlinedButton.styleFrom(
                          backgroundColor: const Color(0xFFF5F5F5),
                          side: BorderSide.none,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(40),
                          ),
                        ),
                        child: const Text(
                          '重置',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF666666),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      height: 40,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFF7A9E), Color(0xFFFF4A6A)],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(40),
                      ),
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(40),
                          ),
                        ),
                        child: const Text(
                          '确定',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    bool isSelected = false; // 这里可以根据实际选中状态来设置
    
    return InkWell(
      onTap: () {
        // 处理选中逻辑
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFFF0F4) : const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(30),
          border: isSelected ? Border.all(color: const Color(0xFFFF4A6A)) : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isSelected ? const Color(0xFFFF4A6A) : const Color(0xFF666666),
          ),
        ),
      ),
    );
  }
}