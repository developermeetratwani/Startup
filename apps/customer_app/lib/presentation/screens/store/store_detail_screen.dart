import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ui_kit/ui_kit.dart';
import 'package:domain/domain.dart';
import '../../providers/store_provider.dart';
import '../../providers/product_provider.dart';
import '../../providers/cart_provider.dart';

class StoreDetailScreen extends ConsumerStatefulWidget {
  final String storeId;

  const StoreDetailScreen({super.key, required this.storeId});

  @override
  ConsumerState<StoreDetailScreen> createState() => _StoreDetailScreenState();
}

class _StoreDetailScreenState extends ConsumerState<StoreDetailScreen> {
  String? _selectedCategory;

  @override
  Widget build(BuildContext context) {
    final storeAsync = ref.watch(singleStoreProvider(widget.storeId));
    final productsAsync = ref.watch(storeProductsProvider((
      storeId: widget.storeId,
      categoryId: _selectedCategory,
    )));
    final cartSummary = ref.watch(cartSummaryProvider);

    return Scaffold(
      body: storeAsync.when(
        data: (store) {
          if (store == null) {
            return const Scaffold(
              body: Center(child: Text('Store not found')),
            );
          }

          return CustomScrollView(
            slivers: [
              // Store Header App Bar
              SliverAppBar(
                expandedHeight: 220,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    store.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      shadows: [Shadow(color: Colors.black54, blurRadius: 4)],
                    ),
                  ),
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      ProductImage(imageUrl: store.bannerImageUrl, height: 220),
                      Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.transparent, Colors.black87],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                actions: [
                  IconButton(
                    icon: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        const Icon(Icons.shopping_bag_outlined),
                        if (cartSummary.itemCount > 0)
                          Positioned(
                            right: -4,
                            top: -4,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: AppColors.accent,
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                '${cartSummary.itemCount}',
                                style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                      ],
                    ),
                    onPressed: () => context.push('/cart'),
                  ),
                ],
              ),

              // Store Information Meta
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.pagePadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: store.isOpen ? AppColors.success.withOpacity(0.15) : AppColors.error.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              store.isOpen ? 'OPEN NOW' : 'CLOSED',
                              style: TextStyle(
                                color: store.isOpen ? AppColors.success : AppColors.error,
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.star_rounded, color: AppColors.warning, size: 18),
                          Text(' ${store.rating.toStringAsFixed(1)}', style: AppTextStyles.labelLarge),
                          Text(' (${store.totalRatings} reviews)', style: AppTextStyles.bodySmall),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(store.description.isNotEmpty ? store.description : 'Authentic fashion store with fast local delivery.'),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.location_on_outlined, size: 16, color: AppColors.textSecondary),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              store.location.fullAddress.isNotEmpty ? store.location.fullAddress : '${store.location.city}, Gujarat',
                              style: AppTextStyles.bodySmall,
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 24),

                      // Category selection
                      if (store.categoryIds.isNotEmpty) ...[
                        Text('Categories', style: AppTextStyles.titleMedium),
                        const SizedBox(height: 8),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              ChoiceChip(
                                label: const Text('All Items'),
                                selected: _selectedCategory == null,
                                onSelected: (_) => setState(() => _selectedCategory = null),
                              ),
                              const SizedBox(width: 8),
                              ...store.categoryIds.map((cat) => Padding(
                                    padding: const EdgeInsets.only(right: 8),
                                    child: ChoiceChip(
                                      label: Text(cat.toUpperCase()),
                                      selected: _selectedCategory == cat,
                                      onSelected: (_) => setState(() => _selectedCategory = cat),
                                    ),
                                  )),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],

                      Text('Products Collection', style: AppTextStyles.titleLarge),
                    ],
                  ),
                ),
              ),

              // Product Grid
              productsAsync.when(
                data: (products) {
                  if (products.isEmpty) {
                    return const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.all(32),
                        child: Center(
                          child: Text('No products listed in this store yet.'),
                        ),
                      ),
                    );
                  }

                  return SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding),
                    sliver: SliverGrid(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.65,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final product = products[index];
                          return _ProductCard(product: product);
                        },
                        childCount: products.length,
                      ),
                    ),
                  );
                },
                loading: () => const SliverToBoxAdapter(
                  child: Center(child: Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator())),
                ),
                error: (err, _) => SliverToBoxAdapter(
                  child: Center(child: Text('Failed to load products: $err')),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 40)),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final ProductEntity product;

  const _ProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    final image = product.imageUrls.isNotEmpty ? product.imageUrls.first : null;
    final hasDiscount = product.discountedPrice > 0 && product.discountedPrice < product.basePrice;

    return AppCard(
      onTap: () => context.push('/product/${product.id}'),
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              children: [
                ProductImage(
                  imageUrl: image,
                  width: double.infinity,
                  height: double.infinity,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(AppSpacing.radiusMd)),
                ),
                if (hasDiscount)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.accent,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'OFFER',
                        style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: AppTextStyles.labelLarge,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(product.priceDisplay, style: AppTextStyles.priceSmall),
                    if (hasDiscount) ...[
                      const SizedBox(width: 4),
                      Text(
                        '₹${(product.basePrice / 100).toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 11,
                          decoration: TextDecoration.lineThrough,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
