import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'mars_motion.dart';

/// Brand artwork is decorative; all operational information comes from callers.
class MarsHero extends StatefulWidget {
  final String eyebrow;
  final String title;
  final String description;
  final String? actionLabel;
  final VoidCallback? onAction;
  final Color accent;
  final IconData icon;
  const MarsHero(
      {super.key,
      required this.eyebrow,
      required this.title,
      required this.description,
      this.actionLabel,
      this.onAction,
      this.accent = AppColors.accent,
      this.icon = Icons.north_east_rounded});

  @override
  State<MarsHero> createState() => _MarsHeroState();
}

class _MarsHeroState extends State<MarsHero>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller =
      AnimationController(vsync: this, duration: const Duration(seconds: 18));

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context) ||
        !TickerMode.valuesOf(context).enabled) {
      _controller.stop();
    } else {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => MarsReveal(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: ColoredBox(
            color: AppColors.onyx,
            child: Stack(
              children: [
                Positioned.fill(
                    child: IgnorePointer(
                        child: RepaintBoundary(
                  child: AnimatedBuilder(
                      animation: _controller,
                      builder: (context, _) => CustomPaint(
                          painter:
                              _OrbitPainter(widget.accent, _controller.value))),
                ))),
                Padding(
                  padding: const EdgeInsets.all(26),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                  color: widget.accent,
                                  shape: BoxShape.circle)),
                          const SizedBox(width: 8),
                          Expanded(
                              child: Text(widget.eyebrow.toUpperCase(),
                                  style: AppTextStyles.labelUppercase.copyWith(
                                      color: AppColors.textOnDark,
                                      letterSpacing: 2))),
                          Icon(widget.icon, color: widget.accent, size: 22),
                        ]),
                        const SizedBox(height: 26),
                        Text(widget.title,
                            style: AppTextStyles.displayLarge.copyWith(
                                color: AppColors.textOnDark,
                                fontSize: 36,
                                height: 1.08,
                                letterSpacing: -1.5)),
                        const SizedBox(height: 14),
                        ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 430),
                            child: Text(widget.description,
                                style: AppTextStyles.bodyMedium.copyWith(
                                    color: AppColors.textOnDark
                                        .withValues(alpha: 0.72),
                                    height: 1.6))),
                        if (widget.actionLabel != null &&
                            widget.onAction != null) ...[
                          const SizedBox(height: 24),
                          FilledButton.icon(
                              onPressed: widget.onAction,
                              style: FilledButton.styleFrom(
                                  backgroundColor: AppColors.linen,
                                  foregroundColor: AppColors.onyx,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 16)),
                              icon: const Icon(Icons.arrow_outward_rounded,
                                  size: 18),
                              label: Text(widget.actionLabel!)),
                        ],
                      ]),
                ),
              ],
            ),
          ),
        ),
      );
}

class _OrbitPainter extends CustomPainter {
  final Color color;
  final double phase;
  _OrbitPainter(this.color, this.phase);
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width * 0.96, size.height * 0.44);
    final radius = math.min(size.width, size.height) * 0.8;
    canvas.drawCircle(
        center,
        radius * 1.4,
        Paint()
          ..shader = RadialGradient(
            colors: [color.withValues(alpha: 0.26), color.withValues(alpha: 0)],
          ).createShader(
              Rect.fromCircle(center: center, radius: radius * 1.4)));
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(-0.5 + phase * 0.3);
    for (var i = 0; i < 5; i++) {
      canvas.drawOval(
          Rect.fromCenter(
              center: Offset.zero,
              width: radius * (1 + i * .28),
              height: radius * (0.6 + i * .23)),
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 0.8
            ..color = color.withValues(alpha: .12 + i * .025));
    }
    final angle = phase * math.pi * 2;
    canvas.drawCircle(
        Offset(math.cos(angle) * radius * .78, math.sin(angle) * radius * .48),
        5,
        Paint()..color = color.withValues(alpha: .65));
    canvas.restore();
  }

  @override
  bool shouldRepaint(_OrbitPainter oldDelegate) =>
      phase != oldDelegate.phase || color != oldDelegate.color;
}

class MarsSectionHeading extends StatelessWidget {
  final String number;
  final String title;
  final String? subtitle;
  const MarsSectionHeading(
      {super.key, required this.number, required this.title, this.subtitle});
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 18),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(number,
              style:
                  AppTextStyles.labelSmall.copyWith(color: AppColors.accent)),
          const SizedBox(width: 12),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(title, style: AppTextStyles.headlineMedium),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(subtitle!, style: AppTextStyles.bodySmall)
                ],
              ])),
        ]),
      );
}
