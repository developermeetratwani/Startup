import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ui_kit/ui_kit.dart';
import 'driver_home_screen.dart';
import '../earnings/driver_earnings_screen.dart';
import '../profile/driver_profile_screen.dart';
import '../auth/driver_kyc_screen.dart';
import '../../providers/driver_providers.dart';

class DriverNavShell extends ConsumerStatefulWidget {
  const DriverNavShell({super.key});

  @override
  ConsumerState<DriverNavShell> createState() => _DriverNavShellState();
}

class _DriverNavShellState extends ConsumerState<DriverNavShell> {
  int _currentIndex = 0;

  final _screens = const [
    DriverHomeScreen(),
    DriverEarningsScreen(),
    DriverProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(driverProfileProvider);

    // Hard KYC Gate: Lock all delivery and earnings access until all KYC items are verified
    if (!profile.isVerified) {
      return const DriverKycScreen();
    }

    return Scaffold(
      body: MarsTabStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: MarsNavigation(
        selectedIndex: _currentIndex,
        onSelected: (index) => setState(() => _currentIndex = index),
        accent: AppColors.ratingGreen,
        destinations: const [
          MarsDestination('Deliveries', Icons.route_rounded),
          MarsDestination('Earnings', Icons.account_balance_wallet_outlined),
          MarsDestination('Profile', Icons.person_outline_rounded)
        ],
      ),
    );
  }
}
