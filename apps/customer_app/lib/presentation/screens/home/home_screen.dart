import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ui_kit/ui_kit.dart';
import 'package:domain/domain.dart';
import '../../providers/location_provider.dart';
import '../../providers/store_provider.dart';
import '../../providers/cart_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = ref.watch(locationProvider);
    final selectedCategory = ref.watch(selectedCategoryProvider);
    final storesAsync = ref.watch(nearbyStoresProvider);
    final cartSummary = ref.watch(cartSummaryProvider);

    final categories = [
      {'id': 'all', 'label': 'All Fashion', 'icon': Icons.grid_view_rounded},
      {'id': 'women', 'label': 'Women', 'icon': Icons.woman_rounded},
      {'id': 'men', 'label': 'Men', 'icon': Icons.man_rounded},
      {'id': 'ethnic', 'label': 'Ethnic Wear', 'icon': Icons.dry_cleaning_rounded},
      {'id': 'western', 'label': 'Western', 'icon': Icons.checkroom_rounded},
      {'id': 'kids', 'label': 'Kids', 'icon': Icons.child_care_rounded},
    ];

    return Scaffold(
      appBar: AppBar(
        titleSpacing: AppSpacing.pagePadding,
        title: GestureDetector(
          onTap: () => _showLocationSelector(context, ref),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.location_on, color: AppColors.accent, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    location.areaName,
                    style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const Icon(Icons.keyboard_arrow_down, size: 18),
                ],
              ),
              Text(
                '${location.cityName} • Hyperlocal Delivery',
                style: AppTextStyles.bodySmall,
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
          IconButton(
            icon: const Icon(Icons.receipt_long_outlined),
            onPressed: () => context.push('/orders'),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => ref.refresh(nearbyStoresProvider),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding),
                child: GestureDetector(
                  onTap: () => context.push('/search'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.search, color: AppColors.textSecondary),
                        const SizedBox(width: 10),
                        Text(
                          'Search kurta, sarees, jeans, shirts...',
                          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textHint),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.lg),

              // Promotional Banner
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.accent,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'LOCAL DISCOVERY',
                          style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Direct from Gandhinagar &\nKubernagar Stores',
                        style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Get local delivery in under 2 hours',
                        style: TextStyle(color: Color(0xFFADB5BD), fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.lg),

              // Categories
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding),
                child: Text('Explore Categories', style: AppTextStyles.titleLarge),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 44,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding),
                  itemCount: categories.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final cat = categories[index];
                    final catId = cat['id'] == 'all' ? null : cat['id'] as String;
                    final isSelected = selectedCategory == catId;

                    return ChoiceChip(
                      avatar: Icon(
                        cat['icon'] as IconData,
                        size: 16,
                        color: isSelected ? Colors.white : AppColors.textPrimary,
                      ),
                      label: Text(cat['label'] as String),
                      selected: isSelected,
                      selectedColor: AppColors.primary,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : AppColors.textPrimary,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                      onSelected: (_) {
                        ref.read(selectedCategoryProvider.notifier).state = catId;
                      },
                    );
                  },
                ),
              ),

              const SizedBox(height: AppSpacing.xl),

              // Nearby Stores Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Nearby Stores', style: AppTextStyles.titleLarge),
                    Text(
                      'Within 15 km',
                      style: AppTextStyles.bodySmall.copyWith(color: AppColors.accent),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Store List
              storesAsync.when(
                data: (stores) {
                  if (stores.isEmpty) {
                    return _buildEmptyStoresState(context, ref);
                  }
                  return ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding),
                    itemCount: stores.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final store = stores[index];
                      return _StoreCard(store: store);
                    },
                  );
                },
                loading: () => Column(
                  children: List.generate(
                    3,
                    (i) => const Padding(
                      padding: EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding, vertical: 8),
                      child: ShimmerProductCard(),
                    ),
                  ),
                ),
                error: (err, _) => Padding(
                  padding: const EdgeInsets.all(AppSpacing.pagePadding),
                  child: Center(
                    child: Column(
                      children: [
                        const Icon(Icons.error_outline, size: 48, color: AppColors.error),
                        const SizedBox(height: 8),
                        Text('Could not load stores: $err'),
                        TextButton(
                          onPressed: () => ref.refresh(nearbyStoresProvider),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        onTap: (index) {
          if (index == 1) context.push('/search');
          if (index == 2) context.push('/cart');
          if (index == 3) context.push('/profile');
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_bag_outlined), label: 'Cart'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
        ],
      ),
    );
  }

  void _showLocationSelector(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppSpacing.radiusLg)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.pagePadding),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Select Delivery Market', style: AppTextStyles.titleLarge),
                const SizedBox(height: 8),
                Text(
                  'Choose your target location to see stores in your vicinity',
                  style: AppTextStyles.bodySmall,
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: const Icon(Icons.my_location, color: AppColors.accent),
                  title: const Text('Use Current GPS Location'),
                  onTap: () {
                    ref.read(locationProvider.notifier).detectCurrentLocation();
                    Navigator.pop(context);
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.storefront, color: AppColors.primary),
                  title: const Text('Kubernagar, Ahmedabad'),
                  subtitle: const Text('Market cluster • Ahmedabad East'),
                  onTap: () {
                    ref.read(locationProvider.notifier).setPresetLocation(
                          area: 'Kubernagar',
                          city: 'Ahmedabad',
                          lat: 23.0768,
                          lng: 72.6346,
                        );
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.storefront, color: AppColors.primary),
                  title: const Text('Gandhinagar, Gujarat'),
                  subtitle: const Text('Sector 1-30 & Infocity cluster'),
                  onTap: () {
                    ref.read(locationProvider.notifier).setPresetLocation(
                          area: 'Sector 21',
                          city: 'Gandhinagar',
                          lat: 23.2156,
                          lng: 72.6369,
                        );
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.storefront, color: AppColors.primary),
                  title: const Text('Vapi, Gujarat'),
                  subtitle: const Text('Gunjan Market, Koparli Rd & GIDC cluster'),
                  onTap: () {
                    ref.read(locationProvider.notifier).setPresetLocation(
                          area: 'Gunjan Market',
                          city: 'Vapi',
                          lat: 20.3712,
                          lng: 72.9044,
                        );
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyStoresState(BuildContext context, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding, vertical: 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: Center(
        child: Column(
          children: [
            const Icon(Icons.store_mall_directory_outlined, size: 56, color: AppColors.textSecondary),
            const SizedBox(height: 12),
            Text('No stores found in this area', style: AppTextStyles.titleMedium),
            const SizedBox(height: 6),
            const Text(
              'Try switching your market location between Kubernagar or Gandhinagar',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _showLocationSelector(context, ref),
              child: const Text('Change Location'),
            ),
          ],
        ),
      ),
    );
  }
}

class _StoreCard extends StatelessWidget {
  final StoreEntity store;

  const _StoreCard({required this.store});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: () => context.push('/store/${store.id}'),
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner / Image
          Stack(
            children: [
              ProductImage(
                imageUrl: store.bannerImageUrl,
                height: 140,
                width: double.infinity,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(AppSpacing.radiusMd)),
              ),
              Positioned(
                top: 10,
                right: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: store.isOpen ? AppColors.success : AppColors.error,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    store.isOpen ? 'OPEN' : 'CLOSED',
                    style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),

          Padding(
            padding: const EdgeInsets.all(AppSpacing.cardPadding),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(store.name, style: AppTextStyles.titleMedium),
                      const SizedBox(height: 4),
                      Text(
                        store.location.address.isNotEmpty
                            ? store.location.address
                            : '${store.location.city} • Fast Local Pickup',
                        style: AppTextStyles.bodySmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.star_rounded, color: AppColors.warning, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            store.rating.toStringAsFixed(1),
                            style: AppTextStyles.labelSmall.copyWith(color: AppColors.textPrimary),
                          ),
                          const SizedBox(width: 8),
                          Text('•  ${store.totalRatings} ratings', style: AppTextStyles.bodySmall),
                        ],
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: AppColors.textHint),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
