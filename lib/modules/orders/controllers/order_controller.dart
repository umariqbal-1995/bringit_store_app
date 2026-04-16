import 'package:dio/dio.dart';
import 'package:get/get.dart';
import '../../../core/network/dio_client.dart';
import '../../../data/models/order_model.dart';

class OrderController extends GetxController {
  final isLoading = false.obs;
  final isActionLoading = false.obs;
  final orders = <OrderModel>[].obs;
  final selectedOrder = Rxn<OrderModel>();
  final filterStatus = 'all'.obs;
  final readyOrderIds = <String>{}.obs;

  @override
  void onInit() {
    super.onInit();
    fetchOrders();
  }

  List<OrderModel> get filteredOrders {
    if (filterStatus.value == 'all') return orders;
    return orders.where((o) => o.status == filterStatus.value).toList();
  }

  Future<void> fetchOrders() async {
    isLoading.value = true;
    try {
      final res = await DioClient.instance.get('/store/orders');
      final data = res.data['data'] ?? res.data;
      final list = data is List ? data : (data['orders'] ?? []);
      orders.value = (list as List).map((e) => OrderModel.fromJson(e)).toList();
    } catch (_) {}
    isLoading.value = false;
  }

  Future<void> fetchOrderDetail(String orderId) async {
    try {
      final res = await DioClient.instance.get('/store/orders/$orderId');
      final data = res.data['data'] ?? res.data;
      selectedOrder.value = OrderModel.fromJson(data);
    } catch (_) {}
  }

  Future<void> acceptOrder(String orderId) async {
    isActionLoading.value = true;
    try {
      await DioClient.instance.post('/store/orders/$orderId/accept', data: {});
      await fetchOrders();
      if (selectedOrder.value?.id == orderId) await fetchOrderDetail(orderId);
      Get.snackbar('Success', 'Order accepted!', snackPosition: SnackPosition.BOTTOM);
    } catch (_) {
      Get.snackbar('Error', 'Failed to accept order', snackPosition: SnackPosition.BOTTOM);
    }
    isActionLoading.value = false;
  }

  Future<void> rejectOrder(String orderId, String reason) async {
    isActionLoading.value = true;
    try {
      await DioClient.instance.post('/store/orders/$orderId/reject', data: {'reason': reason});
      await fetchOrders();
      Get.back();
      Get.snackbar('Order Rejected', 'Order has been rejected', snackPosition: SnackPosition.BOTTOM);
    } catch (_) {
      Get.snackbar('Error', 'Failed to reject order', snackPosition: SnackPosition.BOTTOM);
    }
    isActionLoading.value = false;
  }

  Future<void> markPreparing(String orderId, String riderId) async {
    isActionLoading.value = true;
    try {
      await DioClient.instance.post('/store/orders/$orderId/prepare', data: {'riderId': riderId});
      await fetchOrders();
      if (selectedOrder.value?.id == orderId) await fetchOrderDetail(orderId);
      Get.snackbar('Success', 'Order is now being prepared', snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      String msg = 'Failed to update order';
      if (e is DioException) msg = e.response?.data?['message']?.toString() ?? msg;
      Get.snackbar('Error', msg, snackPosition: SnackPosition.BOTTOM);
    }
    isActionLoading.value = false;
  }

  Future<void> markReady(String orderId, String riderId) async {
    isActionLoading.value = true;
    try {
      await DioClient.instance.post('/store/orders/$orderId/mark-ready', data: {'riderId': riderId});
      readyOrderIds.add(orderId);
      await fetchOrders();
      if (selectedOrder.value?.id == orderId) await fetchOrderDetail(orderId);
      Get.snackbar('Success', 'Order is ready for pickup!', snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      String msg = 'Failed to update order';
      if (e is DioException) msg = e.response?.data?['message']?.toString() ?? msg;
      Get.snackbar('Error', msg, snackPosition: SnackPosition.BOTTOM);
    }
    isActionLoading.value = false;
  }
}
