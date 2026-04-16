import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/storage/storage_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../routes/app_routes.dart';

class StoreTypeView extends StatelessWidget {
  const StoreTypeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 32),
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(Icons.store_rounded, color: AppColors.primary, size: 32),
              ),
              const SizedBox(height: 24),
              const Text(
                'What type of\nbusiness is this?',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: AppColors.textPrimary, height: 1.2),
              ),
              const SizedBox(height: 8),
              const Text(
                'This helps us show the right tools for your business.',
                style: TextStyle(fontSize: 15, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 48),
              _TypeCard(
                icon: Icons.restaurant_rounded,
                title: 'Restaurant',
                subtitle: 'You prepare food — manage your menu, ingredients and dishes',
                color: AppColors.primary,
                bg: AppColors.primaryLight,
                onTap: () => _selectType('RESTAURANT'),
              ),
              const SizedBox(height: 16),
              _TypeCard(
                icon: Icons.storefront_rounded,
                title: 'Store / Shop',
                subtitle: 'You sell products — groceries, retail, pharmacy or any goods',
                color: AppColors.info,
                bg: AppColors.infoLight,
                onTap: () => _selectType('STORE'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectType(String type) async {
    StorageService.setStoreType(type);
    Get.offAllNamed(AppRoutes.storeSetup, arguments: {'type': type});
  }
}

class _TypeCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final Color bg;
  final VoidCallback onTap;

  const _TypeCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.bg,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border, width: 1.5),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(16)),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.4)),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.arrow_forward_ios_rounded, size: 16, color: color),
          ],
        ),
      ),
    );
  }
}
