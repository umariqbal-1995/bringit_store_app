import 'package:get/get.dart';
import '../../../core/network/dio_client.dart';
import '../../../data/models/product_model.dart';

class ProductController extends GetxController {
  final isLoading = false.obs;
  final isSaving = false.obs;
  final products = <ProductModel>[].obs;
  final selectedProduct = Rxn<ProductModel>();

  @override
  void onInit() {
    super.onInit();
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    isLoading.value = true;
    try {
      final res = await DioClient.instance.get('/store/menu', queryParameters: {'limit': 100});
      final data = res.data['data'] ?? res.data;
      final list = data is List ? data : (data['items'] ?? data['menu'] ?? []);
      products.value = (list as List).map((e) => ProductModel.fromJson(e)).toList();
    } catch (_) {}
    isLoading.value = false;
  }

  Future<void> createProduct(Map<String, dynamic> data) async {
    isSaving.value = true;
    try {
      final res = await DioClient.instance.post('/store/menu', data: data);
      await fetchProducts();
      Get.back();
      Get.snackbar('Success', 'Item created!', snackPosition: SnackPosition.BOTTOM);
    } on Exception catch (e) {
      Get.snackbar('Error', e.toString(), snackPosition: SnackPosition.BOTTOM);
    }
    isSaving.value = false;
  }

  Future<void> updateProduct(String id, Map<String, dynamic> data) async {
    isSaving.value = true;
    try {
      await DioClient.instance.put('/store/menu/$id', data: data);
      await fetchProducts();
      Get.back();
      Get.snackbar('Success', 'Item updated!', snackPosition: SnackPosition.BOTTOM);
    } catch (_) {
      Get.snackbar('Error', 'Failed to update item', snackPosition: SnackPosition.BOTTOM);
    }
    isSaving.value = false;
  }

  Future<void> deleteProduct(String id) async {
    try {
      await DioClient.instance.delete('/store/menu/$id');
      products.removeWhere((p) => p.id == id);
      Get.snackbar('Deleted', 'Item removed', snackPosition: SnackPosition.BOTTOM);
    } catch (_) {
      Get.snackbar('Error', 'Failed to delete item', snackPosition: SnackPosition.BOTTOM);
    }
  }
}
