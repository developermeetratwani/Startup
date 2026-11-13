import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'mars_motion.dart';

class MarsEditorial extends StatelessWidget {
  final VoidCallback onExplore;
  const MarsEditorial({super.key, required this.onExplore});

  @override
  Widget build(BuildContext context) => MarsReveal(
          child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Stack(children: [
          Positioned.fill(
              child: Image.asset('assets/fashion_editorial.jpg',
                  package: 'ui_kit',
                  fit: BoxFit.cover,
                  alignment: const Alignment(.4, 0),
                  excludeFromSemantics: true)),
          Positioned.fill(
              child: DecoratedBox(
                  decoration: BoxDecoration(
                      gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          stops: const [
                0,
                .35,
                1
              ],
                          colors: [
                AppColors.onyx.withValues(alpha: .2),
                AppColors.onyx.withValues(alpha: .05),
                AppColors.onyx.withValues(alpha: .94)
              ])))),
          Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Flexible(
                        child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 7),
                            decoration: BoxDecoration(
                                color: AppColors.linen,
                                borderRadius: BorderRadius.circular(30)),
                            child: Text('THE NEIGHBOURHOOD EDIT',
                                style: AppTextStyles.labelUppercase.copyWith(
                                    color: AppColors.onyx,
                                    fontSize: 8,
                                    letterSpacing: 1.5)))),
                    const SizedBox(width: 10),
                    const Icon(Icons.auto_awesome_outlined,
                        color: AppColors.linen, size: 20),
                  ]),
                  const SizedBox(height: 144),
                  Text('Good style.\nGreat proximity.',
                      style: AppTextStyles.displayLarge.copyWith(
                          color: AppColors.linen,
                          fontSize: 38,
                          height: 1.04,
                          letterSpacing: -1.8)),
                  const SizedBox(height: 12),
                  Text('Your next favourite is just around the corner.',
                      style: AppTextStyles.bodySmall
                          .copyWith(color: AppColors.linen, height: 1.5)),
                  const SizedBox(height: 20),
                  FilledButton.icon(
                      onPressed: onExplore,
                      style: FilledButton.styleFrom(
                          backgroundColor: AppColors.linen,
                          foregroundColor: AppColors.onyx,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 18, vertical: 14)),
                      label: const Text('Find your next favourite'),
                      icon: const Icon(Icons.arrow_outward_rounded, size: 18)),
                ],
              )),
        ]),
      ));
}

class MarsEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final String? actionLabel;
  final VoidCallback? onAction;
  const MarsEmptyState(
      {super.key,
      required this.icon,
      required this.title,
      required this.description,
      this.actionLabel,
      this.onAction});
  @override
  Widget build(BuildContext context) => Center(
          child: SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: MarsReveal(
            child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                    color: AppColors.raspberryLight,
                    borderRadius: BorderRadius.circular(32)),
                child: Icon(icon, size: 42, color: AppColors.accent)),
            const SizedBox(height: 24),
            Text(title,
                style: AppTextStyles.headlineMedium,
                textAlign: TextAlign.center),
            const SizedBox(height: 10),
            ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 300),
                child: Text(description,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary, height: 1.6))),
            if (onAction != null && actionLabel != null) ...[
              const SizedBox(height: 22),
              FilledButton(onPressed: onAction, child: Text(actionLabel!)),
            ],
          ],
        )),
      ));
}
