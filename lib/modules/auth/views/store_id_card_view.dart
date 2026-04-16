import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/services/firebase_storage_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../routes/app_routes.dart';

class StoreIdCardView extends StatefulWidget {
  const StoreIdCardView({super.key});

  @override
  State<StoreIdCardView> createState() => _StoreIdCardViewState();
}

class _StoreIdCardViewState extends State<StoreIdCardView> {
  File? _front;
  File? _back;
  bool _saving = false;
  final _picker = ImagePicker();

  Future<void> _pick(bool isFront, ImageSource source) async {
    final picked = await _picker.pickImage(source: source, imageQuality: 85, maxWidth: 1600);
    if (picked == null) return;
    setState(() {
      if (isFront) _front = File(picked.path);
      else _back = File(picked.path);
    });
  }

  Future<String?> _upload(File file, String name) async {
    return await FirebaseStorageService.uploadFile(file, 'id_cards');
  }

  Future<void> _finish() async {
    if (_front == null || _back == null) {
      Get.snackbar('Required', 'Please upload both front and back of your ID card.', snackPosition: SnackPosition.BOTTOM);
      return;
    }
    setState(() => _saving = true);
    try {
      final frontUrl = await _upload(_front!, 'id_front.jpg');
      final backUrl = await _upload(_back!, 'id_back.jpg');
      await DioClient.instance.put('/store/me', data: {
        'idCardFrontUrl': frontUrl,
        'idCardBackUrl': backUrl,
      });
      Get.offAllNamed(AppRoutes.home);
    } catch (_) {
      Get.snackbar('Error', 'Upload failed. You can submit ID documents later from settings.', snackPosition: SnackPosition.BOTTOM);
      Get.offAllNamed(AppRoutes.home);
    }
    setState(() => _saving = false);
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
              _progressBar(step: 5),
              const SizedBox(height: 24),
              const Text('Verify your identity', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
              const SizedBox(height: 4),
              const Text('Upload a clear photo of your CNIC — both sides.', style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: AppColors.warningLight, borderRadius: BorderRadius.circular(10)),
                child: const Row(
                  children: [
                    Icon(Icons.lock_outlined, color: AppColors.warning, size: 18),
                    SizedBox(width: 8),
                    Expanded(child: Text('Your documents are encrypted and used only for identity verification.', style: TextStyle(fontSize: 12, color: AppColors.warning))),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              _cardLabel('Front Side', Icons.credit_card_rounded),
              const SizedBox(height: 10),
              _idCardPicker(
                file: _front,
                isFront: true,
                placeholder: 'Front of CNIC',
                hint: 'Tap to upload front side',
              ),
              const SizedBox(height: 24),
              _cardLabel('Back Side', Icons.credit_card_outlined),
              const SizedBox(height: 10),
              _idCardPicker(
                file: _back,
                isFront: false,
                placeholder: 'Back of CNIC',
                hint: 'Tap to upload back side',
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: _saving ? null : _finish,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: _saving
                    ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                    : const Text('Complete Setup', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              ),
              const SizedBox(height: 12),
              Center(
                child: TextButton(
                  onPressed: _saving ? null : () => Get.offAllNamed(AppRoutes.home),
                  child: const Text('Skip for now', style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _cardLabel(String label, IconData icon) => Row(
    children: [
      Icon(icon, size: 18, color: AppColors.textSecondary),
      const SizedBox(width: 8),
      Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
    ],
  );

  Widget _idCardPicker({required File? file, required bool isFront, required String placeholder, required String hint}) {
    return GestureDetector(
      onTap: () => _showSourceSheet(isFront),
      child: Container(
        width: double.infinity,
        height: 160,
        decoration: BoxDecoration(
          color: AppColors.backgroundSecondary,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: file != null ? AppColors.success : AppColors.border,
            width: file != null ? 2 : 1.5,
          ),
          image: file != null ? DecorationImage(image: FileImage(file), fit: BoxFit.cover) : null,
        ),
        child: file == null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 48, height: 48,
                    decoration: BoxDecoration(color: AppColors.infoLight, shape: BoxShape.circle),
                    child: const Icon(Icons.add_a_photo_outlined, color: AppColors.info, size: 24),
                  ),
                  const SizedBox(height: 10),
                  Text(hint, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                  const SizedBox(height: 3),
                  const Text('Camera or gallery', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                ],
              )
            : Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: AppColors.success, borderRadius: BorderRadius.circular(20)),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [Icon(Icons.check, color: Colors.white, size: 13), SizedBox(width: 4), Text('Uploaded', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700))],
                    ),
                  ),
                ),
              ),
      ),
    );
  }

  void _showSourceSheet(bool isFront) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 20),
            Text(isFront ? 'Upload Front Side' : 'Upload Back Side', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            ListTile(
              leading: Container(width: 40, height: 40, decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.camera_alt_outlined, color: AppColors.primary)),
              title: const Text('Take Photo', style: TextStyle(fontWeight: FontWeight.w600)),
              onTap: () { Get.back(); _pick(isFront, ImageSource.camera); },
            ),
            ListTile(
              leading: Container(width: 40, height: 40, decoration: BoxDecoration(color: AppColors.infoLight, borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.photo_library_outlined, color: AppColors.info)),
              title: const Text('Choose from Gallery', style: TextStyle(fontWeight: FontWeight.w600)),
              onTap: () { Get.back(); _pick(isFront, ImageSource.gallery); },
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
