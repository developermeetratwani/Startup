import 'package:flutter/material.dart';

/// App color system derived from curated high-fashion luxury palettes:
/// - Tomato Red: #F04438
/// - Linen: #F4EFE9
/// - Onyx Jet Black: #0F1016 / #171717
/// - Medium Purple / Lilac: #A78BFA
/// - Medium Violet Red / Rich Raspberry: #D93670
/// - Royal Gold: #D4AF37 / #F59E0B
class AppColors {
  AppColors._();

  // ─── 5-Color Master Palette ────────────────────────────────────────────────
  static const Color tomato = Color(0xFFF04438); // #F04438 - Tomato / Coral
  static const Color linen = Color(0xFFF4EFE9); // #F4EFE9 - Warm Linen Canvas
  static const Color onyx = Color(0xFF0F1016); // #0F1016 - Deep Obsidian
  static const Color purple =
      Color(0xFFA78BFA); // #A78BFA - Soft Lilac / Purple
  static const Color raspberry =
      Color(0xFFD93670); // #D93670 - Rich Raspberry / Violet Red

  // ─── Brand Roles ───────────────────────────────────────────────────────────
  static const Color primary = Color(0xFF0F1016); // Executive Obsidian
  static const Color primaryLight = Color(0xFF232530);

  // Accent: Rich Raspberry for brand highlights, active states, cart & badges
  static const Color accent = Color(0xFFD93670);
  static const Color accentLight = Color(0xFFE85A8E);

  // Secondary Accents
  static const Color accentTomato = Color(0xFFF04438);
  static const Color accentPurple = Color(0xFFA78BFA);
  static const Color purpleLight = Color(0xFFF1EBFF);
  static const Color raspberryLight = Color(0xFFFCE8F0);
  static const Color tomatoLight = Color(0xFFFEECEB);

  // ─── Luxury Metallic Accents (MARS Gold / VIP) ─────────────────────────────
  static const Color gold = Color(0xFFD4AF37); // Classic Champagne Gold
  static const Color goldLight = Color(0xFFFEF3C7);
  static const Color goldDark = Color(0xFFB45309);
  static const List<Color> goldGradient = [
    Color(0xFFF59E0B),
    Color(0xFFD97706),
    Color(0xFFB45309),
  ];

  // ─── Surfaces & Luxury Glass ───────────────────────────────────────────────
  static const Color background =
      Color(0xFFF7F5F1); // Crisp, ultra-clean modern canvas
  static const Color surface = Color(0xFFFFFFFF); // Pristine white card surface
  static const Color surfaceWarm =
      Color(0xFFFAF7F3); // Warm linen editorial card tint
  static const Color surfaceVariant =
      Color(0xFFF3F4F6); // Soft neutral background for pills/inputs
  static const Color cardBorder =
      Color(0xFFE9E5DF); // Subtle, ultra-clean card border
  static const Color divider = Color(0xFFECE8E2); // Crisp divider line

  // Glassmorphic translucent surfaces
  static const Color glassWhite = Color(0xCCFFFFFF);
  static const Color glassDark = Color(0xDD0F1016);
  static const Color glassBorder = Color(0x1F000000);

  // ─── Hyperlocal Indicators (Zomato / Swiggy standard) ──────────────────────
  static const Color ratingGreen =
      Color(0xFF15803D); // High-trust emerald rating badge
  static const Color ratingGold = Color(0xFFF59E0B);
  static const Color fastDelivery = Color(0xFFE11D48); // Flash delivery badge
  static const Color liveEmerald = Color(0xFF10B981); // Pulse beacon green

  // ─── Typography ────────────────────────────────────────────────────────────
  static const Color textPrimary = Color(0xFF0F1016);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textHint = Color(0xFF94A3B8);
  static const Color textOnDark = Color(0xFFF8FAFC);

  // ─── Status ────────────────────────────────────────────────────────────────
  static const Color success = Color(0xFF16A34A);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFF04438);
  static const Color info = Color(0xFF6366F1);

  // Order status colors
  static const Color statusPending = Color(0xFFF59E0B);
  static const Color statusConfirmed = Color(0xFF6366F1);
  static const Color statusPreparing = Color(0xFFA78BFA);
  static const Color statusReady = Color(0xFFD93670);
  static const Color statusPickedUp = Color(0xFFF04438);
  static const Color statusDelivered = Color(0xFF16A34A);
  static const Color statusCancelled = Color(0xFFDC2626);

  // ─── Ambient Multi-Layer Shadows ───────────────────────────────────────────
  static const Color shadow = Color(0x0A0F1016);
  static const Color shadowMedium = Color(0x120F1016);
  static const Color shadowGlow = Color(0x22D93670);
  static const Color shimmerBase = Color(0xFFF1F2F6);
  static const Color shimmerHighlight = Color(0xFFFFFFFF);
}
