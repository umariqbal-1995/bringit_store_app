import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_theme.dart';
import '../controllers/notification_controller.dart';
import '../../../data/models/notification_model.dart';

class NotificationView extends StatelessWidget {
  const NotificationView({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<StoreNotificationController>();
    return Scaffold(
      backgroundColor: AppColors.backgroundSecondary,
      appBar: AppBar(
        title: const Text('Notifications'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => Get.back(),
        ),
        actions: [
          TextButton(
            onPressed: ctrl.markAllRead,
            child: const Text('Mark all read', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600, fontSize: 13)),
          ),
        ],
      ),
      body: Obx(() {
        if (ctrl.isLoading.value) {
          return const Center(child: CircularProgressIndicator(color: AppColors.primary));
        }
        if (ctrl.notifications.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.notifications_none_outlined, size: 64, color: AppColors.textTertiary),
                SizedBox(height: 12),
                Text('No notifications', style: TextStyle(fontSize: 16, color: AppColors.textSecondary)),
              ],
            ),
          );
        }
        return RefreshIndicator(
          color: AppColors.primary,
          onRefresh: ctrl.fetchNotifications,
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: ctrl.notifications.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (_, i) => _NotifCard(notif: ctrl.notifications[i], ctrl: ctrl),
          ),
        );
      }),
    );
  }
}

class _NotifCard extends StatelessWidget {
  final NotificationModel notif;
  final StoreNotificationController ctrl;
  const _NotifCard({required this.notif, required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => ctrl.markRead(notif.id),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: notif.isRead ? AppColors.background : AppColors.primaryLight,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: notif.isRead ? AppColors.border : AppColors.primary.withOpacity(0.3),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: _iconBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(_icon, color: _iconColor, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          notif.title,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: notif.isRead ? FontWeight.w500 : FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      if (!notif.isRead)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                        ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    notif.body,
                    style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (notif.createdAt != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      _formatTime(notif.createdAt!),
                      style: const TextStyle(fontSize: 11, color: AppColors.textTertiary),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData get _icon {
    switch (notif.type) {
      case 'order': return Icons.receipt_outlined;
      case 'payment': return Icons.payment_outlined;
      case 'rider': return Icons.delivery_dining_outlined;
      default: return Icons.notifications_outlined;
    }
  }

  Color get _iconColor {
    switch (notif.type) {
      case 'order': return AppColors.primary;
      case 'payment': return AppColors.success;
      case 'rider': return AppColors.purple;
      default: return AppColors.info;
    }
  }

  Color get _iconBg {
    switch (notif.type) {
      case 'order': return AppColors.primaryLight;
      case 'payment': return AppColors.successLight;
      case 'rider': return AppColors.purpleLight;
      default: return AppColors.infoLight;
    }
  }

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}
