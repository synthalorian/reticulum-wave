import 'package:flutter/material.dart';

/// Synthwave '84 color palette for Reticulum Wave.
/// Deep purples, electric accents, neon highlights — matching the omarchy desktop theme.
class AppColors {
  AppColors._();

  // Core deep purples
  static const Color deepPurple = Color(0xFF240037);
  static const Color electricPurple = Color(0xFF8F00FF);
  static const Color darkBackground = Color(0xFF1A0B2E);
  static const Color surface = Color(0xFF2D1B4E);

  // Neon accents
  static const Color hotPink = Color(0xFFFF7EDB);
  static const Color magenta = Color(0xFFFF00FF);
  static const Color neonYellow = Color(0xFFF3E70F);
  static const Color cyan = Color(0xFF00F0FF);

  // Functional
  static const Color online = Color(0xFF00FF88);
  static const Color offline = Color(0xFFFF4444);
  static const Color warning = Color(0xFFFFAA00);
  static const Color textPrimary = Color(0xFFF0E6FF);
  static const Color textSecondary = Color(0xFFB8A9C9);
  static const Color divider = Color(0xFF3D2B5E);
}

/// App theme configuration — Material 3 with synthwave dark palette.
class AppTheme {
  AppTheme._();

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.electricPurple,
        onPrimary: Colors.white,
        secondary: AppColors.hotPink,
        onSecondary: Colors.white,
        surface: AppColors.surface,
        onSurface: AppColors.textPrimary,
        error: AppColors.offline,
        onError: Colors.white,
        surfaceContainerHighest: AppColors.deepPurple,
        outline: AppColors.divider,
      ),
      scaffoldBackgroundColor: AppColors.darkBackground,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.deepPurple,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
          letterSpacing: 0.5,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.deepPurple,
        selectedItemColor: AppColors.neonYellow,
        unselectedItemColor: AppColors.textSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      cardTheme: const CardThemeData(
        color: AppColors.surface,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.electricPurple,
        foregroundColor: Colors.white,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.deepPurple,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.divider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.electricPurple, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.divider,
        thickness: 1,
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
        headlineMedium: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        titleLarge: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
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
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.electricPurple,
        ),
      ),
    );
  }
}
