import 'package:flutter/material.dart';

/// Color definitions for Linkless Browser
/// Following the exact specifications from app.md
class AppColors {
  // Dark Mode Colors
  static const Color darkBackground = Color(
    0xFF000000,
  ); // True black for AMOLED
  static const Color darkPrimary = Color(0xFFB3FF9D); // Bright green
  static const Color darkText = Color(0xFFFFFFFF); // White text

  // Light Mode Colors
  static const Color lightBackground = Color(0xFFFFFFFF); // Pure white
  static const Color lightPrimary = Color(0xFF07BDFF); // Bright blue
  static const Color lightText = Color(0xFF000000); // Black text

  // Common colors
  static const Color error = Color(0xFFFF5252);
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFC107);

  // Text colors with opacity
  static const Color darkTextSecondary = Color(0xFFB0B0B0);
  static const Color lightTextSecondary = Color(0xFF666666);
}
