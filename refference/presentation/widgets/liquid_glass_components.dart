import 'dart:math' as math;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../core/liquid_glass/liquid_glass.dart';
import '../../core/theme/color_palette.dart';

/// Liquid Glass Button with beautiful press effects
class LiquidGlassButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  final IconData? icon;
  final bool isPrimary;
  final bool isLoading;
  final double? width;
  final double height;

  const LiquidGlassButton({
    super.key,
    required this.text,
    required this.onTap,
    this.icon,
    this.isPrimary = true,
    this.isLoading = false,
    this.width,
    this.height = 56,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final glassSettings = LiquidGlassSettings(
      refractiveIndex: 1.21,
      thickness: 30,
      blur: 8,
      saturation: 1.5,
      lightIntensity: isDark ? 0.7 : 1.0,
      ambientStrength: isDark ? 0.2 : 0.5,
      lightAngle: math.pi / 4,
      glassColor: isPrimary
          ? ColorPalette.primary.withOpacity(0.3)
          : (isDark ? ColorPalette.glassDark : ColorPalette.glassLight),
    );

    return LiquidStretch(
      child: GestureDetector(
        onTap: isLoading ? null : onTap,
        child: LiquidGlass.grouped(
          settings: glassSettings,
          shape: const LiquidRoundedSuperellipse(borderRadius: 16),
          child: GlassGlow(
            child: Container(
              width: width,
              height: height,
              decoration: BoxDecoration(
                gradient: isPrimary
                    ? LinearGradient(
                        colors: [
                          ColorPalette.primary.withOpacity(0.8),
                          ColorPalette.primaryLight.withOpacity(0.6),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: isLoading
                    ? const CupertinoActivityIndicator(color: Colors.white)
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (icon != null) ...[
                            Icon(
                              icon,
                              color: isPrimary
                                  ? Colors.white
                                  : ColorPalette.primary,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                          ],
                          Text(
                            text,
                            style: Theme.of(context)
                                .textTheme
                                .labelLarge
                                ?.copyWith(
                                  color: isPrimary
                                      ? Colors.white
                                      : (isDark
                                          ? ColorPalette.textPrimaryDark
                                          : ColorPalette.textPrimary),
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Liquid Glass Card for content
class LiquidGlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double? width;
  final double? height;
  final VoidCallback? onTap;

  const LiquidGlassCard({
    super.key,
    required this.child,
    this.padding,
    this.width,
    this.height,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final glassSettings = LiquidGlassSettings(
      refractiveIndex: 1.15,
      thickness: 25,
      blur: 10,
      saturation: 1.3,
      lightIntensity: isDark ? 0.6 : 0.9,
      ambientStrength: isDark ? 0.3 : 0.6,
      lightAngle: math.pi / 4,
      glassColor: isDark ? ColorPalette.glassDark : ColorPalette.glassLight,
    );

    return LiquidStretch(
      child: GestureDetector(
        onTap: onTap,
        behavior: onTap != null
            ? HitTestBehavior.opaque
            : HitTestBehavior.deferToChild,
        child: LiquidGlass.grouped(
          settings: glassSettings,
          shape: const LiquidRoundedSuperellipse(borderRadius: 20),
          child: GlassGlow(
            child: Container(
              width: width,
              height: height,
              padding: padding ?? const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: (isDark
                        ? ColorPalette.surfaceDark
                        : ColorPalette.surfaceLight)
                    .withOpacity(0.3),
                borderRadius: BorderRadius.circular(20),
              ),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

/// Liquid Glass Text Input Field
class LiquidGlassTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? hintText;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixTap;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final TextInputType? keyboardType;
  final bool obscureText;

  const LiquidGlassTextField({
    super.key,
    this.controller,
    this.hintText,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixTap,
    this.onChanged,
    this.onSubmitted,
    this.keyboardType,
    this.obscureText = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final glassSettings = LiquidGlassSettings(
      refractiveIndex: 1.18,
      thickness: 20,
      blur: 6,
      saturation: 1.4,
      lightIntensity: isDark ? 0.5 : 0.8,
      ambientStrength: isDark ? 0.25 : 0.55,
      lightAngle: math.pi / 4,
      glassColor: isDark ? ColorPalette.glassDark : ColorPalette.glassLight,
    );

    return LiquidGlass.grouped(
      settings: glassSettings,
      shape: const LiquidRoundedSuperellipse(borderRadius: 16),
      child: Container(
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: (isDark ? ColorPalette.surfaceDark : ColorPalette.surfaceLight)
              .withOpacity(0.4),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            if (prefixIcon != null) ...[
              Icon(
                prefixIcon,
                color: isDark
                    ? ColorPalette.textSecondaryDark
                    : ColorPalette.textSecondary,
                size: 20,
              ),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Material(
                color: Colors.transparent,
                child: TextField(
                  controller: controller,
                  onChanged: onChanged,
                  onSubmitted: onSubmitted,
                  keyboardType: keyboardType,
                  obscureText: obscureText,
                  style: Theme.of(context).textTheme.bodyLarge,
                  decoration: InputDecoration(
                    hintText: hintText,
                    hintStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: isDark
                              ? ColorPalette.textTertiaryDark
                              : ColorPalette.textTertiary,
                        ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
            ),
            if (suffixIcon != null) ...[
              const SizedBox(width: 12),
              GestureDetector(
                onTap: onSuffixTap,
                child: Icon(suffixIcon, color: ColorPalette.primary, size: 20),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Liquid Glass Icon Button
class LiquidGlassIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final double size;
  final Color? iconColor;
  final Color? backgroundColor;

  const LiquidGlassIconButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.size = 48,
    this.iconColor,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final glassSettings = LiquidGlassSettings(
      refractiveIndex: 1.2,
      thickness: 25,
      blur: 8,
      saturation: 1.4,
      lightIntensity: isDark ? 0.6 : 0.9,
      ambientStrength: isDark ? 0.25 : 0.5,
      lightAngle: math.pi / 4,
      glassColor: backgroundColor?.withOpacity(0.3) ??
          (isDark ? ColorPalette.glassDark : ColorPalette.glassLight),
    );

    return LiquidStretch(
      child: GestureDetector(
        onTap: () {
          print('🔴 LiquidGlassIconButton tapped!'); // Debug log
          onTap();
        },
        child: LiquidGlass.grouped(
          settings: glassSettings,
          shape: const LiquidOval(),
          child: GlassGlow(
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: backgroundColor?.withOpacity(0.2),
              ),
              child: Center(
                child: Icon(
                  icon,
                  color: iconColor ??
                      (isDark
                          ? ColorPalette.textPrimaryDark
                          : ColorPalette.textPrimary),
                  size: size * 0.5,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
