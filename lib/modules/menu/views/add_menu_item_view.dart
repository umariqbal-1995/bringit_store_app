import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/services/firebase_storage_service.dart';
import '../../../core/theme/app_theme.dart';
import '../controllers/menu_controller.dart';

class AddMenuItemView extends StatefulWidget {
  final bool isEditing;
  const AddMenuItemView({super.key, this.isEditing = false});

  @override
  State<AddMenuItemView> createState() => _AddMenuItemViewState();
}

class _AddMenuItemViewState extends State<AddMenuItemView> {
  late final StoreMenuController controller;
  late final TextEditingController nameCtrl;
  late final TextEditingController priceCtrl;
  late final TextEditingController descCtrl;
  late final TextEditingController categoryCtrl;
  late final RxBool isAvailable;
  File? _imageFile;
  String? _existingImageUrl;
  bool _uploadingImage = false;
  final _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    controller = Get.find<StoreMenuController>();
    final item = widget.isEditing ? controller.selectedItem.value : null;
    nameCtrl = TextEditingController(text: item?.name ?? '');
    priceCtrl = TextEditingController(text: item?.price.toString() ?? '');
    descCtrl = TextEditingController(text: item?.description ?? '');
    categoryCtrl = TextEditingController(text: item?.category ?? '');
    isAvailable = (item?.isAvailable ?? true).obs;
    _existingImageUrl = item?.imageUrl;
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    priceCtrl.dispose();
    descCtrl.dispose();
    categoryCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final picked = await _picker.pickImage(source: source, imageQuality: 82, maxWidth: 800, maxHeight: 800);
    if (picked != null) setState(() => _imageFile = File(picked.path));
  }

  void _showImageSheet() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 20),
            ListTile(
              leading: Container(width: 40, height: 40, decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.camera_alt_outlined, color: AppColors.primary)),
              title: const Text('Take Photo', style: TextStyle(fontWeight: FontWeight.w600)),
              onTap: () { Get.back(); _pickImage(ImageSource.camera); },
            ),
            ListTile(
              leading: Container(width: 40, height: 40, decoration: BoxDecoration(color: AppColors.infoLight, borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.photo_library_outlined, color: AppColors.info)),
              title: const Text('Choose from Gallery', style: TextStyle(fontWeight: FontWeight.w600)),
              onTap: () { Get.back(); _pickImage(ImageSource.gallery); },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (nameCtrl.text.trim().isEmpty || priceCtrl.text.trim().isEmpty) {
      Get.snackbar('Error', 'Name and price are required', snackPosition: SnackPosition.BOTTOM);
      return;
    }

    String? imageUrl = _existingImageUrl;

    if (_imageFile != null) {
      setState(() => _uploadingImage = true);
      try {
        imageUrl = await FirebaseStorageService.uploadFile(_imageFile!, 'menu_items');
      } catch (_) {
        Get.snackbar('Warning', 'Image upload failed. Saving without image.', snackPosition: SnackPosition.BOTTOM);
      }
      setState(() => _uploadingImage = false);
    }

    final data = <String, dynamic>{
      'name': nameCtrl.text.trim(),
      'price': double.tryParse(priceCtrl.text) ?? 0,
      'description': descCtrl.text.trim(),
      'category': categoryCtrl.text.trim(),
      'imageUrl': imageUrl,
      'isAvailable': isAvailable.value,
    };

    final item = widget.isEditing ? controller.selectedItem.value : null;
    if (widget.isEditing && item != null) {
      controller.updateItem(item.id, data);
    } else {
      controller.createItem(data);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundSecondary,
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Edit Menu Item' : 'Add Menu Item'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _label('Item Name *'),
                  const SizedBox(height: 6),
                  TextField(controller: nameCtrl, decoration: _dec('e.g. Combo Meal')),
                  const SizedBox(height: 16),
                  _label('Price *'),
                  const SizedBox(height: 6),
                  TextField(
                    controller: priceCtrl,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}'))],
                    decoration: _dec('0.00').copyWith(
                      prefixText: 'PKR ',
                      prefixStyle: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _label('Description'),
                  const SizedBox(height: 6),
                  TextField(controller: descCtrl, maxLines: 3, decoration: _dec('Optional...')),
                  const SizedBox(height: 16),
                  _label('Category'),
                  const SizedBox(height: 6),
                  TextField(controller: categoryCtrl, decoration: _dec('e.g. Meals, Drinks...')),
                  const SizedBox(height: 16),
                  _label('Item Image'),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: _showImageSheet,
                    child: Container(
                      width: double.infinity,
                      height: 140,
                      decoration: BoxDecoration(
                        color: AppColors.backgroundSecondary,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _imageFile != null ? AppColors.success : AppColors.border,
                          width: _imageFile != null ? 2 : 1.5,
                        ),
                        image: _imageFile != null
                            ? DecorationImage(image: FileImage(_imageFile!), fit: BoxFit.cover)
                            : (_existingImageUrl != null
                                ? DecorationImage(image: NetworkImage(_existingImageUrl!), fit: BoxFit.cover)
                                : null),
                      ),
                      child: (_imageFile == null && _existingImageUrl == null)
                          ? Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 44, height: 44,
                                  decoration: BoxDecoration(color: AppColors.infoLight, shape: BoxShape.circle),
                                  child: const Icon(Icons.add_a_photo_outlined, color: AppColors.info, size: 22),
                                ),
                                const SizedBox(height: 8),
                                const Text('Tap to add image', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                                const SizedBox(height: 2),
                                const Text('Camera or gallery', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                              ],
                            )
                          : Align(
                              alignment: Alignment.topRight,
                              child: Padding(
                                padding: const EdgeInsets.all(8),
                                child: GestureDetector(
                                  onTap: _showImageSheet,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(20)),
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [Icon(Icons.edit, color: Colors.white, size: 12), SizedBox(width: 4), Text('Change', style: TextStyle(color: Colors.white, fontSize: 11))],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Available', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                      Obx(() => Switch(
                            value: isAvailable.value,
                            onChanged: (v) => isAvailable.value = v,
                            activeColor: AppColors.primary,
                          )),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Obx(() {
              final busy = controller.isSaving.value || _uploadingImage;
              return ElevatedButton(
                onPressed: busy ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: busy
                    ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                    : Text(
                        widget.isEditing ? 'Update Item' : 'Add Item',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                      ),
              );
            }),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _label(String t) => Text(t, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary));

  InputDecoration _dec(String hint) => InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: AppColors.backgroundSecondary,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary, width: 2)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      );
}
