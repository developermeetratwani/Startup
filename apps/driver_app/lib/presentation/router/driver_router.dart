import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../screens/auth/driver_login_screen.dart';
import '../screens/auth/driver_register_screen.dart';
import '../screens/home/driver_nav_shell.dart';
import '../screens/earnings/driver_earnings_screen.dart';
import '../screens/profile/driver_profile_screen.dart';

final driverRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (_, __) => const DriverNavShell(),
      ),
      GoRoute(
        path: '/login',
        builder: (_, __) => const DriverLoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (_, __) => const DriverRegisterScreen(),
      ),
      GoRoute(
        path: '/earnings',
        builder: (_, __) => const DriverEarningsScreen(),
      ),
      GoRoute(
        path: '/profile',
        builder: (_, __) => const DriverProfileScreen(),
      ),
    ],
  );
});
