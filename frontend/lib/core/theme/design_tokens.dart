import 'package:flutter/material.dart';

class DesignTokens {
  // Spacing
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

  // Corner Radii
  static const double radiusXs = 4.0;
  static const double radiusSm = 6.0;
  static const double radiusMd = 10.0;
  static const double radiusLg = 14.0;
  static const double radiusXl = 18.0;
  static const double radiusFull = 9999.0;

  static const BorderRadius borderXs = BorderRadius.all(Radius.circular(radiusXs));
  static const BorderRadius borderSm = BorderRadius.all(Radius.circular(radiusSm));
  static const BorderRadius borderMd = BorderRadius.all(Radius.circular(radiusMd));
  static const BorderRadius borderLg = BorderRadius.all(Radius.circular(radiusLg));
  static const BorderRadius borderXl = BorderRadius.all(Radius.circular(radiusXl));
  static const BorderRadius borderFull = BorderRadius.all(Radius.circular(radiusFull));

  // Glassmorphism Blur
  static const double blurSubtle = 8.0;
  static const double blurStandard = 14.0;
  static const double blurHeavy = 24.0;

  // Animation Durations
  static const Duration durationFast = Duration(milliseconds: 150);
  static const Duration durationNormal = Duration(milliseconds: 250);
  static const Duration durationSlow = Duration(milliseconds: 350);

  // Responsive Breakpoints
  static const double breakpointMobile = 640.0;
  static const double breakpointTablet = 1024.0;
  static const double breakpointDesktop = 1440.0;

  // Shadows
  static List<BoxShadow> shadowSm(bool isDark) => [
    BoxShadow(
      color: isDark ? Colors.black.withOpacity(0.25) : Colors.black.withOpacity(0.04),
      blurRadius: 4,
      offset: const Offset(0, 1),
    ),
  ];

  static List<BoxShadow> shadowMd(bool isDark) => [
    BoxShadow(
      color: isDark ? Colors.black.withOpacity(0.35) : Colors.black.withOpacity(0.06),
      blurRadius: 10,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> shadowLg(bool isDark) => [
    BoxShadow(
      color: isDark ? Colors.black.withOpacity(0.45) : Colors.black.withOpacity(0.08),
      blurRadius: 20,
      offset: const Offset(0, 8),
    ),
  ];

  static List<BoxShadow> glowPrimary = [
    BoxShadow(
      color: const Color(0xFF6366F1).withOpacity(0.35),
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
  ];
}

