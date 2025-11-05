import 'package:flutter/material.dart';

/// Linkless Color Palette
/// Professional color system for liquid glass UI
class ColorPalette {
  // Primary Palette - Deep Blue Family (Trust & Stability)
  static const Color primaryDark = Color(0xFF0A2463);
  static const Color primary = Color(0xFF1E3A8A);
  static const Color primaryLight = Color(0xFF3B82F6);
  static const Color primaryLightest = Color(0xFFDCEFFE);

  // Accent Palette - Orange Family (Energy & Action)
  static const Color accentDark = Color(0xFFE85527);
  static const Color accent = Color(0xFFFF6B35);
  static const Color accentLight = Color(0xFFFF8C61);
  static const Color accentLightest = Color(0xFFFFE8E0);

  // Neutral Palette - Light Theme
  static const Color white = Color(0xFFFFFFFF);
  static const Color surfaceLight = Color(0xFFFAFAFA);
  static const Color backgroundLight = Color(0xFFF5F5F5);
  static const Color borderLight = Color(0xFFE5E5E5);

  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF666666);
  static const Color textTertiary = Color(0xFF999999);
  static const Color textDisabled = Color(0xFFCCCCCC);

  // Neutral Palette - Dark Theme (AMOLED)
  static const Color black = Color(0xFF000000);
  static const Color surfaceDark = Color(0xFF000000);
  static const Color backgroundDark = Color(0xFF000000);
  static const Color borderDark = Color(0xFF1A1A1A);

  static const Color textPrimaryDark = Color(0xFFFAFAFA);
  static const Color textSecondaryDark = Color(0xFFB3B3B3);
  static const Color textTertiaryDark = Color(0xFF808080);
  static const Color textDisabledDark = Color(0xFF4D4D4D);

  // Semantic Colors
  static const Color success = Color(0xFF10B981);
  static const Color successLight = Color(0xFFD1FAE5);

  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFEF3C7);

  static const Color error = Color(0xFFEF4444);
  static const Color errorLight = Color(0xFFFEE2E2);

  static const Color info = Color(0xFF3B82F6);
  static const Color infoLight = Color(0xFFDBEAFE);

  // SMS Status Colors
  static const Color smsIdle = Color(0xFF94A3B8);
  static const Color smsRequesting = Color(0xFF8B5CF6);
  static const Color smsSending = Color(0xFF8B5CF6); // Same as requesting
  static const Color smsReceiving = Color(0xFF06B6D4);
  static const Color smsProcessing = Color(0xFFF59E0B);
  static const Color smsComplete = Color(0xFF10B981);
  static const Color smsError = Color(0xFFEF4444);

  // Liquid Glass Specific Colors
  static Color glassLight = white.withOpacity(0.2);
  static Color glassDark = const Color(0xFF1E1E1E).withOpacity(0.6);

  static Color glowPrimary = primaryLight.withOpacity(0.6);
  static Color glowAccent = accent.withOpacity(0.6);
}
