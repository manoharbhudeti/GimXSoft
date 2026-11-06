import 'package:flutter/material.dart';

/// Unslopped Color System: Pure graphite neutral ramp with restrained athletic accent.
/// Follows heydamir/unslop specifications:
/// - Three text roles: primary, secondary, muted
/// - Single accent used deliberately for primary actions and selection
/// - Zero hue gradients, zero neon glows, zero colored shadows
class AppColors {
  // Brand & Accent Color (Athletic Amber/Ember - grounded in iron, chalk and stopwatches)
  static const Color primary = Color(0xFFD97706); // Athletic Amber
  static const Color primaryHover = Color(0xFFB45309);
  static const Color primaryLight = Color(0xFFFEF3C7);
  static const Color primaryDark = Color(0xFF92400E);

  // Secondary Accent (Athletic Emerald for positive status / occupancy)
  static const Color secondary = Color(0xFF10B981);
  static const Color secondaryLight = Color(0xFFECFDF5);
  static const Color secondaryDark = Color(0xFF047857);

  // Semantic Status (Toned to sit quietly inside the graphite ramp)
  static const Color success = Color(0xFF4CC38A); // Positive dark / #16A34A light
  static const Color successLight = Color(0xFF16A34A);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFE5484D); // Negative dark / #DC2626 light
  static const Color errorLight = Color(0xFFDC2626);
  static const Color info = Color(0xFF3B82F6);

  // Modern SaaS color aliases for backwards compatibility
  static const Color accentCyan = Color(0xFF0284C7);
  static const Color accentPurple = Color(0xFF7C3AED);
  static const Color accentRose = Color(0xFFE11D48);
  static const Color accentOrange = Color(0xFFEA580C);
  static const Color rose = accentRose;
  static const Color amber = warning;
  static const Color emerald = success;
  static const Color cyan = accentCyan;
  static const Color violet = primary;

  // Dark Theme Neutral Ramp (Graphite: neutral, quiet, deliberate)
  static const Color darkDeepest = Color(0xFF0F0F10); // Sidebar & base shell
  static const Color darkBackground = Color(0xFF141415); // Page canvas
  static const Color darkSurface = Color(0xFF0F0F10); // Elevated containers
  static const Color darkCard = Color(0xFF19191B); // Card surfaces
  static const Color darkRaised = Color(0xFF232325); // Active row, input, hover
  static const Color darkBorder = Color(0x14EDEDED); // Hairline 8% opacity
  static const Color darkBorderLight = Color(0x1FEDEDED); // Hairline 12% opacity
  static const Color darkTextPrimary = Color(0xFFEDEDED); // 93% white
  static const Color darkTextSecondary = Color(0xFFA1A1A6); // Secondary body
  static const Color darkTextMuted = Color(0xFF85858B); // Meta, captions, icons
  static const Color darkGlassSurface = Color(0xFF19191B); // Solid quiet card
  static const Color darkGlassBorder = Color(0x14EDEDED); // Quiet hairline

  // Light Theme Neutral Ramp (Graphite: clean, neutral, crisp)
  static const Color lightDeepest = Color(0xFFF4F4F5);
  static const Color lightBackground = Color(0xFFFAFAFA); // Crisp neutral canvas
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightRaised = Color(0xFFF4F4F5);
  static const Color lightBorder = Color(0x14171717); // Hairline 8% opacity
  static const Color lightBorderLight = Color(0x1F171717); // Hairline 12% opacity
  static const Color lightTextPrimary = Color(0xFF171717); // Deep graphite text
  static const Color lightTextSecondary = Color(0xFF525252);
  static const Color lightTextMuted = Color(0xFF737373);
  static const Color lightGlassSurface = Color(0xFFFFFFFF);
  static const Color lightGlassBorder = Color(0x14171717);

  // Theme-aware helpers
  static Color background(bool isDark) => isDark ? darkBackground : lightBackground;
  static Color surface(bool isDark) => isDark ? darkSurface : lightSurface;
  static Color card(bool isDark) => isDark ? darkCard : lightCard;
  static Color raised(bool isDark) => isDark ? darkRaised : lightRaised;
  static Color border(bool isDark) => isDark ? darkBorder : lightBorder;
  static Color textPrimary(bool isDark) => isDark ? darkTextPrimary : lightTextPrimary;
  static Color textSecondary(bool isDark) => isDark ? darkTextSecondary : lightTextSecondary;
  static Color textMuted(bool isDark) => isDark ? darkTextMuted : lightTextMuted;
  static Color glassSurface(bool isDark) => isDark ? darkGlassSurface : lightGlassSurface;
  static Color glassBorder(bool isDark) => isDark ? darkGlassBorder : lightGlassBorder;
}
