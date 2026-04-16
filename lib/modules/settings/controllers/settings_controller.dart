import 'package:get/get.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/storage/storage_service.dart';
import '../../../data/models/store_model.dart';
import '../../../routes/app_routes.dart';

class SettingsController extends GetxController {
  final isLoading = false.obs;
  final isSaving = false.obs;
  final store = Rxn<StoreModel>();

  @override
  void onInit() {
    super.onInit();
    fetchStore();
  }

  Future<void> fetchStore() async {
    isLoading.value = true;
    try {
      final res = await DioClient.instance.get('/store/me');
      final data = res.data['data'] ?? res.data;
      store.value = StoreModel.fromJson(data);
      final type = store.value?.type;
      if (type != null) StorageService.setStoreType(type);
    } catch (_) {}
    isLoading.value = false;
  }

  Future<void> updateStore(Map<String, dynamic> data) async {
    isSaving.value = true;
    try {
      await DioClient.instance.put('/store/me', data: data);
      if (data['type'] != null) StorageService.setStoreType(data['type'].toString());
      await fetchStore();
      Get.back();
      Get.snackbar('Success', 'Store updated!', snackPosition: SnackPosition.BOTTOM);
    } catch (_) {
      Get.snackbar('Error', 'Failed to update store', snackPosition: SnackPosition.BOTTOM);
    }
    isSaving.value = false;
  }

  void logout() {
    StorageService.clearAll();
    Get.offAllNamed(AppRoutes.sendOtp);
  }
}
