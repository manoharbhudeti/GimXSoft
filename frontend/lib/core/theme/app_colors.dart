import 'package:flutter/material.dart';

class AppColors {
  // Brand & Accent Colors
  static const Color primary = Color(0xFF6366F1); // Electric Indigo
  static const Color primaryHover = Color(0xFF4F46E5);
  static const Color primaryLight = Color(0xFFEEF2FF);
  static const Color primaryDark = Color(0xFF4338CA);

  static const Color secondary = Color(0xFF10B981); // Emerald
  static const Color secondaryLight = Color(0xFFECFDF5);
  static const Color secondaryDark = Color(0xFF047857);

  static const Color accentCyan = Color(0xFF06B6D4);
  static const Color accentPurple = Color(0xFF8B5CF6);
  static const Color accentRose = Color(0xFFF43F5E);
  static const Color accentOrange = Color(0xFFF97316);

  // Status Indicators
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  // Dark Theme Neutral Colors
  static const Color darkBackground = Color(0xFF0B0F17);
  static const Color darkSurface = Color(0xFF111827);
  static const Color darkCard = Color(0xFF161F30);
  static const Color darkBorder = Color(0xFF1F2937);
  static const Color darkBorderLight = Color(0xFF374151);
  static const Color darkTextPrimary = Color(0xFFF9FAFB);
  static const Color darkTextSecondary = Color(0xFF9CA3AF);
  static const Color darkTextMuted = Color(0xFF6B7280);
  static const Color darkGlassSurface = Color(0xD9111827);
  static const Color darkGlassBorder = Color(0x26FFFFFF);

  // Light Theme Neutral Colors
  static const Color lightBackground = Color(0xFFF8FAFC);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightBorder = Color(0xFFE2E8F0);
  static const Color lightBorderLight = Color(0xFFF1F5F9);
  static const Color lightTextPrimary = Color(0xFF0F172A);
  static const Color lightTextSecondary = Color(0xFF475569);
  static const Color lightTextMuted = Color(0xFF94A3B8);
  static const Color lightGlassSurface = Color(0xE6FFFFFF);
  static const Color lightGlassBorder = Color(0x66CBD5E1);

  // Theme-aware helpers
  static Color background(bool isDark) => isDark ? darkBackground : lightBackground;
  static Color surface(bool isDark) => isDark ? darkSurface : lightSurface;
  static Color card(bool isDark) => isDark ? darkCard : lightCard;
  static Color border(bool isDark) => isDark ? darkBorder : lightBorder;
  static Color textPrimary(bool isDark) => isDark ? darkTextPrimary : lightTextPrimary;
  static Color textSecondary(bool isDark) => isDark ? darkTextSecondary : lightTextSecondary;
  static Color textMuted(bool isDark) => isDark ? darkTextMuted : lightTextMuted;
  static Color glassSurface(bool isDark) => isDark ? darkGlassSurface : lightGlassSurface;
  static Color glassBorder(bool isDark) => isDark ? darkGlassBorder : lightGlassBorder;
}

