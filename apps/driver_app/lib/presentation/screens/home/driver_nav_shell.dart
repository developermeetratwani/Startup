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
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        selectedItemColor: AppColors.accent,
        unselectedItemColor: AppColors.textSecondary,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.two_wheeler_rounded),
            label: 'Deliveries',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.currency_rupee_rounded),
            label: 'Earnings',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
