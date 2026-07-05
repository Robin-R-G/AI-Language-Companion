// lib/shared/theme/app_theme.dart
import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Brand colors
  static const primary = Color(0xFF4A90D9);
  static const primaryDark = Color(0xFF357ABD);
  static const primaryLight = Color(0xFF6BA5E1);

  // Background
  static const background = Color(0xFFF8F9FA);
  static const surface = Color(0xFFFFFFFF);
  static const surfaceVariant = Color(0xFFF1F3F5);

  // Text
  static const textPrimary = Color(0xFF212529);
  static const textSecondary = Color(0xFF6C757D);
  static const textTertiary = Color(0xFFADB5BD);

  // Borders
  static const border = Color(0xFFDEE2E6);

  // Status
  static const success = Color(0xFF28A745);
  static const error = Color(0xFFDC3545);
  static const warning = Color(0xFFFFC107);
  static const warningDark = Color(0xFFE0A800);
  static const info = Color(0xFF17A2B8);

  // Skill colors
  static const grammar = Color(0xFF6C63FF);
  static const grammarDark = Color(0xFF524BCC);
  static const vocabulary = Color(0xFF28A745);
  static const vocabularyDark = Color(0xFF1E7E34);
  static const speaking = Color(0xFFFF6B6B);
  static const speakingDark = Color(0xFFEE5A5A);
  static const writing = Color(0xFFFFB347);
  static const writingDark = Color(0xFFFFA332);
  static const reading = Color(0xFF4ECDC4);
  static const readingDark = Color(0xFF3DBEB6);
  static const listening = Color(0xFF9B59B6);
  static const listeningDark = Color(0xFF8544A0);
}

class AppTextStyles {
  AppTextStyles._();

  static const headingLarge = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  static const headingMedium = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const headingSmall = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary,
  );

  static const bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary,
  );

  static const bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondary,
  );
}

class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: AppColors.background,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        centerTitle: true,
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceVariant,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }
}
