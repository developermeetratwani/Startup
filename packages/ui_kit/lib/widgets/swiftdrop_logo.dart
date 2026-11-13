import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// The shared SwiftDrop brand mark, kept consistent across every application.
class SwiftDropMark extends StatelessWidget {
  final double size;
  final bool framed;

  const SwiftDropMark({
    super.key,
    this.size = 40,
    this.framed = true,
  });

  @override
  Widget build(BuildContext context) {
    final mark = Image.asset(
      'assets/brand/swiftdrop_mark.png',
      package: 'ui_kit',
      fit: BoxFit.contain,
      filterQuality: FilterQuality.high,
      excludeFromSemantics: true,
    );

    return Semantics(
      image: true,
      label: 'SwiftDrop',
      child: SizedBox.square(
        dimension: size,
        child: framed
            ? DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(size * .24),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.purple.withValues(alpha: .16),
                      blurRadius: size * .28,
                      offset: Offset(0, size * .08),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(size * .24),
                  child: mark,
                ),
              )
            : mark,
      ),
    );
  }
}

/// Responsive SwiftDrop lock-up for headers, splash screens, and navigation.
class SwiftDropLogo extends StatelessWidget {
  final double height;
  final String? qualifier;

  const SwiftDropLogo({
    super.key,
    this.height = 40,
    this.qualifier,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      image: true,
      label: qualifier == null ? 'SwiftDrop' : 'SwiftDrop $qualifier',
      child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(height * .16),
          child: Image.asset(
            'assets/brand/swiftdrop_lockup.png',
            package: 'ui_kit',
            width: height * 3.06,
            height: height,
            fit: BoxFit.cover,
            filterQuality: FilterQuality.high,
            excludeFromSemantics: true,
          ),
        ),
        if (qualifier != null) ...[
          SizedBox(height: height * .14),
          Text(
            qualifier!.toUpperCase(),
            style: AppTextStyles.labelUppercase.copyWith(
              color: AppColors.textSecondary,
              fontSize: height * .18,
              letterSpacing: 1.7,
            ),
          ),
        ],
      ],
      ),
    );
  }
}
