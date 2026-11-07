import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:core/core.dart';
import 'package:ui_kit/ui_kit.dart';
import '../../providers/vendor_providers.dart';

class AddEditProductScreen extends ConsumerStatefulWidget {
  const AddEditProductScreen({super.key});

  @override
  ConsumerState<AddEditProductScreen> createState() => _AddEditProductScreenState();
}

class _AddEditProductScreenState extends ConsumerState<AddEditProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _basePriceController = TextEditingController();
  final _discountPriceController = TextEditingController();
  final _colorController = TextEditingController(text: 'Multicolor');
  final _stockController = TextEditingController(text: '10');

  String _selectedCategory = 'women';
  final List<String> _sizes = ['M', 'L', 'XL'];
  bool _isLoading = false;

  // Multi-image list (4-5 images supported)
  final List<String> _imageUrls = [
    'https://images.unsplash.com/photo-1610030469983-98e550d6193c?w=800',
    'https://images.unsplash.com/photo-1583391733956-3750e0ff4e8b?w=800',
  ];

  final _categories = [
    {'id': 'women', 'label': 'Women Fashion'},
    {'id': 'men', 'label': 'Men Clothing'},
    {'id': 'ethnic', 'label': 'Ethnic & Bridal'},
    {'id': 'western', 'label': 'Western & Casuals'},
    {'id': 'kids', 'label': 'Kids Wear'},
  ];

  final _curatedCloudinaryPresets = [
    {'title': 'Saree / Chiffon', 'url': 'https://images.unsplash.com/photo-1610030469983-98e550d6193c?w=800'},
    {'title': 'Designer Kurti', 'url': 'https://images.unsplash.com/photo-1617627143750-d86bc21e42bb?w=800'},
    {'title': 'Bridal Lehenga', 'url': 'https://images.unsplash.com/photo-1583391733956-3750e0ff4e8b?w=800'},
    {'title': 'Men Cotton Shirt', 'url': 'https://images.unsplash.com/photo-1596755094514-f87e34085b2c?w=800'},
    {'title': 'Denim & Western', 'url': 'https://images.unsplash.com/photo-1576995853123-5a10305d93c0?w=800'},
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _basePriceController.dispose();
    _discountPriceController.dispose();
    _colorController.dispose();
    _stockController.dispose();
    super.dispose();
  }

  void _addImage(String url) {
    if (_imageUrls.length >= 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Maximum 5 images allowed per product')),
      );
      return;
    }
    setState(() => _imageUrls.add(url));
  }

  Future<void> _pickAndUploadImage(ImageSource source) async {
    final picker = ImagePicker();
    final XFile? file = await picker.pickImage(
      source: source,
      maxWidth: 1600,
      imageQuality: 85,
    );
    if (file == null) return;

    setState(() => _isLoading = true);
    try {
      final bytes = await file.readAsBytes();
      const cloudinary = CloudinaryService();
      final (url, failure) = await cloudinary.uploadImageBytes(
        bytes: bytes,
        fileName: 'prod_${DateTime.now().millisecondsSinceEpoch}.jpg',
        folder: 'products',
      );
      if (url != null) {
        _addImage(url);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              backgroundColor: AppColors.success,
              content: Text('✅ Image uploaded directly to Cloudinary!'),
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: AppColors.error,
              content: Text('Upload failed: ${failure?.message ?? "Error"}'),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Upload error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showAddPhotoSheet() {
    final customUrlCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Add Product Photo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
              ],
            ),
            const SizedBox(height: 6),
            const Text(
              'Click a fresh photo or select from gallery to upload directly to Cloudinary.',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),

            // Direct Camera & Gallery Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    icon: const Icon(Icons.camera_alt_rounded, size: 18),
                    label: const Text('Camera', style: TextStyle(fontWeight: FontWeight.bold)),
                    onPressed: () {
                      Navigator.pop(ctx);
                      _pickAndUploadImage(ImageSource.camera);
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    icon: const Icon(Icons.photo_library_rounded, size: 18),
                    label: const Text('Gallery', style: TextStyle(fontWeight: FontWeight.bold)),
                    onPressed: () {
                      Navigator.pop(ctx);
                      _pickAndUploadImage(ImageSource.gallery);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            const Row(
              children: [
                Expanded(child: Divider()),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Text('OR ENTER LINK', style: TextStyle(fontSize: 10, color: AppColors.textSecondary, fontWeight: FontWeight.bold)),
                ),
                Expanded(child: Divider()),
              ],
            ),
            const SizedBox(height: 12),

            // URL Input
            TextField(
              controller: customUrlCtrl,
              decoration: const InputDecoration(
                labelText: 'Image URL or Cloudinary Link',
                hintText: 'https://res.cloudinary.com/...',
                prefixIcon: Icon(Icons.cloud_upload_outlined),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(44)),
              onPressed: () {
                if (customUrlCtrl.text.trim().isNotEmpty) {
                  _addImage(customUrlCtrl.text.trim());
                  Navigator.pop(ctx);
                }
              },
              child: const Text('Add Image Link'),
            ),
            const SizedBox(height: 16),

            const Text('Or Select High-Res Preset:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _curatedCloudinaryPresets.map((preset) {
                return ActionChip(
                  avatar: const Icon(Icons.image, size: 16),
                  label: Text(preset['title']!),
                  onPressed: () {
                    _addImage(preset['url']!);
                    Navigator.pop(ctx);
                  },
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final storeAsync = ref.read(currentStoreProvider);
      final storeId = storeAsync.valueOrNull?.id ?? 'store-kubernagar-1';
      final vendorId = storeAsync.valueOrNull?.vendorId ?? 'vendor-1';

      final baseInRupees = double.tryParse(_basePriceController.text.trim()) ?? 0;
      final discountInRupees = double.tryParse(_discountPriceController.text.trim()) ?? baseInRupees;

      final baseInPaise = (baseInRupees * 100).toInt();
      final discountInPaise = (discountInRupees * 100).toInt();

      final color = _colorController.text.trim().isEmpty ? 'Multicolor' : _colorController.text.trim();
      final stock = int.tryParse(_stockController.text.trim()) ?? 10;

      final variants = _sizes.map((s) => {
            'size': s,
            'color': color,
            'colorHex': '#E94560',
            'additionalPrice': 0,
            'sku': '${_nameController.text.substring(0, _nameController.text.length.clamp(1, 3)).toUpperCase()}-$s',
            'stockCount': stock,
          }).toList();

      final images = _imageUrls.isNotEmpty
          ? _imageUrls
          : ['https://images.unsplash.com/photo-1523381210434-271e8be1f52b?w=800'];

      await ref.read(vendorProductRepoProvider).addProduct(
            storeId: storeId,
            vendorId: vendorId,
            name: _nameController.text.trim(),
            description: _descController.text.trim(),
            categoryId: _selectedCategory,
            basePrice: baseInPaise,
            discountedPrice: discountInPaise,
            imageUrls: images,
            variants: variants,
          );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Product added with multi-image Cloudinary gallery!')),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not save product: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Fashion Product')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.pagePadding),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Product Information', style: AppTextStyles.titleMedium),
              const SizedBox(height: 14),

              // Product Name
              AppTextField(
                label: 'Product Title',
                hint: 'e.g. Traditional Bandhani Kurti',
                controller: _nameController,
                validator: (v) => v == null || v.isEmpty ? 'Title is required' : null,
              ),
              const SizedBox(height: AppSpacing.md),

              // Category dropdown
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: InputDecoration(
                  labelText: 'Fashion Category',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusSm)),
                ),
                items: _categories
                    .map((c) => DropdownMenuItem(value: c['id'], child: Text(c['label']!)))
                    .toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedCategory = val);
                },
              ),
              const SizedBox(height: AppSpacing.md),

              // Description
              AppTextField(
                label: 'Description & Fabric Details',
                hint: 'e.g. 100% pure cotton, hand-embroidered neckline, machine washable',
                controller: _descController,
                maxLines: 3,
                validator: (v) => v == null || v.isEmpty ? 'Description is required' : null,
              ),
              const SizedBox(height: AppSpacing.lg),

              // Multi-Photo Gallery (Cloudinary)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Product Photos (${_imageUrls.length}/5)', style: AppTextStyles.titleMedium),
                  TextButton.icon(
                    icon: const Icon(Icons.add_photo_alternate_rounded, size: 18),
                    label: const Text('Add Photo (Cloudinary)'),
                    onPressed: _showAddPhotoSheet,
                  ),
                ],
              ),
              const SizedBox(height: 8),

              SizedBox(
                height: 110,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _imageUrls.length + (_imageUrls.length < 5 ? 1 : 0),
                  separatorBuilder: (_, __) => const SizedBox(width: 10),
                  itemBuilder: (context, index) {
                    if (index == _imageUrls.length) {
                      return InkWell(
                        onTap: _showAddPhotoSheet,
                        child: Container(
                          width: 90,
                          decoration: BoxDecoration(
                            color: AppColors.surfaceVariant,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.divider, style: BorderStyle.solid),
                          ),
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.cloud_upload_rounded, color: AppColors.primary),
                              SizedBox(height: 4),
                              Text('+ Add Photo', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary)),
                            ],
                          ),
                        ),
                      );
                    }

                    final url = _imageUrls[index];
                    return Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            url,
                            width: 90,
                            height: 110,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              width: 90,
                              height: 110,
                              color: AppColors.surfaceVariant,
                              child: const Icon(Icons.broken_image),
                            ),
                          ),
                        ),
                        Positioned(
                          top: 4,
                          right: 4,
                          child: GestureDetector(
                            onTap: () => setState(() => _imageUrls.removeAt(index)),
                            child: Container(
                              padding: const EdgeInsets.all(3),
                              decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                              child: const Icon(Icons.close, size: 14, color: Colors.white),
                            ),
                          ),
                        ),
                        if (index == 0)
                          Positioned(
                            bottom: 4,
                            left: 4,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                              decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(3)),
                              child: const Text('Cover', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ),

              const SizedBox(height: AppSpacing.lg),

              // Pricing
              Text('Pricing & Discounts (₹)', style: AppTextStyles.titleMedium),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: AppTextField(
                      label: 'MRP / Regular Price (₹)',
                      hint: '1299',
                      controller: _basePriceController,
                      keyboardType: TextInputType.number,
                      validator: (v) => v == null || v.isEmpty ? 'Price is required' : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AppTextField(
                      label: 'Selling Price (₹)',
                      hint: '899',
                      controller: _discountPriceController,
                      keyboardType: TextInputType.number,
                      validator: (v) => v == null || v.isEmpty ? 'Selling price required' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),

              // Sizes Selection
              Text('Available Sizes', style: AppTextStyles.titleMedium),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: ['XS', 'S', 'M', 'L', 'XL', 'XXL', '3XL', 'Free Size'].map((size) {
                  final isSelected = _sizes.contains(size);
                  return FilterChip(
                    label: Text(size),
                    selected: isSelected,
                    selectedColor: AppColors.primary,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _sizes.add(size);
                        } else {
                          _sizes.remove(size);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: AppSpacing.md),

              // Color & Stock
              Row(
                children: [
                  Expanded(
                    child: AppTextField(
                      label: 'Primary Color',
                      hint: 'e.g. Maroon / Indigo',
                      controller: _colorController,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AppTextField(
                      label: 'Stock Per Size',
                      hint: '10',
                      controller: _stockController,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),

              // Submit Button
              AppButton(
                label: 'Publish Product to Store',
                isLoading: _isLoading,
                onPressed: _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
