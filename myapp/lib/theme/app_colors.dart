// lib/theme/app_colors.dart
import 'package:flutter/material.dart';

class AppColors {
  // Primary colors
  static const Color primary = Color(0xFF66B3FF);
  static const Color secondary = Color(0xFF1E293B);

  // Background colors
  static const Color background = Colors.white;
  static const Color surface = Color(0xFFF8FAFF);

  // Text colors
  static const Color text = Colors.black;
  static const Color caption = Color(0xFF858585);

  // Status colors
  static const Color success = Color(0xFF00C853);
  static const Color error = Color(0xFFEE5253);
  static const Color warning = Color(0xFFFFB74D);
  static const Color inactive = Color(0xFFE2E8F0);

  // Border & Divider
  static const Color border = Color(0xFFE2E8F0);
  static const Color divider = Color(0xFFEEF2F6);

  // Role-specific gradients
  static const Map<String, LinearGradient> cardGradients = {
    'passenger': LinearGradient(
      colors: [Color(0xFF0286FF), Color(0xFF0267CC)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    'driver': LinearGradient(
      colors: [Color(0xFF00C853), Color(0xFF009624)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    'vendor': LinearGradient(
      colors: [Color(0xFFFF6B6B), Color(0xFFEE5253)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
  };
}
