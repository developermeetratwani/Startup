import 'package:flutter/material.dart';

/// App color system derived from the curated luxury palette:
/// - Tomato Red: #F04438
/// - Linen (Warm Alabaster Canvas): #F4EFE9
/// - Onyx Jet Black: #171717
/// - Medium Purple / Lilac: #A78BFA
/// - Medium Violet Red / Rich Raspberry: #D93670
class AppColors {
  AppColors._();

  // ─── 5-Color Master Palette ────────────────────────────────────────────────
  static const Color tomato        = Color(0xFFF04438); // #F04438 - Tomato / Coral
  static const Color linen         = Color(0xFFF4EFE9); // #F4EFE9 - Warm Linen Canvas
  static const Color onyx          = Color(0xFF171717); // #171717 - Deep Jet Black
  static const Color purple        = Color(0xFFA78BFA); // #A78BFA - Soft Lilac / Purple
  static const Color raspberry     = Color(0xFFD93670); // #D93670 - Rich Raspberry / Violet Red

  // ─── Brand Roles ───────────────────────────────────────────────────────────
  // Primary: Sleek Jet Black for luxury boutique typography, primary CTAs & contrast
  static const Color primary       = Color(0xFF171717);
  static const Color primaryLight  = Color(0xFF282828);

  // Accent: Rich Raspberry for brand highlights, active states, cart & badges
  static const Color accent        = Color(0xFFD93670);
  static const Color accentLight   = Color(0xFFE85A8E);

  // Secondary Accents
  static const Color accentTomato  = Color(0xFFF04438);
  static const Color accentPurple  = Color(0xFFA78BFA);
  static const Color purpleLight   = Color(0xFFF1EBFF);
  static const Color raspberryLight = Color(0xFFFCE8F0);
  static const Color tomatoLight   = Color(0xFFFEECEB);

  // ─── Surfaces ──────────────────────────────────────────────────────────────
  // Warm Linen canvas replaces stark grey for an editorial high-end boutique feel
  static const Color background    = Color(0xFFF4EFE9);
  static const Color surface       = Color(0xFFFFFFFF);
  static const Color surfaceWarm   = Color(0xFFFAF7F3);
  static const Color surfaceVariant = Color(0xFFEBE5DC);
  static const Color cardBorder    = Color(0xFFE5DDD3);

  // ─── Typography ────────────────────────────────────────────────────────────
  static const Color textPrimary   = Color(0xFF171717);
  static const Color textSecondary = Color(0xFF6B655F);
  static const Color textHint      = Color(0xFFA19B93);
  static const Color textOnDark    = Color(0xFFF4EFE9);

  // ─── Status ────────────────────────────────────────────────────────────────
  static const Color success       = Color(0xFF16A34A);
  static const Color warning       = Color(0xFFF59E0B);
  static const Color error         = Color(0xFFF04438); // Palette Tomato
  static const Color info          = Color(0xFF6366F1);

  // Order status colors
  static const Color statusPending     = Color(0xFFF59E0B);
  static const Color statusConfirmed   = Color(0xFF6366F1);
  static const Color statusPreparing   = Color(0xFFA78BFA); // Palette Purple
  static const Color statusReady       = Color(0xFFD93670); // Palette Raspberry
  static const Color statusPickedUp    = Color(0xFFF04438); // Palette Tomato
  static const Color statusDelivered   = Color(0xFF16A34A);
  static const Color statusCancelled   = Color(0xFFDC2626);

  // ─── Misc ──────────────────────────────────────────────────────────────────
  static const Color divider       = Color(0xFFE5DDD3);
  static const Color shadow        = Color(0x0F171717); // Soft diffused shadow
  static const Color shimmerBase   = Color(0xFFE8E2D9);
  static const Color shimmerHighlight = Color(0xFFF4EFE9);
}
