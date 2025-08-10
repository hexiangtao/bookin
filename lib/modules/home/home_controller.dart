import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/models/banner_model.dart';
import '../../core/models/project_model.dart';
import '../../core/models/technician_model.dart';
import '../../core/services/home_service.dart';
import '../../core/services/error_handler.dart';
import '../../core/services/network_exception.dart';

class HomeController extends GetxController {
  final HomeService _service = HomeService();
  final ErrorHandler _errorHandler = ErrorHandler();

  final RxInt bannerIndex = 0.obs;
  final RxBool loading = false.obs;
  final RxBool isRefreshing = false.obs;
  final RxString errorMessage = ''.obs;

  final RxList<BannerModel> banners = <BannerModel>[].obs;
  final RxList<ProjectModel> projects = <ProjectModel>[].obs;
  final RxList<TechnicianModel> featuredTechnicians = <TechnicianModel>[].obs;

  Timer? _bannerTimer;
  late PageController pageController;

  @override
  void onInit() {
    super.onInit();
    pageController = PageController();
    _loadAll();
  }

  @override
  void onClose() {
    _bannerTimer?.cancel();
    pageController.dispose();
    super.onClose();
  }

  /// 加载所有数据
  Future<void> _loadAll() async {
    if (isRefreshing.value) return;
    
    loading.value = true;
    errorMessage.value = '';
    
    try {
      final results = await Future.wait([
        _service.fetchBanners(),
        _service.fetchHotProjects(),
        _service.fetchFeaturedTechnicians(),
      ]);
      
      banners.assignAll(results[0] as List<BannerModel>);
      projects.assignAll(results[1] as List<ProjectModel>);
      featuredTechnicians.assignAll(results[2] as List<TechnicianModel>);
      
      // 启动banner自动轮播
      _startBannerAutoPlay();
      
    } catch (e) {
      errorMessage.value = e is NetworkException ? e.message : '加载数据失败';
      _errorHandler.handleError(e, showSnackbar: false);
    } finally {
      loading.value = false;
    }
  }

  /// 刷新数据
  Future<void> refreshData() async {
    if (loading.value) return;
    
    isRefreshing.value = true;
    errorMessage.value = '';
    
    try {
      final results = await Future.wait([
        _service.fetchBanners(),
        _service.fetchHotProjects(),
        _service.fetchFeaturedTechnicians(),
      ]);
      
      banners.assignAll(results[0] as List<BannerModel>);
      projects.assignAll(results[1] as List<ProjectModel>);
      featuredTechnicians.assignAll(results[2] as List<TechnicianModel>);
      
      // 重新启动banner自动轮播
      _startBannerAutoPlay();
      
      _errorHandler.showSuccess('刷新成功');
      
    } catch (e) {
      errorMessage.value = e is NetworkException ? e.message : '刷新失败';
      _errorHandler.handleError(e);
    } finally {
      isRefreshing.value = false;
    }
  }

  /// 重试加载
  Future<void> retryLoad() async {
    await _loadAll();
  }

  /// 更新横幅索引
  void updateBannerIndex(int index) {
    bannerIndex.value = index;
  }

  /// 启动banner自动轮播
  void _startBannerAutoPlay() {
    _bannerTimer?.cancel();
    if (banners.length > 1) {
      _bannerTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
        final nextIndex = (bannerIndex.value + 1) % banners.length;
        pageController.animateToPage(
          nextIndex,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      });
    }
  }

  /// 停止banner自动轮播
  void _stopBannerAutoPlay() {
    _bannerTimer?.cancel();
  }

  /// 获取是否有数据
  bool get hasData => banners.isNotEmpty || projects.isNotEmpty || featuredTechnicians.isNotEmpty;

  /// 获取是否显示错误状态
  bool get showError => errorMessage.isNotEmpty && !hasData && !loading.value;
}