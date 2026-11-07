import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ui_kit/ui_kit.dart';
import 'package:domain/domain.dart';
import '../../providers/product_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/floating_cart_bar.dart';

class ProductDetailScreen extends ConsumerStatefulWidget {
  final String productId;

  const ProductDetailScreen({super.key, required this.productId});

  @override
  ConsumerState<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends ConsumerState<ProductDetailScreen> {
  String? _selectedSize;
  String? _selectedColor;
  int _quantity = 1;
  bool _isAdding = false;

  @override
  void dispose() {
    ZomatoCartPopup.hide();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final productAsync = ref.watch(singleProductProvider(widget.productId));
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_bag_outlined),
            onPressed: () => context.push('/cart'),
          ),
        ],
      ),
      body: productAsync.when(
        data: (product) {
          if (product == null) {
            return const Center(child: Text('Product not found'));
          }

          final sizes = product.variants.map((v) => v.size).toSet().toList();
          final colors = product.variants.map((v) => v.color).toSet().toList();

          _selectedSize ??= sizes.isNotEmpty ? sizes.first : 'Standard';
          _selectedColor ??= colors.isNotEmpty ? colors.first : 'Standard';

          // Find current variant stock
          final matchingVariant = product.variants.firstWhere(
            (v) => v.size == _selectedSize && v.color == _selectedColor,
            orElse: () => product.variants.isNotEmpty
                ? product.variants.first
                : const ProductVariantEntity(
                    id: 'default',
                    productId: '',
                    size: 'M',
                    color: 'Standard',
                    colorHex: '#000',
                    sku: '',
                    stockCount: 5,
                  ),
          );

          final bool inStock = matchingVariant.stockCount > 0;

          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppSpacing.pagePadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Product Image
                      ProductImage(
                        imageUrl: product.imageUrls.isNotEmpty ? product.imageUrls.first : null,
                        height: 280,
                        width: double.infinity,
                        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                      ),
                      const SizedBox(height: 16),

                      // Name & Rating
                      Text(product.name, style: AppTextStyles.headlineMedium),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.star_rounded, color: AppColors.warning, size: 20),
                          const SizedBox(width: 4),
                          Text(product.rating.toStringAsFixed(1), style: AppTextStyles.labelLarge),
                          const SizedBox(width: 8),
                          Text('(${product.totalRatings} reviews)', style: AppTextStyles.bodySmall),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: inStock ? AppColors.success.withOpacity(0.15) : AppColors.error.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              inStock ? 'IN STOCK (${matchingVariant.stockCount})' : 'OUT OF STOCK',
                              style: TextStyle(
                                color: inStock ? AppColors.success : AppColors.error,
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Price
                      Row(
                        children: [
                          Text(product.priceDisplay, style: AppTextStyles.price.copyWith(fontSize: 24)),
                          if (product.discountedPrice > 0 && product.discountedPrice < product.basePrice) ...[
                            const SizedBox(width: 10),
                            Text(
                              '₹${(product.basePrice / 100).toStringAsFixed(0)}',
                              style: const TextStyle(
                                fontSize: 16,
                                decoration: TextDecoration.lineThrough,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ],
                      ),
                      const Divider(height: 24),

                      // Size Selection
                      if (sizes.isNotEmpty) ...[
                        Text('Select Size', style: AppTextStyles.titleMedium),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          children: sizes.map((size) {
                            final isSel = _selectedSize == size;
                            return ChoiceChip(
                              label: Text(size),
                              selected: isSel,
                              selectedColor: AppColors.primary,
                              labelStyle: TextStyle(color: isSel ? Colors.white : AppColors.textPrimary),
                              onSelected: (_) => setState(() => _selectedSize = size),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Color Selection
                      if (colors.isNotEmpty) ...[
                        Text('Select Color', style: AppTextStyles.titleMedium),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          children: colors.map((col) {
                            final isSel = _selectedColor == col;
                            return ChoiceChip(
                              label: Text(col),
                              selected: isSel,
                              selectedColor: AppColors.primary,
                              labelStyle: TextStyle(color: isSel ? Colors.white : AppColors.textPrimary),
                              onSelected: (_) => setState(() => _selectedColor = col),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Quantity Selector
                      Row(
                        children: [
                          Text('Quantity', style: AppTextStyles.titleMedium),
                          const Spacer(),
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: AppColors.divider),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.remove, size: 18),
                                  onPressed: _quantity > 1 ? () => setState(() => _quantity--) : null,
                                ),
                                Text('$_quantity', style: AppTextStyles.titleMedium),
                                IconButton(
                                  icon: const Icon(Icons.add, size: 18),
                                  onPressed: _quantity < matchingVariant.stockCount
                                      ? () => setState(() => _quantity++)
                                      : null,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Description
                      Text('Product Description', style: AppTextStyles.titleMedium),
                      const SizedBox(height: 6),
                      Text(
                        product.description.isNotEmpty
                            ? product.description
                            : 'High quality clothing crafted for style and everyday comfort. Available for hyperlocal delivery.',
                        style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 16),

                      // ── STATUTORY LEGAL METROLOGY & CONSUMER PROTECTION (INDIA) ──
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.verified_outlined, size: 16, color: AppColors.primary),
                                SizedBox(width: 6),
                                Text(
                                  'Statutory Legal Metrology Declarations',
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            _metrologyRow('Country of Origin', 'India 🇮🇳 (Mandatory under Rule 6(10))'),
                            _metrologyRow('Net Quantity', '1 Unit Garment / Apparel'),
                            _metrologyRow('Maximum Retail Price (MRP)', '₹${(product.basePrice / 100).toStringAsFixed(0)} (Incl. of all taxes)'),
                            _metrologyRow('Manufactured & Packed By', 'Authorized Boutique Merchant, Kubernagar / Ahmedabad, Gujarat'),
                            _metrologyRow('48-Hour Size Exchange', 'Guaranteed doorstep replacement under Consumer Protection Rules'),
                            _metrologyRow('Grievance Redressal Desk', 'Meet Ratwani (grievance@xyzstartup.in, Kubernagar, Ahmedabad)'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),

              // Sticky Add to Cart Bottom Bar
              Container(
                padding: const EdgeInsets.all(AppSpacing.pagePadding),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: SafeArea(
                  child: Row(
                    children: [
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Total Price', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                          Text(
                            '₹${((product.effectivePrice * _quantity) / 100).toStringAsFixed(0)}',
                            style: AppTextStyles.price,
                          ),
                        ],
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: AppButton(
                          label: inStock ? 'Add to Cart' : 'Out of Stock',
                          isLoading: _isAdding,
                          onPressed: inStock
                              ? () async {
                                  final customerId = user?.uid ?? isolatedGuestSessionId;
                                  setState(() => _isAdding = true);
                                  final cartRepo = ref.read(cartRepositoryProvider);
                                  await cartRepo.addToCart(
                                    CartItemEntity(
                                      id: '${product.id}_${_selectedSize}_$_selectedColor',
                                      customerId: customerId,
                                      productId: product.id,
                                      variantId: matchingVariant.id,
                                      storeId: product.storeId,
                                      vendorId: product.vendorId,
                                      productName: product.name,
                                      imageUrl: product.imageUrls.isNotEmpty ? product.imageUrls.first : '',
                                      unitPrice: product.effectivePrice,
                                      quantity: _quantity,
                                      size: _selectedSize ?? '',
                                      color: _selectedColor ?? '',
                                    ),
                                  );
                                  setState(() => _isAdding = false);
                                  if (mounted) {
                                    final cartSummary = ref.read(cartSummaryProvider);
                                    final currentCount = cartSummary.itemCount > 0 ? cartSummary.itemCount : _quantity;
                                    final currentTotal = cartSummary.grandTotal > 0
                                        ? cartSummary.grandTotalDisplay
                                        : '₹${((product.effectivePrice * _quantity) / 100).toStringAsFixed(0)}';

                                    ZomatoCartPopup.show(
                                      context,
                                      itemCount: currentCount,
                                      totalDisplay: currentTotal,
                                      productName: product.name,
                                      bottomOffset: 92,
                                    );
                                  }
                                }
                              : null,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _metrologyRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(value, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.black87)),
          ),
        ],
      ),
    );
  }

}
