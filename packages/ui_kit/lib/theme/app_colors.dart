import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Brand
  static const Color primary       = Color(0xFF1A1A2E);  // Deep Navy
  static const Color primaryLight  = Color(0xFF16213E);
  static const Color accent        = Color(0xFFE94560);  // Vibrant Red-Pink
  static const Color accentLight   = Color(0xFFFF6B8A);

  // Surface
  static const Color background    = Color(0xFFF8F9FA);
  static const Color surface       = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF1F3F5);

  // Text
  static const Color textPrimary   = Color(0xFF1A1A2E);
  static const Color textSecondary = Color(0xFF6C757D);
  static const Color textHint      = Color(0xFFADB5BD);
  static const Color textOnDark    = Color(0xFFFFFFFF);

  // Status
  static const Color success       = Color(0xFF2ECC71);
  static const Color warning       = Color(0xFFF39C12);
  static const Color error         = Color(0xFFE74C3C);
  static const Color info          = Color(0xFF3498DB);

  // Order status colors
  static const Color statusPending     = Color(0xFFF39C12);
  static const Color statusConfirmed   = Color(0xFF3498DB);
  static const Color statusPreparing   = Color(0xFF9B59B6);
  static const Color statusReady       = Color(0xFF1ABC9C);
  static const Color statusPickedUp    = Color(0xFF2ECC71);
  static const Color statusDelivered   = Color(0xFF27AE60);
  static const Color statusCancelled   = Color(0xFFE74C3C);

  // Misc
  static const Color divider       = Color(0xFFDEE2E6);
  static const Color shadow        = Color(0x1A000000);
  static const Color shimmerBase   = Color(0xFFE0E0E0);
  static const Color shimmerHighlight = Color(0xFFF5F5F5);
}
