import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_theme.dart';
import '../../../routes/app_routes.dart';
import '../controllers/dashboard_controller.dart';
import '../../orders/controllers/order_controller.dart';

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<DashboardController>();
    final orderCtrl = Get.find<OrderController>();
    return Scaffold(
      backgroundColor: AppColors.backgroundSecondary,
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: ctrl.fetchAll,
        child: CustomScrollView(
          slivers: [
            _buildHeader(ctrl),
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _buildStatsRow(ctrl),
                  const SizedBox(height: 20),
                  _buildQuickActions(context),
                  const SizedBox(height: 20),
                  _buildRecentOrders(orderCtrl),
                  const SizedBox(height: 100),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(DashboardController ctrl) {
    return SliverAppBar(
      expandedHeight: 160,
      pinned: true,
      backgroundColor: AppColors.primary,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(color: AppColors.primary),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 60, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Good Morning,',
                              style: TextStyle(color: Colors.white70, fontSize: 13),
                            ),
                            Obx(() => Text(
                              ctrl.storeName.value,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                              ),
                            )),
                          ],
                        ),
                      ),
                      Obx(() => GestureDetector(
                            onTap: ctrl.isStatusLoading.value ? null : ctrl.toggleStoreStatus,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                color: ctrl.isOpen.value
                                    ? AppColors.successLight
                                    : Colors.white.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: ctrl.isOpen.value ? AppColors.success : Colors.white54,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    ctrl.isOpen.value ? 'Open' : 'Closed',
                                    style: TextStyle(
                                      color: ctrl.isOpen.value ? AppColors.success : Colors.white,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      title: const Text(
        'Dashboard',
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
      ),
      titleSpacing: 20,
    );
  }

  Widget _buildStatsRow(DashboardController ctrl) {
    return Obx(() => ctrl.isLoading.value
        ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
        : Row(
            children: [
              _statCard(
                'Total Orders',
                '${ctrl.summary['totalOrders'] ?? 0}',
                Icons.shopping_bag_outlined,
                AppColors.primary,
                AppColors.primaryLight,
              ),
              const SizedBox(width: 12),
              _statCard(
                'Total Revenue',
                'PKR ${(double.tryParse(ctrl.summary['totalRevenue']?.toString() ?? '0') ?? 0.0).toStringAsFixed(0)}',
                Icons.attach_money_rounded,
                AppColors.success,
                AppColors.successLight,
              ),
            ],
          ));
  }

  Widget _statCard(String label, String value, IconData icon, Color color, Color bg) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 2),
            Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    final actions = [
      _QuickAction('New Orders', Icons.new_releases_outlined, AppColors.warning, AppColors.warningLight, AppRoutes.orders),
      _QuickAction('Products', Icons.inventory_2_outlined, AppColors.info, AppColors.infoLight, AppRoutes.products),
      _QuickAction('Riders', Icons.delivery_dining_outlined, AppColors.purple, AppColors.purpleLight, AppRoutes.riders),
      _QuickAction('Analytics', Icons.bar_chart_rounded, AppColors.success, AppColors.successLight, AppRoutes.analytics),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Actions',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
        ),
        const SizedBox(height: 30),
        SizedBox(
          height: 90,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: actions.length,
            separatorBuilder: (_, __) => const SizedBox(width: 20),
            itemBuilder: (_, i) {
              final a = actions[i];
              return GestureDetector(
                onTap: () => Get.toNamed(a.route),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: a.bg,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(a.icon, color: a.color, size: 26),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      a.label,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRecentOrders(OrderController orderCtrl) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Recent Orders',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
            ),
            GestureDetector(
              onTap: () => Get.toNamed(AppRoutes.orders),
              child: const Text(
                'View All',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.primary),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Obx(() {
          if (orderCtrl.isLoading.value) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }
          if (orderCtrl.orders.isEmpty) {
            return Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: const Center(
                child: Column(
                  children: [
                    Icon(Icons.receipt_long_outlined, size: 40, color: AppColors.textTertiary),
                    SizedBox(height: 8),
                    Text('No orders yet', style: TextStyle(color: AppColors.textSecondary)),
                  ],
                ),
              ),
            );
          }
          final recentOrders = orderCtrl.orders.take(5).toList();
          return Column(
            children: recentOrders
                .map((order) => GestureDetector(
                      onTap: () {
                        orderCtrl.selectedOrder.value = order;
                        Get.toNamed(AppRoutes.orderDetail);
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                color: _statusBg(order.status),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(Icons.receipt_outlined, color: _statusColor(order.status), size: 20),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Order #${order.id.length > 6 ? order.id.substring(order.id.length - 6) : order.id}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  Text(
                                    order.customerName ?? 'Customer',
                                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
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
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                _statusChip(order.status),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ))
                .toList(),
          );
        }),
      ],
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

  String _statusLabel(String status) {
    switch (status.toUpperCase()) {
      case 'PLACED': return 'New';
      case 'OUT_FOR_DELIVERY': return 'Out for Delivery';
      default: return status.capitalize ?? status;
    }
  }

  Widget _statusChip(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: _statusBg(status),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        _statusLabel(status),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: _statusColor(status),
        ),
      ),
    );
  }
}

class _QuickAction {
  final String label;
  final IconData icon;
  final Color color;
  final Color bg;
  final String route;
  _QuickAction(this.label, this.icon, this.color, this.bg, this.route);
}
