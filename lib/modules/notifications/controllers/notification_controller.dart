import 'package:get/get.dart';
import '../../../core/network/dio_client.dart';
import '../../../data/models/notification_model.dart';

class StoreNotificationController extends GetxController {
  final isLoading = false.obs;
  final notifications = <NotificationModel>[].obs;

  int get unreadCount => notifications.where((n) => !n.isRead).length;

  @override
  void onInit() {
    super.onInit();
    fetchNotifications();
  }

  Future<void> fetchNotifications() async {
    isLoading.value = true;
    try {
      final res = await DioClient.instance.get('/store/notifications');
      final data = res.data['data'] ?? res.data;
      final list = data is List ? data : (data['notifications'] ?? []);
      notifications.value = (list as List).map((e) => NotificationModel.fromJson(e)).toList();
    } catch (_) {}
    isLoading.value = false;
  }

  Future<void> markRead(String id) async {
    try {
      await DioClient.instance.put('/store/notifications/$id/read');
      final index = notifications.indexWhere((n) => n.id == id);
      if (index != -1) {
        final old = notifications[index];
        notifications[index] = NotificationModel(
          id: old.id,
          title: old.title,
          body: old.body,
          isRead: true,
          type: old.type,
          orderId: old.orderId,
          createdAt: old.createdAt,
        );
        notifications.refresh();
      }
    } catch (_) {}
  }

  Future<void> markAllRead() async {
    try {
      await DioClient.instance.put('/store/notifications/read-all');
      fetchNotifications();
    } catch (_) {}
  }
}
