import 'package:flutter/material.dart';

/// Unslopped Design Tokens based on heydamir/unslop specifications:
/// - 4px spacing scale
/// - Nested border radii (inner = outer - padding, never < 4)
/// - Neutral depth (no colored glows or neon auras)
/// - Unified cubic-bezier(0.22, 1, 0.36, 1) easing curve
class DesignTokens {
  // Spacing Scale (strict 4px grid)
  static const double space2 = 2.0;
  static const double space4 = 4.0;
  static const double space6 = 6.0;
  static const double space8 = 8.0;
  static const double space10 = 10.0;
  static const double space12 = 12.0;
  static const double space16 = 16.0;
  static const double space20 = 20.0;
  static const double space24 = 24.0;
  static const double space32 = 32.0;
  static const double space40 = 40.0;
  static const double space48 = 48.0;
  static const double space64 = 64.0;

  // Semantic spacing aliases
  static const double spacingXs = space4;
  static const double spacingSm = space8;
  static const double spacingMd = space16;
  static const double spacingLg = space24;
  static const double spacingXl = space32;

  // Nested Corner Radii
  // Keycaps/tags: 6px, Rows/Inputs/Buttons: 8-10px, Cards: 12-14px, Panels: 16-20px
  static const double radiusXs = 4.0;
  static const double radiusSm = 6.0;
  static const double radiusMd = 8.0;
  static const double radiusLg = 12.0;
  static const double radiusXl = 16.0;
  static const double radiusFull = 9999.0;

  static const BorderRadius borderXs = BorderRadius.all(Radius.circular(radiusXs));
  static const BorderRadius borderSm = BorderRadius.all(Radius.circular(radiusSm));
  static const BorderRadius borderMd = BorderRadius.all(Radius.circular(radiusMd));
  static const BorderRadius borderLg = BorderRadius.all(Radius.circular(radiusLg));
  static const BorderRadius borderXl = BorderRadius.all(Radius.circular(radiusXl));
  static const BorderRadius borderFull = BorderRadius.all(Radius.circular(radiusFull));

  // Glassmorphism Blur (toned down to subtle calm backdrop filters)
  static const double blurSubtle = 4.0;
  static const double blurStandard = 8.0;
  static const double blurHeavy = 16.0;

  // Motion Durations & Easing
  // Standard curve: cubic-bezier(0.22, 1, 0.36, 1)
  static const Curve easeOutStandard = Cubic(0.22, 1.0, 0.36, 1.0);
  static const Duration durationFast = Duration(milliseconds: 140);
  static const Duration durationNormal = Duration(milliseconds: 200);
  static const Duration durationSlow = Duration(milliseconds: 320);

  // Responsive Breakpoints
  static const double breakpointMobile = 640.0;
  static const double breakpointTablet = 1024.0;
  static const double breakpointDesktop = 1440.0;

  // Quiet Neutral Shadows (Dark uses hairlines + subtle ambient drop; Light uses soft diffuse shadows)
  static List<BoxShadow> shadowSm(bool isDark) => [
    BoxShadow(
      color: isDark ? Colors.black.withOpacity(0.35) : const Color(0x0D000000),
      blurRadius: 2,
      offset: const Offset(0, 1),
    ),
  ];

  static List<BoxShadow> shadowMd(bool isDark) => [
    BoxShadow(
      color: isDark ? Colors.black.withOpacity(0.40) : const Color(0x12000000),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> shadowLg(bool isDark) => [
    BoxShadow(
      color: isDark ? Colors.black.withOpacity(0.50) : const Color(0x14000000),
      blurRadius: 20,
      offset: const Offset(0, 6),
    ),
  ];

  // Restrained neutral elevation (replaces glowing primary shadows)
  static List<BoxShadow> glowPrimary = [
    const BoxShadow(
      color: Color(0x1F000000),
      blurRadius: 8,
      offset: Offset(0, 2),
    ),
  ];
}
