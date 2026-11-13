import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'mars_motion.dart';

class MarsMetricGrid extends StatelessWidget {
  final List<Widget> children;
  const MarsMetricGrid({super.key, required this.children});
  @override
  Widget build(BuildContext context) =>
      LayoutBuilder(builder: (context, constraints) {
        final largeText = MediaQuery.textScalerOf(context).scale(1) > 1.3;
        final columns = largeText || constraints.maxWidth < 300
            ? 1
            : constraints.maxWidth < 390
                ? 2
                : 3;
        final width = (constraints.maxWidth - (columns - 1) * 12) / columns;
        return Wrap(spacing: 12, runSpacing: 12, children: [
          for (final child in children) SizedBox(width: width, child: child),
        ]);
      });
}

class MarsMetric extends StatelessWidget {
  final String label;
  final String value;
  final String? detail;
  final IconData icon;
  final Color accent;
  const MarsMetric(
      {super.key,
      required this.label,
      required this.value,
      required this.icon,
      this.detail,
      this.accent = AppColors.accent});

  @override
  Widget build(BuildContext context) => MarsReveal(
        delay: 100,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: AppColors.cardBorder),
              boxShadow: const [
                BoxShadow(
                    color: AppColors.shadow,
                    blurRadius: 20,
                    offset: Offset(0, 5))
              ]),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                    padding: const EdgeInsets.all(9),
                    decoration: BoxDecoration(
                        color: accent.withValues(alpha: .09),
                        borderRadius: BorderRadius.circular(12)),
                    child: Icon(icon, color: accent, size: 18)),
                const SizedBox(height: 16),
                Text(label,
                    style: AppTextStyles.bodySmall.copyWith(fontSize: 11)),
                const SizedBox(height: 6),
                AnimatedSwitcher(
                    duration: Duration(
                        milliseconds:
                            MediaQuery.disableAnimationsOf(context) ? 0 : 280),
                    child: Text(value,
                        key: ValueKey(value),
                        style: AppTextStyles.titleLarge
                            .copyWith(fontSize: 21, letterSpacing: -.8),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis)),
                if (detail != null) ...[
                  const SizedBox(height: 7),
                  Text(detail!,
                      style: AppTextStyles.bodySmall.copyWith(fontSize: 10))
                ],
              ]),
        ),
      );
}
