import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ui_kit/ui_kit.dart';
import 'package:domain/domain.dart';
import '../../providers/vendor_providers.dart';
import 'vendor_dashboard_screen.dart';
import '../orders/vendor_orders_screen.dart';
import '../products/vendor_products_screen.dart';
import '../earnings/vendor_earnings_screen.dart';
import '../profile/vendor_profile_screen.dart';

class VendorNavShell extends ConsumerStatefulWidget {
  const VendorNavShell({super.key});

  @override
  ConsumerState<VendorNavShell> createState() => _VendorNavShellState();
}

class _VendorNavShellState extends ConsumerState<VendorNavShell> {
  int _currentIndex = 0;

  final _screens = const [
    VendorDashboardScreen(),
    VendorOrdersScreen(),
    VendorProductsScreen(),
    VendorEarningsScreen(),
    VendorProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final ordersAsync = ref.watch(vendorOrdersProvider);
    final pendingCount = ordersAsync.valueOrNull
            ?.where((o) => o.status == OrderStatus.pending)
            .length ??
        0;

    return Scaffold(
      body: MarsTabStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: MarsNavigation(
        selectedIndex: _currentIndex,
        onSelected: (index) => setState(() => _currentIndex = index),
        accent: AppColors.accent,
        destinations: [
          const MarsDestination('Home', Icons.grid_view_rounded),
          MarsDestination('Orders', Icons.receipt_long_rounded,
              badge: pendingCount),
          const MarsDestination('Catalog', Icons.checkroom_rounded),
          const MarsDestination(
              'Earnings', Icons.account_balance_wallet_outlined),
          const MarsDestination('Store', Icons.storefront_outlined)
        ],
      ),
    );
  }
}
