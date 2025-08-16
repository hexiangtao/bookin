import 'package:get/get.dart';
import '../../core/models/technician_model.dart';
import '../../core/services/api_service.dart';

class TechnicianListController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();

  // 响应式状态
  final RxList<TechnicianModel> technicians = <TechnicianModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isLoadingMore = false.obs;
  final RxBool hasMore = true.obs;
  final RxString selectedCity = '正在定位...'.obs;
  final RxString selectedCityCode = ''.obs;
  final RxString gpsLocatedCity = '正在定位...'.obs;
  final RxString gpsLocatedCityCode = ''.obs;
  final RxString searchKeyword = ''.obs;
  final RxBool showFilterPopup = false.obs;
  final RxBool showCityPopup = false.obs;
  final RxBool isLoadingCities = false.obs;
  final RxBool isLoadingFilters = false.obs;
  
  // 筛选选项
  final RxList<Map<String, dynamic>> serviceTypes = <Map<String, dynamic>>[
    {'name': '全部', 'selected': true}
  ].obs;
  final RxList<Map<String, dynamic>> priceRanges = <Map<String, dynamic>>[
    {'name': '全部', 'selected': true}
  ].obs;
  final RxList<Map<String, dynamic>> ratings = <Map<String, dynamic>>[
    {'name': '全部', 'selected': true}
  ].obs;
  
  // 城市数据
  final RxList<String> hotCities = <String>[].obs;
  final RxMap<String, List<String>> cityGroups = <String, List<String>>{}.obs;
  
  int currentPage = 1;
  final int pageSize = 20;

  @override
  void onInit() {
    super.onInit();
    initPageData();
  }

  // 初始化页面数据
  Future<void> initPageData() async {
    await Future.wait([
      initLocationAndLoadCities(),
      loadFilterOptions(),
    ]);
    await loadTechnicians(refresh: true);
  }

  // 初始化位置和加载城市数据
  Future<void> initLocationAndLoadCities() async {
    try {
      // 这里应该调用定位服务获取当前位置
      // 暂时使用默认城市
      selectedCity.value = '北京';
      selectedCityCode.value = '110100';
      gpsLocatedCity.value = '北京';
      gpsLocatedCityCode.value = '110100';
      
      await loadCityData();
    } catch (error) {
      print('定位失败: $error');
      selectedCity.value = '定位失败';
      gpsLocatedCity.value = '定位失败 (点击重试)';
      await loadCityData();
    }
  }

  // 加载城市数据
  Future<void> loadCityData() async {
    if (isLoadingCities.value) return;
    isLoadingCities.value = true;

    try {
      final response = await _apiService.get('/api/cities');
      if (response['code'] == 0 && response['data'] != null) {
        final data = response['data'];
        
        // 设置热门城市
        if (data['hotCities'] != null) {
          hotCities.value = List<String>.from(data['hotCities']);
        }
        
        // 设置城市分组
        if (data['cityGroups'] != null) {
          cityGroups.value = Map<String, List<String>>.from(
            data['cityGroups'].map((key, value) => 
              MapEntry(key, List<String>.from(value))
            )
          );
        }
      }
    } catch (error) {
      print('加载城市数据失败: $error');
    } finally {
      isLoadingCities.value = false;
    }
  }

  // 加载筛选选项
  Future<void> loadFilterOptions() async {
    if (isLoadingFilters.value) return;
    isLoadingFilters.value = true;

    try {
      final response = await _apiService.get('/api/teacher/filter-options');
      if (response['code'] == 0 && response['data'] != null) {
        final data = response['data'];
        
        // 设置服务类型
        if (data['serviceTypes'] != null) {
          serviceTypes.value = [
            {'name': '全部', 'selected': true},
            ...List<Map<String, dynamic>>.from(
              data['serviceTypes'].map((item) => {
                'id': item['id'],
                'name': item['name'],
                'selected': false,
              })
            )
          ];
        }
        
        // 设置价格范围
        if (data['priceRanges'] != null) {
          priceRanges.value = [
            {'name': '全部', 'selected': true},
            ...List<Map<String, dynamic>>.from(
              data['priceRanges'].map((item) => {
                'id': item['id'],
                'name': item['name'],
                'min': item['min'],
                'max': item['max'],
                'selected': false,
              })
            )
          ];
        }
        
        // 设置评分
        if (data['ratings'] != null) {
          ratings.value = [
            {'name': '全部', 'selected': true},
            ...List<Map<String, dynamic>>.from(
              data['ratings'].map((item) => {
                'id': item['id'],
                'name': item['name'],
                'value': item['value'],
                'selected': false,
              })
            )
          ];
        }
      }
    } catch (error) {
      print('加载筛选选项失败: $error');
    } finally {
      isLoadingFilters.value = false;
    }
  }

  // 加载技师列表
  Future<void> loadTechnicians({bool refresh = false}) async {
    if (refresh) {
      currentPage = 1;
      hasMore.value = true;
      isLoading.value = true;
    } else {
      if (!hasMore.value || isLoadingMore.value) return;
      isLoadingMore.value = true;
    }

    try {
      final params = {
        'page': currentPage,
        'pageSize': pageSize,
        'cityCode': selectedCityCode.value,
        'keyword': searchKeyword.value,
      };
      
      // 添加筛选参数
      _addFilterParams(params);
      
      final response = await _apiService.get('/api/teacher/list', params: params);
      
      if (response['code'] == 0 && response['data'] != null) {
        final List<dynamic> list = response['data']['list'] ?? [];
        final List<TechnicianModel> newTechnicians = list
            .map((json) => TechnicianModel.fromJson(json))
            .toList();
        
        if (refresh) {
          technicians.value = newTechnicians;
        } else {
          technicians.addAll(newTechnicians);
        }
        
        hasMore.value = newTechnicians.length >= pageSize;
        if (hasMore.value) currentPage++;
      }
    } catch (error) {
      print('加载技师列表失败: $error');
      Get.snackbar('错误', '加载技师列表失败');
    } finally {
      isLoading.value = false;
      isLoadingMore.value = false;
    }
  }

  // 添加筛选参数
  void _addFilterParams(Map<String, dynamic> params) {
    // 服务类型
    final selectedServiceType = serviceTypes.firstWhereOrNull(
      (item) => item['selected'] == true && item['name'] != '全部'
    );
    if (selectedServiceType != null) {
      params['serviceTypeId'] = selectedServiceType['id'];
    }
    
    // 价格范围
    final selectedPriceRange = priceRanges.firstWhereOrNull(
      (item) => item['selected'] == true && item['name'] != '全部'
    );
    if (selectedPriceRange != null) {
      params['minPrice'] = selectedPriceRange['min'];
      params['maxPrice'] = selectedPriceRange['max'];
    }
    
    // 评分
    final selectedRating = ratings.firstWhereOrNull(
      (item) => item['selected'] == true && item['name'] != '全部'
    );
    if (selectedRating != null) {
      params['minRating'] = selectedRating['value'];
    }
  }

  // 搜索
  void onSearch(String keyword) {
    searchKeyword.value = keyword;
    loadTechnicians(refresh: true);
  }

  // 选择城市
  void selectCity(String cityName, String cityCode) {
    selectedCity.value = cityName;
    selectedCityCode.value = cityCode;
    showCityPopup.value = false;
    loadTechnicians(refresh: true);
  }

  // 切换筛选弹窗
  void toggleFilterPopup() {
    showFilterPopup.value = !showFilterPopup.value;
  }

  // 切换城市弹窗
  void toggleCityPopup() {
    showCityPopup.value = !showCityPopup.value;
  }

  // 选择筛选项
  void selectFilterItem(String type, int index) {
    switch (type) {
      case 'serviceType':
        _selectSingleItem(serviceTypes, index);
        break;
      case 'priceRange':
        _selectSingleItem(priceRanges, index);
        break;
      case 'rating':
        _selectSingleItem(ratings, index);
        break;
    }
  }

  // 选择单个筛选项（单选）
  void _selectSingleItem(RxList<Map<String, dynamic>> list, int index) {
    for (int i = 0; i < list.length; i++) {
      list[i]['selected'] = i == index;
    }
    list.refresh();
  }

  // 应用筛选
  void applyFilter() {
    showFilterPopup.value = false;
    loadTechnicians(refresh: true);
  }

  // 重置筛选
  void resetFilter() {
    _selectSingleItem(serviceTypes, 0);
    _selectSingleItem(priceRanges, 0);
    _selectSingleItem(ratings, 0);
  }

  // 跳转到技师详情
  void goToTechnicianDetail(TechnicianModel technician) {
    Get.toNamed('/technician/detail', arguments: technician);
  }

  // 刷新数据
  Future<void> onRefresh() async {
    await loadTechnicians(refresh: true);
  }

  // 加载更多
  Future<void> onLoadMore() async {
    await loadTechnicians();
  }
}