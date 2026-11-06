import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

enum SnackbarType { success, error, info, warning }

class AppSnackbar {
  static void show(
    BuildContext context, {
    required String message,
    SnackbarType type = SnackbarType.info,
    Duration duration = const Duration(seconds: 3),
  }) {
    final colors = {
      SnackbarType.success: AppColors.success,
      SnackbarType.error:   AppColors.error,
      SnackbarType.info:    AppColors.info,
      SnackbarType.warning: AppColors.warning,
    };
    final icons = {
      SnackbarType.success: Icons.check_circle_rounded,
      SnackbarType.error:   Icons.error_rounded,
      SnackbarType.info:    Icons.info_rounded,
      SnackbarType.warning: Icons.warning_rounded,
    };

    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          duration: duration,
          backgroundColor: colors[type],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          content: Row(
            children: [
              Icon(icons[type], color: Colors.white, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  message,
                  style: AppTextStyles.bodyMedium.copyWith(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      );
  }
}
