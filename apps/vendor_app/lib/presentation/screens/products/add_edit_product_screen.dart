import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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
  final _imageUrlController = TextEditingController();
  final _colorController = TextEditingController(text: 'Multicolor');
  final _stockController = TextEditingController(text: '10');

  String _selectedCategory = 'women';
  final List<String> _sizes = ['M', 'L'];
  bool _isLoading = false;

  final _categories = [
    {'id': 'women', 'label': 'Women Fashion'},
    {'id': 'men', 'label': 'Men Clothing'},
    {'id': 'ethnic', 'label': 'Ethnic & Bridal'},
    {'id': 'western', 'label': 'Western & Casuals'},
    {'id': 'kids', 'label': 'Kids Wear'},
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _basePriceController.dispose();
    _discountPriceController.dispose();
    _imageUrlController.dispose();
    _colorController.dispose();
    _stockController.dispose();
    super.dispose();
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
            'sku': '${_nameController.text.substring(0, 3).toUpperCase()}-$s',
            'stockCount': stock,
          }).toList();

      final imgUrl = _imageUrlController.text.trim().isNotEmpty
          ? _imageUrlController.text.trim()
          : 'https://images.unsplash.com/photo-1523381210434-271e8be1f52b?w=800&auto=format&fit=crop';

      await ref.read(vendorProductRepoProvider).addProduct(
            storeId: storeId,
            vendorId: vendorId,
            name: _nameController.text.trim(),
            description: _descController.text.trim(),
            categoryId: _selectedCategory,
            basePrice: baseInPaise,
            discountedPrice: discountInPaise,
            imageUrls: [imgUrl],
            variants: variants,
          );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Product added successfully to inventory!')),
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

              // Pricing (in INR)
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
                children: ['S', 'M', 'L', 'XL', 'XXL', 'Free Size'].map((size) {
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

              // Primary Color & Initial Stock
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
              const SizedBox(height: AppSpacing.md),

              // Image URL
              AppTextField(
                label: 'Product Image URL (Optional)',
                hint: 'https://images.unsplash.com/...',
                controller: _imageUrlController,
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
