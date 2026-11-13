import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ui_kit/ui_kit.dart';

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  Future<void> mount(WidgetTester tester, Widget child,
      {double width = 390, double scale = 1, bool reduced = true}) async {
    tester.view.physicalSize = Size(width, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(MaterialApp(
        theme: AppTheme.light,
        home: MediaQuery(
            data: MediaQueryData(
                size: Size(width, 1000),
                textScaler: TextScaler.linear(scale),
                disableAnimations: reduced),
            child: Scaffold(body: child))));
    await tester.runAsync(() async => await GoogleFonts.pendingFonts());
    await tester.pump();
  }

  for (final width in [320.0, 390.0, 768.0]) {
    for (final scale in [1.0, 2.0]) {
      testWidgets('Editorial and metrics fit width $width at text scale $scale',
          (tester) async {
        await mount(
            tester,
            SingleChildScrollView(
                child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(children: [
                      MarsEditorial(onExplore: () {}),
                      const SizedBox(height: 12),
                      const MarsHero(
                          eyebrow: 'MARS / Merchant studio',
                          title: 'Your boutique.\nIn full bloom.',
                          description:
                              'Your orders, collection and earnings, together.'),
                      const MarsMetricGrid(children: [
                        MarsMetric(
                            label: 'Total sales',
                            value: '₹1,84,520',
                            icon: Icons.payments),
                        MarsMetric(
                            label: 'Platform fee',
                            value: '₹18,452',
                            icon: Icons.percent),
                        MarsMetric(
                            label: 'Net payout',
                            value: '₹1,66,068',
                            icon: Icons.wallet),
                      ]),
                    ]))),
            width: width,
            scale: scale);
        expect(tester.takeException(), isNull);
      });
    }
  }

  testWidgets(
      'Navigation exposes selection and invokes the intended destination',
      (tester) async {
    var selected = -1;
    await mount(
        tester,
        Align(
            alignment: Alignment.bottomCenter,
            child: MarsNavigation(
                selectedIndex: 0,
                onSelected: (value) => selected = value,
                destinations: const [
                  MarsDestination('Home', Icons.home),
                  MarsDestination('Orders', Icons.receipt, badge: 3),
                  MarsDestination('Store', Icons.store)
                ])),
        width: 320,
        scale: 2);
    await tester.tap(find.text('Orders'));
    expect(selected, 1);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Reduced motion does not schedule continuous frames',
      (tester) async {
    await mount(
        tester,
        const MarsHero(
            eyebrow: 'MARS',
            title: 'Ready when you are.',
            description: 'Your city, closer.'),
        reduced: true);
    await tester.pumpAndSettle();
    expect(tester.binding.hasScheduledFrame, isFalse);
  });

  testWidgets('Hero action works and animated hero disposes cleanly',
      (tester) async {
    var pressed = false;
    await mount(
        tester,
        MarsHero(
            eyebrow: 'MARS',
            title: 'Your next move.',
            description: 'Explore the city.',
            actionLabel: 'Explore',
            onAction: () => pressed = true),
        reduced: false);
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.text('Explore'));
    expect(pressed, isTrue);
    await tester.pumpWidget(const SizedBox());
    await tester.pump();
    expect(tester.takeException(), isNull);
    expect(tester.binding.transientCallbackCount, 0);
  });

  testWidgets('Hidden tabs retain state and pause their tickers',
      (tester) async {
    final index = ValueNotifier(0);
    addTearDown(index.dispose);
    await mount(
        tester,
        ValueListenableBuilder<int>(
            valueListenable: index,
            builder: (_, value, __) =>
                MarsTabStack(index: value, children: const [
                  MarsHero(
                      eyebrow: 'MARS',
                      title: 'First tab',
                      description: 'Animated content'),
                  Text('Second tab'),
                ])),
        reduced: false);
    await tester.pump(const Duration(seconds: 1));
    index.value = 1;
    await tester.pump();
    await tester.pumpAndSettle();
    expect(find.text('Second tab'), findsOneWidget);
    expect(tester.binding.hasScheduledFrame, isFalse);
    index.value = 0;
    await tester.pump();
    expect(find.text('First tab'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
    expect(tester.takeException(), isNull);
  });
  testWidgets('Long product galleries fit narrow screens and select images', (tester) async {
    final semantics = tester.ensureSemantics();

    await mount(tester, const MarsProductGallery(images: ['', '', '', '', '', '', '', ''], label: 'Local find'), width: 320);
    expect(tester.takeException(), isNull);
    await tester.tap(find.byTooltip('Show image 2'));
    await tester.pumpAndSettle();
    expect(find.bySemanticsLabel('Local find, image 2 of 8'), findsOneWidget);
    expect(tester.takeException(), isNull);
    semantics.dispose();
  });

}
