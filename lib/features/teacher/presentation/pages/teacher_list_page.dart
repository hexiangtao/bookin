import 'package:flutter/material.dart';
import 'package:bookin/api/teacher.dart';
import 'package:bookin/pages/teacher/teacher_detail_page.dart';

class TeacherListPage extends StatefulWidget {
  const TeacherListPage({super.key});

  @override
  State<TeacherListPage> createState() => _TeacherListPageState();
}

class _TeacherListPageState extends State<TeacherListPage> {
  List<Teacher> _teachers = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadTeachers();
  }

  Future<void> _loadTeachers() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });
      
      final response = await TeacherApi().getTechList(context);
      final teachers = response.data ?? [];
      setState(() {
        _teachers = teachers;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF333333)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          '选择技师',
          style: TextStyle(
            color: Color(0xFF333333),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF5777)),
              ),
            )
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '加载失败: $_error',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadTeachers,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF5777),
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('重试'),
                      ),
                    ],
                  ),
                )
              : _teachers.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.person_off,
                            size: 64,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 16),
                          Text(
                            '暂无技师',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _teachers.length,
                      itemBuilder: (context, index) {
                        final teacher = _teachers[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 16),
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
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(16),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => TeacherDetailPage(
                                      teacherId: teacher.id,
                                    ),
                                  ),
                                );
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(20),
                                child: Row(
                                  children: [
                                    // Teacher Avatar
                                    Container(
                                      width: 80,
                                      height: 80,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: const Color(0xFFFF5777).withOpacity(0.3),
                                          width: 3,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: const Color(0xFFFF5777).withOpacity(0.2),
                                            blurRadius: 10,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
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
                                                size: 40,
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 20),
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
                                              if (teacher.isVerified)
                                                Container(
                                                  padding: const EdgeInsets.symmetric(
                                                    horizontal: 6,
                                                    vertical: 2,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: const Color(0xFFFF5777),
                                                    borderRadius: BorderRadius.circular(8),
                                                  ),
                                                  child: const Text(
                                                    '认证',
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 10,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                            ],
                                          ),
                                          const SizedBox(height: 8),
                                          Row(
                                            children: [
                                              const Icon(
                                                Icons.star,
                                                size: 16,
                                                color: Color(0xFFFFCA3A),
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                teacher.rating.toString(),
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  color: Color(0xFF666666),
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              const SizedBox(width: 16),
                                              const Icon(
                                                Icons.work_outline,
                                                size: 16,
                                                color: Color(0xFF999999),
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                '${teacher.orderCount}+单',
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  color: Color(0xFF999999),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 12),
                                          if (teacher.specialties?.isNotEmpty == true)
                                            Wrap(
                                              spacing: 8,
                                              runSpacing: 6,
                                              children: teacher.specialties!.take(3).map((specialty) => Container(
                                                padding: const EdgeInsets.symmetric(
                                                  horizontal: 10,
                                                  vertical: 4,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: const Color(0xFFFF5777).withOpacity(0.1),
                                                  borderRadius: BorderRadius.circular(12),
                                                  border: Border.all(
                                                    color: const Color(0xFFFF5777).withOpacity(0.3),
                                                  ),
                                                ),
                                                child: Text(
                                                  specialty,
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    color: Color(0xFFFF5777),
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              )).toList(),
                                            ),
                                          const SizedBox(height: 12),
                                          Row(
                                            children: [
                                              const Icon(
                                                Icons.location_on_outlined,
                                                size: 14,
                                                color: Color(0xFF999999),
                                              ),
                                              const SizedBox(width: 4),
                                              Expanded(
                                                child: Text(
                                                  teacher.address ?? '位置信息暂无',
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    color: Color(0xFF999999),
                                                  ),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    // Arrow Icon
                                    const Icon(
                                      Icons.arrow_forward_ios,
                                      size: 16,
                                      color: Color(0xFFCCCCCC),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
    );
  }
}