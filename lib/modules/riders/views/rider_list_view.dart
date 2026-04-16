import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_theme.dart';
import '../controllers/rider_controller.dart';
import '../../../data/models/rider_model.dart';

class RiderListView extends StatelessWidget {
  const RiderListView({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<RiderController>();
    return Scaffold(
      backgroundColor: AppColors.backgroundSecondary,
      appBar: AppBar(
        title: const Text('Riders'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => Get.back(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_outlined),
            color: AppColors.primary,
            onPressed: () => _showAddRiderSheet(ctrl),
          ),
        ],
      ),
      body: Obx(() {
        if (ctrl.isLoading.value) {
          return const Center(child: CircularProgressIndicator(color: AppColors.primary));
        }
        if (ctrl.riders.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.delivery_dining_outlined, size: 64, color: AppColors.textTertiary),
                const SizedBox(height: 12),
                const Text('No riders yet', style: TextStyle(fontSize: 16, color: AppColors.textSecondary)),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: () => _showAddRiderSheet(ctrl),
                  icon: const Icon(Icons.person_add_outlined),
                  label: const Text('Add Rider'),
                  style: ElevatedButton.styleFrom(minimumSize: const Size(160, 48), elevation: 0),
                ),
              ],
            ),
          );
        }
        return RefreshIndicator(
          color: AppColors.primary,
          onRefresh: ctrl.fetchRiders,
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: ctrl.riders.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (_, i) => _RiderCard(rider: ctrl.riders[i], ctrl: ctrl),
          ),
        );
      }),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddRiderSheet(ctrl),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.person_add_outlined, color: Colors.white),
        label: const Text('Add Rider', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
      ),
    );
  }

  void _showAddRiderSheet(RiderController ctrl, [RiderModel? rider]) {
    final nameCtrl = TextEditingController(text: rider?.name ?? '');
    final phoneCtrl = TextEditingController(text: rider?.phone ?? '');
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
                width: 40,
                height: 4,
                decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              rider != null ? 'Edit Rider' : 'Add New Rider',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 16),
            const Text('Name', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
            const SizedBox(height: 6),
            TextField(
              controller: nameCtrl,
              decoration: InputDecoration(
                hintText: 'Rider full name',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary, width: 2)),
                filled: true,
                fillColor: AppColors.backgroundSecondary,
              ),
            ),
            if (rider == null) ...[
              const SizedBox(height: 12),
              const Text('Phone', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
              const SizedBox(height: 6),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                    decoration: BoxDecoration(
                      color: AppColors.backgroundSecondary,
                      border: Border.all(color: AppColors.border),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text('🇵🇰 +92', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: phoneCtrl,
                      keyboardType: TextInputType.phone,
                      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))],
                      decoration: InputDecoration(
                        hintText: '3XX XXX XXXX',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary, width: 2)),
                        filled: true,
                        fillColor: AppColors.backgroundSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 20),
            Obx(() => ElevatedButton(
                  onPressed: ctrl.isSaving.value
                      ? null
                      : () {
                          if (nameCtrl.text.trim().isEmpty) {
                            Get.snackbar('Error', 'Name is required', snackPosition: SnackPosition.BOTTOM);
                            return;
                          }
                          if (rider != null) {
                            ctrl.updateRider(rider.id, nameCtrl.text.trim());
                          } else {
                            final digits = phoneCtrl.text.trim();
                            if (digits.length < 10) {
                              Get.snackbar('Error', 'Enter a valid 10-digit phone number', snackPosition: SnackPosition.BOTTOM);
                              return;
                            }
                            ctrl.createRider(nameCtrl.text.trim(), '+92$digits');
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 52),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  child: ctrl.isSaving.value
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : Text(rider != null ? 'Update' : 'Add Rider', style: const TextStyle(fontWeight: FontWeight.w700)),
                )),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }
}

class _RiderCard extends StatelessWidget {
  final RiderModel rider;
  final RiderController ctrl;
  const _RiderCard({required this.rider, required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: rider.isAvailable ? AppColors.successLight : AppColors.backgroundSecondary,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              Icons.delivery_dining_outlined,
              color: rider.isAvailable ? AppColors.success : AppColors.textTertiary,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(rider.name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                Text(rider.phone, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: rider.isAvailable ? AppColors.successLight : AppColors.backgroundSecondary,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              rider.isAvailable ? 'Available' : 'Busy',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: rider.isAvailable ? AppColors.success : AppColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(width: 8),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: AppColors.textSecondary, size: 20),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            onSelected: (v) {
              if (v == 'delete') {
                Get.dialog(AlertDialog(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  title: const Text('Remove Rider', style: TextStyle(fontWeight: FontWeight.w700)),
                  content: Text('Remove ${rider.name} from your riders?'),
                  actions: [
                    TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
                    ElevatedButton(
                      onPressed: () { Get.back(); ctrl.deleteRider(rider.id); },
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.error, foregroundColor: Colors.white, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                      child: const Text('Remove'),
                    ),
                  ],
                ));
              }
            },
            itemBuilder: (_) => [
              const PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete_outline, size: 18, color: AppColors.error), SizedBox(width: 8), Text('Remove', style: TextStyle(color: AppColors.error))])),
            ],
          ),
        ],
      ),
    );
  }
}
