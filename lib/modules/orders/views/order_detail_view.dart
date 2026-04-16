import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_theme.dart';
import '../controllers/order_controller.dart';
import '../../riders/controllers/rider_controller.dart';

class OrderDetailView extends StatelessWidget {
  const OrderDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<OrderController>();
    return Scaffold(
      backgroundColor: AppColors.backgroundSecondary,
      appBar: AppBar(
        title: const Text('Order Detail'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
        final order = ctrl.selectedOrder.value;
        if (order == null) {
          return const Center(child: CircularProgressIndicator(color: AppColors.primary));
        }
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Order header card
              _card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Order #${order.id.length > 8 ? order.id.substring(order.id.length - 8) : order.id}',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            if (order.createdAt != null)
                              Text(
                                _formatDate(order.createdAt!),
                                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                              ),
                          ],
                        ),
                        _StatusBadge(status: order.status),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Divider(color: AppColors.divider),
                    const SizedBox(height: 12),
                    _infoRow(Icons.person_outline, 'Customer', order.customerName ?? 'N/A'),
                    if (order.customerPhone != null) ...[
                      const SizedBox(height: 8),
                      _infoRow(Icons.phone_outlined, 'Phone', order.customerPhone!),
                    ],
                    if (order.deliveryAddress != null) ...[
                      const SizedBox(height: 8),
                      _infoRow(Icons.location_on_outlined, 'Delivery', order.deliveryAddress!),
                    ],
                    if (order.riderName != null) ...[
                      const SizedBox(height: 8),
                      _infoRow(Icons.delivery_dining_outlined, 'Rider', order.riderName!),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 12),
              // Order items
              _card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Order Items',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 12),
                    ...order.items.map((item) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Row(
                            children: [
                              Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: AppColors.primaryLight,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Center(
                                  child: Text(
                                    '${item.quantity}x',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  item.name,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ),
                              Text(
                                'PKR ${(item.price * item.quantity).toStringAsFixed(0)}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        )),
                    const Divider(color: AppColors.divider),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                        Text(
                          'PKR ${order.total.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              // Action buttons
              _buildActions(ctrl, order.id, order.status),
              const SizedBox(height: 32),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildActions(OrderController ctrl, String orderId, String status) {
    return Obx(() {
      if (ctrl.isActionLoading.value) {
        return const Center(child: CircularProgressIndicator(color: AppColors.primary));
      }
      switch (status.toUpperCase()) {
        case 'PLACED':
          return Column(
            children: [
              ElevatedButton.icon(
                onPressed: () => ctrl.acceptOrder(orderId),
                icon: const Icon(Icons.check_circle_outline),
                label: const Text('Accept Order'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.success,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 52),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
              ),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: () => _showRejectDialog(ctrl, orderId),
                icon: const Icon(Icons.cancel_outlined),
                label: const Text('Reject Order'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.error,
                  side: const BorderSide(color: AppColors.error),
                  minimumSize: const Size(double.infinity, 52),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ],
          );
        case 'ACCEPTED':
          return ElevatedButton.icon(
            onPressed: () => _showRiderSelectionSheet(ctrl, orderId, forPreparing: true),
            icon: const Icon(Icons.restaurant_outlined),
            label: const Text('Start Preparing'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.purple,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 52),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              elevation: 0,
            ),
          );
        case 'PREPARING':
          if (ctrl.readyOrderIds.contains(orderId)) {
            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.successLight,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.success.withOpacity(0.3)),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.done_all_rounded, color: AppColors.success),
                  SizedBox(width: 8),
                  Text('Ready — Waiting for Rider', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.success)),
                ],
              ),
            );
          }
          return ElevatedButton.icon(
            onPressed: () => _showRiderSelectionSheet(ctrl, orderId, forPreparing: false),
            icon: const Icon(Icons.done_all_rounded),
            label: const Text('Mark as Ready'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.success,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 52),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              elevation: 0,
            ),
          );
        default:
          return const SizedBox.shrink();
      }
    });
  }

  void _showRiderSelectionSheet(OrderController ctrl, String orderId, {required bool forPreparing}) {
    final riderCtrl = Get.find<RiderController>();
    riderCtrl.fetchRiders();

    Get.bottomSheet(
      Container(
        decoration: const BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Select a Rider',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 4),
            Text(
              forPreparing
                  ? 'Assign a rider before starting preparation'
                  : 'Assign a rider before marking the order as ready',
              style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),
            Obx(() {
              if (riderCtrl.isLoading.value) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: CircularProgressIndicator(color: AppColors.primary),
                  ),
                );
              }
              if (riderCtrl.riders.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Center(
                    child: Text(
                      'No riders available. Add a rider first.',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  ),
                );
              }
              return ConstrainedBox(
                constraints: BoxConstraints(maxHeight: Get.height * 0.4),
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: riderCtrl.riders.length,
                  separatorBuilder: (_, __) => const Divider(color: AppColors.divider, height: 1),
                  itemBuilder: (_, i) {
                    final rider = riderCtrl.riders[i];
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                      leading: CircleAvatar(
                        backgroundColor: AppColors.primaryLight,
                        child: Text(
                          rider.name.isNotEmpty ? rider.name[0].toUpperCase() : '?',
                          style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700),
                        ),
                      ),
                      title: Text(rider.name, style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                      subtitle: Text(rider.phone, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                      trailing: rider.isAvailable
                          ? const Icon(Icons.check_circle_outline, color: AppColors.success)
                          : const Icon(Icons.do_not_disturb_on_outlined, color: AppColors.error),
                      onTap: () {
                        Get.back();
                        if (forPreparing) {
                          ctrl.markPreparing(orderId, rider.id);
                        } else {
                          ctrl.markReady(orderId, rider.id);
                        }
                      },
                    );
                  },
                ),
              );
            }),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  void _showRejectDialog(OrderController ctrl, String orderId) {
    final reasonCtrl = TextEditingController();
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Reject Order', style: TextStyle(fontWeight: FontWeight.w700)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Please provide a reason for rejection:'),
            const SizedBox(height: 12),
            TextField(
              controller: reasonCtrl,
              decoration: InputDecoration(
                hintText: 'e.g. Out of stock',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              ctrl.rejectOrder(orderId, reasonCtrl.text.isNotEmpty ? reasonCtrl.text : 'Out of stock');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Reject'),
          ),
        ],
      ),
    );
  }

  Widget _card({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: child,
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppColors.textTertiary),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textTertiary)),
              Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
            ],
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _bg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        status.toUpperCase() == 'PLACED' ? 'NEW' : status.toUpperCase() == 'OUT_FOR_DELIVERY' ? 'OUT FOR DELIVERY' : status.toUpperCase(),
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: _color, letterSpacing: 0.5),
      ),
    );
  }

  Color get _color {
    switch (status.toUpperCase()) {
      case 'PLACED': return AppColors.warning;
      case 'ACCEPTED': return AppColors.info;
      case 'PREPARING': return AppColors.purple;
      case 'OUT_FOR_DELIVERY': return AppColors.success;
      case 'DELIVERED': return AppColors.success;
      case 'CANCELLED': return AppColors.error;
      default: return AppColors.textSecondary;
    }
  }

  Color get _bg {
    switch (status.toUpperCase()) {
      case 'PLACED': return AppColors.warningLight;
      case 'ACCEPTED': return AppColors.infoLight;
      case 'PREPARING': return AppColors.purpleLight;
      case 'OUT_FOR_DELIVERY': return AppColors.successLight;
      case 'DELIVERED': return AppColors.successLight;
      case 'CANCELLED': return AppColors.errorLight;
      default: return AppColors.backgroundSecondary;
    }
  }
}
