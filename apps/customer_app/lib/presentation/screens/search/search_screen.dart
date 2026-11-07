import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ui_kit/ui_kit.dart';
import '../../providers/product_provider.dart';
import '../../widgets/floating_cart_bar.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final searchResultsAsync = ref.watch(searchResultsProvider);

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Padding(
          padding: const EdgeInsets.only(right: 16),
          child: TextField(
            controller: _controller,
            autofocus: true,
            decoration: InputDecoration(
              hintText: 'Search clothes, stores, brands...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _controller.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _controller.clear();
                        ref.read(productSearchQueryProvider.notifier).state = '';
                        setState(() {});
                      },
                    )
                  : null,
            ),
            onChanged: (val) {
              ref.read(productSearchQueryProvider.notifier).state = val;
              setState(() {});
            },
          ),
        ),
      ),
      body: _controller.text.trim().isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.search, size: 64, color: AppColors.textHint),
                  const SizedBox(height: 12),
                  Text('Search across local stores', style: AppTextStyles.titleMedium),
                  const SizedBox(height: 6),
                  Text('Find shirts, kurta, dresses, denim and more', style: AppTextStyles.bodySmall),
                ],
              ),
            )
          : searchResultsAsync.when(
              data: (products) {
                if (products.isEmpty) {
                  return const Center(child: Text('No matching products found'));
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(AppSpacing.pagePadding),
                  itemCount: products.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final product = products[index];
                    return AppCard(
                      onTap: () => context.push('/product/${product.id}'),
                      child: Row(
                        children: [
                          ProductImage(
                            imageUrl: product.imageUrls.isNotEmpty ? product.imageUrls.first : null,
                            width: 60,
                            height: 60,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(product.name, style: AppTextStyles.labelLarge),
                                const SizedBox(height: 2),
                                Text(product.priceDisplay, style: AppTextStyles.priceSmall),
                              ],
                            ),
                          ),
                          const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textHint),
                        ],
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text('Error: $err')),
            ),
      bottomNavigationBar: const FloatingCartBar(),
    );
  }
}
