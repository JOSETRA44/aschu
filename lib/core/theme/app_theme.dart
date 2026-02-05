import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Single Source of Truth for App Theming
class AppTheme {
  AppTheme._();

  // Core Color Palette
  static const Color electricAmber = Color(0xFFFFB300);
  static const Color scaffoldBackground = Color(0xFF0C0C0C);
  static const Color surfaceColor = Color(0xFF1A1A1A);
  static const Color errorColor = Color(0xFFFF5252);
  static const Color onPrimary = Color(0xFF000000);
  static const Color onSurface = Color(0xFFFFFFFF);

  /// Dark Theme (Default)
  static ThemeData get darkTheme {
    final colorScheme = const ColorScheme.dark(
      primary: electricAmber,
      secondary: electricAmber,
      surface: surfaceColor,
      error: errorColor,
      onPrimary: onPrimary,
      onSecondary: onPrimary,
      onSurface: onSurface,
      onError: onSurface,
      brightness: Brightness.dark,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: scaffoldBackground,

      // Typography
      textTheme: GoogleFonts.interTextTheme(
        ThemeData.dark().textTheme.apply(
          bodyColor: onSurface,
          displayColor: onSurface,
        ),
      ),

      // AppBar Theme
      appBarTheme: AppBarTheme(
        backgroundColor: surfaceColor,
        foregroundColor: onSurface,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: onSurface,
        ),
      ),

      // FloatingActionButton Theme
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: electricAmber,
        foregroundColor: onPrimary,
        elevation: 4,
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceColor,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: electricAmber, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: errorColor, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: errorColor, width: 2),
        ),
        labelStyle: const TextStyle(color: onSurface),
        hintStyle: TextStyle(color: onSurface.withOpacity(0.5)),
      ),

      // Card Theme
      cardTheme: CardThemeData(
        color: surfaceColor,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),

      // Icon Theme
      iconTheme: const IconThemeData(color: onSurface),

      // Divider Theme
      dividerTheme: DividerThemeData(
        color: onSurface.withOpacity(0.1),
        thickness: 1,
      ),
    );
  }
}
