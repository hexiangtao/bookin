import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:bookin/api/project.dart';
import 'package:bookin/api/teacher.dart';
import 'package:bookin/pages/booking/create_booking_page.dart';
import 'package:bookin/pages/teacher/teacher_detail_page.dart';
import 'package:bookin/pages/teacher/teacher_list_page.dart';

class ProjectDetailPage extends StatefulWidget {
  final String projectId;

  const ProjectDetailPage({super.key, required this.projectId});

  @override
  State<ProjectDetailPage> createState() => _ProjectDetailPageState();
}

class _ProjectDetailPageState extends State<ProjectDetailPage> with SingleTickerProviderStateMixin {
  final ProjectApi _projectApi = ProjectApi();
  final TeacherApi _teacherApi = TeacherApi();
  Project? _projectDetail;
  List<Teacher> _recommendedTeachers = [];
  bool _isLoading = true;
  bool _isLoadingTeachers = false;
  String? _errorMessage;
  bool _isFavorited = false;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _fetchProjectDetail();
    _fetchRecommendedTeachers();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _fetchProjectDetail() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final response = await _projectApi.getProjectDetail(context, widget.projectId); // Pass context
      if (response.success) {
        _projectDetail = response.data;
      } else {
        _errorMessage = response.message;
      }
    } catch (e) {
      _errorMessage = '加载项目详情失败: ${e.toString()}';
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchRecommendedTeachers() async {
    setState(() {
      _isLoadingTeachers = true;
    });
    try {
      final response = await _teacherApi.getTechList(
        context,
        page: 1,
        pageSize: 5,
        projectId: widget.projectId,
      );
      if (response.success) {
        setState(() {
          _recommendedTeachers = response.data ?? [];
        });
      }
    } catch (e) {
      // Silently handle error for recommended teachers
    } finally {
      setState(() {
        _isLoadingTeachers = false;
      });
    }
  }

  void _toggleFavorite() {
    setState(() {
      _isFavorited = !_isFavorited;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isFavorited ? '已添加到收藏' : '已取消收藏'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _shareProject() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('分享功能开发中...'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.3),
            borderRadius: BorderRadius.circular(20),
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3),
              borderRadius: BorderRadius.circular(20),
            ),
            child: IconButton(
              icon: Icon(
                _isFavorited ? Icons.favorite : Icons.favorite_border,
                color: _isFavorited ? Colors.red : Colors.white,
                size: 20,
              ),
              onPressed: _toggleFavorite,
            ),
          ),
          Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3),
              borderRadius: BorderRadius.circular(20),
            ),
            child: IconButton(
              icon: const Icon(Icons.share, color: Colors.white, size: 20),
              onPressed: _shareProject,
            ),
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
                        onPressed: _fetchProjectDetail,
                        child: const Text('重试'),
                      ),
                    ],
                  ),
                )
              : _projectDetail == null
                  ? const Center(child: Text('项目不存在'))
                  : SingleChildScrollView(
                      child: Column(
                        children: [
                        // Enhanced Project Image Carousel with overlay and tag
                        Stack(
                          children: [
                            SizedBox(
                              height: 400,
                              child: _projectDetail!.images.isNotEmpty
                                  ? CarouselSlider(
                                      options: CarouselOptions(
                                        height: 400,
                                        viewportFraction: 1.0,
                                        enableInfiniteScroll: _projectDetail!.images.length > 1,
                                        autoPlay: _projectDetail!.images.length > 1,
                                        autoPlayInterval: const Duration(seconds: 4),
                                        autoPlayAnimationDuration: const Duration(milliseconds: 800),
                                        autoPlayCurve: Curves.fastOutSlowIn,
                                      ),
                                      items: _projectDetail!.images.map((imageUrl) {
                                        return Container(
                                          width: double.infinity,
                                          decoration: BoxDecoration(
                                            image: DecorationImage(
                                              image: NetworkImage(imageUrl),
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                          child: Container(
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                begin: Alignment.topCenter,
                                                end: Alignment.bottomCenter,
                                                colors: [
                                                  Colors.black.withOpacity(0.1),
                                                  Colors.black.withOpacity(0.3),
                                                ],
                                              ),
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                    )
                                  : Container(
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                          colors: [
                                            Colors.grey[300]!,
                                            Colors.grey[400]!,
                                          ],
                                        ),
                                      ),
                                      child: const Center(
                                        child: Icon(
                                          Icons.image,
                                          size: 80,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                            ),
                            // Banner tag
                            if (_projectDetail!.tags?.isNotEmpty == true)
                              Positioned(
                                top: 30,
                                right: 0,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [Color(0xFFFF5777), Color(0xFFFF7A9E)],
                                    ),
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(15),
                                      bottomLeft: Radius.circular(15),
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFFFF5777).withOpacity(0.3),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Text(
                                    _projectDetail!.tags!.first,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                        // Enhanced Project Basic Info with rounded top corners
                        Transform.translate(
                          offset: const Offset(0, -20),
                          child: Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(30),
                                topRight: Radius.circular(30),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.08),
                                  blurRadius: 20,
                                  offset: const Offset(0, -8),
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _projectDetail!.name,
                                    style: const TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF333333),
                                      height: 1.2,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Wrap(
                                    crossAxisAlignment: WrapCrossAlignment.center,
                                    children: [
                                      const Text(
                                        '¥',
                                        style: TextStyle(
                                          fontSize: 18,
                                          color: Color(0xFFFF5777),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        (_projectDetail!.price / 100).toStringAsFixed(2),
                                        style: const TextStyle(
                                          fontSize: 32,
                                          color: Color(0xFFFF5777),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      if (_projectDetail!.originalPrice > _projectDetail!.price)
                                        Text(
                                          '¥${(_projectDetail!.originalPrice / 100).toStringAsFixed(2)}',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            color: Color(0xFF999999),
                                            decoration: TextDecoration.lineThrough,
                                          ),
                                        ),
                                      const SizedBox(width: 12),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFFF5777).withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Icon(
                                              Icons.access_time,
                                              size: 14,
                                              color: Color(0xFFFF5777),
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              '${_projectDetail!.duration ?? 60}分钟',
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: Color(0xFF666666),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        '${_projectDetail!.salesCount}+选择',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Color(0xFF999999),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        // Enhanced Project Introduction Section
                        Container(
                          margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [Color(0xFFFF5777), Color(0xFFFF7A9E)],
                            ),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFFF5777).withOpacity(0.2),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Stack(
                            children: [
                              // Background decorative circles
                              Positioned(
                                top: -30,
                                right: -30,
                                child: Container(
                                  width: 100,
                                  height: 100,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.1),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: -40,
                                left: -40,
                                child: Container(
                                  width: 120,
                                  height: 120,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.1),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(24),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          width: 4,
                                          height: 24,
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(2),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Text(
                                          '${_projectDetail!.name}·项目介绍',
                                          style: const TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      (_projectDetail!.description?.isNotEmpty == true)
                                          ? _projectDetail!.description!
                                          : '暂无介绍',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        color: Colors.white,
                                        height: 1.6,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Enhanced Problem Section
                        _buildProblemSection(),
                        // Enhanced Massage Parts Section
                        _buildMassagePartsSection(),
                        // Enhanced Materials Section
                        _buildMaterialsSection(),
                        // Enhanced Features Section
                        // Note: features property not available in Project model
                        // if (_projectDetail!.features?.isNotEmpty == true)
                        //   _buildFeaturesSection(),
                        // Enhanced Process Section
                        // Note: process property not available in Project model
                        // if (_projectDetail!.process?.isNotEmpty == true)
                        //   _buildProcessSection(),
                        // Enhanced Contraindications Section
                        _buildContraindicationsSection(),
                        // Enhanced Recommended Teachers Section
                        if (_recommendedTeachers.isNotEmpty)
                          _buildRecommendedTeachersSection(),
                        // Enhanced Notice Section
                        _buildNoticeSection(),
                        // Bottom spacing for fixed button
                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                );
      bottomNavigationBar: _projectDetail == null
          ? null
          : Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.95),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 16,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  child: Container(
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFF5777), Color(0xFFFF7A9E)],
                      ),
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFF5777).withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(28),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const TeacherListPage(),
                            ),
                          );
                        },
                        child: const Center(
                          child: Text(
                            '选择技师',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
    );
  }

  Widget _buildProblemSection() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Decorative corner
          Positioned(
            top: 0,
            right: 0,
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: [
                    Colors.transparent,
                    const Color(0xFFFF5777).withOpacity(0.1),
                  ],
                ),
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(20),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 2,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF5777).withOpacity(0.6),
                          borderRadius: BorderRadius.circular(1),
                        ),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        '您是否有这些烦恼',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF333333),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        height: 2,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF5777).withOpacity(0.6),
                          borderRadius: BorderRadius.circular(1),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: _buildProblemTag('01', '颈肩僵硬'),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildProblemTag('02', '腰痛酸软'),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildProblemTag('03', '身体疲劳'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProblemTag(String number, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFFFF5F7), Colors.white],
        ),
        border: Border.all(color: const Color(0xFFFFCCD5)),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF5777).withOpacity(0.1),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            height: 3,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFFF5777), Color(0xFFFF7A9E)],
              ),
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            number,
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFFFF5777),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            text,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF666666),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildMassagePartsSection() {
    final parts = ['肩颈', '手臂', '腰部', '臀部', '腿部'];
    return _buildSectionContainer(
      title: '按摩部位',
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF5F7),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Wrap(
          spacing: 12,
          runSpacing: 12,
          children: parts.map((part) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFFFCCD5)),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFF5777).withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              part,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFFFF5777),
              ),
            ),
          )).toList(),
        ),
      ),
    );
  }

  Widget _buildMaterialsSection() {
    final materials = ['按摩巾', '一次性口罩', '一次性床单', '音乐盒', '肌肤枕', '眼罩'];
    return _buildSectionContainer(
      title: '包含物料',
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF5F7),
          borderRadius: BorderRadius.circular(16),
        ),
        child: GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 2.5,
          ),
          itemCount: materials.length,
          itemBuilder: (context, index) {
            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFFFCCD5)),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFF5777).withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  materials[index],
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFFFF5777),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildFeaturesSection() {
    // Note: features property not available in Project model
    // Using tags as alternative content
    return _buildSectionContainer(
      title: '特色功效',
      child: Column(
        children: _projectDetail!.tags.map((tag) => Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                tag,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF333333),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '专业的$tag服务',
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF666666),
                  height: 1.5,
                ),
              ),
            ],
          ),
        )).toList(),
      ),
    );
  }

  Widget _buildProcessSection() {
    // Note: process property not available in Project model
    // Using default service process steps
    List<String> defaultProcess = ['咨询预约', '到店服务', '专业操作', '售后跟踪'];
    return _buildSectionContainer(
      title: '服务流程',
      child: Column(
        children: defaultProcess.asMap().entries.map((entry) {
          int index = entry.key;
          String step = entry.value;
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFF5777),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    step,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF333333),
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildContraindicationsSection() {
    final contraindications = [
      '颈动脉斑块、椎管狭窄的禁用。',
      '心脏病、高血压、糖尿病、急慢性传染病、各种恶性肿瘤的禁用。',
      '急性传染病、感染性疾病、皮肤病的禁用。',
      '出血性疾病或外科手术的禁用。',
      '骨质疏松症、骨折未愈合、体内有金属固定物的禁用。',
    ];
    
    return _buildSectionContainer(
      title: '禁忌说明',
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFFFAFAFA),
          border: Border.all(color: const Color(0xFFEEEEEE)),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.only(bottom: 12, left: 8),
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Color(0xFFE0E0E0),
                    style: BorderStyle.solid,
                    width: 1,
                  ),
                ),
              ),
              child: const Text(
                '推拿按摩项目并非适应所有人群,以下不推荐禁忌症状的消费者请谨慎选择:',
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF555555),
                  fontWeight: FontWeight.bold,
                  height: 1.6,
                ),
              ),
            ),
            const SizedBox(height: 16),
            ...contraindications.asMap().entries.map((entry) {
              int index = entry.key;
              String item = entry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 8, right: 12),
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: Color(0xFFFF5777),
                        shape: BoxShape.circle,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        '${index + 1}.$item',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF666666),
                          height: 1.8,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendedTeachersSection() {
    return _buildSectionContainer(
      title: '推荐技师',
      child: SizedBox(
        height: 140,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: _recommendedTeachers.length,
          itemBuilder: (context, index) {
            final teacher = _recommendedTeachers[index];
            return Container(
              width: 280,
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFFFF5777).withOpacity(0.3),
                        width: 2,
                      ),
                    ),
                    child: ClipOval(
                      child: Image.network(
                        teacher.avatar,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[300],
                            child: const Icon(
                              Icons.person,
                              color: Colors.grey,
                              size: 30,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          teacher.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF333333),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(
                              Icons.star,
                              size: 14,
                              color: Color(0xFFFFCA3A),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              teacher.rating.toString(),
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF666666),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              '${teacher.orderCount}+单',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF999999),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        if (teacher.specialties?.isNotEmpty == true)
                          Wrap(
                            spacing: 6,
                            children: teacher.specialties!.take(2).map((specialty) => Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFF5777).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                specialty,
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: Color(0xFFFF5777),
                                ),
                              ),
                            )).toList(),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildNoticeSection() {
    final notices = [
      '到家平台商户提供推拿按摩，属于舒缓保健，不能取代医疗作用。如需治疗，请到医疗机构就诊。',
      '到家平台商户仅提供专业、正规的推拿按摩服务。如您提出不当要求、有不当行为，商户有权拒绝服务，并保留诉诸法律的权利。',
      '到家平台严禁私下交易。为了确保您的权益和安全，所有服务须通过平台进行下单和支付。如您和商户私下交易，平台不承担私下交易后可能出现的任何纠纷责任。',
      '到家平台不向未成年人提供任何形式的商品和服务，并有权取消订单。',
    ];
    
    return _buildSectionContainer(
      title: '下单须知',
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFFFAFAFA),
          border: Border.all(color: const Color(0xFFEEEEEE)),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.only(bottom: 12, left: 8),
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Color(0xFFE0E0E0),
                    style: BorderStyle.solid,
                    width: 1,
                  ),
                ),
              ),
              child: const Text(
                '下单前请仔细阅读:',
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF555555),
                  fontWeight: FontWeight.bold,
                  height: 1.6,
                ),
              ),
            ),
            const SizedBox(height: 16),
            ...notices.map((notice) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 8, right: 12),
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: Color(0xFFFF5777),
                      shape: BoxShape.circle,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      notice,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF666666),
                        height: 1.8,
                      ),
                    ),
                  ),
                ],
              ),
            )).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionContainer({required String title, required Widget child}) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Top gradient line
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 3,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFF5777), Color(0xFFFF7A9E)],
                ),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 4,
                      height: 24,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Color(0xFFFF5777), Color(0xFFFF7A9E)],
                        ),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF333333),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                child,
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProjectDetailTab() {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Project Images
          if (_projectDetail!.images != null && _projectDetail!.images!.isNotEmpty)
            Container(
              height: 250,
              child: PageView.builder(
                itemCount: _projectDetail!.images!.length,
                itemBuilder: (context, index) {
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      image: DecorationImage(
                        image: NetworkImage(_projectDetail!.images![index]),
                        fit: BoxFit.cover,
                      ),
                    ),
                  );
                },
              ),
            )
          else
            Container(
              height: 200,
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Icon(Icons.image, size: 64, color: Colors.grey),
              ),
            ),
          // Project Basic Info
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Project Name
                Text(
                  _projectDetail!.name,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF333333),
                  ),
                ),
                const SizedBox(height: 12),
                // Price Section
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    const Text(
                      '¥',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFFF5777),
                      ),
                    ),
                    Text(
                      '${(_projectDetail!.price / 100).toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFFF5777),
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (_projectDetail!.originalPrice != _projectDetail!.price)
                      Text(
                        '¥${(_projectDetail!.originalPrice / 100).toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Color(0xFF999999),
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                // Sales Statistics
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF5F7),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFFFCCD5)),
                  ),
                  child: Row(
                    children: [
                      _buildStatItem('评分', '${_projectDetail!.rating ?? 5.0}', Icons.star),
                      const SizedBox(width: 24),
                      _buildStatItem('销量', '${_projectDetail!.salesCount ?? 0}', Icons.shopping_cart),
                      const SizedBox(width: 24),
                      _buildStatItem('时长', '${_projectDetail!.duration ?? 60}分钟', Icons.access_time),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // TabBar Section
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    labelColor: const Color(0xFFFF5777),
                    unselectedLabelColor: const Color(0xFF666666),
                    indicatorColor: const Color(0xFFFF5777),
                    indicatorWeight: 3,
                    labelStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    unselectedLabelStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.normal,
                    ),
                    tabs: const [
                      Tab(text: '项目详情'),
                      Tab(text: '推荐技师'),
                      Tab(text: '用户评价'),
                    ],
                  ),
                ),
                SizedBox(
                  height: 600,
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildProjectDetailContent(),
                      _buildRecommendedTeachersTab(),
                      _buildReviewsTab(),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 100), // Space for bottom bar
        ],
      ),
    );
  }

  Widget _buildProjectDetailContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Project Introduction
          if (_projectDetail!.desc != null) ...[
            _buildSectionTitle('项目介绍', Icons.description),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F9FA),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE9ECEF)),
              ),
              child: Text(
                _projectDetail!.desc!,
                style: const TextStyle(
                  fontSize: 15,
                  height: 1.6,
                  color: Color(0xFF333333),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFF5777), Color(0xFFFF8FA3)],
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF333333),
          ),
        ),
      ],
    );
  }

  Widget _buildProcessStep(String step, String title, String description, {bool isLast = false}) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFF5777), Color(0xFFFF8FA3)],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Text(
                  step,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF333333),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF666666),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        if (!isLast) ...[
          const SizedBox(height: 16),
          Container(
            margin: const EdgeInsets.only(left: 16),
            width: 2,
            height: 20,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFF5777), Color(0xFFFF8FA3)],
              ),
              borderRadius: BorderRadius.circular(1),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ],
    );
  }

  Widget _buildRecommendedTeachersTab() {
    return _isLoadingTeachers
        ? const Center(child: CircularProgressIndicator())
        : _recommendedTeachers.isEmpty
            ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.person_search,
                      size: 64,
                      color: Color(0xFFCCCCCC),
                    ),
                    SizedBox(height: 16),
                    Text(
                      '暂无推荐技师',
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFF999999),
                      ),
                    ),
                  ],
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: _recommendedTeachers.length,
                itemBuilder: (context, index) {
                  final teacher = _recommendedTeachers[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TeacherDetailPage(teacherId: teacher.id),
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                // Teacher Avatar
                                Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(30),
                                    border: Border.all(
                                      color: const Color(0xFFFF5777).withOpacity(0.3),
                                      width: 2,
                                    ),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(28),
                                    child: teacher.avatar.isNotEmpty
                                        ? Image.network(
                                            teacher.avatar,
                                            fit: BoxFit.cover,
                                            errorBuilder: (context, error, stackTrace) {
                                              return Container(
                                                color: const Color(0xFFF5F5F5),
                                                child: const Icon(
                                                  Icons.person,
                                                  color: Color(0xFFCCCCCC),
                                                  size: 30,
                                                ),
                                              );
                                            },
                                          )
                                        : Container(
                                            color: const Color(0xFFF5F5F5),
                                            child: const Icon(
                                              Icons.person,
                                              color: Color(0xFFCCCCCC),
                                              size: 30,
                                            ),
                                          ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                // Teacher Info
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            teacher.name,
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF333333),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              gradient: const LinearGradient(
                                                colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                                              ),
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                            child: const Text(
                                              '金牌',
                                              style: TextStyle(
                                                fontSize: 10,
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 6,
                                              vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFFF5777).withOpacity(0.1),
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                const Icon(
                                                  Icons.star,
                                                  color: Color(0xFFFF5777),
                                                  size: 14,
                                                ),
                                                const SizedBox(width: 2),
                                                Text(
                                                  '${teacher.rating}',
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    color: Color(0xFFFF5777),
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Text(
                                            '服务${teacher.serviceCount}次',
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: Color(0xFF999999),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                // Price
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      '¥${((teacher.price ?? 0) / 100).toStringAsFixed(0)}',
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFFFF5777),
                                      ),
                                    ),
                                    const Text(
                                      '起',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFF999999),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            
                            // Specialties
                            if (teacher.specialties.isNotEmpty) ...[
                              const SizedBox(height: 16),
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: teacher.specialties.take(4).map((specialty) {
                                    return Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF0F8FF),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: const Color(0xFF87CEEB).withOpacity(0.5),
                                        ),
                                      ),
                                      child: Text(
                                        specialty,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Color(0xFF4682B4),
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                            ],
                            
                            const SizedBox(height: 16),
                            // Book Button
                            SizedBox(
                              width: double.infinity,
                              height: 44,
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => CreateBookingPage(
                                        techId: teacher.id,
                                        projectId: widget.projectId,
                                        date: DateTime.now().toString().split(' ')[0],
                                        startTime: '09:00',
                                      ),
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFFF5777),
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(22),
                                  ),
                                ),
                                child: const Text(
                                  '立即预约',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16, color: const Color(0xFF666666)),
        const SizedBox(width: 4),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF999999),
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF333333),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildReviewsTab() {
    // Mock review data - replace with actual API call
    final reviews = [
      {
        'userName': '张**',
        'avatar': '',
        'rating': 5.0,
        'date': '2024-01-15',
        'content': '技师手法很专业，服务态度也很好，环境干净整洁，下次还会再来的！',
        'images': [],
      },
      {
        'userName': '李**',
        'avatar': '',
        'rating': 4.5,
        'date': '2024-01-10',
        'content': '整体体验不错，技师很用心，就是等待时间稍微长了一点。',
        'images': [],
      },
      {
        'userName': '王**',
        'avatar': '',
        'rating': 5.0,
        'date': '2024-01-08',
        'content': '非常满意！技师手法专业，力度刚好，环境也很舒适，强烈推荐！',
        'images': [],
      },
    ];

    if (reviews.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.rate_review_outlined,
              size: 64,
              color: Color(0xFFCCCCCC),
            ),
            SizedBox(height: 16),
            Text(
              '暂无用户评价',
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF999999),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Rating Summary
        Container(
          margin: const EdgeInsets.all(20),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              // Overall Rating
              Column(
                children: [
                  Text(
                    '4.8',
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFFF5777),
                    ),
                  ),
                  Row(
                    children: List.generate(5, (index) {
                      return Icon(
                        index < 4 ? Icons.star : Icons.star_border,
                        color: const Color(0xFFFFD700),
                        size: 16,
                      );
                    }),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    '共128条评价',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF999999),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 24),
              // Rating Distribution
              Expanded(
                child: Column(
                  children: [
                    _buildRatingBar('5星', 0.8, 102),
                    _buildRatingBar('4星', 0.15, 19),
                    _buildRatingBar('3星', 0.03, 4),
                    _buildRatingBar('2星', 0.01, 2),
                    _buildRatingBar('1星', 0.01, 1),
                  ],
                ),
              ),
            ],
          ),
        ),
        
        // Reviews List
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: reviews.length,
            itemBuilder: (context, index) {
              final review = reviews[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // User Info
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: const Color(0xFFF5F5F5),
                          child: Text(
                            review['userName'].toString().substring(0, 1),
                            style: const TextStyle(
                              color: Color(0xFF666666),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                review['userName'].toString(),
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF333333),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  Row(
                                    children: List.generate(5, (starIndex) {
                                      return Icon(
                                        starIndex < (review['rating'] as double).floor()
                                            ? Icons.star
                                            : Icons.star_border,
                                        color: const Color(0xFFFFD700),
                                        size: 14,
                                      );
                                    }),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    review['date'].toString(),
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF999999),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Review Content
                    Text(
                      review['content'].toString(),
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF666666),
                        height: 1.5,
                      ),
                    ),
                    // Review Images (if any)
                    if (review['images'] != null && (review['images'] as List).isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: (review['images'] as List).take(3).map((image) {
                          return ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              image.toString(),
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRatingBar(String label, double percentage, int count) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(
            width: 24,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF666666),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              height: 6,
              decoration: BoxDecoration(
                color: const Color(0xFFF0F0F0),
                borderRadius: BorderRadius.circular(3),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: percentage,
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFD700),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 24,
            child: Text(
              count.toString(),
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF999999),
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}