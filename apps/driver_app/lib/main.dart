import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ui_kit/ui_kit.dart';
import 'package:core/core.dart';
import 'firebase_options.dart';
import 'presentation/router/driver_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }
  } catch (e) {
    debugPrint('DriverApp Firebase init: $e');
  }

  // Start real-time cross-app order synchronization bus
  OrderSyncService.startBackgroundSync();

  runApp(
    const ProviderScope(
      child: DriverApp(),
    ),
  );
}

class DriverApp extends ConsumerWidget {
  const DriverApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(driverRouterProvider);

    return MaterialApp.router(
      title: 'MARS Driver — Delivery Partner',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      scrollBehavior: const ButterySmoothScrollBehavior(),
      routerConfig: router,
      builder: (context, child) => PhoneSimulatorWrapper(
        badgeText: 'MARS Driver',
        child: child ?? const SizedBox.shrink(),
      ),
    );
  }
}
