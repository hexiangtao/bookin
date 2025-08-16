import 'package:get/get.dart';
import '../../core/models/technician_model.dart';
import '../../core/models/project_model.dart';
import '../../core/services/api_service.dart';
import '../../core/services/auth_service.dart';
import '../../core/utils/toast_util.dart';

class TechnicianDetailController extends GetxController {
  // 响应式状态
  final isLoading = false.obs;
  final technician = Rxn<TechnicianModel>();
  final projects = <ProjectModel>[].obs;
  final comments = <Map<String, dynamic>>[].obs;
  final isFavorite = false.obs;
  final isBooking = false.obs;
  
  // Tab切换
  final activeTab = 'services'.obs;
  
  // 项目数量管理
  final projectCounts = <int, int>{}.obs;
  final totalCount = 0.obs;
  final totalPrice = 0.0.obs;
  
  // 评论加载状态
  final commentsLoading = false.obs;
  final hasMoreComments = true.obs;
  final commentsPage = 1.obs;
  
  // 分页
  final int pageSize = 10;
  
  String? technicianId;
  
  @override
  void onInit() {
    super.onInit();
    technicianId = Get.parameters['id'];
    if (technicianId != null) {
      loadTechnicianDetail();
    }
  }
  
  // 加载技师详情
  Future<void> loadTechnicianDetail() async {
    try {
      isLoading.value = true;
      
      // 并行加载技师信息、服务项目和评价
      final results = await Future.wait([
        _loadTechnicianInfo(),
        _loadTechnicianProjects(),
        _loadTechnicianComments(),
      ]);
      
      // 检查收藏状态
      await _checkFavoriteStatus();
      
    } catch (e) {
      ToastUtil.showError('加载技师信息失败：${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }
  
  // 加载技师基本信息
  Future<void> _loadTechnicianInfo() async {
    final response = await ApiService.instance.get(
      '/api/teacher/detail',
      queryParameters: {'id': technicianId},
    );
    
    if (response['code'] == 200) {
      technician.value = TechnicianModel.fromJson(response['data']);
    } else {
      throw Exception(response['message'] ?? '获取技师信息失败');
    }
  }
  
  // 加载技师服务项目
  Future<void> _loadTechnicianProjects() async {
    final response = await ApiService.instance.get(
      '/api/teacher/services',
      queryParameters: {'teacherId': technicianId},
    );
    
    if (response['code'] == 200) {
      final List<dynamic> data = response['data'] ?? [];
      projects.value = data.map((item) => ProjectModel.fromJson(item)).toList();
      
      // 初始化项目数量
      for (var project in projects) {
        projectCounts[project.id] = 0;
      }
    } else {
      throw Exception(response['message'] ?? '获取服务项目失败');
    }
  }
  
  // 加载技师评价
  Future<void> _loadTechnicianComments({bool loadMore = false}) async {
    if (!loadMore) {
      commentsLoading.value = true;
      commentsPage.value = 1;
      comments.clear();
    }
    
    try {
      final response = await ApiService.instance.get(
        '/api/teacher/comments',
        queryParameters: {
          'teacherId': technicianId,
          'page': commentsPage,
          'pageSize': pageSize,
        },
      );
      
      if (response['code'] == 200) {
        final List<dynamic> data = response['data']['list'] ?? [];
        final List<Map<String, dynamic>> newComments = 
            data.map((item) => Map<String, dynamic>.from(item)).toList();
        
        if (loadMore) {
          comments.addAll(newComments);
        } else {
          comments.value = newComments;
        }
        
        hasMoreComments.value = newComments.length >= pageSize;
        commentsPage.value++;
      }
    } catch (e) {
      ToastUtil.showError('加载评价失败：${e.toString()}');
    } finally {
      commentsLoading.value = false;
    }
  }
  
  // 检查收藏状态
  Future<void> _checkFavoriteStatus() async {
    if (!await AuthService.instance.isLoggedIn()) return;
    
    try {
      final response = await ApiService.instance.get(
        '/api/user/favorite/check',
        queryParameters: {
          'type': 'teacher',
          'targetId': technicianId,
        },
      );
      
      if (response['code'] == 200) {
        isFavorite.value = response['data']['isFavorite'] ?? false;
      }
    } catch (e) {
      // 忽略收藏状态检查错误
    }
  }
  
  // 切换收藏状态
  Future<void> toggleFavorite() async {
    if (!await AuthService.instance.isLoggedIn()) {
      ToastUtil.showError('请先登录');
      Get.toNamed('/login');
      return;
    }
    
    try {
      final response = await ApiService.instance.post(
        '/api/user/favorite/toggle',
        data: {
          'type': 'teacher',
          'targetId': technicianId,
        },
      );
      
      if (response['code'] == 200) {
        isFavorite.value = !isFavorite.value;
        ToastUtil.showSuccess(isFavorite.value ? '收藏成功' : '取消收藏');
      } else {
        ToastUtil.showError(response['message'] ?? '操作失败');
      }
    } catch (e) {
      ToastUtil.showError('操作失败：${e.toString()}');
    }
  }
  
  // 增加项目数量
  void increaseCount(ProjectModel project) {
    final currentCount = projectCounts[project.id] ?? 0;
    projectCounts[project.id] = currentCount + 1;
    _updateTotals();
  }
  
  // 减少项目数量
  void decreaseCount(ProjectModel project) {
    final currentCount = projectCounts[project.id] ?? 0;
    if (currentCount > 0) {
      projectCounts[project.id] = currentCount - 1;
      _updateTotals();
    }
  }
  
  // 更新总计
  void _updateTotals() {
    int count = 0;
    double price = 0.0;
    
    for (var project in projects) {
      final projectCount = projectCounts[project.id] ?? 0;
      count += projectCount;
      price += projectCount * (project.price / 100.0);
    }
    
    totalCount.value = count;
    totalPrice.value = price;
  }
  
  // Tab切换
  void switchTab(String tab) {
    activeTab.value = tab;
    if (tab == 'comments' && comments.isEmpty) {
      loadMoreComments();
    }
  }
  
  // 计算总数量和总价格的方法已移至_updateTotals中
  

  
  // 立即预订
  void bookNow() async {
    if (totalCount.value == 0) {
      Get.snackbar('提示', '请先选择服务项目');
      return;
    }
    
    isBooking.value = true;
    try {
      // TODO: 实现预订逻辑
      await Future.delayed(const Duration(seconds: 2));
      Get.snackbar('成功', '预订成功');
      // TODO: 导航到订单页面
    } catch (e) {
      Get.snackbar('错误', '预订失败');
    } finally {
      isBooking.value = false;
    }
  }
  
  // 查看证书
  void viewCertificates() {
    // TODO: 显示技师证书
    Get.snackbar('提示', '查看证书功能开发中');
  }
  
  // 图片预览
  void previewImage(String imageUrl, List<String> images) {
    // TODO: 实现图片预览功能
    Get.snackbar('提示', '图片预览功能开发中');
  }
  
  // 加载更多评论
  void loadMoreComments() async {
    if (commentsLoading.value || !hasMoreComments.value) return;
    
    commentsLoading.value = true;
    try {
      // TODO: 实现加载更多评论的API调用
      await Future.delayed(const Duration(seconds: 1));
      
      // 模拟数据
      final moreComments = [
        {
          'id': 'comment_${comments.length + 1}',
          'userName': '用户${comments.length + 1}',
          'avatar': 'https://via.placeholder.com/40',
          'rating': 5,
          'content': '服务很好，技师很专业',
          'serviceType': '按摩服务',
          'time': '2024-01-${15 + comments.length}',
        },
      ];
      
      comments.addAll(moreComments);
      commentsPage.value++;
      
      // 模拟没有更多数据
      if (comments.length >= 10) {
        hasMoreComments.value = false;
      }
    } catch (e) {
      Get.snackbar('错误', '加载评论失败');
    } finally {
      commentsLoading.value = false;
    }
  }
  

  

}