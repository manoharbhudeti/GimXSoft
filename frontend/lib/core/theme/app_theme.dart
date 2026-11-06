import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';
import 'design_tokens.dart';

/// Unslopped App Theme conforming to heydamir/unslop specifications:
/// - Inter typography with tabular figures
/// - Strict weight discipline: 400 (regular) and 500 (medium), max 600
/// - Zero negative letter spacing under 16px
/// - Hairline borders at 8% opacity
class AppTheme {
  static ThemeData get darkTheme {
    final baseText = GoogleFonts.interTextTheme(ThemeData.dark().textTheme);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.darkBackground,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        onPrimary: Color(0xFF141415),
        secondary: AppColors.secondary,
        onSecondary: Colors.white,
        surface: AppColors.darkSurface,
        onSurface: AppColors.darkTextPrimary,
        error: AppColors.error,
        onError: Colors.white,
      ),
      textTheme: baseText.copyWith(
        displayLarge: baseText.displayLarge?.copyWith(
          color: AppColors.darkTextPrimary,
          fontWeight: FontWeight.w500,
          fontFeatures: const [FontFeature.tabularFigures()],
          letterSpacing: -0.5,
        ),
        headlineLarge: baseText.headlineLarge?.copyWith(
          color: AppColors.darkTextPrimary,
          fontWeight: FontWeight.w500,
          fontFeatures: const [FontFeature.tabularFigures()],
          letterSpacing: -0.3,
        ),
        headlineMedium: baseText.headlineMedium?.copyWith(
          color: AppColors.darkTextPrimary,
          fontWeight: FontWeight.w500,
          letterSpacing: -0.2,
        ),
        titleLarge: baseText.titleLarge?.copyWith(
          color: AppColors.darkTextPrimary,
          fontWeight: FontWeight.w500,
          letterSpacing: 0,
        ),
        titleMedium: baseText.titleMedium?.copyWith(
          color: AppColors.darkTextPrimary,
          fontWeight: FontWeight.w500,
          letterSpacing: 0,
        ),
        titleSmall: baseText.titleSmall?.copyWith(
          color: AppColors.darkTextSecondary,
          fontWeight: FontWeight.w400,
          letterSpacing: 0,
        ),
        bodyLarge: baseText.bodyLarge?.copyWith(
          color: AppColors.darkTextPrimary,
          fontWeight: FontWeight.w400,
          letterSpacing: 0,
        ),
        bodyMedium: baseText.bodyMedium?.copyWith(
          color: AppColors.darkTextSecondary,
          fontWeight: FontWeight.w400,
          letterSpacing: 0,
        ),
        bodySmall: baseText.bodySmall?.copyWith(
          color: AppColors.darkTextMuted,
          fontWeight: FontWeight.w400,
          letterSpacing: 0,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.darkCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: DesignTokens.borderLg,
          side: const BorderSide(color: AppColors.darkBorder, width: 1),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.darkBorder,
        thickness: 1,
        space: 1,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkCard,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        hintStyle: const TextStyle(color: AppColors.darkTextMuted, fontSize: 13),
        border: OutlineInputBorder(
          borderRadius: DesignTokens.borderMd,
          borderSide: const BorderSide(color: AppColors.darkBorder, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: DesignTokens.borderMd,
          borderSide: const BorderSide(color: AppColors.darkBorder, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: DesignTokens.borderMd,
          borderSide: const BorderSide(color: AppColors.primary, width: 1.2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: DesignTokens.borderMd,
          borderSide: const BorderSide(color: AppColors.error, width: 1),
        ),
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: AppColors.darkRaised,
          borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
          border: Border.all(color: AppColors.darkBorder),
        ),
        textStyle: const TextStyle(color: AppColors.darkTextPrimary, fontSize: 11),
      ),
    );
  }

  static ThemeData get lightTheme {
    final baseText = GoogleFonts.interTextTheme(ThemeData.light().textTheme);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.lightBackground,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        onPrimary: Colors.white,
        secondary: AppColors.secondary,
        onSecondary: Colors.white,
        surface: AppColors.lightSurface,
        onSurface: AppColors.lightTextPrimary,
        error: AppColors.error,
        onError: Colors.white,
      ),
      textTheme: baseText.copyWith(
        displayLarge: baseText.displayLarge?.copyWith(
          color: AppColors.lightTextPrimary,
          fontWeight: FontWeight.w500,
          fontFeatures: const [FontFeature.tabularFigures()],
          letterSpacing: -0.5,
        ),
        headlineLarge: baseText.headlineLarge?.copyWith(
          color: AppColors.lightTextPrimary,
          fontWeight: FontWeight.w500,
          fontFeatures: const [FontFeature.tabularFigures()],
          letterSpacing: -0.3,
        ),
        headlineMedium: baseText.headlineMedium?.copyWith(
          color: AppColors.lightTextPrimary,
          fontWeight: FontWeight.w500,
          letterSpacing: -0.2,
        ),
        titleLarge: baseText.titleLarge?.copyWith(
          color: AppColors.lightTextPrimary,
          fontWeight: FontWeight.w500,
          letterSpacing: 0,
        ),
        titleMedium: baseText.titleMedium?.copyWith(
          color: AppColors.lightTextPrimary,
          fontWeight: FontWeight.w500,
          letterSpacing: 0,
        ),
        titleSmall: baseText.titleSmall?.copyWith(
          color: AppColors.lightTextSecondary,
          fontWeight: FontWeight.w400,
          letterSpacing: 0,
        ),
        bodyLarge: baseText.bodyLarge?.copyWith(
          color: AppColors.lightTextPrimary,
          fontWeight: FontWeight.w400,
          letterSpacing: 0,
        ),
        bodyMedium: baseText.bodyMedium?.copyWith(
          color: AppColors.lightTextSecondary,
          fontWeight: FontWeight.w400,
          letterSpacing: 0,
        ),
        bodySmall: baseText.bodySmall?.copyWith(
          color: AppColors.lightTextMuted,
          fontWeight: FontWeight.w400,
          letterSpacing: 0,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.lightCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: DesignTokens.borderLg,
          side: const BorderSide(color: AppColors.lightBorder, width: 1),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.lightBorder,
        thickness: 1,
        space: 1,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.lightRaised,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        hintStyle: const TextStyle(color: AppColors.lightTextMuted, fontSize: 13),
        border: OutlineInputBorder(
          borderRadius: DesignTokens.borderMd,
          borderSide: const BorderSide(color: AppColors.lightBorder, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: DesignTokens.borderMd,
          borderSide: const BorderSide(color: AppColors.lightBorder, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: DesignTokens.borderMd,
          borderSide: const BorderSide(color: AppColors.primary, width: 1.2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: DesignTokens.borderMd,
          borderSide: const BorderSide(color: AppColors.error, width: 1),
        ),
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: AppColors.lightCard,
          borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
          border: Border.all(color: AppColors.lightBorder),
          boxShadow: DesignTokens.shadowSm(false),
        ),
        textStyle: const TextStyle(color: AppColors.lightTextPrimary, fontSize: 11),
      ),
    );
  }
}
