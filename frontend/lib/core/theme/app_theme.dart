import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'design_tokens.dart';
import 'theme_customization_models.dart';

/// Dynamic App Theme for GimXSoft
/// Builds cohesive ThemeData matching the customer's selected AppThemePalette and AppFontCombination.
class AppTheme {
  static ThemeData buildTheme({
    required bool isDark,
    required AppThemePalette palette,
    required AppFontCombination fontCombo,
  }) {
    final textPrimary = palette.textPrimary(isDark);
    final textSecondary = palette.textSecondary(isDark);
    final textMuted = palette.textMuted(isDark);

    // Build heading text styles with Heading Font (Bolder weights for high visual punch)
    final displayLarge = fontCombo.headingStyleBuilder(
      fontSize: 32,
      fontWeight: FontWeight.w900,
      color: textPrimary,
      letterSpacing: -0.5,
    );
    final headlineLarge = fontCombo.headingStyleBuilder(
      fontSize: 24,
      fontWeight: FontWeight.w800,
      color: textPrimary,
      letterSpacing: -0.3,
    );
    final headlineMedium = fontCombo.headingStyleBuilder(
      fontSize: 20,
      fontWeight: FontWeight.w800,
      color: textPrimary,
      letterSpacing: -0.2,
    );
    final titleLarge = fontCombo.headingStyleBuilder(
      fontSize: 16,
      fontWeight: FontWeight.w700,
      color: textPrimary,
      letterSpacing: 0,
    );
    final titleMedium = fontCombo.headingStyleBuilder(
      fontSize: 14,
      fontWeight: FontWeight.w700,
      color: textPrimary,
      letterSpacing: 0,
    );

    // Build body and supporting styles with Body Font
    final titleSmall = fontCombo.bodyStyleBuilder(
      fontSize: 13,
      fontWeight: FontWeight.w500,
      color: textSecondary,
      letterSpacing: 0,
    );
    final bodyLarge = fontCombo.bodyStyleBuilder(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: textPrimary,
      letterSpacing: 0,
    );
    final bodyMedium = fontCombo.bodyStyleBuilder(
      fontSize: 13,
      fontWeight: FontWeight.w400,
      color: textSecondary,
      letterSpacing: 0,
    );
    final bodySmall = fontCombo.bodyStyleBuilder(
      fontSize: 11,
      fontWeight: FontWeight.w400,
      color: textMuted,
      letterSpacing: 0,
    );
    final labelLarge = fontCombo.bodyStyleBuilder(
      fontSize: 13,
      fontWeight: FontWeight.w600,
      color: textPrimary,
      letterSpacing: 0,
    );
    final labelMedium = fontCombo.bodyStyleBuilder(
      fontSize: 11,
      fontWeight: FontWeight.w500,
      color: textSecondary,
      letterSpacing: 0,
    );
    final labelSmall = fontCombo.bodyStyleBuilder(
      fontSize: 10,
      fontWeight: FontWeight.w400,
      color: textMuted,
      letterSpacing: 0,
    );

    final textTheme = TextTheme(
      displayLarge: displayLarge,
      headlineLarge: headlineLarge,
      headlineMedium: headlineMedium,
      titleLarge: titleLarge,
      titleMedium: titleMedium,
      titleSmall: titleSmall,
      bodyLarge: bodyLarge,
      bodyMedium: bodyMedium,
      bodySmall: bodySmall,
      labelLarge: labelLarge,
      labelMedium: labelMedium,
      labelSmall: labelSmall,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: isDark ? Brightness.dark : Brightness.light,
      primaryColor: palette.primary,
      scaffoldBackgroundColor: palette.background(isDark),
      colorScheme: ColorScheme(
        brightness: isDark ? Brightness.dark : Brightness.light,
        primary: palette.primary,
        onPrimary: palette.id == ThemePaletteId.wineAndSand ? const Color(0xFF380811) : Colors.white,
        secondary: AppColors.secondary,
        onSecondary: Colors.white,
        surface: palette.surface(isDark),
        onSurface: textPrimary,
        error: AppColors.error,
        onError: Colors.white,
      ),
      textTheme: textTheme,
      cardTheme: CardThemeData(
        color: palette.card(isDark),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: DesignTokens.borderLg,
          side: BorderSide(color: palette.border(isDark), width: 1),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: palette.border(isDark),
        thickness: 1,
        space: 1,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: palette.raised(isDark),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        hintStyle: TextStyle(color: textMuted, fontSize: 13),
        border: OutlineInputBorder(
          borderRadius: DesignTokens.borderMd,
          borderSide: BorderSide(color: palette.border(isDark), width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: DesignTokens.borderMd,
          borderSide: BorderSide(color: palette.border(isDark), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: DesignTokens.borderMd,
          borderSide: BorderSide(color: palette.primary, width: 1.5),
        ),
        errorBorder: const OutlineInputBorder(
          borderRadius: DesignTokens.borderMd,
          borderSide: BorderSide(color: AppColors.error, width: 1),
        ),
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: palette.primary,
        indicatorColor: palette.primary,
        unselectedLabelColor: textSecondary,
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: palette.raised(isDark),
          borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
          border: Border.all(color: palette.border(isDark)),
        ),
        textStyle: TextStyle(color: textPrimary, fontSize: 11),
      ),
    );
  }

  static ThemeData get darkTheme => buildTheme(
        isDark: true,
        palette: AppColors.activePalette,
        fontCombo: AppFontCombination.leagueSpartanAndInter,
      );

  static ThemeData get lightTheme => buildTheme(
        isDark: false,
        palette: AppColors.activePalette,
        fontCombo: AppFontCombination.leagueSpartanAndInter,
      );
}
