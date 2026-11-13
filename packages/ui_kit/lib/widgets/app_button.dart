import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

enum AppButtonVariant { primary, secondary, outline, text, danger }

class AppButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final bool isLoading;
  final bool fullWidth;
  final IconData? leadingIcon;
  final double? width;

  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.isLoading = false,
    this.fullWidth = true,
    this.leadingIcon,
    this.width,
  });

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton> {
  bool _isPressed = false;

  Color _getTextColor() {
    switch (widget.variant) {
      case AppButtonVariant.primary:
      case AppButtonVariant.secondary:
      case AppButtonVariant.danger:
        return Colors.white;
      case AppButtonVariant.outline:
      case AppButtonVariant.text:
        return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final textColor = _getTextColor();
    final child = widget.isLoading
        ? SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2, color: textColor),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.leadingIcon != null) ...[
                Icon(widget.leadingIcon, size: 18, color: textColor),
                const SizedBox(width: AppSpacing.sm),
              ],
              Flexible(
                  child: Text(
                widget.label,
                textAlign: TextAlign.center,
                style: AppTextStyles.labelLarge.copyWith(
                  color: textColor,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.2,
                ),
              )),
            ],
          );

    Widget button;
    switch (widget.variant) {
      case AppButtonVariant.primary:
        button = Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.18),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ElevatedButton(
            onPressed: widget.isLoading ? null : widget.onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: child,
          ),
        );
      case AppButtonVariant.secondary:
        button = Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: AppColors.accent.withValues(alpha: 0.22),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ElevatedButton(
            onPressed: widget.isLoading ? null : widget.onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accent,
              foregroundColor: Colors.white,
            ),
            child: child,
          ),
        );
      case AppButtonVariant.outline:
        button = OutlinedButton(
          onPressed: widget.isLoading ? null : widget.onPressed,
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,
            side: const BorderSide(color: AppColors.primary, width: 1.5),
          ),
          child: child,
        );
      case AppButtonVariant.text:
        button = TextButton(
          onPressed: widget.isLoading ? null : widget.onPressed,
          style: TextButton.styleFrom(
            foregroundColor: AppColors.primary,
          ),
          child: child,
        );
      case AppButtonVariant.danger:
        button = ElevatedButton(
          onPressed: widget.isLoading ? null : widget.onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.error,
            foregroundColor: Colors.white,
          ),
          child: child,
        );
    }

    final sizedButton = widget.fullWidth
        ? SizedBox(width: widget.width ?? double.infinity, child: button)
        : button;

    return Listener(
      onPointerDown: (_) => setState(() => _isPressed = true),
      onPointerUp: (_) => setState(() => _isPressed = false),
      onPointerCancel: (_) => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed &&
                widget.onPressed != null &&
                !widget.isLoading &&
                !MediaQuery.disableAnimationsOf(context)
            ? 0.975
            : 1.0,
        duration: const Duration(milliseconds: 110),
        curve: Curves.easeOutCubic,
        child: sizedButton,
      ),
    );
  }
}
