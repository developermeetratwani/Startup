import 'package:flutter/material.dart';
import 'package:ui_kit/ui_kit.dart';
import 'driver_home_screen.dart';
import '../earnings/driver_earnings_screen.dart';
import '../profile/driver_profile_screen.dart';

class DriverNavShell extends StatefulWidget {
  const DriverNavShell({super.key});

  @override
  State<DriverNavShell> createState() => _DriverNavShellState();
}

class _DriverNavShellState extends State<DriverNavShell> {
  int _currentIndex = 0;

  final _screens = const [
    DriverHomeScreen(),
    DriverEarningsScreen(),
    DriverProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
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
