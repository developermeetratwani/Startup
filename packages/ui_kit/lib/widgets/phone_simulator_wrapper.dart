import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'mars_motion.dart';

/// Desktop presentation frame with an accurate, keyboard-aware app viewport.
/// Phones use the entire screen without any simulated device chrome.
class PhoneSimulatorWrapper extends StatelessWidget {
  final Widget child;
  final String? badgeText;
  const PhoneSimulatorWrapper({super.key, required this.child, this.badgeText});

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    if (!kIsWeb || media.size.width < 700) return child;
    final partner = (badgeText ?? '').contains('Vendor');
    final rider = (badgeText ?? '').contains('Driver');
    final wide = media.size.width >= 1050;
    final accent = rider
        ? AppColors.liveEmerald
        : partner
            ? AppColors.purple
            : AppColors.accent;
    return Material(
      color: AppColors.onyx,
      child: SafeArea(
          child: Padding(
        padding: EdgeInsets.all(wide ? 32 : 18),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          if (wide)
            Expanded(
                child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 38),
              child: SingleChildScrollView(child: MarsReveal(
                  child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(children: [
                    Text('SwiftDrop',
                        style: AppTextStyles.displayLarge.copyWith(
                            color: AppColors.linen,
                            fontSize: 26,
                            letterSpacing: 8)),
                    const SizedBox(width: 16),
                    Container(width: 34, height: 1, color: accent),
                  ]),
                  const SizedBox(height: 64),
                  Text(
                      rider
                          ? 'MOVE THE CITY.'
                          : partner
                              ? 'THE LOCAL EDIT.'
                              : 'YOUR CITY. YOUR STYLE.',
                      style: AppTextStyles.labelUppercase
                          .copyWith(color: accent, letterSpacing: 3)),
                  const SizedBox(height: 20),
                  Text(
                      rider
                          ? 'Every mile.\nMore possibility.'
                          : partner
                              ? 'Small boutique.\nBig energy.'
                              : 'Great style.\nCloser than\nyou think.',
                      style: AppTextStyles.displayLarge.copyWith(
                          color: AppColors.linen,
                          fontSize: 54,
                          height: 1.06,
                          letterSpacing: -2.6)),
                  const SizedBox(height: 26),
                  ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 330),
                      child: Text(
                          rider
                              ? 'Your next delivery, your next opportunity. Keep your city moving with SwiftDrop.'
                              : partner
                                  ? 'The workspace for your next chapter. Orders, collections and growth, beautifully in sync.'
                                  : 'Discover independent boutiques and fresh fashion from the neighbourhoods you love.',
                          style: AppTextStyles.bodyLarge.copyWith(
                              color: AppColors.textHint, height: 1.8))),
                  const SizedBox(height: 48),
                  Container(
                      height: 1,
                      width: 280,
                      color: AppColors.textHint.withValues(alpha: .2)),
                  const SizedBox(height: 22),
                  Text('AHMEDABAD  /  GANDHINAGAR',
                      style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.textHint, letterSpacing: 2)),
                ],
              ))),
            )),
          SizedBox(
              width: 440,
              child: DecoratedBox(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                        color: AppColors.textHint.withValues(alpha: .25)),
                    boxShadow: [
                      BoxShadow(
                          color: accent.withValues(alpha: .12),
                          blurRadius: 90,
                          spreadRadius: 8)
                    ]),
                child: ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                    child: LayoutBuilder(
                        builder: (context, constraints) => MediaQuery(
                            data: media.copyWith(
                                size: Size(constraints.maxWidth,
                                    constraints.maxHeight),
                                padding: EdgeInsets.zero,
                                viewPadding: EdgeInsets.zero),
                            child: child))),
              )),
          if (wide) const SizedBox(width: 40),
        ]),
      )),
    );
  }
}
