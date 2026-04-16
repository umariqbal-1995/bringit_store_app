import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/storage/storage_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../routes/app_routes.dart';

class StoreSetupView extends StatefulWidget {
  const StoreSetupView({super.key});

  @override
  State<StoreSetupView> createState() => _StoreSetupViewState();
}

class _StoreSetupViewState extends State<StoreSetupView> {
  final _nameCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _isSaving = false.obs;

  String get _storeType => (Get.arguments as Map?)?['type']?.toString() ?? StorageService.getStoreType() ?? 'RESTAURANT';
  bool get _isRestaurant => _storeType == 'RESTAURANT';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              // Progress indicator
              Row(
                children: [
                  _step(1, done: true),
                  _line(),
                  _step(2, active: true),
                  _line(),
                  _step(3),
                  _line(),
                  _step(4),
                  _line(),
                  _step(5),
                ],
              ),
              const SizedBox(height: 32),
              Container(
                width: 64, height: 64,
                decoration: BoxDecoration(
                  color: _isRestaurant ? AppColors.primaryLight : AppColors.infoLight,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  _isRestaurant ? Icons.restaurant_rounded : Icons.storefront_rounded,
                  color: _isRestaurant ? AppColors.primary : AppColors.info,
                  size: 32,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Set up your business',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 6),
              Text(
                _isRestaurant
                    ? 'Tell customers about your restaurant'
                    : 'Tell customers about your store',
                style: const TextStyle(fontSize: 15, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 32),
              _label('Business Name *'),
              const SizedBox(height: 6),
              TextField(
                controller: _nameCtrl,
                textCapitalization: TextCapitalization.words,
                decoration: _inputDeco(
                  _isRestaurant ? 'e.g. Pizza Palace' : 'e.g. Fresh Mart',
                  Icons.store_rounded,
                ),
              ),
              const SizedBox(height: 16),
              _label('City *'),
              const SizedBox(height: 6),
              TextField(
                controller: _cityCtrl,
                textCapitalization: TextCapitalization.words,
                decoration: _inputDeco('e.g. Karachi', Icons.location_city_rounded),
              ),
              const SizedBox(height: 16),
              _label('Description (optional)'),
              const SizedBox(height: 6),
              TextField(
                controller: _descCtrl,
                maxLines: 3,
                textCapitalization: TextCapitalization.sentences,
                decoration: _inputDeco(
                  _isRestaurant ? 'What makes your food special?' : 'What do you sell?',
                  null,
                ),
              ),
              const SizedBox(height: 32),
              Obx(() => ElevatedButton(
                    onPressed: _isSaving.value ? null : _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 56),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    child: _isSaving.value
                        ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                        : const Text('Launch My Business', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                  )),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _save() async {
    final name = _nameCtrl.text.trim();
    final city = _cityCtrl.text.trim();
    if (name.isEmpty) {
      Get.snackbar('Required', 'Please enter your business name', snackPosition: SnackPosition.BOTTOM);
      return;
    }
    if (city.isEmpty) {
      Get.snackbar('Required', 'Please enter your city', snackPosition: SnackPosition.BOTTOM);
      return;
    }
    _isSaving.value = true;
    try {
      final data = <String, dynamic>{
        'name': name,
        'city': city,
        'type': _storeType,
        'status': 'ACTIVE',
      };
      if (_descCtrl.text.trim().isNotEmpty) data['description'] = _descCtrl.text.trim();
      await DioClient.instance.put('/store/me', data: data);
      Get.offAllNamed(AppRoutes.storeLocation);
    } catch (_) {
      Get.snackbar('Error', 'Failed to save. Please try again.', snackPosition: SnackPosition.BOTTOM);
    }
    _isSaving.value = false;
  }

  Widget _label(String text) => Text(text, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary));

  InputDecoration _inputDeco(String hint, IconData? icon) => InputDecoration(
        hintText: hint,
        prefixIcon: icon != null ? Icon(icon, size: 20, color: AppColors.textTertiary) : null,
        filled: true,
        fillColor: AppColors.backgroundSecondary,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.border)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.border)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.primary, width: 2)),
      );

  Widget _step(int n, {bool done = false, bool active = false}) {
    final color = done || active ? AppColors.primary : AppColors.border;
    return Container(
      width: 32, height: 32,
      decoration: BoxDecoration(
        color: done ? AppColors.primary : active ? AppColors.primaryLight : AppColors.backgroundSecondary,
        shape: BoxShape.circle,
        border: Border.all(color: color, width: 2),
      ),
      child: Center(
        child: done
            ? const Icon(Icons.check, size: 16, color: Colors.white)
            : Text('$n', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: active ? AppColors.primary : AppColors.textTertiary)),
      ),
    );
  }

  Widget _line({bool done = true}) => Expanded(child: Container(height: 2, color: done ? AppColors.primary : AppColors.border, margin: const EdgeInsets.symmetric(horizontal: 4)));

  @override
  void dispose() {
    _nameCtrl.dispose();
    _cityCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }
}
