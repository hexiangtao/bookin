import 'package:flutter/material.dart';
import 'package:bookin/api/teacher.dart';
import 'package:bookin/api/comment.dart';
import 'package:bookin/pages/booking/create_booking_page.dart';
import 'package:bookin/pages/project/project_detail_page.dart';

class TeacherDetailPage extends StatefulWidget {
  final String teacherId;

  const TeacherDetailPage({super.key, required this.teacherId});

  @override
  State<TeacherDetailPage> createState() => _TeacherDetailPageState();
}

class _TeacherDetailPageState extends State<TeacherDetailPage>
    with SingleTickerProviderStateMixin {
  final TeacherApi _teacherApi = TeacherApi();
  final CommentApi _commentApi = CommentApi();
  late TabController _tabController;

  Teacher? _teacherInfo;
  List<TeacherProject> _teacherProjects = [];
  List<Comment> _teacherComments = [];

  bool _isLoading = true;

  String? _errorMessage;
  bool _isFavorited = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _fetchTeacherDetails();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _fetchTeacherDetails() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final teacherInfoResponse = await _teacherApi.getTechDetail(context, widget.teacherId); // Pass context
      final teacherProjectsResponse = await _teacherApi.getTeachProjects(context, widget.teacherId); // Pass context
      final teacherCommentsResponse = await _commentApi.getCommentList(context, targetId: widget.teacherId, targetType: 'tech'); // Pass context

      if (teacherInfoResponse.success) {
        _teacherInfo = teacherInfoResponse.data;
      } else {
        _errorMessage = teacherInfoResponse.message;
      }

      if (teacherProjectsResponse.success) {
        _teacherProjects = teacherProjectsResponse.data ?? [];
      } else {
        _errorMessage = teacherProjectsResponse.message;
      }

      if (teacherCommentsResponse.success) {
        _teacherComments = teacherCommentsResponse.data?.list ?? [];
      } else {
        _errorMessage = teacherCommentsResponse.message;
      }
    } catch (e) {
      _errorMessage = '加载技师详情失败: ${e.toString()}';
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _toggleFavorite() {
    setState(() {
      _isFavorited = !_isFavorited;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isFavorited ? '已收藏技师' : '已取消收藏'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _shareTeacher() {
    // TODO: Implement share functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('分享功能开发中...'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('技师详情'),
        actions: [
          IconButton(
            icon: Icon(
              _isFavorited ? Icons.favorite : Icons.favorite_border,
              color: _isFavorited ? Colors.red : null,
            ),
            onPressed: _toggleFavorite,
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _shareTeacher,
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
                        onPressed: _fetchTeacherDetails,
                        child: const Text('重试'),
                      ),
                    ],
                  ),
                )
              : _teacherInfo == null
                  ? const Center(child: Text('技师不存在'))
                  : Column(
                      children: [
                        // Teacher Header
                        Container(
                          padding: const EdgeInsets.all(16.0),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.1),
                                spreadRadius: 1,
                                blurRadius: 3,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              // Teacher Avatar
                              ClipRRect(
                                borderRadius: BorderRadius.circular(40),
                                child: _teacherInfo!.avatar.isNotEmpty
                                    ? Image.network(
                                        _teacherInfo!.avatar,
                                        width: 80,
                                        height: 80,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) {
                                          return Container(
                                            width: 80,
                                            height: 80,
                                            color: Colors.grey[300],
                                            child: const Icon(Icons.person, color: Colors.grey, size: 40),
                                          );
                                        },
                                      )
                                    : Container(
                                        width: 80,
                                        height: 80,
                                        color: Colors.grey[300],
                                        child: const Icon(Icons.person, color: Colors.grey, size: 40),
                                      ),
                              ),
                              const SizedBox(width: 16),
                              // Teacher Info
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _teacherInfo!.name,
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        const Icon(Icons.star, color: Colors.amber, size: 16),
                                        const SizedBox(width: 4),
                                        Text('${_teacherInfo!.rating}'),
                                        const SizedBox(width: 12),
                                        Text('${_teacherInfo!.serviceCount}单'),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    if (_teacherInfo!.tags.isNotEmpty)
                                      Wrap(
                                        spacing: 4.0,
                                        children: _teacherInfo!.tags.map((tag) => 
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: Colors.blue.withOpacity(0.1),
                                              borderRadius: BorderRadius.circular(12),
                                              border: Border.all(color: Colors.blue.withOpacity(0.3)),
                                            ),
                                            child: Text(
                                              tag,
                                              style: const TextStyle(color: Colors.blue, fontSize: 10),
                                            ),
                                          )
                                        ).toList(),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Tab Bar
                        Container(
                          color: Colors.white,
                          child: TabBar(
                            controller: _tabController,
                            labelColor: Colors.blue,
                            unselectedLabelColor: Colors.grey,
                            indicatorColor: Colors.blue,
                            tabs: const [
                              Tab(text: '技师详情'),
                              Tab(text: '服务项目'),
                              Tab(text: '客户评价'),
                            ],
                          ),
                        ),
                        // Tab Bar View
                        Expanded(
                          child: TabBarView(
                            controller: _tabController,
                            children: [
                              _buildTeacherDetailTab(),
                              _buildServiceProjectsTab(),
                              _buildCommentsTab(),
                            ],
                          ),
                        ),
                      ],
                     ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  // TODO: Add consultation functionality
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('咨询功能开发中...')),
                  );
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.blue,
                  side: const BorderSide(color: Colors.blue),
                  minimumSize: const Size(0, 50),
                ),
                child: const Text('咨询'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: () {
                  if (_teacherProjects.isNotEmpty) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CreateBookingPage(
                          techId: widget.teacherId,
                          projectId: _teacherProjects.first.id,
                          date: DateTime.now().toString().split(' ')[0],
                          startTime: '09:00',
                        ),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('该技师暂无可预约项目')),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(0, 50),
                ),
                child: const Text('立即预约'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTeacherDetailTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Basic Info Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '基本信息',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildInfoRow('技师姓名', _teacherInfo!.name),
                  _buildInfoRow('服务评分', '${_teacherInfo!.rating}分'),
                  _buildInfoRow('服务次数', '${_teacherInfo!.serviceCount}次'),
                  if (_teacherInfo!.experience != null)
                    _buildInfoRow('从业经验', '${_teacherInfo!.experience}年'),
                  if (_teacherInfo!.certification != null && _teacherInfo!.certification!.isNotEmpty)
                    _buildInfoRow('专业认证', _teacherInfo!.certification!),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Specialties Card
          if (_teacherInfo!.specialties.isNotEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '专业技能',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8.0,
                      runSpacing: 8.0,
                      children: _teacherInfo!.specialties.map((specialty) => 
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.green.withOpacity(0.3)),
                          ),
                          child: Text(
                            specialty,
                            style: const TextStyle(color: Colors.green, fontSize: 12),
                          ),
                        )
                      ).toList(),
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 16),
          // Introduction Card
          if (_teacherInfo!.introduction != null && _teacherInfo!.introduction!.isNotEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '个人简介',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _teacherInfo!.introduction!,
                      style: const TextStyle(fontSize: 14, height: 1.5),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(color: Colors.grey),
            ),
          ),
          Text(value),
        ],
      ),
    );
  }

  Widget _buildServiceProjectsTab() {
    return _teacherProjects.isEmpty
        ? const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.work_off, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text('暂无服务项目', style: TextStyle(color: Colors.grey)),
              ],
            ),
          )
        : ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: _teacherProjects.length,
            itemBuilder: (context, index) {
              final project = _teacherProjects[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProjectDetailPage(projectId: project.id),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        // Project Icon
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: project.icon.isNotEmpty
                              ? Image.network(
                                  project.icon,
                                  width: 60,
                                  height: 60,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      width: 60,
                                      height: 60,
                                      color: Colors.grey[300],
                                      child: const Icon(Icons.medical_services, color: Colors.grey),
                                    );
                                  },
                                )
                              : Container(
                                  width: 60,
                                  height: 60,
                                  color: Colors.grey[300],
                                  child: const Icon(Icons.medical_services, color: Colors.grey),
                                ),
                        ),
                        const SizedBox(width: 12),
                        // Project Info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                project.name,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              if (project.tips.isNotEmpty)
                                Text(
                                  project.tips,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                            ],
                          ),
                        ),
                        // Price and Book Button
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '¥${(project.price / 100).toStringAsFixed(0)}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.red,
                              ),
                            ),
                            const SizedBox(height: 8),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => CreateBookingPage(
                                      techId: widget.teacherId.toString(),
                                      projectId: project.id.toString(),
                                      date: DateTime.now().toString().split(' ')[0],
                                      startTime: '09:00',
                                    ),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                                minimumSize: const Size(60, 32),
                              ),
                              child: const Text('预约', style: TextStyle(fontSize: 12)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
  }

  Widget _buildCommentsTab() {
    return _teacherComments.isEmpty
        ? const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.rate_review, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text('暂无客户评价', style: TextStyle(color: Colors.grey)),
              ],
            ),
          )
        : ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: _teacherComments.length,
            itemBuilder: (context, index) {
              final comment = _teacherComments[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // User Info and Rating
                      Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: comment.userAvatar.isNotEmpty
                                ? Image.network(
                                    comment.userAvatar,
                                    width: 40,
                                    height: 40,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        width: 40,
                                        height: 40,
                                        color: Colors.grey[300],
                                        child: const Icon(Icons.person, color: Colors.grey),
                                      );
                                    },
                                  )
                                : Container(
                                    width: 40,
                                    height: 40,
                                    color: Colors.grey[300],
                                    child: const Icon(Icons.person, color: Colors.grey),
                                  ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  comment.userName,
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Row(
                                  children: List.generate(5, (i) {
                                    return Icon(
                                      i < comment.rating ? Icons.star : Icons.star_border,
                                      color: Colors.amber,
                                      size: 16,
                                    );
                                  }),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            comment.createTime.split('T')[0],
                            style: const TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // Comment Content
                      Text(
                        comment.content,
                        style: const TextStyle(fontSize: 14, height: 1.5),
                      ),
                      // Comment Images
                      if (comment.images.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8.0,
                          runSpacing: 8.0,
                          children: comment.images.map((imageUrl) {
                            return ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                imageUrl,
                                width: 80,
                                height: 80,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    width: 80,
                                    height: 80,
                                    color: Colors.grey[300],
                                    child: const Icon(Icons.error, color: Colors.grey),
                                  );
                                },
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          );
  }
}
