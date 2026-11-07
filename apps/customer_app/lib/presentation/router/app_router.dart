import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/auth_provider.dart';
import '../screens/auth/splash_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/store/store_detail_screen.dart';
import '../screens/product/product_detail_screen.dart';
import '../screens/cart/cart_screen.dart';
import '../screens/checkout/checkout_screen.dart';
import '../screens/orders/orders_list_screen.dart';
import '../screens/orders/order_tracking_screen.dart';
import '../screens/orders/order_exchange_screen.dart';
import '../screens/address/address_list_screen.dart';
import '../screens/address/add_address_screen.dart';
import '../screens/search/search_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/legal/legal_and_consent_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/splash',
    redirect: (context, state) {
      User? user;
      try {
        user = FirebaseAuth.instance.currentUser;
      } catch (_) {}

      final domainUser = ref.read(currentUserProvider);

      // Allow guest exploration of orders & tracking for seamless preview
      final requiresAuth = state.matchedLocation.startsWith('/addresses') &&
          user == null && domainUser == null;

      if (requiresAuth) {
        return '/login';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (_, __) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (_, __) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (_, __) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (_, __) => const HomeScreen(),
      ),
      GoRoute(
        path: '/store/:id',
        builder: (_, state) => StoreDetailScreen(
          storeId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: '/product/:id',
        builder: (_, state) => ProductDetailScreen(
          productId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: '/cart',
        builder: (_, __) => const CartScreen(),
      ),
      GoRoute(
        path: '/checkout',
        builder: (_, __) => const CheckoutScreen(),
      ),
      GoRoute(
        path: '/orders',
        builder: (_, __) => const OrdersListScreen(),
      ),
      GoRoute(
        path: '/orders/track/:id',
        builder: (_, state) => OrderTrackingScreen(
          orderId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: '/orders/:id/exchange',
        builder: (_, state) => OrderExchangeScreen(
          orderId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: '/addresses',
        builder: (_, __) => const AddressListScreen(),
      ),
      GoRoute(
        path: '/addresses/add',
        builder: (_, __) => const AddAddressScreen(),
      ),
      GoRoute(
        path: '/search',
        builder: (_, __) => const SearchScreen(),
      ),
      GoRoute(
        path: '/profile',
        builder: (_, __) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/legal',
        builder: (_, __) => const LegalAndConsentScreen(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(child: Text('Page not found: ${state.uri}')),
    ),
  );
});
