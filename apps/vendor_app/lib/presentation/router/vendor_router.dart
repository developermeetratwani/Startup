import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../screens/auth/vendor_login_screen.dart';
import '../screens/auth/vendor_register_screen.dart';
import '../screens/auth/pending_approval_screen.dart';
import '../screens/home/vendor_nav_shell.dart';
import '../screens/products/add_edit_product_screen.dart';
import '../screens/orders/vendor_orders_screen.dart';
import '../screens/earnings/vendor_earnings_screen.dart';
import '../screens/profile/vendor_profile_screen.dart';

final vendorRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (_, __) => const VendorNavShell(),
      ),
      GoRoute(
        path: '/login',
        builder: (_, __) => const VendorLoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (_, __) => const VendorRegisterScreen(),
      ),
      GoRoute(
        path: '/pending-approval',
        builder: (_, __) => const PendingApprovalScreen(),
      ),
      GoRoute(
        path: '/products/add',
        builder: (_, __) => const AddEditProductScreen(),
      ),
      GoRoute(
        path: '/orders',
        builder: (_, __) => const VendorOrdersScreen(),
      ),
      GoRoute(
        path: '/earnings',
        builder: (_, __) => const VendorEarningsScreen(),
      ),
      GoRoute(
        path: '/profile',
        builder: (_, __) => const VendorProfileScreen(),
      ),
    ],
  );
});
