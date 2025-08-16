import 'package:get/get.dart';
import '../../core/models/technician_model.dart';
import '../../core/services/technician_service.dart';
import '../../core/services/storage_service.dart';

class TechnicianController extends GetxController {
  final TechnicianService _service = TechnicianService();
  final StorageService _storage = Get.find<StorageService>();

  // 技师列表数据
  final RxList<TechnicianModel> technicians = <TechnicianModel>[].obs;
  
  // 加载状态
  final RxBool isLoading = false.obs;
  final RxBool isLoadingMore = false.obs;
  final RxBool hasError = false.obs;
  final RxString errorMessage = ''.obs;
  
  // 分页相关
  final RxInt currentPage = 1.obs;
  final RxBool hasMore = true.obs;
  final int pageSize = 10;
  
  // 搜索和筛选
  final RxString searchKeyword = ''.obs;
  final RxInt currentTab = 0.obs; // 0: 全部, 1: 免出行费, 2: 可服务
  final RxString selectedCity = '正在定位...'.obs;
  final RxString selectedCityCode = ''.obs;
  
  // 筛选选项
  final RxList<FilterOption> serviceTypes = <FilterOption>[].obs;
  final RxList<FilterOption> priceRanges = <FilterOption>[].obs;
  final RxList<FilterOption> ratings = <FilterOption>[].obs;
  
  // 筛选状态
  final RxString selectedRating = ''.obs;
  
  // 筛选选项列表（用于UI显示）
  List<FilterOption> get ratingOptions => ratings;
  
  // 城市相关
  final RxList<CityModel> hotCities = <CityModel>[].obs;
  final RxMap<String, List<CityModel>> cityGroups = <String, List<CityModel>>{}.obs;
  final RxBool cityNotOpened = false.obs;
  final RxString cityNotOpenTip = '当前城市暂未开放,敬请期待'.obs;
  final RxBool isLoadingCities = false.obs;
  
  // GPS定位的城市
  final Rxn<CityModel> gpsLocatedCity = Rxn<CityModel>();
  
  // 弹窗状态
  final RxBool showFilterPopup = false.obs;
  final RxBool showCityPopup = false.obs;

  @override
  void onInit() {
    super.onInit();
    _initUserCity();
    loadFilterOptions();
    loadTechnicians();
  }

  /// 初始化用户城市信息
  void _initUserCity() {
    // 从设置中获取城市信息
    final cityName = _storage.getSetting<String>('cityName');
    final cityCode = _storage.getSetting<String>('cityCode');
    if (cityName != null) {
      selectedCity.value = cityName;
      selectedCityCode.value = cityCode ?? '';
    }
  }

  /// 加载技师列表
  Future<void> loadTechnicians({bool refresh = false}) async {
    if (refresh) {
      currentPage.value = 1;
      hasMore.value = true;
      technicians.clear();
    }
    
    if (isLoading.value || (!hasMore.value && !refresh)) return;
    
    if (refresh) {
      isLoading.value = true;
    } else {
      isLoadingMore.value = true;
    }
    
    hasError.value = false;
    
    try {
      final result = await _service.fetchTechnicians(
        page: currentPage.value,
        pageSize: pageSize,
        category: _getSelectedServiceType(),
        location: selectedCityCode.value.isNotEmpty ? selectedCityCode.value : null,
        sortBy: _getSortBy(),
      );
      
      if (refresh) {
        technicians.assignAll(result);
      } else {
        technicians.addAll(result);
      }
      
      // 判断是否还有更多数据
      hasMore.value = result.length >= pageSize;
      if (hasMore.value) {
        currentPage.value++;
      }
      
    } catch (e) {
      print('加载技师列表失败: $e');
      hasError.value = true;
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
      isLoadingMore.value = false;
    }
  }

  /// 搜索技师
  Future<void> searchTechnicians() async {
    if (searchKeyword.value.trim().isEmpty) {
      Get.snackbar('提示', '请输入搜索内容');
      return;
    }
    
    currentPage.value = 1;
    hasMore.value = true;
    technicians.clear();
    isLoading.value = true;
    hasError.value = false;
    
    try {
      final result = await _service.searchTechnicians(
        keyword: searchKeyword.value.trim(),
        page: currentPage.value,
        pageSize: pageSize,
      );
      
      technicians.assignAll(result);
      hasMore.value = result.length >= pageSize;
      if (hasMore.value) {
        currentPage.value++;
      }
      
    } catch (e) {
      print('搜索技师失败: $e');
      hasError.value = true;
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  /// 清空搜索
  void clearSearch() {
    searchKeyword.value = '';
    loadTechnicians(refresh: true);
  }

  /// 切换筛选标签
  void switchTab(int index) {
    if (currentTab.value == index) return;
    currentTab.value = index;
    loadTechnicians(refresh: true);
  }

  /// 选择城市
  void selectCity(CityModel city) {
    selectedCity.value = city.name;
    selectedCityCode.value = city.code;
    showCityPopup.value = false;
    
    // 更新用户信息
    _updateUserCityInfo(city.name, city.code);
    
    // 重新加载技师列表
    loadTechnicians(refresh: true);
  }

  /// 加载筛选选项
  Future<void> loadFilterOptions() async {
    // 初始化默认筛选选项
    serviceTypes.assignAll([
      FilterOption(id: '', name: '全部', selected: true),
      FilterOption(id: 'massage', name: '按摩', selected: false),
      FilterOption(id: 'spa', name: 'SPA', selected: false),
      FilterOption(id: 'beauty', name: '美容', selected: false),
    ]);
    
    priceRanges.assignAll([
      FilterOption(id: '', name: '全部', selected: true),
      FilterOption(id: '0-100', name: '100元以下', selected: false),
      FilterOption(id: '100-200', name: '100-200元', selected: false),
      FilterOption(id: '200-500', name: '200-500元', selected: false),
      FilterOption(id: '500+', name: '500元以上', selected: false),
    ]);
    
    ratings.assignAll([
      FilterOption(id: '', name: '全部', selected: true),
      FilterOption(id: '4.5+', name: '4.5分以上', selected: false),
      FilterOption(id: '4.0+', name: '4.0分以上', selected: false),
      FilterOption(id: '3.5+', name: '3.5分以上', selected: false),
    ]);
  }

  /// 选择筛选选项
  void selectFilterOption(String category, int index) {
    List<FilterOption> options;
    switch (category) {
      case 'serviceTypes':
        options = serviceTypes;
        break;
      case 'priceRanges':
        options = priceRanges;
        break;
      case 'ratings':
        options = ratings;
        break;
      default:
        return;
    }
    
    // 取消所有选中状态
    for (var option in options) {
      option.selected = false;
    }
    
    // 选中当前选项
    options[index].selected = true;
    
    // 更新对应的响应式列表
    switch (category) {
      case 'serviceTypes':
        serviceTypes.refresh();
        break;
      case 'priceRanges':
        priceRanges.refresh();
        break;
      case 'ratings':
        ratings.refresh();
        break;
    }
  }

  /// 重置筛选
  void resetFilters() {
    for (var options in [serviceTypes, priceRanges, ratings]) {
      for (int i = 0; i < options.length; i++) {
        options[i].selected = i == 0; // 只选中第一个（全部）
      }
    }
    serviceTypes.refresh();
    priceRanges.refresh();
    ratings.refresh();
  }

  /// 应用筛选
  void applyFilters() {
    showFilterPopup.value = false;
    loadTechnicians(refresh: true);
  }

  /// 获取选中的服务类型
  String? _getSelectedServiceType() {
    final selected = serviceTypes.firstWhereOrNull((option) => option.selected);
    return selected?.id.isNotEmpty == true ? selected?.id : null;
  }

  /// 获取排序方式
  String? _getSortBy() {
    switch (currentTab.value) {
      case 1: // 免出行费
        return 'free_travel';
      case 2: // 可服务
        return 'available';
      default:
        return null;
    }
  }

  /// 更新用户城市信息
  void _updateUserCityInfo(String cityName, String cityCode) {
    final userInfo = _storage.getUserInfo();
    if (userInfo != null) {
      // 如果用户信息存在，更新城市信息
      // 注意：这里需要根据 UserModel 的实际结构来更新
      // 暂时跳过更新，因为 UserModel 可能没有 cityName 和 cityCode 字段
    }
    // 可以考虑使用其他方式保存城市信息，比如单独的设置项
    _storage.saveSetting('cityName', cityName);
    _storage.saveSetting('cityCode', cityCode);
  }

  /// 刷新数据
  void refresh() {
    loadTechnicians(refresh: true);
  }

  /// 加载更多
  void loadMore() {
    if (!isLoadingMore.value && hasMore.value) {
      loadTechnicians();
    }
  }
}

/// 筛选选项模型
class FilterOption {
  final String id;
  final String name;
  bool selected;
  
  FilterOption({
    required this.id,
    required this.name,
    this.selected = false,
  });
}

/// 城市模型
class CityModel {
  final String name;
  final String code;
  
  const CityModel({
    required this.name,
    required this.code,
  });
  
  factory CityModel.fromJson(Map<String, dynamic> json) {
    return CityModel(
      name: json['name'] ?? '',
      code: json['code'] ?? '',
    );
  }
}