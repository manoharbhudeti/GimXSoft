import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// ---------------------------------------------------------------------------
/// THEME CUSTOMIZATION: PALETTE CONFIGURATION
/// ---------------------------------------------------------------------------

enum ThemePaletteId {
  wineAndSand,
  orangeAndMilk,
  midnightAndVanilla,
  blaze,
}

class AppThemePalette {
  final ThemePaletteId id;
  final String name;
  final String description;
  final String primaryColorName;
  final String backgroundColorName;
  final Color primary;
  final Color primaryHover;
  final Color primaryLight;
  final Color primaryDark;
  final Color lightBackground;
  final Color darkBackground;
  final Color lightSurface;
  final Color darkSurface;
  final Color lightCard;
  final Color darkCard;
  final Color lightRaised;
  final Color darkRaised;
  final Color lightBorder;
  final Color darkBorder;
  final Color lightTextPrimary;
  final Color darkTextPrimary;
  final Color lightTextSecondary;
  final Color darkTextSecondary;
  final Color lightTextMuted;
  final Color darkTextMuted;
  final List<Color> previewSwatches;

  const AppThemePalette({
    required this.id,
    required this.name,
    required this.description,
    required this.primaryColorName,
    required this.backgroundColorName,
    required this.primary,
    required this.primaryHover,
    required this.primaryLight,
    required this.primaryDark,
    required this.lightBackground,
    required this.darkBackground,
    required this.lightSurface,
    required this.darkSurface,
    required this.lightCard,
    required this.darkCard,
    required this.lightRaised,
    required this.darkRaised,
    required this.lightBorder,
    required this.darkBorder,
    required this.lightTextPrimary,
    required this.darkTextPrimary,
    required this.lightTextSecondary,
    required this.darkTextSecondary,
    required this.lightTextMuted,
    required this.darkTextMuted,
    required this.previewSwatches,
  });

  Color background(bool isDark) => isDark ? darkBackground : lightBackground;
  Color surface(bool isDark) => isDark ? darkSurface : lightSurface;
  Color card(bool isDark) => isDark ? darkCard : lightCard;
  Color raised(bool isDark) => isDark ? darkRaised : lightRaised;
  Color border(bool isDark) => isDark ? darkBorder : lightBorder;
  Color textPrimary(bool isDark) => isDark ? darkTextPrimary : lightTextPrimary;
  Color textSecondary(bool isDark) => isDark ? darkTextSecondary : lightTextSecondary;
  Color textMuted(bool isDark) => isDark ? darkTextMuted : lightTextMuted;

  // Preset 1: Wine & Sand (Wine Red + Light Sand)
  static const wineAndSand = AppThemePalette(
    id: ThemePaletteId.wineAndSand,
    name: 'Wine & Sand',
    description: 'Sophisticated wine burgundy accents grounded in warm mineral sand',
    primaryColorName: 'Wine Red',
    backgroundColorName: 'Light Sand',
    primary: Color(0xFF881337), // Rich Wine Red
    primaryHover: Color(0xFF9F1239),
    primaryLight: Color(0xFFFCE7F3),
    primaryDark: Color(0xFF4C0519),
    lightBackground: Color(0xFFF7F4EE), // Light Sand
    darkBackground: Color(0xFF191114), // Deep Wine Dark
    lightSurface: Color(0xFFFFFFFF),
    darkSurface: Color(0xFF22161B),
    lightCard: Color(0xFFFFFFFF),
    darkCard: Color(0xFF26191F),
    lightRaised: Color(0xFFEFE7DC),
    darkRaised: Color(0xFF332028),
    lightBorder: Color(0x1F881337),
    darkBorder: Color(0x28FCE7F3),
    lightTextPrimary: Color(0xFF2C1318),
    darkTextPrimary: Color(0xFFFFF1F2),
    lightTextSecondary: Color(0xFF6E5259),
    darkTextSecondary: Color(0xFFD8B4BC),
    lightTextMuted: Color(0xFF937B81),
    darkTextMuted: Color(0xFFA58B93),
    previewSwatches: [
      Color(0xFF881337), // Wine Red
      Color(0xFFF7F4EE), // Light Sand
      Color(0xFFEFE7DC), // Raised Sand
      Color(0xFF191114), // Dark Wine
    ],
  );

  // Preset 2: Orange & Milk (Athletic Orange + Warm Milk)
  static const orangeAndMilk = AppThemePalette(
    id: ThemePaletteId.orangeAndMilk,
    name: 'Orange & Milk',
    description: 'High-energy athletic orange balanced with creamy milk porcelain surfaces',
    primaryColorName: 'Orange',
    backgroundColorName: 'Milk',
    primary: Color(0xFFEA580C), // Athletic Orange
    primaryHover: Color(0xFFC2410C),
    primaryLight: Color(0xFFFFEDD5),
    primaryDark: Color(0xFF7C2D12),
    lightBackground: Color(0xFFFAF7F2), // Creamy Milk
    darkBackground: Color(0xFF151413), // Roasted Graphite
    lightSurface: Color(0xFFFFFFFF),
    darkSurface: Color(0xFF1E1B19),
    lightCard: Color(0xFFFFFFFF),
    darkCard: Color(0xFF24211E),
    lightRaised: Color(0xFFF2ECE1),
    darkRaised: Color(0xFF2E2A26),
    lightBorder: Color(0x1AEA580C),
    darkBorder: Color(0x24EDEDED),
    lightTextPrimary: Color(0xFF1C1917),
    darkTextPrimary: Color(0xFFEDEDED),
    lightTextSecondary: Color(0xFF78716C),
    darkTextSecondary: Color(0xFFA8A29E),
    lightTextMuted: Color(0xFFA8A29E),
    darkTextMuted: Color(0xFF85858B),
    previewSwatches: [
      Color(0xFFEA580C), // Orange
      Color(0xFFFAF7F2), // Milk
      Color(0xFFF2ECE1), // Warm Cream
      Color(0xFF151413), // Charcoal
    ],
  );

  // Preset 3: Midnight & Vanilla (Midnight Indigo + French Vanilla)
  static const midnightAndVanilla = AppThemePalette(
    id: ThemePaletteId.midnightAndVanilla,
    name: 'Midnight & Vanilla',
    description: 'Deep celestial midnight indigo contrasted with rich French vanilla',
    primaryColorName: 'Midnight Indigo',
    backgroundColorName: 'Vanilla',
    primary: Color(0xFF4F46E5), // Midnight Indigo
    primaryHover: Color(0xFF4338CA),
    primaryLight: Color(0xFFEEF2FF),
    primaryDark: Color(0xFF312E81),
    lightBackground: Color(0xFFFDFBF7), // French Vanilla
    darkBackground: Color(0xFF0F111A), // Deep Midnight
    lightSurface: Color(0xFFFFFFFF),
    darkSurface: Color(0xFF161926),
    lightCard: Color(0xFFFFFFFF),
    darkCard: Color(0xFF1B2030),
    lightRaised: Color(0xFFF5EFE3),
    darkRaised: Color(0xFF252C42),
    lightBorder: Color(0x1F4F46E5),
    darkBorder: Color(0x286366F1),
    lightTextPrimary: Color(0xFF1E1B4B),
    darkTextPrimary: Color(0xFFF5F3FF),
    lightTextSecondary: Color(0xFF475569),
    darkTextSecondary: Color(0xFF94A3B8),
    lightTextMuted: Color(0xFF64748B),
    darkTextMuted: Color(0xFF818CF8),
    previewSwatches: [
      Color(0xFF4F46E5), // Midnight Indigo
      Color(0xFFFDFBF7), // Vanilla
      Color(0xFFF5EFE3), // Cream
      Color(0xFF0F111A), // Obsidian
    ],
  );

  // Preset 4: Blaze (Blaze Orange + Pitch Black)
  static const blaze = AppThemePalette(
    id: ThemePaletteId.blaze,
    name: 'Blaze',
    description: 'Striking pure black high-contrast motorsport stage with electric blaze flame',
    primaryColorName: 'Blaze Orange',
    backgroundColorName: 'Black',
    primary: Color(0xFFFF5722), // Blaze Orange
    primaryHover: Color(0xFFE64A19),
    primaryLight: Color(0xFFFFCCBC),
    primaryDark: Color(0xFFBF360C),
    lightBackground: Color(0xFFF5F5F5),
    darkBackground: Color(0xFF0A0A0A), // Pure Pitch Black
    lightSurface: Color(0xFFFFFFFF),
    darkSurface: Color(0xFF121212),
    lightCard: Color(0xFFFFFFFF),
    darkCard: Color(0xFF171717),
    lightRaised: Color(0xFFEAEAEA),
    darkRaised: Color(0xFF222222),
    lightBorder: Color(0x1FFF5722),
    darkBorder: Color(0x28FF5722),
    lightTextPrimary: Color(0xFF111111),
    darkTextPrimary: Color(0xFFEDEDED),
    lightTextSecondary: Color(0xFF555555),
    darkTextSecondary: Color(0xFFA0A0A0),
    lightTextMuted: Color(0xFF777777),
    darkTextMuted: Color(0xFF888888),
    previewSwatches: [
      Color(0xFFFF5722), // Blaze Orange
      Color(0xFF0A0A0A), // Black
      Color(0xFF1F1F1F), // Dark Gray
      Color(0xFFF5F5F5), // Light Gray
    ],
  );

  static const List<AppThemePalette> allPalettes = [
    wineAndSand,
    orangeAndMilk,
    midnightAndVanilla,
    blaze,
  ];

  static AppThemePalette fromId(String? rawId) {
    if (rawId == null) return orangeAndMilk;
    for (final p in allPalettes) {
      if (p.id.name.toLowerCase() == rawId.toLowerCase()) return p;
    }
    return orangeAndMilk;
  }
}

/// ---------------------------------------------------------------------------
/// TYPOGRAPHY CUSTOMIZATION: COMBINATIONS & PAIRINGS
/// ---------------------------------------------------------------------------

enum FontCombinationId {
  syneAndDmMono,
  gothamAndInter,
  leagueSpartanAndInter,
  megionAndDmSans,
  nofexAndInter,
}

class AppFontCombination {
  final FontCombinationId id;
  final String name;
  final String headingFontName;
  final String bodyFontName;
  final String categoryTag;
  final String description;
  final TextStyle Function({TextStyle? textStyle, Color? color, FontWeight? fontWeight, double? fontSize, double? letterSpacing, double? height}) headingStyleBuilder;
  final TextStyle Function({TextStyle? textStyle, Color? color, FontWeight? fontWeight, double? fontSize, double? letterSpacing, double? height}) bodyStyleBuilder;

  const AppFontCombination({
    required this.id,
    required this.name,
    required this.headingFontName,
    required this.bodyFontName,
    required this.categoryTag,
    required this.description,
    required this.headingStyleBuilder,
    required this.bodyStyleBuilder,
  });

  // 1. Syne + DM Mono
  static final syneAndDmMono = AppFontCombination(
    id: FontCombinationId.syneAndDmMono,
    name: 'Syne + DM Mono',
    headingFontName: 'Syne',
    bodyFontName: 'DM Mono',
    categoryTag: 'Architectural & Tech',
    description: 'Distinctive avant-garde geometric display paired with disciplined monospace data body',
    headingStyleBuilder: GoogleFonts.syne,
    bodyStyleBuilder: GoogleFonts.dmMono,
  );

  // 2. Gotham + Inter (Gotham geometric profile with Inter readable body)
  static final gothamAndInter = AppFontCombination(
    id: FontCombinationId.gothamAndInter,
    name: 'Gotham + Inter',
    headingFontName: 'Gotham (Geometric)',
    bodyFontName: 'Inter',
    categoryTag: 'Modern Executive',
    description: 'Clean architectural geometric headlines supported by the global SaaS benchmark Inter',
    headingStyleBuilder: GoogleFonts.montserrat, // Open standard geometric companion for Gotham
    bodyStyleBuilder: GoogleFonts.inter,
  );

  // 3. League Spartan + Inter (Bold athletic headlines)
  static final leagueSpartanAndInter = AppFontCombination(
    id: FontCombinationId.leagueSpartanAndInter,
    name: 'League Spartan + Inter',
    headingFontName: 'League Spartan',
    bodyFontName: 'Inter',
    categoryTag: 'Bold Athletic',
    description: 'Punchy heavy athletic header cuts designed for gym performance dashboards',
    headingStyleBuilder: GoogleFonts.leagueSpartan,
    bodyStyleBuilder: GoogleFonts.inter,
  );

  // 4. Megion + DM Sans (Editorial luxury display with humanist sans)
  static final megionAndDmSans = AppFontCombination(
    id: FontCombinationId.megionAndDmSans,
    name: 'Megion + DM Sans',
    headingFontName: 'Megion (Display)',
    bodyFontName: 'DM Sans',
    categoryTag: 'Luxury Editorial',
    description: 'Refined editorial character headers balanced with warm, human-crafted DM Sans',
    headingStyleBuilder: GoogleFonts.cinzel, // Classical refined luxury editorial fallback
    bodyStyleBuilder: GoogleFonts.dmSans,
  );

  // 5. Nofex + Inter (Futuristic cyber grotesque display)
  static final nofexAndInter = AppFontCombination(
    id: FontCombinationId.nofexAndInter,
    name: 'Nofex + Inter',
    headingFontName: 'Nofex (Grotesque)',
    bodyFontName: 'Inter',
    categoryTag: 'Futuristic Cyber',
    description: 'Next-generation tech headline styling anchored with neutral body proportions',
    headingStyleBuilder: GoogleFonts.spaceGrotesk, // Modern cyber grotesque display standard
    bodyStyleBuilder: GoogleFonts.inter,
  );

  static final List<AppFontCombination> allCombinations = [
    syneAndDmMono,
    gothamAndInter,
    leagueSpartanAndInter,
    megionAndDmSans,
    nofexAndInter,
  ];

  static AppFontCombination fromId(String? rawId) {
    if (rawId == null) return leagueSpartanAndInter;
    for (final f in allCombinations) {
      if (f.id.name.toLowerCase() == rawId.toLowerCase()) return f;
    }
    return leagueSpartanAndInter;
  }
}
