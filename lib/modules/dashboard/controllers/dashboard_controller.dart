import 'package:get/get.dart';
import '../../../core/network/dio_client.dart';

class DashboardController extends GetxController {
  final isLoading = false.obs;
  final isStatusLoading = false.obs;
  final summary = <String, dynamic>{}.obs;
  final isOpen = false.obs;
  final storeName = 'My Store'.obs;

  @override
  void onInit() {
    super.onInit();
    fetchAll();
  }

  Future<void> fetchAll() async {
    await Future.wait([fetchSummary(), fetchStoreStatus()]);
  }

  Future<void> fetchSummary() async {
    isLoading.value = true;
    try {
      final res = await DioClient.instance.get('/store/dashboard/summary');
      final data = res.data['data'] ?? res.data;
      summary.value = data is Map<String, dynamic> ? data : {};
    } catch (_) {}
    isLoading.value = false;
  }

  Future<void> fetchStoreStatus() async {
    try {
      final res = await DioClient.instance.get('/store/me');
      final data = res.data['data'] ?? res.data;
      isOpen.value = data['isOpen'] ?? false;
      storeName.value = data['name'] ?? 'My Store';
    } catch (_) {}
  }

  Future<void> toggleStoreStatus() async {
    isStatusLoading.value = true;
    try {
      final newStatus = !isOpen.value;
      await DioClient.instance.put('/store/status', data: {'isOpen': newStatus});
      isOpen.value = newStatus;
      Get.snackbar(
        newStatus ? 'Store Open' : 'Store Closed',
        newStatus ? 'Your store is now accepting orders' : 'Your store is now closed',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (_) {
      Get.snackbar('Error', 'Failed to update store status',
          snackPosition: SnackPosition.BOTTOM);
    }
    isStatusLoading.value = false;
  }
}
