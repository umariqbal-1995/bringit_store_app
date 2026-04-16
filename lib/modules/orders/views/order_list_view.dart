import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_theme.dart';
import '../../../routes/app_routes.dart';
import '../controllers/order_controller.dart';
import '../../../data/models/order_model.dart';

class OrderListView extends StatelessWidget {
  const OrderListView({super.key});

  static const _tabs = [
    ('all', 'All'),
    ('PLACED', 'New'),
    ('ACCEPTED', 'Accepted'),
    ('PREPARING', 'Preparing'),
    ('OUT_FOR_DELIVERY', 'Out for Delivery'),
    ('DELIVERED', 'Done'),
    ('CANCELLED', 'Cancelled'),
  ];

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<OrderController>();
    return Scaffold(
      backgroundColor: AppColors.backgroundSecondary,
      appBar: AppBar(
        title: const Text('Orders'),
        backgroundColor: AppColors.background,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: ctrl.fetchOrders,
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter tabs
          Container(
            color: AppColors.background,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Obx(() => Row(
                    children: _tabs
                        .map((tab) => Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: GestureDetector(
                                onTap: () => ctrl.filterStatus.value = tab.$1,
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: ctrl.filterStatus.value == tab.$1
                                        ? AppColors.primary
                                        : AppColors.backgroundSecondary,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    tab.$2,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: ctrl.filterStatus.value == tab.$1
                                          ? Colors.white
                                          : AppColors.textSecondary,
                                    ),
                                  ),
                                ),
                              ),
                            ))
                        .toList(),
                  )),
            ),
          ),
          const SizedBox(height: 1),
          // Order list
          Expanded(
            child: Obx(() {
              if (ctrl.isLoading.value) {
                return const Center(child: CircularProgressIndicator(color: AppColors.primary));
              }
              final orders = ctrl.filteredOrders;
              if (orders.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.receipt_long_outlined, size: 64, color: AppColors.textTertiary),
                      SizedBox(height: 12),
                      Text('No orders found', style: TextStyle(color: AppColors.textSecondary, fontSize: 16)),
                    ],
                  ),
                );
              }
              return RefreshIndicator(
                color: AppColors.primary,
                onRefresh: ctrl.fetchOrders,
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: orders.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (_, i) => _OrderCard(order: orders[i], ctrl: ctrl),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final OrderModel order;
  final OrderController ctrl;
  const _OrderCard({required this.order, required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        ctrl.selectedOrder.value = order;
        Get.toNamed(AppRoutes.orderDetail);
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: _statusBg(order.status),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(Icons.receipt_outlined, color: _statusColor(order.status), size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Order #${order.id.length > 8 ? order.id.substring(order.id.length - 8) : order.id}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        order.customerName ?? 'Customer',
                        style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'PKR ${order.total.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    _StatusChip(status: order.status),
                  ],
                ),
              ],
            ),
            if (order.items.isNotEmpty) ...[
              const SizedBox(height: 10),
              const Divider(height: 1, color: AppColors.divider),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(Icons.shopping_basket_outlined, size: 14, color: AppColors.textTertiary),
                  const SizedBox(width: 4),
                  Text(
                    '${order.items.length} item${order.items.length > 1 ? 's' : ''}: ${order.items.take(2).map((e) => e.name).join(', ')}${order.items.length > 2 ? '...' : ''}',
                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ],
            // Quick action buttons for pending orders
            if (order.status == 'PLACED') ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        ctrl.selectedOrder.value = order;
                        Get.toNamed(AppRoutes.orderDetail);
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.error,
                        side: const BorderSide(color: AppColors.error),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text('Reject', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => ctrl.acceptOrder(order.id),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.success,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        minimumSize: const Size(0, 0),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        elevation: 0,
                      ),
                      child: const Text('Accept', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _statusColor(String status) {
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

  Color _statusBg(String status) {
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

class _StatusChip extends StatelessWidget {
  final String status;
  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        _label,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: _color),
      ),
    );
  }

  String get _label {
    switch (status.toUpperCase()) {
      case 'PLACED': return 'New';
      case 'OUT_FOR_DELIVERY': return 'Out for Delivery';
      default: return status.capitalize ?? status;
    }
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
