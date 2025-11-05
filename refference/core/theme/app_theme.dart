import 'package:flutter/material.dart';
import 'color_palette.dart';

class AppTheme {
  // Light Theme
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.light(
        primary: ColorPalette.primary,
        primaryContainer: ColorPalette.primaryLightest,
        secondary: ColorPalette.accent,
        secondaryContainer: ColorPalette.accentLightest,
        surface: ColorPalette.surfaceLight,
        background: ColorPalette.backgroundLight,
        error: ColorPalette.error,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: ColorPalette.textPrimary,
        onBackground: ColorPalette.textPrimary,
        onError: Colors.white,
      ),
      scaffoldBackgroundColor: ColorPalette.backgroundLight,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: ColorPalette.textPrimary),
      ),
      textTheme: _textTheme(ColorPalette.textPrimary),
      iconTheme: const IconThemeData(
        color: ColorPalette.textSecondary,
        size: 24,
      ),
    );
  }

  // Dark Theme
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.dark(
        primary: ColorPalette.primaryLight,
        primaryContainer: ColorPalette.primaryDark,
        secondary: ColorPalette.accentLight,
        secondaryContainer: ColorPalette.accentDark,
        surface: ColorPalette.surfaceDark,
        background: ColorPalette.backgroundDark,
        error: ColorPalette.error,
        onPrimary: Colors.black,
        onSecondary: Colors.black,
        onSurface: ColorPalette.textPrimaryDark,
        onBackground: ColorPalette.textPrimaryDark,
        onError: Colors.white,
      ),
      scaffoldBackgroundColor: ColorPalette.backgroundDark,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: ColorPalette.textPrimaryDark),
      ),
      textTheme: _textTheme(ColorPalette.textPrimaryDark),
      iconTheme: const IconThemeData(
        color: ColorPalette.textSecondaryDark,
        size: 24,
      ),
    );
  }

  static TextTheme _textTheme(Color baseColor) {
    return TextTheme(
      // Display (Headlines)
      displayLarge: TextStyle(
        fontSize: 57,
        fontWeight: FontWeight.w700,
        color: baseColor,
        letterSpacing: -0.5,
        height: 1.2,
      ),
      displayMedium: TextStyle(
        fontSize: 45,
        fontWeight: FontWeight.w600,
        color: baseColor,
        letterSpacing: -0.3,
        height: 1.2,
      ),
      displaySmall: TextStyle(
        fontSize: 36,
        fontWeight: FontWeight.w600,
        color: baseColor,
        letterSpacing: 0,
        height: 1.2,
      ),
      // Headlines
      headlineLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.w600,
        color: baseColor,
        letterSpacing: 0,
        height: 1.3,
      ),
      headlineMedium: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        color: baseColor,
        letterSpacing: 0,
        height: 1.3,
      ),
      headlineSmall: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: baseColor,
        letterSpacing: 0,
        height: 1.3,
      ),
      // Body
      bodyLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: baseColor,
        letterSpacing: 0.15,
        height: 1.5,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: baseColor,
        letterSpacing: 0.25,
        height: 1.5,
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: baseColor,
        letterSpacing: 0.4,
        height: 1.5,
      ),
      // Labels
      labelLarge: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: baseColor,
        letterSpacing: 0.1,
        height: 1.4,
      ),
      labelMedium: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: baseColor,
        letterSpacing: 0.5,
        height: 1.4,
      ),
      labelSmall: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: baseColor,
        letterSpacing: 0.5,
        height: 1.4,
      ),
    );
  }
}
