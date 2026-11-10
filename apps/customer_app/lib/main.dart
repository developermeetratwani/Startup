import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:ui_kit/ui_kit.dart';
import 'package:core/core.dart';
import 'core/constants/app_constants.dart';
import 'presentation/router/app_router.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }
  } catch (e) {
    debugPrint('Firebase init notice: $e');
  }

  // Start real-time cross-app order synchronization bus
  OrderSyncService.startBackgroundSync();

  // Load historical route learning cache
  await DeliveryEtaService.init();

  runApp(
    const ProviderScope(
      child: CustomerApp(),
    ),
  );
}

class CustomerApp extends ConsumerWidget {
  const CustomerApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      scrollBehavior: const ButterySmoothScrollBehavior(),
      routerConfig: router,
      builder: (context, child) => PhoneSimulatorWrapper(
        badgeText: 'MARS',
        child: child ?? const SizedBox.shrink(),
      ),
    );
  }
}
