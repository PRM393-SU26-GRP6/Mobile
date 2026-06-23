import 'package:flutter/material.dart';

class AppColors {
  // Header / primary green
  static const Color primary = Color(0xFF0FA24A);
  // Page background (light)
  static const Color secondary = Color(0xFFF6FFF4);
  // Accent / buttons (darker green)
  static const Color accent = Color(0xFF0A7A36);
  static const Color textPrimary = Color(0xFF083118);
  static const Color textSecondary = Color(0xFF6B7A6D);
  static const Color inputBackground = Color(0xFFFFFFFF);
  static const Color inputBorder = Color(0xFFE6F2EA);
  static const Color buttonGradientStart = Color(0xFF18C66C);
  static const Color buttonGradientEnd = Color(0xFF0FA24A);
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.secondary,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      colorScheme: ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.accent,
        surface: Colors.white,
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
        headlineMedium: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          color: AppColors.textPrimary,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}
