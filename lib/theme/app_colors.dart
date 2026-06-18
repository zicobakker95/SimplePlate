import 'package:flutter/material.dart';

/// PlateSimple brand palette — clean, food-positive greens on dark.
class AppColors {
  AppColors._();

  // Brand
  static const Color primary = Color(0xFF16A34A); // green-600
  static const Color primaryDark = Color(0xFF15803D); // green-700
  static const Color accent = Color(0xFF22C55E); // green-500
  static const Color accentSoft = Color(0xFFBBF7D0); // green-200

  // Surfaces
  static const Color background = Color(0xFF0B0F0C);
  static const Color surface = Color(0xFF141A16);
  static const Color surfaceAlt = Color(0xFF1C241E);
  static const Color border = Color(0xFF2A3830);

  // Text
  static const Color textPrimary = Color(0xFFEDF2EE);
  static const Color textSecondary = Color(0xFFA1B5A6);
  static const Color textMuted = Color(0xFF6B806F);

  // Macro colours
  static const Color protein = Color(0xFF3B82F6); // blue
  static const Color carbs = Color(0xFFF59E0B); // amber
  static const Color fat = Color(0xFFEF4444); // red
  static const Color calories = Color(0xFF22C55E); // green

  // Semantic
  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFF59E0B);
  static const Color danger = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  static const LinearGradient brandGradient = LinearGradient(
    colors: [Color(0xFF16A34A), Color(0xFF22C55E)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
