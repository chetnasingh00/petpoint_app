// lib/theme.dart
import 'package:flutter/material.dart';

class AppColors {
  // New pastel palette
  static const Color pastelBlue = Color(0xFF9ECFFC); // soft pastel blue
  static const Color pastelYellow = Color(0xFFFFE4A3); // warm pastel yellow
  static const Color softTeal = Color(0xFF7FC6B7);
  static const Color bg = Color(0xFFF6F8FB); // very light
  static const Color card = Color(0xFFFFFFFF);
  static const Color muted = Color(0xFF6B7280);

  // Backwards-compatible aliases for screens that reference older names
  static const Color primaryBlue = pastelBlue;
  static const Color accentYellow = pastelYellow;
  static const Color teal = softTeal;
}

class AppTheme {
  static ThemeData pastel() {
    final base = ThemeData.light();
    return base.copyWith(
      scaffoldBackgroundColor: AppColors.bg,
      primaryColor: AppColors.pastelBlue,
      colorScheme: base.colorScheme.copyWith(
        primary: AppColors.pastelBlue,
        secondary: AppColors.pastelYellow,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.pastelBlue,
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      textTheme: base.textTheme.copyWith(
        headlineSmall: const TextStyle(fontSize: 26, fontWeight: FontWeight.w700, color: Colors.black87),
        titleLarge: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
        bodyMedium: const TextStyle(fontSize: 16, color: AppColors.muted),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.pastelBlue,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          minimumSize: const Size(140, 48),
          elevation: 4,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: AppColors.pastelBlue, width: 1.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          foregroundColor: AppColors.pastelBlue,
          minimumSize: const Size(140, 48),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.card,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      ),
    );
  }
}