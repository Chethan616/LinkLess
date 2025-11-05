// Minimal shim for `liquid_glass_renderer` used by the example project.
// This file provides lightweight, pass-through implementations of the
// symbols the example imports. It's intended only to make the example
// compile when the real package is not available at the path in
// `pubspec.yaml` (e.g. `path: ../`).

import 'package:flutter/material.dart';

class LgrLogs {
  static void initAllLogs() {}
}

class LiquidGlassSettings {
  final double thickness;
  final double blur;
  final double lightIntensity;
  final double ambientStrength;
  final double chromaticAberration;
  final double saturation;
  final double refractiveIndex;
  final Color? glassColor;
  final double? depth;
  final double? refraction;
  final double? lightAngle;
  final double? visibility;
  final double? dispersion;
  final double? frost;

  const LiquidGlassSettings({
    this.thickness = 40.0,
    this.blur = 10.0,
    this.lightIntensity = 1.0,
    this.ambientStrength = 1.0,
    this.chromaticAberration = 0.0,
    this.saturation = 1.0,
    this.refractiveIndex = 1.33,
    this.glassColor,
    this.depth,
    this.refraction,
    this.lightAngle,
    this.visibility,
    this.dispersion,
    this.frost,
  });

  factory LiquidGlassSettings.figma({
    double depth = 0,
    double refraction = 0,
    double lightAngle = 0,
    double dispersion = 0,
    double frost = 0,
    Color? glassColor,
  }) {
    return LiquidGlassSettings(
      depth: depth,
      refraction: refraction,
      lightAngle: lightAngle,
      dispersion: dispersion,
      frost: frost,
      glassColor: glassColor,
    );
  }

  LiquidGlassSettings copyWith({
    double? thickness,
    double? blur,
    double? lightIntensity,
    double? ambientStrength,
    double? chromaticAberration,
    double? saturation,
    double? refractiveIndex,
    Color? glassColor,
    double? lightAngle,
    double? visibility,
  }) {
    return LiquidGlassSettings(
      thickness: thickness ?? this.thickness,
      blur: blur ?? this.blur,
      lightIntensity: lightIntensity ?? this.lightIntensity,
      ambientStrength: ambientStrength ?? this.ambientStrength,
      chromaticAberration: chromaticAberration ?? this.chromaticAberration,
      saturation: saturation ?? this.saturation,
      refractiveIndex: refractiveIndex ?? this.refractiveIndex,
      glassColor: glassColor ?? this.glassColor,
      lightAngle: lightAngle ?? this.lightAngle,
      visibility: visibility ?? this.visibility,
    );
  }
}

extension _ColorWithValues on Color {
  Color withValues({required double alpha}) => withOpacity(alpha);
}

class LiquidGlassLayer extends StatelessWidget {
  final Widget child;
  final LiquidGlassSettings? settings;
  final bool? fake;

  const LiquidGlassLayer({
    Key? key,
    required this.child,
    this.settings,
    this.fake,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => child;
}

class LiquidGlassBlendGroup extends StatelessWidget {
  final Widget child;
  final double? blend;

  const LiquidGlassBlendGroup({Key? key, required this.child, this.blend})
    : super(key: key);

  @override
  Widget build(BuildContext context) => child;
}

class LiquidStretch extends StatelessWidget {
  final Widget child;
  final double? interactionScale;
  final double? stretch;

  const LiquidStretch({
    Key? key,
    required this.child,
    this.interactionScale,
    this.stretch,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => child;
}

class GlassGlow extends StatelessWidget {
  final Widget child;

  const GlassGlow({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) => child;
}

class LiquidGlass extends StatelessWidget {
  final Widget? child;
  final Object? shape;

  const LiquidGlass({Key? key, this.shape, this.child}) : super(key: key);

  static Widget grouped({
    required Widget child,
    LiquidGlassSettings? settings,
    Object? shape,
    Clip? clipBehavior,
  }) {
    return LiquidGlass(shape: shape, child: child);
  }

  static Widget withOwnLayer({
    required Widget child,
    LiquidGlassSettings? settings,
    Object? shape,
    bool? fake,
  }) {
    return LiquidGlass(shape: shape, child: child);
  }

  @override
  Widget build(BuildContext context) => child ?? const SizedBox.shrink();
}

class LiquidRoundedSuperellipse extends ShapeBorder {
  final double borderRadius;
  const LiquidRoundedSuperellipse({this.borderRadius = 0});

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.zero;

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) =>
      getOuterPath(rect, textDirection: textDirection);

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    return Path()
      ..addRRect(RRect.fromRectAndRadius(rect, Radius.circular(borderRadius)));
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {}

  @override
  ShapeBorder scale(double t) =>
      LiquidRoundedSuperellipse(borderRadius: borderRadius * t);
}

class LiquidOval extends ShapeBorder {
  const LiquidOval();

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.zero;

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) =>
      getOuterPath(rect, textDirection: textDirection);

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    return Path()..addOval(rect);
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {}

  @override
  ShapeBorder scale(double t) => const LiquidOval();
}
