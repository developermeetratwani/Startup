import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ui_kit/ui_kit.dart';
import 'package:domain/domain.dart';
import '../../providers/location_provider.dart';
import '../../providers/store_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/product_provider.dart';
import '../../widgets/live_rider_tracking_sheet.dart';
import '../../widgets/support_chatbot_sheet.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = ref.watch(locationProvider);
    final selectedCategory = ref.watch(selectedCategoryProvider);
    final storesAsync = ref.watch(nearbyStoresProvider);
    final cartSummary = ref.watch(cartSummaryProvider);
    final productsAsync = ref.watch(homeProductsProvider(selectedCategory));

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
          // HelpBot 24/7 AI Pill
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: InkWell(
              onTap: () => SupportChatbotSheet.show(context),
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.6)),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.smart_toy_rounded, size: 15, color: AppColors.primary),
                    SizedBox(width: 4),
                    Text('HelpBot', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary)),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 6),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: InkWell(
              onTap: () => LiveRiderTrackingSheet.show(context),
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.accent.withValues(alpha: 0.6)),
                ),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4),
                  child: Text('Radar', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.accent)),
                ),
              ),
            ),
          ),
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
              // Active Order Live Tracking Quick Banner (Zomato style)
              Padding(
                padding: const EdgeInsets.only(left: AppSpacing.pagePadding, right: AppSpacing.pagePadding, bottom: 12),
                child: InkWell(
                  onTap: () => context.push('/orders/track/ord-kubernagar-8920'),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE23744).withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                      border: Border.all(color: const Color(0xFFE23744).withValues(alpha: 0.5)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: Color(0xFFE23744),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.two_wheeler_rounded, color: Colors.white, size: 20),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text('Active Delivery: En Route 🛵', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFFE23744))),
                                  SizedBox(width: 6),
                                  CircleAvatar(radius: 3, backgroundColor: Colors.green),
                                ],
                              ),
                              SizedBox(height: 2),
                              Text('Suresh Solanki is delivering (~18 Mins) • Tap to view', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE23744),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Text('Track Map 🗺️', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Search Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding),
                child: GestureDetector(
                  onTap: () => context.push('/search'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                      border: Border.all(color: AppColors.cardBorder, width: 1),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x08171717),
                          blurRadius: 10,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.search, color: AppColors.accent, size: 20),
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
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF171717), Color(0xFF262422)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x1F171717),
                        blurRadius: 16,
                        offset: Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [AppColors.accentTomato, AppColors.accent],
                              ),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'LOCAL DISCOVERY',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.6,
                              ),
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.purple.withOpacity(0.18),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: AppColors.purple.withOpacity(0.4),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.flash_on_rounded, color: AppColors.purple, size: 12),
                                const SizedBox(width: 3),
                                Text(
                                  '< 2h delivery',
                                  style: TextStyle(
                                    color: AppColors.purple,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Direct from Gandhinagar &\nKubernagar Stores',
                        style: TextStyle(
                          color: AppColors.linen,
                          fontSize: 19,
                          fontWeight: FontWeight.w700,
                          height: 1.25,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Curated boutique collections delivered straight to your door',
                        style: TextStyle(
                          color: AppColors.linen.withOpacity(0.72),
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 10),
                      InkWell(
                        onTap: () => LiveRiderTrackingSheet.show(context),
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.accent,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 4),
                            child: Text('Track Nearby Riders on Map', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                          ),
                        ),
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
                      label: Text(cat['label'] as String),
                      selected: isSelected,
                      selectedColor: AppColors.primary,
                      backgroundColor: AppColors.surface,
                      side: BorderSide(
                        color: isSelected ? AppColors.primary : AppColors.cardBorder,
                        width: 1,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(22),
                      ),
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : AppColors.textPrimary,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                        fontSize: 13,
                      ),
                      onSelected: (_) {
                        ref.read(selectedCategoryProvider.notifier).state = catId;
                      },
                    );
                  },
                ),
              ),

              const SizedBox(height: AppSpacing.xl),

              // Fresh & Trending Apparel Arrivals (Direct from Local Boutiques)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Fresh Apparel Arrivals', style: AppTextStyles.titleLarge),
                    Text(
                      '48h Size Exchange ⚡',
                      style: AppTextStyles.bodySmall.copyWith(color: AppColors.accent, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              productsAsync.when(
                data: (products) {
                  if (products.isEmpty) return const SizedBox.shrink();
                  return SizedBox(
                    height: 215,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding),
                      itemCount: products.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 12),
                      itemBuilder: (context, index) => _HomeProductCard(product: products[index]),
                    ),
                  );
                },
                loading: () => const SizedBox(
                  height: 200,
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (_, __) => const SizedBox.shrink(),
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
      floatingActionButton: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton.extended(
            heroTag: 'fab_helpbot',
            backgroundColor: AppColors.primary,
            icon: const Icon(Icons.smart_toy_rounded, color: Colors.white, size: 20),
            label: const Text('HelpBot AI', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
            onPressed: () => SupportChatbotSheet.show(context),
          ),
          const SizedBox(width: 10),
          FloatingActionButton.extended(
            heroTag: 'fab_radar',
            backgroundColor: AppColors.accent,
            icon: const Icon(Icons.near_me_rounded, color: Colors.white, size: 20),
            label: const Text('Live Radar', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
            onPressed: () => LiveRiderTrackingSheet.show(context),
          ),
        ],
      ),
    );
  }

  void _showLocationSelector(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppSpacing.radiusLg)),
      ),
      builder: (_) => _LocationSelectorSheet(widgetRef: ref),
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
                borderRadius: const BorderRadius.vertical(top: Radius.circular(AppSpacing.radiusLg)),
              ),
              Positioned(
                top: 10,
                right: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: store.isOpen ? AppColors.success : AppColors.error,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    store.isOpen ? 'OPEN' : 'CLOSED',
                    style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5),
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

  void _promptForHouseDetails(BuildContext context, WidgetRef ref) {
    final loc = ref.read(locationProvider);
    final houseCtrl = TextEditingController();
    final societyCtrl = TextEditingController();
    final landmarkCtrl = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusMd)),
        title: Row(
          children: [
            const Icon(Icons.home_work_rounded, color: AppColors.primary, size: 24),
            const SizedBox(width: 8),
            Text('Complete Delivery Address', style: AppTextStyles.titleMedium),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.gps_fixed_rounded, color: AppColors.success, size: 14),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'GPS Location: ${loc.areaName}, ${loc.cityName}',
                        style: const TextStyle(color: AppColors.success, fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: houseCtrl,
                decoration: const InputDecoration(
                  labelText: 'House / Flat / Block No. *',
                  hintText: 'e.g. Flat 302, Block B',
                  isDense: true,
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: societyCtrl,
                decoration: const InputDecoration(
                  labelText: 'Building / Society / Apartment Name *',
                  hintText: 'e.g. Krishna Park Residency',
                  isDense: true,
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: landmarkCtrl,
                decoration: const InputDecoration(
                  labelText: 'Nearby Landmark (Optional)',
                  hintText: 'e.g. Near Water Tank or Main Road',
                  isDense: true,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Skip for Now'),
          ),
          ElevatedButton(
            onPressed: () {
              final house = houseCtrl.text.trim();
              final society = societyCtrl.text.trim();
              final landmark = landmarkCtrl.text.trim();
              final fullAddress = [
                if (house.isNotEmpty) house,
                if (society.isNotEmpty) society,
                if (landmark.isNotEmpty) 'Near $landmark',
                loc.areaName,
                loc.cityName,
              ].join(', ');

              ref.read(locationProvider.notifier).setPresetLocation(
                area: society.isNotEmpty ? society : loc.areaName,
                city: loc.cityName,
                lat: loc.latitude,
                lng: loc.longitude,
              );

              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Delivery address saved:\n$fullAddress')),
              );
            },
            child: const Text('Save Address'),
          ),
        ],
      ),
    );
  }
class _LocationSelectorSheet extends ConsumerWidget {
  final WidgetRef widgetRef;
  const _LocationSelectorSheet({required this.widgetRef});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locationState = ref.watch(locationProvider);

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppSpacing.radiusLg)),
      ),
      padding: const EdgeInsets.all(AppSpacing.pagePadding),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Select Delivery Market', style: AppTextStyles.titleLarge),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Choose your delivery hub to discover local fashion stores in your vicinity',
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: locationState.isLoading
                  ? null
                  : () async {
                      await ref.read(locationProvider.notifier).detectCurrentLocation();
                      if (context.mounted) {
                        Navigator.pop(context);
                        _promptForHouseDetails(context, ref);
                      }
                    },
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  border: Border.all(color: AppColors.primary.withOpacity(0.25)),
                ),
                child: Row(
                  children: [
                    if (locationState.isLoading)
                      const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                      )
                    else
                      const Icon(Icons.my_location_rounded, color: AppColors.primary, size: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Use Exact Live GPS Location',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.primary),
                          ),
                          Text(
                            locationState.isLoading
                                ? 'Pinpointing your GPS coordinates...'
                                : 'Auto-detects Ghuma, Nikol, Kubernagar, Gandhinagar...',
                            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right_rounded, color: AppColors.primary),
                  ],
                ),
              ),
            ),
            if (locationState.error != null) ...[
              const SizedBox(height: 8),
              Text(
                locationState.error!,
                style: const TextStyle(color: Colors.red, fontSize: 12),
              ),
            ],
            const SizedBox(height: 20),
            const Text(
              'POPULAR LOCAL HUBS',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSecondary, letterSpacing: 0.8),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView(
                shrinkWrap: true,
                children: [
                  _hubTile(
                    context: context,
                    ref: ref,
                    title: 'Gandhinagar',
                    subtitle: 'Capital Hub • Delivery across all Sectors',
                    area: 'Gandhinagar',
                    city: 'Gandhinagar',
                    lat: 23.2156,
                    lng: 72.6369,
                  ),
                  _hubTile(
                    context: context,
                    ref: ref,
                    title: 'Kubernagar, Ahmedabad',
                    subtitle: 'Market Cluster • Ahmedabad East',
                    area: 'Kubernagar',
                    city: 'Ahmedabad',
                    lat: 23.0768,
                    lng: 72.6346,
                  ),
                  _hubTile(
                    context: context,
                    ref: ref,
                    title: 'Nikol, Ahmedabad',
                    subtitle: 'East Ahmedabad Fashion Hub',
                    area: 'Nikol',
                    city: 'Ahmedabad',
                    lat: 23.0485,
                    lng: 72.6738,
                  ),
                  _hubTile(
                    context: context,
                    ref: ref,
                    title: 'Ghuma / Bopal, Ahmedabad',
                    subtitle: 'West Ahmedabad Lifestyle Hub',
                    area: 'Ghuma',
                    city: 'Ahmedabad',
                    lat: 23.0330,
                    lng: 72.4646,
                  ),
                  _hubTile(
                    context: context,
                    ref: ref,
                    title: 'C.G. Road, Ahmedabad',
                    subtitle: 'Central Fashion & Boutique District',
                    area: 'Navrangpura',
                    city: 'Ahmedabad',
                    lat: 23.0373,
                    lng: 72.5562,
                  ),
                  _hubTile(
                    context: context,
                    ref: ref,
                    title: 'Sindhu Bhavan Road (SBR), Ahmedabad',
                    subtitle: 'West Ahmedabad High-Street & Bodakdev Couture',
                    area: 'Sindhu Bhavan Road',
                    city: 'Ahmedabad',
                    lat: 23.0402,
                    lng: 72.5028,
                  ),
                  _hubTile(
                    context: context,
                    ref: ref,
                    title: 'Prahlad Nagar & SG Highway, Ahmedabad',
                    subtitle: 'West Ahmedabad Premium Retail Hub',
                    area: 'Prahlad Nagar',
                    city: 'Ahmedabad',
                    lat: 23.0125,
                    lng: 72.5100,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _hubTile({
    required BuildContext context,
    required WidgetRef ref,
    required String title,
    required String subtitle,
    required String area,
    required String city,
    required double lat,
    required double lng,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(Icons.storefront_rounded, color: AppColors.primary, size: 20),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textHint),
      onTap: () {
        ref.read(locationProvider.notifier).setPresetLocation(
          area: area,
          city: city,
          lat: lat,
          lng: lng,
        );
        Navigator.pop(context);
      },
    );
  }
}


class _HomeProductCard extends StatelessWidget {
  final ProductEntity product;

  const _HomeProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    final image = product.imageUrls.isNotEmpty ? product.imageUrls.first : null;
    final hasDiscount = product.discountedPrice > 0 && product.discountedPrice < product.basePrice;

    return InkWell(
      onTap: () => context.push('/product/${product.id}'),
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      child: Container(
        width: 150,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ProductImage(
                    imageUrl: image,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(AppSpacing.radiusMd)),
                  ),
                  if (hasDiscount)
                    Positioned(
                      top: 6,
                      left: 6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.accent,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text('OFFER', style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  Positioned(
                    bottom: 4,
                    right: 4,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.65),
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: const Text('48h Exch', style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.w600)),
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
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Text(
                        '₹${((product.discountedPrice > 0 ? product.discountedPrice : product.basePrice) / 100).toStringAsFixed(0)}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.primary),
                      ),
                      if (hasDiscount) ...[
                        const SizedBox(width: 4),
                        Text(
                          '₹${(product.basePrice / 100).toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontSize: 10,
                            color: AppColors.textHint,
                            decoration: TextDecoration.lineThrough,
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
      ),
    );
  }
}
