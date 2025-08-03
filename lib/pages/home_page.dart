import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:bookin/api/base.dart';
import 'package:bookin/api/home.dart';
import 'package:bookin/api/project.dart';
import 'package:bookin/api/teacher.dart';
import 'package:bookin/pages/project/project_detail_page.dart' as project_detail;
import 'package:bookin/pages/teacher/teacher_detail_page.dart';
import 'package:bookin/pages/teacher_list_page.dart';
import 'package:bookin/widgets/network_image_with_fallback.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePageContent extends StatefulWidget {
  const HomePageContent({super.key});

  @override
  State<HomePageContent> createState() => _HomePageContentState();
}

class _HomePageContentState extends State<HomePageContent>
    with AutomaticKeepAliveClientMixin {
  final HomeApi _homeApi = HomeApi();
  final TeacherApi _teacherApi = TeacherApi();
  List<BannerItem> _banners = [];
  List<Announcement> _announcements = [];
  List<Project> _hotProjects = [];
  List<Teacher> _featuredTechnicians = [];
  bool _isLoading = true;
  String? _errorMessage;
  
  // 新增功能状态
  bool _showAnnouncementPopup = false;
  bool _showCouponPopup = false;
  Map<String, dynamic>? _couponInfo;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _fetchHomePageData();
      _checkInviteCode();
      _checkCouponPopup();
    });
  }

  Future<void> _fetchHomePageData() async {
    if (!mounted) return;
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final results = await Future.wait([
        _homeApi.getBanners(context).catchError((e) => ApiResponse<List<BannerItem>>(code: ApiCode.FAIL, success: false, data: [], message: 'Failed to load banners')),
        _homeApi.getAnnouncements(context).catchError((e) => ApiResponse<List<Announcement>>(code: ApiCode.FAIL, success: false, data: [], message: 'Failed to load announcements')),
        _homeApi.getHotProjects(context).catchError((e) => ApiResponse<List<Project>>(code: ApiCode.FAIL, success: false, data: [], message: 'Failed to load projects')),
        _teacherApi.getHighQualityTeachers(context).catchError((e) => ApiResponse<List<Teacher>>(code: ApiCode.FAIL, success: false, data: [], message: 'Failed to load teachers')),
      ]);

      if (!mounted) return;

      if (results[0].success) {
        _banners = List<BannerItem>.from(results[0].data ?? []);
      }

      if (results[1].success) {
        _announcements = List<Announcement>.from(results[1].data ?? []);
      }

      if (results[2].success) {
        _hotProjects = List<Project>.from(results[2].data ?? []);
      }

      if (results[3].success) {
        _featuredTechnicians = List<Teacher>.from(results[3].data ?? []);
      }

    } catch (e) {
      print('Home page data fetch error: $e');
      if (mounted) {
        setState(() {
          _errorMessage = '数据加载失败，请下拉刷新重试';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // 检查邀请码
  Future<void> _checkInviteCode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final inviteCode = prefs.getString('pendingInviteCode');
      
      if (inviteCode != null && inviteCode.isNotEmpty) {
        print('检测到邀请码: $inviteCode');
        // 这里可以处理邀请码逻辑
        // 处理完成后清除邀请码
        await prefs.remove('pendingInviteCode');
      }
    } catch (e) {
      print('检查邀请码失败: $e');
    }
  }

  // 检查优惠券弹窗
  Future<void> _checkCouponPopup() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final today = DateTime.now().toIso8601String().split('T')[0];
      final lastShownDate = prefs.getString('couponPopupLastShown');
      
      // 如果今天已经显示过，不再显示
      if (lastShownDate == today) {
        return;
      }

      // 延迟显示弹窗
      await Future.delayed(const Duration(milliseconds: 1500));
      
      // 模拟获取优惠券信息
      final couponInfo = {
        'couponId': '123',
        'name': '新人专享优惠券',
        'discountType': 1, // 1: 金额, 2: 折扣
        'amount': 50,
        'condition': '满100可用'
      };
      
      if (mounted) {
        setState(() {
          _couponInfo = couponInfo;
          _showCouponPopup = true;
        });
        
        // 记录今天已显示
        await prefs.setString('couponPopupLastShown', today);
      }
    } catch (e) {
      print('检查优惠券弹窗失败: $e');
    }
  }

  // 领取优惠券
  Future<void> _receiveCoupon() async {
    try {
      if (_couponInfo == null) return;
      
      // 显示加载
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('领取中...')),
      );
      
      // 调用API领取优惠券
      // await UserApi.receiveCoupon(_couponInfo!['couponId']);
      
      setState(() {
        _showCouponPopup = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('领取成功！')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('领取失败: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8), // H5版本的背景色
      appBar: AppBar(
        backgroundColor: const Color(0xFFFF5777),
        elevation: 0,
        title: const Text(
          '岚媛到家',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Colors.white),
            onPressed: () {
              setState(() {
                _showAnnouncementPopup = true;
              });
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: _fetchHomePageData,
            color: const Color(0xFFFF5777),
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF5777)),
                    ),
                  )
                : _errorMessage != null
                    ? _buildErrorWidget()
                    : _buildContent(),
          ),
          // 公告弹窗
          if (_showAnnouncementPopup) _buildAnnouncementPopup(),
          // 优惠券弹窗
          if (_showCouponPopup) _buildCouponPopup(),
        ],
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            _errorMessage!,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _fetchHomePageData,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF5777),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: const Text('重试'),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10), // 顶部间距
          
          // 轮播图
          _buildBannerSection(),
          
          // 服务特色
          _buildServiceFeaturesSection(),
          
          // 公告栏
          if (_announcements.isNotEmpty) _buildAnnouncementSection(),
          
          // 精选技师
          if (_featuredTechnicians.isNotEmpty) _buildFeaturedTechniciansSection(),
          
          // 项目分类标题
          _buildProjectCategorySection(),
          
          // 项目列表
          _buildProjectListSection(),
          
          const SizedBox(height: 100), // 底部空间
        ],
      ),
    );
  }

  Widget _buildBannerSection() {
    return Container(
      height: 200, // 增加轮播图高度，更接近H5版本
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: _banners.isEmpty
          ? _buildDefaultBanner()
          : CarouselSlider(
              options: CarouselOptions(
                height: 200,
                autoPlay: true,
                autoPlayInterval: const Duration(seconds: 4),
                viewportFraction: 1.0,
                enableInfiniteScroll: _banners.length > 1,
              ),
              items: _banners.map((banner) {
                return Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12), // 增加圆角
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Stack(
                      children: [
                        NetworkImageWithFallback(
                          imageUrl: banner.imageUrl,
                          width: double.infinity,
                          height: 200,
                          fit: BoxFit.cover,
                          errorWidget: _buildBannerPlaceholder(banner.title),
                          placeholder: _buildBannerPlaceholder('加载中...'),
                        ),
                        // 添加渐变遮罩
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withOpacity(0.1),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
    );
  }

  Widget _buildDefaultBanner() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFF5777),
            Color(0xFFFF4757),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Stack(
        children: [
          // 背景装饰
          Positioned(
            right: -20,
            top: -20,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.1),
              ),
            ),
          ),
          Positioned(
            left: -30,
            bottom: -30,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.05),
              ),
            ),
          ),
          // 主要内容
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.spa,
                    size: 36,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  '岚媛到家',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  '身体SPA • 对症按摩',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'VIP PREMIUM HEALTH BUTLER IN PRIVATE VILLA',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBannerPlaceholder(String title) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFFF5777),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.image,
              size: 28,
              color: Colors.white,
            ),
            const SizedBox(height: 8),
            Text(
              title.isNotEmpty ? title : '岚媛到家',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceFeaturesSection() {
    return Container(
      margin: const EdgeInsets.fromLTRB(15, 0, 15, 10),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 6,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildFeatureItem('🛡️', '服务保障'),
          Container(width: 1, height: 16, color: Colors.grey[200]),
          _buildFeatureItem('⭐', '专业技师'),
          Container(width: 1, height: 16, color: Colors.grey[200]),
          _buildFeatureItem('🏠', '上门服务'),
          Container(width: 1, height: 16, color: Colors.grey[200]),
          _buildFeatureItem('💯', '满意保证'),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(String emoji, String title) {
    return Row(
      children: [
        Text(
          emoji,
          style: TextStyle(fontSize: 10, color: Colors.grey[600]),
        ),
        const SizedBox(width: 4),
        Text(
          title,
          style: const TextStyle(
            fontSize: 13,
            color: Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildAnnouncementSection() {
    return Container(
      margin: const EdgeInsets.fromLTRB(15, 0, 15, 10),
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(
            Icons.volume_up,
            color: Color(0xFFFF5777),
            size: 18,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: SizedBox(
              height: 20,
              child: PageView.builder(
                scrollDirection: Axis.vertical,
                itemCount: _announcements.length,
                itemBuilder: (context, index) {
                  final announcement = _announcements[index];
                  return Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      announcement.title,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black54,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturedTechniciansSection() {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
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
          // 标题行
          Container(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Color(0xFFF5F5F5),
                  width: 1,
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF5777).withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Text('👑', style: TextStyle(fontSize: 16)),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      '精选技师',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const TeacherListPage(),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF5777).withOpacity(0.08),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Row(
                      children: [
                        Text(
                          '查看更多',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 2),
                        Icon(
                          Icons.arrow_forward_ios,
                          size: 12,
                          color: Colors.grey[700],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // 技师列表
          SizedBox(
            height: 200, // 从160增加到200，提供更充足的空间
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              itemCount: _featuredTechnicians.isEmpty ? 3 : _featuredTechnicians.length,
              itemBuilder: (context, index) {
                if (_featuredTechnicians.isEmpty) {
                  return _buildTechnicianPlaceholder(['芸芸', '婧然', '奶茶'][index]);
                }
                
                final technician = _featuredTechnicians[index];
                return _buildTechnicianCard(technician);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTechnicianCard(Teacher technician) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TeacherDetailPage(teacherId: technician.id),
          ),
        );
      },
      child: Container(
        width: 110,
        height: 192, // 增加卡片总高度以适应更高的头像
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            // 图片区域
            Stack(
              children: [
                Container(
                  width: 94, // 图片容器宽度
                  height: 110, // 增加图片容器高度匹配H5版本
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: NetworkImageWithFallback(
                      imageUrl: technician.avatar,
                      width: 94,
                      height: 110,
                      fit: BoxFit.cover,
                      errorWidget: _buildTechnicianImagePlaceholder(technician.name),
                      placeholder: _buildTechnicianImagePlaceholder(technician.name),
                    ),
                  ),
                ),
                if (technician.isRecommend)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFF4757), Color(0xFFFF3742)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(6),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFF4757).withOpacity(0.3),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '🔥',
                            style: TextStyle(fontSize: 8),
                          ),
                          SizedBox(width: 1),
                          Text(
                            '红牌',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
            // 文本区域 - 使用固定高度确保显示完整
            Container(
              height: 66, // 固定文本区域高度
              padding: const EdgeInsets.fromLTRB(8, 4, 8, 8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    technician.name,
                    style: const TextStyle(
                      fontSize: 14, // 稍微减小字体
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '已接单${technician.serviceCount}',
                    style: TextStyle(
                      fontSize: 11, // 减小字体确保显示完整
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTechnicianPlaceholder(String name) {
    return Container(
      width: 110,
      height: 176, // 与真实卡片保持一致的高度
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 94,
            height: 94,
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: _buildTechnicianImagePlaceholder(name),
            ),
          ),
          Container(
            height: 66,
            padding: const EdgeInsets.fromLTRB(8, 4, 8, 8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),
                Text(
                  '已接单0',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTechnicianImagePlaceholder(String name) {
    return Container(
      color: const Color(0xFFF5F5F5),
      child: Center(
        child: Text(
          name.isNotEmpty ? name[0] : '?',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFFFF5777),
          ),
        ),
      ),
    );
  }

  Widget _buildProjectCategorySection() {
    return Container(
      margin: const EdgeInsets.fromLTRB(15, 0, 15, 10),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF5F8),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: const Row(
        children: [
          Text(
            '全部项目',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Color(0xFF666666),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProjectListSection() {
    if (_hotProjects.isEmpty) {
      return Container(
        height: 120,
        margin: const EdgeInsets.symmetric(horizontal: 12),
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
        child: const Center(
          child: Text(
            '暂无项目',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        children: _hotProjects.map((project) {
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // 项目图片
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: NetworkImageWithFallback(
                        imageUrl: project.icon ?? '',
                        width: 110,
                        height: 110,
                        fit: BoxFit.cover,
                        errorWidget: _buildProjectImagePlaceholder(),
                        placeholder: _buildProjectImagePlaceholder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // 项目信息
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 项目标题
                        Text(
                          project.name,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        // 项目信息行
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFF5777).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                '${project.duration ?? 60}分钟',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFFFF5777),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '已出售${project.num ?? 0}+',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // 价格和按钮行
                        Row(
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.baseline,
                              textBaseline: TextBaseline.alphabetic,
                              children: [
                                const Text(
                                  '¥',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFFFF5777),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  '${(project.price / 100).toStringAsFixed(0)}',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    color: Color(0xFFFF5777),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(width: 8),
                            if (project.originalPrice > project.price)
                              Text(
                                '¥${(project.originalPrice / 100).toStringAsFixed(0)}',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey[400],
                                  decoration: TextDecoration.lineThrough,
                                ),
                              ),
                            const Spacer(),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => project_detail.ProjectDetailPage(projectId: project.id.toString()),
                                  ),
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [Color(0xFFFF5777), Color(0xFFFF4757)],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFFFF5777).withOpacity(0.4),
                                      blurRadius: 6,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: const Text(
                                  '选择技师',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildProjectImagePlaceholder() {
    return Container(
      color: const Color(0xFFF5F5F5),
      child: const Center(
        child: Icon(
          Icons.spa,
          color: Color(0xFFFF5777),
          size: 24,
        ),
      ),
    );
  }

  // 公告弹窗
  Widget _buildAnnouncementPopup() {
    return Container(
      color: Colors.black.withOpacity(0.5),
      child: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 40),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                '系统公告',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              if (_announcements.isNotEmpty)
                ..._announcements.map((announcement) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    announcement.title,
                    style: const TextStyle(fontSize: 14),
                  ),
                ))
              else
                const Text(
                  '暂无公告',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _showAnnouncementPopup = false;
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF5777),
                  foregroundColor: Colors.white,
                ),
                child: const Text('确定'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 优惠券弹窗
  Widget _buildCouponPopup() {
    if (_couponInfo == null) return const SizedBox.shrink();
    
    return Container(
      color: Colors.black.withOpacity(0.5),
      child: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 40),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                '🎉 恭喜获得优惠券',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFFF5777),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFF5777), Color(0xFFFF4757)],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Text(
                      _couponInfo!['name'],
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '¥${_couponInfo!['amount']}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      _couponInfo!['condition'],
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () {
                        setState(() {
                          _showCouponPopup = false;
                        });
                      },
                      child: const Text('稍后再说'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _receiveCoupon,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF5777),
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('立即领取'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
