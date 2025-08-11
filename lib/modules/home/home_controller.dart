import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/models/banner_model.dart';
import '../../core/models/project_model.dart';
import '../../core/models/technician_model.dart';
import '../../core/models/announcement_model.dart';
import '../../core/models/coupon_model.dart';
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
  final RxList<AnnouncementModel> announcements = <AnnouncementModel>[].obs;
  final RxList<CouponModel> coupons = <CouponModel>[].obs;
  
  // 各模块加载状态
  final RxBool bannersLoading = false.obs;
  final RxBool projectsLoading = false.obs;
  final RxBool techniciansLoading = false.obs;
  final RxBool announcementsLoading = false.obs;
  final RxBool couponsLoading = false.obs;
  
  // 各模块错误状态
  final RxBool bannersError = false.obs;
  final RxBool projectsError = false.obs;
  final RxBool techniciansError = false.obs;
  final RxBool announcementsError = false.obs;
  final RxBool couponsError = false.obs;
  
  // 弹窗控制
  final RxBool showAnnouncementDialog = false.obs;
  final RxBool showCouponDialog = false.obs;

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
    
    // 独立加载每个接口，避免单个接口失败影响整个页面
    await Future.wait([
      loadBanners(),
      loadHotProjects(),
      loadFeaturedTechnicians(),
      _loadAnnouncements(),
      _loadCoupons(),
    ]);
    
    loading.value = false;
    
    // 检查是否需要显示弹窗
    _checkDialogs();
    
    // 启动banner自动轮播
    _startBannerAutoPlay();
  }
  
  /// 加载横幅数据
  Future<void> loadBanners() async {
    bannersLoading.value = true;
    bannersError.value = false;
    try {
      final result = await _service.fetchBanners();
      banners.assignAll(result);
    } catch (e) {
      print('加载横幅失败: $e');
      bannersError.value = true;
      // 横幅加载失败不影响其他功能
    } finally {
      bannersLoading.value = false;
    }
  }
  
  /// 加载热门项目
  Future<void> loadHotProjects() async {
    projectsLoading.value = true;
    projectsError.value = false;
    try {
      final result = await _service.fetchHotProjects();
      projects.assignAll(result);
    } catch (e) {
      print('加载热门项目失败: $e');
      projectsError.value = true;
      // 项目加载失败不影响其他功能
    } finally {
      projectsLoading.value = false;
    }
  }
  
  /// 加载推荐技师
  Future<void> loadFeaturedTechnicians() async {
    techniciansLoading.value = true;
    techniciansError.value = false;
    try {
      final result = await _service.fetchFeaturedTechnicians();
      featuredTechnicians.assignAll(result);
    } catch (e) {
      print('加载推荐技师失败: $e');
      techniciansError.value = true;
      // 技师加载失败不影响其他功能
    } finally {
      techniciansLoading.value = false;
    }
  }
  
  /// 加载公告
  Future<void> _loadAnnouncements() async {
    announcementsLoading.value = true;
    announcementsError.value = false;
    try {
      final result = await _service.fetchAnnouncements();
      announcements.assignAll(result);
    } catch (e) {
      print('加载公告失败: $e');
      announcementsError.value = true;
      // 公告加载失败不影响其他功能
    } finally {
      announcementsLoading.value = false;
    }
  }
  
  /// 加载优惠券
  Future<void> _loadCoupons() async {
    couponsLoading.value = true;
    couponsError.value = false;
    try {
      final result = await _service.fetchCoupons();
      coupons.assignAll(result);
    } catch (e) {
      print('加载优惠券失败: $e');
      couponsError.value = true;
      // 优惠券加载失败不影响其他功能
    } finally {
      couponsLoading.value = false;
    }
  }

  /// 刷新数据
  Future<void> refreshData() async {
    if (loading.value) return;
    
    isRefreshing.value = true;
    errorMessage.value = '';
    
    // 独立刷新每个接口，避免单个接口失败影响整个刷新
    await Future.wait([
      loadBanners(),
      loadHotProjects(),
      loadFeaturedTechnicians(),
      _loadAnnouncements(),
      _loadCoupons(),
    ]);
    
    isRefreshing.value = false;
    
    // 重新启动banner自动轮播
    _startBannerAutoPlay();
    
    _errorHandler.showSuccess('刷新成功');
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
  /// 只有当所有数据都为空且不在加载状态时才显示错误页面
  bool get showError => !hasData && !loading.value && !isRefreshing.value;
  
  /// 检查是否需要显示弹窗
  void _checkDialogs() {
    // 检查公告弹窗
    final popupAnnouncements = announcements.where((a) => a.type == 'popup' && a.isValid).toList();
    if (popupAnnouncements.isNotEmpty) {
      showAnnouncementDialog.value = true;
    }
    
    // 检查优惠券弹窗
    final availableCoupons = coupons.where((c) => c.canReceive).toList();
    if (availableCoupons.isNotEmpty) {
      showCouponDialog.value = true;
    }
  }
  
  /// 关闭公告弹窗
  void closeAnnouncementDialog() {
    showAnnouncementDialog.value = false;
  }
  
  /// 关闭优惠券弹窗
  void closeCouponDialog() {
    showCouponDialog.value = false;
  }
  
  /// 领取优惠券
  Future<void> receiveCoupon(int couponId) async {
    try {
      final success = await _service.receiveCoupon(couponId);
      if (success) {
        // 更新本地数据
        final index = coupons.indexWhere((c) => c.id == couponId);
        if (index != -1) {
          final updatedCoupon = CouponModel(
            id: coupons[index].id,
            name: coupons[index].name,
            description: coupons[index].description,
            type: coupons[index].type,
            value: coupons[index].value,
            minAmount: coupons[index].minAmount,
            startTime: coupons[index].startTime,
            endTime: coupons[index].endTime,
            totalCount: coupons[index].totalCount,
            usedCount: coupons[index].usedCount,
            isReceived: true,
            isUsed: coupons[index].isUsed,
            imageUrl: coupons[index].imageUrl,
            applicableCategories: coupons[index].applicableCategories,
          );
          coupons[index] = updatedCoupon;
        }
        _errorHandler.showSuccess('优惠券领取成功');
      } else {
        _errorHandler.showWarning('优惠券领取失败');
      }
    } catch (e) {
      _errorHandler.handleError(e);
    }
  }
  
  /// 获取横幅公告
  List<AnnouncementModel> get bannerAnnouncements {
    return announcements.where((a) => a.type == 'banner' && a.isValid).toList();
  }
  
  /// 获取弹窗公告
  List<AnnouncementModel> get popupAnnouncements {
    return announcements.where((a) => a.type == 'popup' && a.isValid).toList();
  }
  
  /// 获取可领取的优惠券
  List<CouponModel> get availableCoupons {
    return coupons.where((c) => c.canReceive).toList();
  }
}