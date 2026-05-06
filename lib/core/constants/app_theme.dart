import 'package:flutter/material.dart';

/// App-wide theme constants, using an AMOLED-friendly dark palette.
class AppTheme {
  AppTheme._();

  // ── Colours ─────────────────────────────────────────────────────────────────
  static const Color background = Color(0xFF000000);
  static const Color surface = Color(0xFF121212);
  static const Color surfaceVariant = Color(0xFF1E1E1E);
  static const Color cardColor = Color(0xFF1A1A1A);
  static const Color dividerColor = Color(0xFF2C2C2C);

  static const Color primary = Color(0xFF00BCD4); // cyan accent
  static const Color primaryVariant = Color(0xFF0097A7);
  static const Color secondary = Color(0xFF80CBC4);
  static const Color error = Color(0xFFCF6679);

  static const Color onBackground = Color(0xFFEEEEEE);
  static const Color onSurface = Color(0xFFE0E0E0);
  static const Color onSurfaceMuted = Color(0xFF9E9E9E);
  static const Color onPrimary = Color(0xFF000000);

  // ── Radius ───────────────────────────────────────────────────────────────────
  static const double radiusSmall = 6.0;
  static const double radiusMedium = 12.0;
  static const double radiusLarge = 20.0;

  // ── Spacing ──────────────────────────────────────────────────────────────────
  static const double spaceXS = 4.0;
  static const double spaceS = 8.0;
  static const double spaceM = 16.0;
  static const double spaceL = 24.0;
  static const double spaceXL = 32.0;

  // ── Text Styles ──────────────────────────────────────────────────────────────
  static const TextStyle displayLarge = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: onBackground,
    letterSpacing: -0.5,
  );

  static const TextStyle titleLarge = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: onBackground,
  );

  static const TextStyle titleMedium = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: onBackground,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontSize: 14,
    color: onSurface,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    color: onSurfaceMuted,
  );

  static const TextStyle labelMedium = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    color: primary,
    letterSpacing: 0.4,
  );

  // ── Material Theme ───────────────────────────────────────────────────────────
  static ThemeData get darkTheme {
    final base = ThemeData.dark(useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: background,
      colorScheme: const ColorScheme.dark(
        primary: primary,
        onPrimary: onPrimary,
        secondary: secondary,
        surface: surface,
        onSurface: onSurface,
        error: error,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: background,
        foregroundColor: onBackground,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: titleLarge,
      ),
      cardTheme: CardThemeData(
        color: cardColor,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          side: const BorderSide(color: dividerColor, width: 0.5),
        ),
        margin: const EdgeInsets.symmetric(horizontal: spaceM, vertical: spaceXS),
      ),
      dividerTheme: const DividerThemeData(
        color: dividerColor,
        thickness: 0.5,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceVariant,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: const BorderSide(color: primary, width: 1.5),
        ),
        hintStyle: const TextStyle(color: onSurfaceMuted),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: spaceM,
          vertical: spaceS,
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primary,
        foregroundColor: onPrimary,
        elevation: 4,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: surfaceVariant,
        contentTextStyle: const TextStyle(color: onSurface),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusSmall)),
        behavior: SnackBarBehavior.floating,
      ),
      iconTheme: const IconThemeData(color: onSurface),
    );
  }
}
