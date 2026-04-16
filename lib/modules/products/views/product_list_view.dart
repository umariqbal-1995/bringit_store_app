import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_theme.dart';
import '../../../routes/app_routes.dart';
import '../controllers/product_controller.dart';
import '../../../data/models/product_model.dart';

class ProductListView extends StatelessWidget {
  const ProductListView({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<ProductController>();
    return Scaffold(
      backgroundColor: AppColors.backgroundSecondary,
      appBar: AppBar(
        title: const Text('Products'),
        backgroundColor: AppColors.background,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            color: AppColors.primary,
            onPressed: () {
              ctrl.selectedProduct.value = null;
              Get.toNamed(AppRoutes.addProduct);
            },
          ),
        ],
      ),
      body: Obx(() {
        if (ctrl.isLoading.value) {
          return const Center(child: CircularProgressIndicator(color: AppColors.primary));
        }
        if (ctrl.products.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.inventory_2_outlined, size: 64, color: AppColors.textTertiary),
                const SizedBox(height: 12),
                const Text('No products yet', style: TextStyle(fontSize: 16, color: AppColors.textSecondary)),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: () {
                    ctrl.selectedProduct.value = null;
                    Get.toNamed(AppRoutes.addProduct);
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Add Product'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(160, 48),
                    elevation: 0,
                  ),
                ),
              ],
            ),
          );
        }
        return RefreshIndicator(
          color: AppColors.primary,
          onRefresh: ctrl.fetchProducts,
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: ctrl.products.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (_, i) => _ProductCard(product: ctrl.products[i], ctrl: ctrl),
          ),
        );
      }),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          ctrl.selectedProduct.value = null;
          Get.toNamed(AppRoutes.addProduct);
        },
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Add Product', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final ProductModel product;
  final ProductController ctrl;
  const _ProductCard({required this.product, required this.ctrl});

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
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.backgroundSecondary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: product.imageUrl != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(product.imageUrl!, fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(Icons.fastfood_rounded, color: AppColors.textTertiary, size: 28)),
                  )
                : const Icon(Icons.fastfood_rounded, color: AppColors.textTertiary, size: 28),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                ),
                if (product.description != null && product.description!.isNotEmpty)
                  Text(
                    product.description!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
                const SizedBox(height: 4),
                Text(
                  'PKR ${product.price.toStringAsFixed(0)}',
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.primary),
                ),
              ],
            ),
          ),
          Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: product.isAvailable ? AppColors.successLight : AppColors.errorLight,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  product.isAvailable ? 'Active' : 'Hidden',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: product.isAvailable ? AppColors.success : AppColors.error,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      ctrl.selectedProduct.value = product;
                      Get.toNamed(AppRoutes.editProduct);
                    },
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: AppColors.infoLight,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.edit_outlined, size: 16, color: AppColors.info),
                    ),
                  ),
                  const SizedBox(width: 6),
                  GestureDetector(
                    onTap: () => _confirmDelete(ctrl, product.id),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: AppColors.errorLight,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.delete_outline, size: 16, color: AppColors.error),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _confirmDelete(ProductController ctrl, String id) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete Product', style: TextStyle(fontWeight: FontWeight.w700)),
        content: const Text('Are you sure you want to delete this product?'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Get.back();
              ctrl.deleteProduct(id);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
