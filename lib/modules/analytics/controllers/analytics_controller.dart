import 'package:get/get.dart';
import '../../../core/network/dio_client.dart';

class AnalyticsController extends GetxController {
  final isLoading = false.obs;
  final overview = <String, dynamic>{}.obs;
  final sales = [].obs;
  final topProducts = [].obs;
  final topProductNames = <String, String>{}.obs;
  final revenueTrend = [].obs;

  @override
  void onInit() {
    super.onInit();
    fetchAll();
  }

  Future<void> fetchAll() async {
    isLoading.value = true;
    await Future.wait([
      fetchOverview(),
      fetchSales(),
      fetchTopProducts(),
      fetchRevenueTrend(),
    ]);
    isLoading.value = false;
  }

  Future<void> fetchOverview() async {
    try {
      final res = await DioClient.instance.get('/store/analytics/overview');
      final data = res.data['data'] ?? res.data;
      overview.value = data is Map<String, dynamic> ? data : {};
    } catch (_) {}
  }

  Future<void> fetchSales() async {
    try {
      final res = await DioClient.instance.get('/store/analytics/sales');
      final data = res.data['data'] ?? res.data;
      sales.value = data is List ? data : [];
    } catch (_) {}
  }

  Future<void> fetchTopProducts() async {
    try {
      final res = await DioClient.instance.get('/store/analytics/top-products');
      final data = res.data['data'] ?? res.data;
      final list = data is List ? data : [];
      topProducts.value = list;
      // Fetch names for menu items
      await _resolveProductNames(list);
    } catch (_) {}
  }

  Future<void> _resolveProductNames(List items) async {
    try {
      // Fetch full menu to resolve names
      final menuRes = await DioClient.instance.get('/store/menu', queryParameters: {'limit': 100});
      final menuData = menuRes.data['data'] ?? menuRes.data;
      final menuList = menuData is List ? menuData : [];
      final nameMap = <String, String>{};
      for (final item in menuList) {
        nameMap[item['id'] ?? ''] = item['name'] ?? '';
      }
      topProductNames.value = nameMap;
    } catch (_) {}
  }

  Future<void> fetchRevenueTrend() async {
    try {
      final res = await DioClient.instance.get('/store/analytics/revenue-trend');
      final data = res.data['data'] ?? res.data;
      revenueTrend.value = data is List ? data : [];
    } catch (_) {}
  }
}
