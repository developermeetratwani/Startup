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
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.accent,
        unselectedItemColor: AppColors.textSecondary,
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_rounded),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(Icons.receipt_long_rounded),
                if (pendingCount > 0)
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
                        '$pendingCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            label: 'Orders',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.inventory_2_rounded),
            label: 'Products',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.monetization_on_rounded),
            label: 'Earnings',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.storefront_rounded),
            label: 'Store',
          ),
        ],
      ),
    );
  }
}
