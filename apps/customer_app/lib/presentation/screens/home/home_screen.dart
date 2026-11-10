import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ui_kit/ui_kit.dart';
import 'package:domain/domain.dart';
import 'package:core/core.dart';
import '../../providers/location_provider.dart';
import '../../providers/store_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/product_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/support_chatbot_sheet.dart';
import '../../widgets/floating_cart_bar.dart';
import '../../widgets/luxury_bottom_nav_bar.dart';
import '../../widgets/luxury_stories_bar.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  bool _isNavBarVisible = true;
  String _activeQuickFilter = 'all';
  int _activeDealPage = 0;

  @override
  Widget build(BuildContext context) {
    final location = ref.watch(locationProvider);
    final selectedCategory = ref.watch(selectedCategoryProvider);

    final homeEta = DeliveryEtaService.getRouteEtaInfo(
      originArea: 'Kubernagar',
      destinationArea: location.areaName,
      storeLat: 23.0768,
      storeLng: 72.6346,
      customerLat: location.latitude,
      customerLng: location.longitude,
    );
    final etaBadgeText = homeEta.isHistoricalAverage
        ? '~${homeEta.minutes} MINS AVG'
        : '${(homeEta.minutes - 4).clamp(10, 90)}-${homeEta.minutes} MINS';
    final storesAsync = ref.watch(nearbyStoresProvider);
    final cartSummary = ref.watch(cartSummaryProvider);
    final productsAsync = ref.watch(homeProductsProvider(selectedCategory));

    final categoriesList = [
      {'id': 'all', 'label': 'All Fashion', 'sub': 'Explore all', 'icon': Icons.local_fire_department_rounded, 'color': const Color(0xFFF04438), 'bg': const Color(0xFFFFF0F3)},
      {'id': 'ethnic', 'label': 'Ethnic Wear', 'sub': 'Kurtis & Sarees', 'icon': Icons.dry_cleaning_rounded, 'color': const Color(0xFFD93670), 'bg': const Color(0xFFFDF2F7)},
      {'id': 'women', 'label': 'Women', 'sub': 'Dresses & Tops', 'icon': Icons.woman_rounded, 'color': const Color(0xFFA78BFA), 'bg': const Color(0xFFF5F0FF)},
      {'id': 'men', 'label': 'Men', 'sub': 'Tees & Shirts', 'icon': Icons.man_rounded, 'color': const Color(0xFF2563EB), 'bg': const Color(0xFFEFF6FF)},
      {'id': 'western', 'label': 'Western', 'sub': 'Denim & Cargo', 'icon': Icons.checkroom_rounded, 'color': const Color(0xFF0D9488), 'bg': const Color(0xFFF0FDFA)},
      {'id': 'kids', 'label': 'Kids & Teens', 'sub': 'Trendy wear', 'icon': Icons.child_care_rounded, 'color': const Color(0xFF16A34A), 'bg': const Color(0xFFF0FDF4)},
    ];

    final quickFilters = [
      {'id': 'all', 'label': 'All Stores'},
      {'id': 'fast', 'label': '⚡ Under 20m'},
      {'id': 'rating', 'label': '★ 4.0+ Top Rated'},
      {'id': 'offers', 'label': '🏷️ Great Offers'},
      {'id': 'exchange', 'label': '🔄 48h Exchange'},
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        titleSpacing: AppSpacing.pagePadding,
        title: GestureDetector(
          onTap: () => _showLocationSelector(context, ref),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.accent, AppColors.accentTomato],
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.location_on_rounded, color: Colors.white, size: 14),
                  ),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      location.areaName.isNotEmpty ? location.areaName : 'Ahmedabad',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.titleMedium.copyWith(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ),
                  const Icon(Icons.keyboard_arrow_down_rounded, size: 20, color: AppColors.textPrimary),
                ],
              ),
              const SizedBox(height: 2),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5E9),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.bolt_rounded, size: 11, color: Color(0xFF267E3E)),
                        const SizedBox(width: 2),
                        Text(
                          etaBadgeText,
                          style: const TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF267E3E),
                            letterSpacing: 0.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      '${location.cityName} • Hyperlocal',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          // VIP MARS Gold Crown Pill
          GestureDetector(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Row(
                    children: [
                      Icon(Icons.workspace_premium_rounded, color: Color(0xFFFFD700), size: 18),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'MARS Gold VIP: Free Delivery waived & 15-Min priority dispatch active!',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                  backgroundColor: const Color(0xFF0F1016),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  duration: const Duration(seconds: 3),
                ),
              );
            },
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(color: Color(0x33F59E0B), blurRadius: 6, offset: Offset(0, 2)),
                ],
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.workspace_premium_rounded, color: Colors.white, size: 13),
                  SizedBox(width: 3),
                  Text(
                    'GOLD',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Order Receipt shortcut
          IconButton(
            icon: const Icon(Icons.receipt_long_rounded, color: AppColors.primary, size: 22),
            tooltip: 'My Orders',
            onPressed: () => context.push('/orders'),
          ),
          // Cart Bag with vibrant badge
          IconButton(
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(Icons.shopping_bag_outlined, color: AppColors.primary, size: 24),
                if (cartSummary.itemCount > 0)
                  Positioned(
                    right: -5,
                    top: -5,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [AppColors.accent, AppColors.accentTomato]),
                        shape: BoxShape.circle,
                        boxShadow: const [BoxShadow(color: Color(0x33D93670), blurRadius: 4)],
                      ),
                      child: Text(
                        '${cartSummary.itemCount}',
                        style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w900),
                      ),
                    ),
                  ),
              ],
            ),
            onPressed: () => context.push('/cart'),
          ),
          // User Avatar
          GestureDetector(
            onTap: () => context.push('/profile'),
            child: Container(
              margin: const EdgeInsets.only(right: 14, left: 2),
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.cardBorder, width: 1.5),
              ),
              child: const CircleAvatar(
                radius: 14,
                backgroundColor: AppColors.primary,
                child: Icon(Icons.person_rounded, size: 16, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
      body: NotificationListener<UserScrollNotification>(
        onNotification: (notification) {
          if (notification.metrics.pixels <= 10) {
            if (!_isNavBarVisible) setState(() => _isNavBarVisible = true);
          } else if (notification.direction == ScrollDirection.reverse) {
            if (_isNavBarVisible) setState(() => _isNavBarVisible = false);
          } else if (notification.direction == ScrollDirection.forward) {
            if (!_isNavBarVisible) setState(() => _isNavBarVisible = true);
          }
          return true;
        },
        child: RefreshIndicator(
          color: AppColors.accent,
          onRefresh: () async => ref.refresh(nearbyStoresProvider),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Active Order Live Tracking Banner (Zomato style)
                Padding(
                  padding: const EdgeInsets.fromLTRB(AppSpacing.pagePadding, 12, AppSpacing.pagePadding, 8),
                  child: InkWell(
                    onTap: () => context.push('/orders/track/ord-kubernagar-8920'),
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF171717), Color(0xFF282828)],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: const [
                          BoxShadow(color: Color(0x1F000000), blurRadius: 10, offset: Offset(0, 3)),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                              color: AppColors.accent,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.delivery_dining_rounded, color: Colors.white, size: 18),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text('Active Order • En Route', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: Colors.white)),
                                    SizedBox(width: 6),
                                    CircleAvatar(radius: 3.5, backgroundColor: Color(0xFF22C55E)),
                                  ],
                                ),
                                SizedBox(height: 2),
                                Text('Rider Suresh (~14 Mins) • Tap to view GPS map', style: TextStyle(fontSize: 11, color: Colors.white70)),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.accent,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text('TRACK', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w800)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Floating Search Bar (Zomato / Swiggy Pill)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding, vertical: 8),
                  child: GestureDetector(
                    onTap: () => context.push('/search'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: AppColors.cardBorder, width: 1.2),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x08000000),
                            blurRadius: 16,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.search_rounded, color: AppColors.accent, size: 22),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Search "Sabyasachi", "Oversized Tees", "Sneakers"...',
                              style: TextStyle(
                                color: AppColors.textHint,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Container(
                            height: 20,
                            width: 1,
                            color: AppColors.divider,
                            margin: const EdgeInsets.symmetric(horizontal: 8),
                          ),
                          const Icon(Icons.mic_none_rounded, color: AppColors.accent, size: 20),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                // High-Fashion Live Drops Stories Bar (Nike / Luxe style)
                LuxuryStoriesBar(
                  onStorySelected: (tag) {
                    setState(() => _activeQuickFilter = tag);
                  },
                ),

                const SizedBox(height: 10),

                // Dynamic Promotional Banner Carousel (Admin sync)
                StreamBuilder<List<DealBanner>>(
                  stream: DealsService.dealsStream,
                  builder: (context, snapshot) {
                    final deals = snapshot.data ?? DealsService.allDeals.where((d) => d.isActive).toList();
                    if (deals.isEmpty) return const SizedBox.shrink();

                    return Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding),
                          child: SizedBox(
                            height: 195,
                            child: PageView.builder(
                              itemCount: deals.length,
                              onPageChanged: (idx) => setState(() => _activeDealPage = idx),
                              itemBuilder: (context, index) {
                                final deal = deals[index];
                                final startColor = Color(int.tryParse(deal.gradientStart) ?? 0xFF171717);
                                final endColor = Color(int.tryParse(deal.gradientEnd) ?? 0xFFD93670);

                                return Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 3),
                                  padding: const EdgeInsets.all(18),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [startColor, endColor],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(20),
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
                                              color: Colors.white.withValues(alpha: 0.22),
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                            child: Text(
                                              deal.badgeText,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 10,
                                                fontWeight: FontWeight.w800,
                                                letterSpacing: 0.6,
                                              ),
                                            ),
                                          ),
                                          const Spacer(),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: Colors.black.withValues(alpha: 0.3),
                                              borderRadius: BorderRadius.circular(20),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                const Icon(Icons.local_offer_rounded, color: Color(0xFFFFD700), size: 13),
                                                const SizedBox(width: 4),
                                                Text(
                                                  '${deal.discountPercent}% OFF',
                                                  style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w900),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        deal.title,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 19,
                                          fontWeight: FontWeight.w900,
                                          letterSpacing: -0.3,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Expanded(
                                        child: Text(
                                          deal.subtitle,
                                          style: TextStyle(
                                            color: Colors.white.withValues(alpha: 0.88),
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          InkWell(
                                            onTap: () {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(
                                                  content: Text('🎉 Promo Code "${deal.promoCode}" copied! Enjoy ${deal.discountPercent}% OFF.'),
                                                  backgroundColor: AppColors.primary,
                                                  behavior: SnackBarBehavior.floating,
                                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                                ),
                                              );
                                            },
                                            borderRadius: BorderRadius.circular(20),
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius: BorderRadius.circular(20),
                                                boxShadow: const [BoxShadow(color: Color(0x24000000), blurRadius: 6)],
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  const Icon(Icons.copy_rounded, color: AppColors.primary, size: 13),
                                                  const SizedBox(width: 6),
                                                  Text(
                                                    'USE: ${deal.promoCode}',
                                                    style: const TextStyle(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.w900),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          const Spacer(),
                                          const Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text('Swipe for deals', style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w600)),
                                              SizedBox(width: 4),
                                              Icon(Icons.arrow_forward_rounded, color: Colors.white70, size: 14),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Page Dots Indicator
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            deals.length,
                            (i) => AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              margin: const EdgeInsets.symmetric(horizontal: 3),
                              height: 5,
                              width: _activeDealPage == i ? 18 : 6,
                              decoration: BoxDecoration(
                                color: _activeDealPage == i ? AppColors.accent : AppColors.cardBorder,
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),

                const SizedBox(height: 18),

                // Category Explorer ("WHAT'S ON YOUR MIND?")
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "WHAT'S ON YOUR MIND?",
                            style: AppTextStyles.labelSmall.copyWith(
                              letterSpacing: 1.2,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            "Explore Hyperlocal Fashion",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: AppColors.textPrimary,
                              letterSpacing: -0.4,
                            ),
                          ),
                        ],
                      ),
                      TextButton(
                        onPressed: () {
                          ref.read(selectedCategoryProvider.notifier).state = null;
                        },
                        child: const Text('View All', style: TextStyle(color: AppColors.accent, fontWeight: FontWeight.w700, fontSize: 13)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 104,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding),
                    itemCount: categoriesList.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 14),
                    itemBuilder: (context, index) {
                      final item = categoriesList[index];
                      final catId = item['id'] == 'all' ? null : item['id'] as String;
                      final isSelected = selectedCategory == catId;

                      return GestureDetector(
                        onTap: () {
                          ref.read(selectedCategoryProvider.notifier).state = catId;
                        },
                        child: Column(
                          children: [
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: 66,
                              height: 66,
                              decoration: BoxDecoration(
                                color: item['bg'] as Color,
                                borderRadius: BorderRadius.circular(22),
                                border: Border.all(
                                  color: isSelected ? AppColors.primary : Colors.transparent,
                                  width: isSelected ? 2.5 : 0,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: (item['color'] as Color).withValues(alpha: isSelected ? 0.25 : 0.08),
                                    blurRadius: isSelected ? 12 : 6,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Icon(
                                  item['icon'] as IconData,
                                  color: item['color'] as Color,
                                  size: 32,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              item['label'] as String,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                                color: isSelected ? AppColors.primary : AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 12),

                // Interactive Quick Filters Bar (Swiggy / Zomato style)
                SizedBox(
                  height: 38,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding),
                    itemCount: quickFilters.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final qf = quickFilters[index];
                      final isSelected = _activeQuickFilter == qf['id'];

                      return InkWell(
                        onTap: () => setState(() => _activeQuickFilter = qf['id'] as String),
                        borderRadius: BorderRadius.circular(20),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.primary : Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected ? AppColors.primary : AppColors.cardBorder,
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0x08000000),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Text(
                            qf['label'] as String,
                            style: TextStyle(
                              color: isSelected ? Colors.white : AppColors.textPrimary,
                              fontSize: 12,
                              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 22),

                // Fresh Apparel Arrivals (Instant Add)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Flexible(
                        child: Text(
                          'Trending Boutique Drops',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.4,
                            color: AppColors.textPrimary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.raspberryLight,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          '48h Doorstep Exchange ⚡',
                          style: TextStyle(fontSize: 10, color: AppColors.accent, fontWeight: FontWeight.w800),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                productsAsync.when(
                  data: (products) {
                    if (products.isEmpty) return const SizedBox.shrink();
                    return SizedBox(
                      height: 252,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding),
                        itemCount: products.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 14),
                        itemBuilder: (context, index) => _HomeProductCard(product: products[index]),
                      ),
                    );
                  },
                  loading: () => const SizedBox(
                    height: 230,
                    child: Center(child: CircularProgressIndicator(color: AppColors.accent)),
                  ),
                  error: (_, __) => const SizedBox.shrink(),
                ),

                const SizedBox(height: 26),

                // Nearby Stores Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Flexible(
                        child: Text(
                          'Featured Boutiques & Stores',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.4,
                            color: AppColors.textPrimary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        'Within 15 km',
                        style: TextStyle(fontSize: 12, color: AppColors.accent, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Store List with Active Filters applied
                storesAsync.when(
                  data: (stores) {
                    if (stores.isEmpty) {
                      return _buildEmptyStoresState(context, ref);
                    }

                    // Apply filter
                    var filteredStores = List<StoreEntity>.from(stores);
                    if (_activeQuickFilter == 'rating') {
                      filteredStores = filteredStores.where((s) => s.rating >= 4.0).toList();
                    }

                    return ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding),
                      itemCount: filteredStores.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        return _StoreCard(store: filteredStores[index]);
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
      ),
      bottomNavigationBar: AnimatedSlide(
        offset: _isNavBarVisible ? Offset.zero : const Offset(0, 1.5),
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeInOutCubic,
        child: AnimatedOpacity(
          opacity: _isNavBarVisible ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 200),
          child: IgnorePointer(
            ignoring: !_isNavBarVisible,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: const [
                FloatingCartBar(),
                LuxuryBottomNavBar(currentIndex: 0),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: AnimatedSlide(
        offset: _isNavBarVisible ? Offset.zero : const Offset(0, 2.5),
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeInOutCubic,
        child: AnimatedOpacity(
          opacity: _isNavBarVisible ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 200),
          child: IgnorePointer(
            ignoring: !_isNavBarVisible,
            child: FloatingActionButton.extended(
              heroTag: 'fab_helpbot',
              backgroundColor: AppColors.primary,
              icon: const Icon(Icons.smart_toy_rounded, color: Colors.white, size: 20),
              label: const Text('HelpBot AI', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
              onPressed: () => SupportChatbotSheet.show(context),
            ),
          ),
        ),
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Center(
        child: Column(
          children: [
            const Icon(Icons.store_mall_directory_outlined, size: 56, color: AppColors.textSecondary),
            const SizedBox(height: 12),
            Text('No stores found in this area', style: AppTextStyles.titleMedium),
            const SizedBox(height: 6),
            const Text(
              'Try switching your market location between Kubernagar, Bodakdev, or Gandhinagar',
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

// ── Ultra-Premium Store Card (Zomato / Swiggy Restaurant Tier) ─────────────────
class _StoreCard extends StatelessWidget {
  final StoreEntity store;

  const _StoreCard({required this.store});

  Widget _buildMiniPill(String name, String price) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            name,
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFF1F2937)),
          ),
          const SizedBox(width: 4),
          Text(
            price,
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.accent),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.cardBorder, width: 1),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0C000000),
            blurRadius: 18,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => context.push('/store/${store.id}'),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hero Store Image with Scrim
              Stack(
                children: [
                  ProductImage(
                    imageUrl: store.bannerImageUrl,
                    height: 165,
                    width: double.infinity,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  // Dark Scrim Gradient
                  Positioned.fill(
                    child: Container(
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.transparent,
                            Color(0xCC000000),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Top Status Chip
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: store.isOpen ? const Color(0xFF16A34A) : Colors.black87,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: const [
                          BoxShadow(color: Color(0x33000000), blurRadius: 6),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircleAvatar(
                            radius: 3,
                            backgroundColor: store.isOpen ? Colors.white : Colors.redAccent,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            store.isOpen ? 'OPEN NOW' : 'CLOSED',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Top Right Favorite Button
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.9),
                        shape: BoxShape.circle,
                        boxShadow: const [
                          BoxShadow(color: Color(0x1F000000), blurRadius: 6),
                        ],
                      ),
                      child: const Icon(Icons.favorite_border_rounded, size: 18, color: AppColors.primary),
                    ),
                  ),
                  // Bottom Left Scrim Offer
                  const Positioned(
                    bottom: 10,
                    left: 12,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.local_offer_rounded, color: Color(0xFFFFD700), size: 14),
                        SizedBox(width: 5),
                        Text(
                          'FLAT ₹150 OFF ABOVE ₹599',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 12,
                            letterSpacing: 0.3,
                            shadows: [Shadow(color: Colors.black, blurRadius: 4)],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Bottom Right Scrim ETA
                  Positioned(
                    bottom: 8,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.65),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.bolt_rounded, color: Color(0xFFFF9800), size: 13),
                          SizedBox(width: 2),
                          Text(
                            '15-20 MINS',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              // Store Info Body
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title and Rating Row
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Flexible(
                                child: Text(
                                  store.name,
                                  style: AppTextStyles.titleMedium.copyWith(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: -0.2,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 6),
                              const Icon(Icons.verified_rounded, color: Color(0xFF2563EB), size: 16),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Emerald Green Rating Badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.ratingGreen,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                store.rating > 0 ? store.rating.toStringAsFixed(1) : '4.5',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(width: 2),
                              const Icon(Icons.star_rounded, color: Colors.white, size: 13),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    // Categories / Subtitle
                    Text(
                      store.location.address.isNotEmpty
                          ? store.location.address
                          : 'Kurtas • Western Wear • Streetwear • Local Boutique',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 10),
                    // Boutique Trending Showcase
                    Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF9FAFB),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFF3F4F6)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.auto_awesome, size: 12, color: Color(0xFFD4AF37)),
                          const SizedBox(width: 5),
                          const Text(
                            'POPULAR',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF6B7280),
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              physics: const BouncingScrollPhysics(),
                              child: Row(
                                children: [
                                  _buildMiniPill('Oversized Tee', '₹599'),
                                  const SizedBox(width: 5),
                                  _buildMiniPill('Slim Cargo', '₹999'),
                                  const SizedBox(width: 5),
                                  _buildMiniPill('Linen Shirt', '₹1,249'),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Zomato/Swiggy style footer strip
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceVariant,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.delivery_dining_rounded, size: 15, color: AppColors.accent),
                          const SizedBox(width: 6),
                          const Expanded(
                            child: Text(
                              'Free delivery above ₹299',
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.accent.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              '48h Exchange',
                              style: TextStyle(fontSize: 9, color: AppColors.accent, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Home Product Card with Instant One-Tap ADD+ (Swiggy / Blinkit style) ──────
class _HomeProductCard extends ConsumerWidget {
  final ProductEntity product;

  const _HomeProductCard({required this.product});

  Future<void> _quickAddToCart(BuildContext context, WidgetRef ref) async {
    final user = ref.read(currentUserProvider);
    final customerId = user?.uid ?? isolatedGuestSessionId;
    final cartRepo = ref.read(cartRepositoryProvider);

    final variant = product.variants.isNotEmpty ? product.variants.first : null;
    final item = CartItemEntity(
      id: '${product.id}_${variant?.id ?? "default"}',
      customerId: customerId,
      productId: product.id,
      variantId: variant?.id ?? 'default',
      storeId: product.storeId,
      vendorId: product.storeId,
      productName: product.name,
      imageUrl: product.imageUrls.isNotEmpty ? product.imageUrls.first : '',
      unitPrice: product.discountedPrice > 0 ? product.discountedPrice : product.basePrice,
      quantity: 1,
      size: variant?.size ?? 'M',
      color: variant?.color ?? 'Standard',
    );

    await cartRepo.addToCart(item);

    if (context.mounted) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text('Added "${product.name}" to cart!', style: const TextStyle(fontWeight: FontWeight.w600)),
              ),
              TextButton(
                onPressed: () => context.push('/cart'),
                child: const Text('VIEW CART', style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          backgroundColor: AppColors.primary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final image = product.imageUrls.isNotEmpty ? product.imageUrls.first : null;
    final cartAsync = ref.watch(cartStreamProvider);
    final cartItems = cartAsync.valueOrNull ?? [];
    final cartItem = cartItems.cast<CartItemEntity?>().firstWhere(
      (item) => item?.productId == product.id,
      orElse: () => null,
    );
    final hasDiscount = product.discountedPrice > 0 && product.discountedPrice < product.basePrice;
    final discountPercent = hasDiscount
        ? (((product.basePrice - product.discountedPrice) / product.basePrice) * 100).round()
        : 0;

    return Container(
      width: 165,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder, width: 1),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => context.push('/product/${product.id}'),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Image
              SizedBox(
                height: 130,
                width: double.infinity,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    ProductImage(
                      imageUrl: image,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                    ),
                    if (hasDiscount)
                      Positioned(
                        top: 8,
                        left: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [AppColors.accent, AppColors.accentTomato],
                            ),
                            borderRadius: BorderRadius.circular(6),
                            boxShadow: const [BoxShadow(color: Color(0x28000000), blurRadius: 4)],
                          ),
                          child: Text(
                            '$discountPercent% OFF',
                            style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w800),
                          ),
                        ),
                      ),
                    Positioned(
                      top: 6,
                      right: 6,
                      child: Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.9),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.favorite_border_rounded, size: 14, color: AppColors.primary),
                      ),
                    ),
                    Positioned(
                      bottom: 6,
                      right: 6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.black87,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.bolt_rounded, color: Colors.amber, size: 10),
                            SizedBox(width: 2),
                            Text('15m', style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Body
              Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      '48h Doorstep Exchange',
                      style: TextStyle(fontSize: 10, color: AppColors.accent, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Price
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '₹${((product.discountedPrice > 0 ? product.discountedPrice : product.basePrice) / 100).toStringAsFixed(0)}',
                              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: AppColors.primary),
                            ),
                            if (hasDiscount)
                              Text(
                                '₹${(product.basePrice / 100).toStringAsFixed(0)}',
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: AppColors.textHint,
                                  decoration: TextDecoration.lineThrough,
                                ),
                              ),
                          ],
                        ),
                        // Interactive ADD / Stepper Button
                        if (cartItem != null && cartItem.quantity > 0)
                          Container(
                            decoration: BoxDecoration(
                              color: AppColors.accent,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.accent.withValues(alpha: 0.3),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                InkWell(
                                  onTap: () {
                                    final cartRepo = ref.read(cartRepositoryProvider);
                                    if (cartItem.quantity > 1) {
                                      cartRepo.updateQuantity(
                                        customerId: cartItem.customerId,
                                        itemId: cartItem.id,
                                        quantity: cartItem.quantity - 1,
                                      );
                                    } else {
                                      cartRepo.removeFromCart(
                                        customerId: cartItem.customerId,
                                        itemId: cartItem.id,
                                      );
                                    }
                                  },
                                  borderRadius: const BorderRadius.horizontal(left: Radius.circular(16)),
                                  child: const Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                                    child: Icon(Icons.remove, size: 14, color: Colors.white),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 4),
                                  child: Text(
                                    '',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                                InkWell(
                                  onTap: () {
                                    final cartRepo = ref.read(cartRepositoryProvider);
                                    cartRepo.updateQuantity(
                                      customerId: cartItem.customerId,
                                      itemId: cartItem.id,
                                      quantity: cartItem.quantity + 1,
                                    );
                                  },
                                  borderRadius: const BorderRadius.horizontal(right: Radius.circular(16)),
                                  child: const Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                                    child: Icon(Icons.add, size: 14, color: Colors.white),
                                  ),
                                ),
                              ],
                            ),
                          )
                        else
                          InkWell(
                            onTap: () => _quickAddToCart(context, ref),
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: AppColors.accent, width: 1.4),
                                boxShadow: const [
                                  BoxShadow(color: Color(0x12D93670), blurRadius: 4, offset: Offset(0, 2)),
                                ],
                              ),
                              child: const Text(
                                'ADD +',
                                style: TextStyle(
                                  color: AppColors.accent,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 11,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
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
          Expanded(
            child: Text(
              'Complete Delivery Address',
              style: AppTextStyles.titleMedium,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Help our delivery rider reach your door in 15 minutes:',
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: houseCtrl,
              decoration: const InputDecoration(
                labelText: 'Flat / House / Floor No.',
                hintText: 'e.g. Flat 402, Block B',
                isDense: true,
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: societyCtrl,
              decoration: const InputDecoration(
                labelText: 'Building / Society / Apartment',
                hintText: 'e.g. Shaligram Heights',
                isDense: true,
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: landmarkCtrl,
              decoration: const InputDecoration(
                labelText: 'Nearby Landmark',
                hintText: 'e.g. Opposite Metro Pillar 128',
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
                Flexible(
                  child: Text('Select Delivery Market', style: AppTextStyles.titleLarge, overflow: TextOverflow.ellipsis),
                ),
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
                  color: AppColors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.25)),
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
                                : 'Auto-detects Bodakdev, Vastrapur, Kubernagar, Gandhinagar...',
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
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.1, color: AppColors.textHint),
            ),
            const SizedBox(height: 8),
            _HubTile(
              title: 'Kubernagar Market Hub',
              subtitle: 'Kubernagar, Ahmedabad • 18+ active boutiques',
              area: 'Kubernagar',
              city: 'Ahmedabad',
              lat: 23.0673,
              lng: 72.6394,
            ),
            _HubTile(
              title: 'Bodakdev & Vastrapur Hub',
              subtitle: 'SG Highway, Ahmedabad • 24+ premium stores',
              area: 'Bodakdev',
              city: 'Ahmedabad',
              lat: 23.0378,
              lng: 72.5126,
            ),
            _HubTile(
              title: 'Gandhinagar Sector 11 Hub',
              subtitle: 'Gandhinagar Central • 12+ stores',
              area: 'Sector 11',
              city: 'Gandhinagar',
              lat: 23.2156,
              lng: 72.6369,
            ),
          ],
        ),
      ),
    );
  }
}

class _HubTile extends ConsumerWidget {
  final String title;
  final String subtitle;
  final String area;
  final String city;
  final double lat;
  final double lng;

  const _HubTile({
    required this.title,
    required this.subtitle,
    required this.area,
    required this.city,
    required this.lat,
    required this.lng,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
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
