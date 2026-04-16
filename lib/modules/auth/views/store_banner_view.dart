import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/services/firebase_storage_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../routes/app_routes.dart';

class StoreBannerView extends StatefulWidget {
  const StoreBannerView({super.key});

  @override
  State<StoreBannerView> createState() => _StoreBannerViewState();
}

class _StoreBannerViewState extends State<StoreBannerView> {
  File? _banner;
  bool _uploading = false;
  bool _saving = false;
  final _picker = ImagePicker();

  Future<void> _pick(ImageSource source) async {
    final picked = await _picker.pickImage(source: source, imageQuality: 80, maxWidth: 1200);
    if (picked != null) setState(() => _banner = File(picked.path));
  }

  Future<String?> _upload(File file) async {
    return await FirebaseStorageService.uploadFile(file, 'banners');
  }

  Future<void> _continue() async {
    if (_banner == null) {
      // Skip — banner is optional
      Get.offAllNamed(AppRoutes.storeIdCard);
      return;
    }
    setState(() => _uploading = true);
    try {
      final url = await _upload(_banner!);
      if (url != null) {
        setState(() { _uploading = false; _saving = true; });
        await DioClient.instance.put('/store/me', data: {'bannerUrls': [url]});
      }
      Get.offAllNamed(AppRoutes.storeIdCard);
    } catch (_) {
      Get.snackbar('Error', 'Upload failed. You can add a banner later from settings.', snackPosition: SnackPosition.BOTTOM);
      Get.offAllNamed(AppRoutes.storeIdCard);
    }
    setState(() { _uploading = false; _saving = false; });
  }

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
              _progressBar(step: 4),
              const SizedBox(height: 24),
              const Text('Add a store banner', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
              const SizedBox(height: 4),
              const Text('A banner helps customers recognize your store.', style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
              const SizedBox(height: 32),
              // Banner preview / picker
              GestureDetector(
                onTap: () => _showSourceSheet(),
                child: Container(
                  width: double.infinity,
                  height: 200,
                  decoration: BoxDecoration(
                    color: AppColors.backgroundSecondary,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border, width: 2, style: _banner == null ? BorderStyle.solid : BorderStyle.solid),
                    image: _banner != null ? DecorationImage(image: FileImage(_banner!), fit: BoxFit.cover) : null,
                  ),
                  child: _banner == null
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 56, height: 56,
                              decoration: BoxDecoration(color: AppColors.primaryLight, shape: BoxShape.circle),
                              child: const Icon(Icons.add_photo_alternate_outlined, color: AppColors.primary, size: 28),
                            ),
                            const SizedBox(height: 12),
                            const Text('Tap to upload banner', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                            const SizedBox(height: 4),
                            const Text('JPG or PNG, recommended 1200×400', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                          ],
                        )
                      : Align(
                          alignment: Alignment.bottomRight,
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: GestureDetector(
                              onTap: _showSourceSheet,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(20)),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [Icon(Icons.edit, color: Colors.white, size: 14), SizedBox(width: 4), Text('Change', style: TextStyle(color: Colors.white, fontSize: 12))],
                                ),
                              ),
                            ),
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: (_uploading || _saving) ? null : _continue,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: (_uploading || _saving)
                    ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                    : Text(_banner != null ? 'Save & Continue' : 'Skip for now', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSourceSheet() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 20),
            ListTile(
              leading: Container(width: 40, height: 40, decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.camera_alt_outlined, color: AppColors.primary)),
              title: const Text('Take Photo', style: TextStyle(fontWeight: FontWeight.w600)),
              onTap: () { Get.back(); _pick(ImageSource.camera); },
            ),
            ListTile(
              leading: Container(width: 40, height: 40, decoration: BoxDecoration(color: AppColors.infoLight, borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.photo_library_outlined, color: AppColors.info)),
              title: const Text('Choose from Gallery', style: TextStyle(fontWeight: FontWeight.w600)),
              onTap: () { Get.back(); _pick(ImageSource.gallery); },
            ),
          ],
        ),
      ),
    );
  }

  Widget _progressBar({required int step}) {
    return Row(
      children: List.generate(5, (i) {
        final n = i + 1;
        final done = n < step;
        final active = n == step;
        return Expanded(
          child: Row(
            children: [
              _dot(n, done: done, active: active),
              if (i < 4) Expanded(child: Container(height: 2, color: done ? AppColors.primary : AppColors.border, margin: const EdgeInsets.symmetric(horizontal: 4))),
            ],
          ),
        );
      }),
    );
  }

  Widget _dot(int n, {bool done = false, bool active = false}) {
    return Container(
      width: 28, height: 28,
      decoration: BoxDecoration(
        color: done ? AppColors.primary : active ? AppColors.primaryLight : AppColors.backgroundSecondary,
        shape: BoxShape.circle,
        border: Border.all(color: done || active ? AppColors.primary : AppColors.border, width: 2),
      ),
      child: Center(
        child: done ? const Icon(Icons.check, size: 14, color: Colors.white)
            : Text('$n', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: active ? AppColors.primary : AppColors.textTertiary)),
      ),
    );
  }
}
