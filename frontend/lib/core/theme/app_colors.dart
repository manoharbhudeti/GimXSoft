import 'package:flutter/material.dart';
import 'theme_customization_models.dart';

/// Dynamic Color System for GimXSoft
/// Provides constants for baseline compatibility and dynamic getters for the active theme palette.
class AppColors {
  static AppThemePalette _activePalette = AppThemePalette.orangeAndMilk;

  static AppThemePalette get activePalette => _activePalette;

  static void setPalette(AppThemePalette palette) {
    _activePalette = palette;
  }

  // Active theme dynamic colors
  static Color dynamicPrimary(BuildContext context) => Theme.of(context).primaryColor;
  static Color dynamicBackground(BuildContext context) => Theme.of(context).scaffoldBackgroundColor;
  static Color dynamicCard(BuildContext context) =>
      Theme.of(context).cardTheme.color ?? _activePalette.card(Theme.of(context).brightness == Brightness.dark);
  static Color get accent => _activePalette.primary;

  // Baseline brand colors
  static const Color primary = Color(0xFFEA580C);
  static const Color primaryHover = Color(0xFFC2410C);
  static const Color primaryLight = Color(0xFFFFEDD5);
  static const Color primaryDark = Color(0xFF7C2D12);

  // Secondary Accent (Athletic Emerald for positive status / occupancy)
  static const Color secondary = Color(0xFF10B981);
  static const Color secondaryLight = Color(0xFFECFDF5);
  static const Color secondaryDark = Color(0xFF047857);

  // Semantic Status (Toned to sit quietly inside the graphite ramp)
  static const Color success = Color(0xFF4CC38A);
  static const Color successLight = Color(0xFF16A34A);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFE5484D);
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

  // Constant Neutral Ramp
  static const Color darkDeepest = Color(0xFF0F0F10);
  static const Color darkBackground = Color(0xFF141415);
  static const Color darkSurface = Color(0xFF0F0F10);
  static const Color darkCard = Color(0xFF19191B);
  static const Color darkRaised = Color(0xFF232325);
  static const Color darkBorder = Color(0x14EDEDED);
  static const Color darkBorderLight = Color(0x1FEDEDED);
  static const Color darkTextPrimary = Color(0xFFEDEDED);
  static const Color darkTextSecondary = Color(0xFFA1A1A6);
  static const Color darkTextMuted = Color(0xFF85858B);
  static const Color darkGlassSurface = Color(0xFF19191B);
  static const Color darkGlassBorder = Color(0x14EDEDED);

  static const Color lightDeepest = Color(0xFFF4F4F5);
  static const Color lightBackground = Color(0xFFFAF7F2);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightRaised = Color(0xFFF4F4F5);
  static const Color lightBorder = Color(0x14171717);
  static const Color lightBorderLight = Color(0x1F171717);
  static const Color lightTextPrimary = Color(0xFF171717);
  static const Color lightTextSecondary = Color(0xFF525252);
  static const Color lightTextMuted = Color(0xFF737373);
  static const Color lightGlassSurface = Color(0xFFFFFFFF);
  static const Color lightGlassBorder = Color(0x14171717);

  // Dynamic Theme-aware helpers driven by activePalette
  static Color background(bool isDark) => _activePalette.background(isDark);
  static Color surface(bool isDark) => _activePalette.surface(isDark);
  static Color card(bool isDark) => _activePalette.card(isDark);
  static Color raised(bool isDark) => _activePalette.raised(isDark);
  static Color border(bool isDark) => _activePalette.border(isDark);
  static Color textPrimary(bool isDark) => _activePalette.textPrimary(isDark);
  static Color textSecondary(bool isDark) => _activePalette.textSecondary(isDark);
  static Color textMuted(bool isDark) => _activePalette.textMuted(isDark);
  static Color glassSurface(bool isDark) => _activePalette.card(isDark);
  static Color glassBorder(bool isDark) => _activePalette.border(isDark);
}
