import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_theme.dart';
import '../controllers/analytics_controller.dart';

class AnalyticsView extends StatelessWidget {
  const AnalyticsView({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<AnalyticsController>();
    return Scaffold(
      backgroundColor: AppColors.backgroundSecondary,
      appBar: AppBar(
        title: const Text('Analytics'),
        backgroundColor: AppColors.background,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: ctrl.fetchAll,
          ),
        ],
      ),
      body: Obx(() {
        if (ctrl.isLoading.value) {
          return const Center(child: CircularProgressIndicator(color: AppColors.primary));
        }
        return RefreshIndicator(
          color: AppColors.primary,
          onRefresh: ctrl.fetchAll,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildOverviewCards(ctrl),
                const SizedBox(height: 20),
                _buildSalesBreakdown(ctrl),
                const SizedBox(height: 20),
                _buildTopProducts(ctrl),
                const SizedBox(height: 20),
                _buildRevenueTrend(ctrl),
                const SizedBox(height: 100),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildOverviewCards(AnalyticsController ctrl) {
    final overview = ctrl.overview;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Overview', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.5,
          children: [
            _analyticsCard(
              'Total Orders',
              '${overview['totalOrders'] ?? 0}',
              Icons.shopping_bag_outlined,
              AppColors.primary,
              AppColors.primaryLight,
            ),
            _analyticsCard(
              'Total Revenue',
              'PKR ${(double.tryParse(overview['totalRevenue']?.toString() ?? '0') ?? 0.0).toStringAsFixed(0)}',
              Icons.attach_money_rounded,
              AppColors.success,
              AppColors.successLight,
            ),
            _analyticsCard(
              'Pending',
              '${overview['pendingOrders'] ?? 0}',
              Icons.pending_outlined,
              AppColors.warning,
              AppColors.warningLight,
            ),
            _analyticsCard(
              'Total Riders',
              '${overview['totalRiders'] ?? 0}',
              Icons.delivery_dining_outlined,
              AppColors.purple,
              AppColors.purpleLight,
            ),
          ],
        ),
      ],
    );
  }

  Widget _analyticsCard(String label, String value, IconData icon, Color color, Color bg) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 32, height: 32,
            decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
          Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
        ],
      ),
    );
  }

  // Sales API returns: [{_count:{id}, _sum:{totalPkr}, status}]
  Widget _buildSalesBreakdown(AnalyticsController ctrl) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Sales by Status', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        const SizedBox(height: 12),
        Obx(() {
          final sales = ctrl.sales;
          if (sales.isEmpty) {
            return _emptyCard('No sales data yet');
          }
          final list = sales is List ? sales : [];
          return Container(
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: list.asMap().entries.map((entry) {
                final item = entry.value as Map<String, dynamic>;
                final status = item['status'] ?? 'UNKNOWN';
                final count = item['_count']?['id'] ?? 0;
                final revenue = double.tryParse(item['_sum']?['totalPkr']?.toString() ?? '0') ?? 0.0;
                final color = _statusColor(status);
                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Row(
                        children: [
                          Container(width: 4, height: 20, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
                          const SizedBox(width: 10),
                          Text(status, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                          const Spacer(),
                          Text('$count orders  ', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                          Text('PKR ${revenue.toStringAsFixed(0)}', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: color)),
                        ],
                      ),
                    ),
                    if (entry.key < list.length - 1) const Divider(height: 1, color: AppColors.divider, indent: 16, endIndent: 16),
                  ],
                );
              }).toList(),
            ),
          );
        }),
      ],
    );
  }

  // Top products API: [{_sum:{quantity, totalPkr}, menuItemId, storeProductId}]
  Widget _buildTopProducts(AnalyticsController ctrl) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Top Items', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        const SizedBox(height: 12),
        Obx(() {
          if (ctrl.topProducts.isEmpty) return _emptyCard('No product data yet');
          final items = ctrl.topProducts.take(5).toList();
          return Container(
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: items.length,
              separatorBuilder: (_, __) => const Divider(height: 1, color: AppColors.divider, indent: 16, endIndent: 16),
              itemBuilder: (_, i) {
                final item = items[i] as Map<String, dynamic>;
                final qty = item['_sum']?['quantity'] ?? 0;
                final revenue = double.tryParse(item['_sum']?['totalPkr']?.toString() ?? '0') ?? 0.0;
                final name = ctrl.topProductNames[item['menuItemId'] ?? item['storeProductId'] ?? ''] ?? 'Item #${i + 1}';
                return ListTile(
                  leading: Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(10)),
                    child: Center(child: Text('${i + 1}', style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.primary, fontSize: 14))),
                  ),
                  title: Text(name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  subtitle: Text('$qty sold', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  trailing: Text('PKR ${revenue.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: AppColors.primary)),
                );
              },
            ),
          );
        }),
      ],
    );
  }

  // Revenue trend API: [{date, total}]
  Widget _buildRevenueTrend(AnalyticsController ctrl) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Revenue Trend', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        const SizedBox(height: 12),
        Obx(() {
          if (ctrl.revenueTrend.isEmpty) return _emptyCard('No trend data yet');
          final maxRevenue = ctrl.revenueTrend
              .map((e) => double.tryParse((e as Map)['total']?.toString() ?? '0') ?? 0.0)
              .fold<double>(0, (a, b) => a > b ? a : b);
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: (ctrl.revenueTrend as List).map((e) {
                final item = e as Map<String, dynamic>;
                final revenue = double.tryParse(item['total']?.toString() ?? '0') ?? 0.0;
                final pct = maxRevenue > 0 ? revenue / maxRevenue : 0.0;
                final dateStr = item['date']?.toString() ?? '';
                final date = dateStr.length >= 10 ? dateStr.substring(5, 10) : dateStr;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    children: [
                      SizedBox(width: 40, child: Text(date, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary))),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: pct,
                            backgroundColor: AppColors.backgroundSecondary,
                            valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                            minHeight: 8,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 70,
                        child: Text('PKR ${revenue.toStringAsFixed(0)}', textAlign: TextAlign.right, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          );
        }),
      ],
    );
  }

  Widget _emptyCard(String msg) => Container(
        height: 80,
        decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
        child: Center(child: Text(msg, style: const TextStyle(color: AppColors.textSecondary))),
      );

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
}
