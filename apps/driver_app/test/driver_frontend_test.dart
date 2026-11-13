import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ui_kit/ui_kit.dart';
import 'package:driver_app/data/repositories/driver_earnings_repository.dart';
import 'package:driver_app/presentation/providers/driver_providers.dart';
import 'package:driver_app/presentation/screens/home/driver_home_screen.dart';
import 'package:driver_app/presentation/screens/home/driver_nav_shell.dart';

void main() {
  for (final online in [false, true]) {
    testWidgets('Driver dashboard renders at 320px while ${online ? "online" : "offline"}', (tester) async {
      tester.view.physicalSize = const Size(320, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(ProviderScope(overrides: [
        driverDutyProvider.overrideWith((ref) => online),
        activeDeliveryProvider.overrideWithValue(null),
        driverEarningsProvider.overrideWith((ref) => Stream.value(const DriverEarningsSummary(
          todayEarnings: 22500, weeklyEarnings: 85000, totalDeliveries: 5, todayDeliveries: 3, rating: 4.9))),
      ], child: MaterialApp(theme: AppTheme.light,
        home: const MediaQuery(data: MediaQueryData(size: Size(320, 900), disableAnimations: true),
          child: DriverHomeScreen()))));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      expect(find.text(online ? 'Your city.\nYour next move.' : 'A fresh start.\nEvery shift.'), findsOneWidget);
      expect(find.text('₹225'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    });
  }

  testWidgets('Unverified driver stays behind the existing KYC gate', (tester) async {
    await tester.pumpWidget(ProviderScope(overrides: [
      driverProfileProvider.overrideWith((ref) => const DriverProfileState(isVerified: false)),
    ], child: MaterialApp(theme: AppTheme.light, home: const DriverNavShell())));
    await tester.pump();
    expect(find.text('Mandatory Driver KYC'), findsOneWidget);
    expect(find.byType(DriverHomeScreen), findsNothing);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });
}
