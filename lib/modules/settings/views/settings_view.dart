import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_theme.dart';
import '../../../routes/app_routes.dart';
import '../controllers/settings_controller.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<SettingsController>();
    return Scaffold(
      backgroundColor: AppColors.backgroundSecondary,
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: AppColors.background,
        actions: [
          Obx(() => ctrl.isLoading.value
              ? const Padding(padding: EdgeInsets.only(right: 16), child: SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary)))
              : const SizedBox.shrink()),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Store profile header
            Obx(() => Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: const Icon(Icons.store_rounded, color: AppColors.primary, size: 32),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              ctrl.store.value?.name ?? 'My Store',
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                            ),
                            if (ctrl.store.value?.phone != null)
                              Text(ctrl.store.value!.phone!, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: ctrl.store.value?.isOpen == true ? AppColors.successLight : AppColors.errorLight,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    ctrl.store.value?.isOpen == true ? 'Open' : 'Closed',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: ctrl.store.value?.isOpen == true ? AppColors.success : AppColors.error,
                                    ),
                                  ),
                                ),
                                if (ctrl.store.value?.type != null) ...[
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: ctrl.store.value?.type == 'RESTAURANT' ? AppColors.purpleLight : AppColors.infoLight,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      ctrl.store.value?.type == 'RESTAURANT' ? 'Restaurant' : 'Store',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: ctrl.store.value?.type == 'RESTAURANT' ? AppColors.purple : AppColors.info,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => _showEditStoreSheet(ctrl),
                        icon: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(color: AppColors.backgroundSecondary, borderRadius: BorderRadius.circular(10)),
                          child: const Icon(Icons.edit_outlined, size: 18, color: AppColors.textSecondary),
                        ),
                      ),
                    ],
                  ),
                )),
            const SizedBox(height: 16),
            // Settings sections
            Obx(() {
              final isRestaurant = ctrl.store.value?.type == 'RESTAURANT';
              return _section([
                _tile(Icons.receipt_long_outlined, 'Orders', AppColors.primary, AppColors.primaryLight, () => Get.toNamed(AppRoutes.orders)),
                if (isRestaurant)
                  _tile(Icons.restaurant_menu_outlined, 'Menu Items', AppColors.purple, AppColors.purpleLight, () => Get.toNamed(AppRoutes.products))
                else
                  _tile(Icons.inventory_2_outlined, 'Products', AppColors.info, AppColors.infoLight, () => Get.toNamed(AppRoutes.products)),
                _tile(Icons.delivery_dining_outlined, 'Manage Riders', AppColors.warning, AppColors.warningLight, () => Get.toNamed(AppRoutes.riders)),
              ]);
            }),
            const SizedBox(height: 12),
            _section([
              _tile(Icons.notifications_outlined, 'Notifications', AppColors.success, AppColors.successLight, () => Get.toNamed(AppRoutes.notifications)),
              _tile(Icons.bar_chart_rounded, 'Analytics', AppColors.error, AppColors.errorLight, () => Get.toNamed(AppRoutes.analytics)),
            ]),
            const SizedBox(height: 12),
            // Logout
            GestureDetector(
              onTap: () => _confirmLogout(ctrl),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.errorLight,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.error.withOpacity(0.2)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.logout_rounded, color: AppColors.error, size: 22),
                    SizedBox(width: 12),
                    Text('Logout', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.error)),
                    Spacer(),
                    Icon(Icons.arrow_forward_ios, color: AppColors.error, size: 14),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            const Text('BringIt Store v1.0.0', style: TextStyle(fontSize: 12, color: AppColors.textTertiary)),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _section(List<Widget> tiles) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: tiles.asMap().entries.map((e) {
          return Column(
            children: [
              e.value,
              if (e.key < tiles.length - 1) const Divider(height: 1, color: AppColors.divider, indent: 56),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _tile(IconData icon, String label, Color color, Color bg, VoidCallback onTap) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, color: color, size: 18),
      ),
      title: Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.textTertiary),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }

  void _showEditStoreSheet(SettingsController ctrl) {
    final nameCtrl = TextEditingController(text: ctrl.store.value?.name ?? '');
    final descCtrl = TextEditingController(text: ctrl.store.value?.description ?? '');
    final selectedType = (ctrl.store.value?.type ?? 'RESTAURANT').obs;
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.only(
          left: 20, right: 20, top: 20,
          bottom: MediaQuery.of(Get.context!).viewInsets.bottom + 20,
        ),
        decoration: const BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Edit Store', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            const Text('Business Type', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
            const SizedBox(height: 8),
            Obx(() => Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => selectedType.value = 'RESTAURANT',
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: selectedType.value == 'RESTAURANT' ? AppColors.primaryLight : AppColors.backgroundSecondary,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: selectedType.value == 'RESTAURANT' ? AppColors.primary : AppColors.border, width: selectedType.value == 'RESTAURANT' ? 2 : 1),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.restaurant_rounded, size: 16, color: selectedType.value == 'RESTAURANT' ? AppColors.primary : AppColors.textSecondary),
                          const SizedBox(width: 6),
                          Text('Restaurant', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: selectedType.value == 'RESTAURANT' ? AppColors.primary : AppColors.textSecondary)),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: GestureDetector(
                    onTap: () => selectedType.value = 'STORE',
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: selectedType.value == 'STORE' ? AppColors.infoLight : AppColors.backgroundSecondary,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: selectedType.value == 'STORE' ? AppColors.info : AppColors.border, width: selectedType.value == 'STORE' ? 2 : 1),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.storefront_rounded, size: 16, color: selectedType.value == 'STORE' ? AppColors.info : AppColors.textSecondary),
                          const SizedBox(width: 6),
                          Text('Store', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: selectedType.value == 'STORE' ? AppColors.info : AppColors.textSecondary)),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            )),
            const SizedBox(height: 12),
            const Text('Store Name', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
            const SizedBox(height: 6),
            TextField(
              controller: nameCtrl,
              decoration: InputDecoration(
                hintText: 'Store name',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary, width: 2)),
                filled: true,
                fillColor: AppColors.backgroundSecondary,
              ),
            ),
            const SizedBox(height: 12),
            const Text('Description', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
            const SizedBox(height: 6),
            TextField(
              controller: descCtrl,
              maxLines: 2,
              decoration: InputDecoration(
                hintText: 'Short description...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary, width: 2)),
                filled: true,
                fillColor: AppColors.backgroundSecondary,
              ),
            ),
            const SizedBox(height: 20),
            Obx(() => ElevatedButton(
                  onPressed: ctrl.isSaving.value
                      ? null
                      : () => ctrl.updateStore({
                            'name': nameCtrl.text.trim(),
                            'description': descCtrl.text.trim(),
                            'type': selectedType.value,
                          }),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 52),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  child: ctrl.isSaving.value
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('Save Changes', style: TextStyle(fontWeight: FontWeight.w700)),
                )),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  void _confirmLogout(SettingsController ctrl) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Logout', style: TextStyle(fontWeight: FontWeight.w700)),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () { Get.back(); ctrl.logout(); },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}
