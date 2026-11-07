import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ui_kit/ui_kit.dart';
import 'package:domain/domain.dart';
import '../../providers/vendor_providers.dart';

class VendorProductsScreen extends ConsumerWidget {
  const VendorProductsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(vendorProductsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Inventory'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline_rounded, color: AppColors.accent, size: 28),
            onPressed: () => context.push('/products/add'),
          ),
        ],
      ),
      body: productsAsync.when(
        data: (products) {
          if (products.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.checkroom_rounded, size: 56, color: AppColors.textHint),
                  const SizedBox(height: 12),
                  const Text('No products listed yet', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 6),
                  const Text('Start adding clothes to receive customer orders', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => context.push('/products/add'),
                    icon: const Icon(Icons.add),
                    label: const Text('Add First Product'),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(AppSpacing.pagePadding),
            itemCount: products.length,
            separatorBuilder: (_, __) => const SizedBox(height: 14),
            itemBuilder: (context, i) {
              final product = products[i];
              return _ProductInventoryCard(product: product);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('New Product', style: TextStyle(color: Colors.white)),
        onPressed: () => context.push('/products/add'),
      ),
    );
  }
}

class _ProductInventoryCard extends ConsumerWidget {
  final ProductEntity product;

  const _ProductInventoryCard({required this.product});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final totalStock = product.variants.fold(0, (sum, v) => sum + v.stockCount);
    final inStock = totalStock > 0;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Image
              ClipRRect(
                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                child: Image.network(
                  product.imageUrls.isNotEmpty
                      ? product.imageUrls.first
                      : 'https://images.unsplash.com/photo-1523381210434-271e8be1f52b?w=800&auto=format&fit=crop',
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 80,
                    height: 80,
                    color: AppColors.surfaceVariant,
                    child: const Icon(Icons.image_not_supported_rounded),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              // Product Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '₹${(product.discountedPrice / 100).toStringAsFixed(0)}  •  Base: ₹${(product.basePrice / 100).toStringAsFixed(0)}',
                      style: const TextStyle(color: AppColors.accent, fontWeight: FontWeight.w600),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: inStock ? AppColors.success.withValues(alpha: 0.15) : AppColors.error.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            inStock ? 'In Stock ($totalStock)' : 'OUT OF STOCK',
                            style: TextStyle(
                              color: inStock ? AppColors.success : AppColors.error,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Text('${product.variants.length} variant(s)', style: AppTextStyles.bodySmall),
                      ],
                    ),
                  ],
                ),
              ),
              // Publish Switch
              Switch(
                value: product.isPublished,
                activeColor: AppColors.primary,
                onChanged: (val) {
                  ref.read(vendorProductRepoProvider).togglePublishStatus(product.id, val);
                },
              ),
            ],
          ),
          const Divider(height: 20),
          // Variants List with Stock Counter
          Text('Sizes & Variants:', style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: product.variants.map((variant) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                  border: Border.all(
                    color: variant.stockCount > 0 ? AppColors.divider : AppColors.error.withOpacity(0.5),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('${variant.size} • ${variant.color}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    const SizedBox(width: 8),
                    InkWell(
                      onTap: () {
                        final newStock = variant.stockCount > 0 ? variant.stockCount - 1 : 0;
                        ref.read(vendorProductRepoProvider).updateVariantStock(
                              productId: product.id,
                              variantId: variant.id,
                              newStock: newStock,
                            );
                      },
                      child: const Icon(Icons.remove_circle_outline, size: 16, color: AppColors.textSecondary),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: Text('${variant.stockCount}', style: const TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    InkWell(
                      onTap: () {
                        ref.read(vendorProductRepoProvider).updateVariantStock(
                              productId: product.id,
                              variantId: variant.id,
                              newStock: variant.stockCount + 1,
                            );
                      },
                      child: const Icon(Icons.add_circle_outline, size: 16, color: AppColors.primary),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
