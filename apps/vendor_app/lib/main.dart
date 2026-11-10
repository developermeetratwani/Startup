import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ui_kit/ui_kit.dart';
import 'package:core/core.dart';
import 'firebase_options.dart';
import 'presentation/router/vendor_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }
  } catch (e) {
    debugPrint('VendorApp Firebase init: $e');
  }

  // Start real-time cross-app order synchronization bus
  OrderSyncService.startBackgroundSync();

  runApp(
    const ProviderScope(
      child: VendorApp(),
    ),
  );
}

class VendorApp extends ConsumerWidget {
  const VendorApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(vendorRouterProvider);

    return MaterialApp.router(
      title: 'MARS Vendor — Retailer Portal',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      scrollBehavior: const ButterySmoothScrollBehavior(),
      routerConfig: router,
      builder: (context, child) => PhoneSimulatorWrapper(
        badgeText: 'MARS Vendor',
        child: child ?? const SizedBox.shrink(),
      ),
    );
  }
}
