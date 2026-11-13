import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';
import 'app_spacing.dart';
import '../widgets/mars_motion.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary: AppColors.primary,
        onPrimary: AppColors.textOnDark,
        secondary: AppColors.accent,
        onSecondary: Colors.white,
        tertiary: AppColors.purple,
        onTertiary: Colors.white,
        error: AppColors.error,
        onError: Colors.white,
        surface: AppColors.surface,
        onSurface: AppColors.textPrimary,
        surfaceContainerHighest: AppColors.surfaceVariant,
        outline: AppColors.cardBorder,
      ),
      scaffoldBackgroundColor: AppColors.background,
      pageTransitionsTheme: const PageTransitionsTheme(builders: {
        TargetPlatform.android: MarsPageTransitions(),
        TargetPlatform.iOS: MarsPageTransitions(),
        TargetPlatform.windows: MarsPageTransitions(),
        TargetPlatform.macOS: MarsPageTransitions(),
        TargetPlatform.linux: MarsPageTransitions(),
      }),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
            side: const BorderSide(color: AppColors.cardBorder)),
      ),
      dialogTheme: DialogThemeData(
          backgroundColor: AppColors.surface,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(28))),
      bottomSheetTheme: const BottomSheetThemeData(
          backgroundColor: AppColors.surface,
          showDragHandle: true,
          modalBackgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)))),
      snackBarTheme: SnackBarThemeData(
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.onyx,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
      chipTheme: ChipThemeData(
          backgroundColor: AppColors.surface,
          selectedColor: AppColors.raspberryLight,
          side: const BorderSide(color: AppColors.cardBorder),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
      dataTableTheme: DataTableThemeData(
          headingRowColor: WidgetStateProperty.all(AppColors.surfaceWarm),
          headingTextStyle: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: .3,
              color: AppColors.textSecondary),
          dataTextStyle: GoogleFonts.plusJakartaSans(
              fontSize: 12, color: AppColors.textPrimary),
          dividerThickness: .7,
          headingRowHeight: 52,
          dataRowMinHeight: 58,
          dataRowMaxHeight: 78),
      tabBarTheme: TabBarThemeData(
          labelColor: AppColors.accent,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.accent,
          dividerColor: AppColors.divider,
          labelStyle: GoogleFonts.plusJakartaSans(
              fontWeight: FontWeight.w700, fontSize: 13)),
      textTheme: GoogleFonts.plusJakartaSansTextTheme(),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        titleTextStyle: GoogleFonts.plusJakartaSans(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.2,
          color: AppColors.textPrimary,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: 15,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: GoogleFonts.plusJakartaSans(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.1,
            color: Colors.white,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.cardBorder, width: 1.5),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: 15,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: GoogleFonts.plusJakartaSans(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.cardBorder, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.cardBorder, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.error, width: 1),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: 16,
        ),
        hintStyle: GoogleFonts.plusJakartaSans(
          color: AppColors.textHint,
          fontSize: 14,
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.divider,
        thickness: 1,
        space: 1,
      ),
    );
  }
}

/// Global buttery-smooth scroll behavior for 60Hz/120Hz displays across iOS & Android
class ButterySmoothScrollBehavior extends MaterialScrollBehavior {
  const ButterySmoothScrollBehavior();

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    return const BouncingScrollPhysics(
      parent: AlwaysScrollableScrollPhysics(),
    );
  }

  @override
  Widget buildOverscrollIndicator(
      BuildContext context, Widget child, ScrollableDetails details) {
    return child;
  }
}
