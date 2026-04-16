import 'package:dio/dio.dart';
import 'package:get/get.dart';
import '../../../core/network/dio_client.dart';
import '../../../data/models/rider_model.dart';

class RiderController extends GetxController {
  final isLoading = false.obs;
  final isSaving = false.obs;
  final riders = <RiderModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchRiders();
  }

  Future<void> fetchRiders() async {
    isLoading.value = true;
    try {
      final res = await DioClient.instance.get('/store/riders');
      final data = res.data['data'] ?? res.data;
      final list = data is List ? data : (data['riders'] ?? []);
      riders.value = (list as List).map((e) => RiderModel.fromJson(e)).toList();
    } catch (_) {}
    isLoading.value = false;
  }

  Future<void> createRider(String name, String phone) async {
    isSaving.value = true;
    try {
      await DioClient.instance.post('/store/riders', data: {'name': name, 'phone': phone});
      await fetchRiders();
      Get.back();
      Get.snackbar('Success', 'Rider added!', snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      String msg = 'Failed to add rider';
      if (e is DioException) {
        msg = e.response?.data?['message']?.toString() ?? msg;
        final errors = e.response?.data?['errors'];
        if (errors is Map && errors.isNotEmpty) {
          msg = errors.values.first is List
              ? (errors.values.first as List).first.toString()
              : errors.values.first.toString();
        }
      }
      Get.snackbar('Error', msg, snackPosition: SnackPosition.BOTTOM);
    }
    isSaving.value = false;
  }

  Future<void> updateRider(String id, String name) async {
    try {
      await DioClient.instance.put('/store/riders/$id', data: {'name': name});
      await fetchRiders();
      Get.back();
      Get.snackbar('Success', 'Rider updated!', snackPosition: SnackPosition.BOTTOM);
    } catch (_) {
      Get.snackbar('Error', 'Failed to update rider', snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> deleteRider(String id) async {
    try {
      await DioClient.instance.delete('/store/riders/$id');
      riders.removeWhere((r) => r.id == id);
      Get.snackbar('Deleted', 'Rider removed', snackPosition: SnackPosition.BOTTOM);
    } catch (_) {
      Get.snackbar('Error', 'Failed to delete rider', snackPosition: SnackPosition.BOTTOM);
    }
  }
}
