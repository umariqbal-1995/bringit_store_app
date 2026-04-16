import 'package:get/get.dart';
import '../../../core/network/dio_client.dart';
import '../../../data/models/menu_item_model.dart';

class StoreMenuController extends GetxController {
  final isLoading = false.obs;
  final isSaving = false.obs;
  final menuItems = <MenuItemModel>[].obs;
  final selectedItem = Rxn<MenuItemModel>();

  @override
  void onInit() {
    super.onInit();
    fetchMenu();
  }

  Future<void> fetchMenu() async {
    isLoading.value = true;
    try {
      final res = await DioClient.instance.get('/store/menu');
      final data = res.data['data'] ?? res.data;
      final list = data is List ? data : (data['items'] ?? data['menu'] ?? []);
      menuItems.value = (list as List).map((e) => MenuItemModel.fromJson(e)).toList();
    } catch (_) {}
    isLoading.value = false;
  }

  Future<void> createItem(Map<String, dynamic> data) async {
    isSaving.value = true;
    try {
      await DioClient.instance.post('/store/menu', data: data);
      await fetchMenu();
      Get.back();
      Get.snackbar('Success', 'Menu item created!', snackPosition: SnackPosition.BOTTOM);
    } catch (_) {
      Get.snackbar('Error', 'Failed to create menu item', snackPosition: SnackPosition.BOTTOM);
    }
    isSaving.value = false;
  }

  Future<void> updateItem(String id, Map<String, dynamic> data) async {
    isSaving.value = true;
    try {
      await DioClient.instance.put('/store/menu/$id', data: data);
      await fetchMenu();
      Get.back();
      Get.snackbar('Success', 'Menu item updated!', snackPosition: SnackPosition.BOTTOM);
    } catch (_) {
      Get.snackbar('Error', 'Failed to update menu item', snackPosition: SnackPosition.BOTTOM);
    }
    isSaving.value = false;
  }

  Future<void> deleteItem(String id) async {
    try {
      await DioClient.instance.delete('/store/menu/$id');
      menuItems.removeWhere((m) => m.id == id);
      Get.snackbar('Deleted', 'Menu item removed', snackPosition: SnackPosition.BOTTOM);
    } catch (_) {
      Get.snackbar('Error', 'Failed to delete menu item', snackPosition: SnackPosition.BOTTOM);
    }
  }
}
