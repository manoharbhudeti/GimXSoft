import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// ===========================================================================
/// GIMXSOFT DYNAMIC THEME & TYPOGRAPHY MASTER CONFIGURATION FILE
/// ===========================================================================
///
/// SINGLE SOURCE OF TRUTH for all visual themes, color palettes, and typography
/// pairings across the entire CRM application.
///
/// ---------------------------------------------------------------------------
/// QUICK GUIDE FOR FUTURE DYNAMIC MODIFICATIONS:
/// ---------------------------------------------------------------------------
///
/// 1. TO ADD A NEW THEME:
///    a) Add a preset in [AppThemePalette] below with your custom hex colors.
///    b) Add an entry in [AppIndependentTheme] with `isDark` set to true/false.
///    c) Add it to [AppIndependentTheme.allThemes].
///    (OR use `AppThemeRegistry.registerTheme(...)` dynamically at runtime).
///
/// 2. TO ADD A NEW TYPOGRAPHY COMBINATION:
///    a) Add a preset in [AppFontCombination] pairing any Google Fonts.
///    b) Add it to [AppFontCombination.allCombinations].
///    (OR use `AppFontRegistry.registerFont(...)` dynamically at runtime).
///
/// 3. ALL COMPONENTS AUTOMATICALLY INHERIT:
///    Any new theme or font added here immediately surfaces in the Settings
///    Panel, persists across sessions, and applies globally across all screens.
/// ===========================================================================

/// ---------------------------------------------------------------------------
/// 1. THEME PALETTE IDENTIFIERS
/// ---------------------------------------------------------------------------
enum ThemePaletteId {
  whiteMode,
  darkMode,
  wineAndSand,
  orangeAndMilk,
  midnightAndVanilla,
  blaze,
  custom,
}

/// ---------------------------------------------------------------------------
/// 2. THEME PALETTE SPECIFICATION
/// ---------------------------------------------------------------------------
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

  // --- BUILT-IN PALETTE PRESETS ---

  // Preset 1: White Mode (Classic Light)
  static const whiteMode = AppThemePalette(
    id: ThemePaletteId.whiteMode,
    name: 'White Mode',
    description: 'Clean daylight slate surfaces with crisp porcelain contrast and athletic amber accents',
    primaryColorName: 'Athletic Orange',
    backgroundColorName: 'Porcelain White',
    primary: Color(0xFFEA580C),
    primaryHover: Color(0xFFC2410C),
    primaryLight: Color(0xFFFFEDD5),
    primaryDark: Color(0xFF7C2D12),
    lightBackground: Color(0xFFFAF7F2),
    darkBackground: Color(0xFF141415),
    lightSurface: Color(0xFFFFFFFF),
    darkSurface: Color(0xFF19191B),
    lightCard: Color(0xFFFFFFFF),
    darkCard: Color(0xFF19191B),
    lightRaised: Color(0xFFF4F4F5),
    darkRaised: Color(0xFF232325),
    lightBorder: Color(0x14171717),
    darkBorder: Color(0x14EDEDED),
    lightTextPrimary: Color(0xFF171717),
    darkTextPrimary: Color(0xFFEDEDED),
    lightTextSecondary: Color(0xFF525252),
    darkTextSecondary: Color(0xFFA1A1A6),
    lightTextMuted: Color(0xFF737373),
    darkTextMuted: Color(0xFF85858B),
    previewSwatches: [
      Color(0xFFEA580C), // Orange
      Color(0xFFFAF7F2), // Porcelain White
      Color(0xFFFFFFFF), // Pure White Card
      Color(0xFF171717), // Deep Text
    ],
  );

  // Preset 2: Dark Mode (Classic Dark)
  static const darkMode = AppThemePalette(
    id: ThemePaletteId.darkMode,
    name: 'Dark Mode',
    description: 'Deep obsidian graphite void with luminous amber accents and reduced nighttime glare',
    primaryColorName: 'Athletic Orange',
    backgroundColorName: 'Obsidian Void',
    primary: Color(0xFFEA580C),
    primaryHover: Color(0xFFC2410C),
    primaryLight: Color(0xFFFFEDD5),
    primaryDark: Color(0xFF7C2D12),
    lightBackground: Color(0xFFFAF7F2),
    darkBackground: Color(0xFF141415),
    lightSurface: Color(0xFFFFFFFF),
    darkSurface: Color(0xFF0F0F10),
    lightCard: Color(0xFFFFFFFF),
    darkCard: Color(0xFF19191B),
    lightRaised: Color(0xFFF4F4F5),
    darkRaised: Color(0xFF232325),
    lightBorder: Color(0x14171717),
    darkBorder: Color(0x14EDEDED),
    lightTextPrimary: Color(0xFF171717),
    darkTextPrimary: Color(0xFFEDEDED),
    lightTextSecondary: Color(0xFF525252),
    darkTextSecondary: Color(0xFFA1A1A6),
    lightTextMuted: Color(0xFF737373),
    darkTextMuted: Color(0xFF85858B),
    previewSwatches: [
      Color(0xFFEA580C), // Orange
      Color(0xFF141415), // Obsidian Void
      Color(0xFF19191B), // Elevated Graphite Card
      Color(0xFFEDEDED), // Off-white Text
    ],
  );

  // Preset 3: Wine Red + Light Sand
  static const wineAndSand = AppThemePalette(
    id: ThemePaletteId.wineAndSand,
    name: 'Wine Red + Light Sand',
    description: 'Rich velvet wine red canvas with high-contrast warm light sand typography and accents',
    primaryColorName: 'Wine Red',
    backgroundColorName: 'Light Sand',
    primary: Color(0xFFF7F4EE),
    primaryHover: Color(0xFFEAD7BE),
    primaryLight: Color(0xFF5E1322),
    primaryDark: Color(0xFF2E060D),
    lightBackground: Color(0xFF380811),
    darkBackground: Color(0xFF32060F),
    lightSurface: Color(0xFF3D0A14),
    darkSurface: Color(0xFF2E060D),
    lightCard: Color(0xFF4E101D),
    darkCard: Color(0xFF450C18),
    lightRaised: Color(0xFF631525),
    darkRaised: Color(0xFF5A1220),
    lightBorder: Color(0x33F7F4EE),
    darkBorder: Color(0x2EF7F4EE),
    lightTextPrimary: Color(0xFFF7F4EE),
    darkTextPrimary: Color(0xFFF7F4EE),
    lightTextSecondary: Color(0xFFE5DACB),
    darkTextSecondary: Color(0xFFE5DACB),
    lightTextMuted: Color(0xFFBFAF9E),
    darkTextMuted: Color(0xFFBFAF9E),
    previewSwatches: [
      Color(0xFF881337), // Wine Red Accent
      Color(0xFF380811), // Wine Red Canvas
      Color(0xFF4E101D), // Elevated Wine Card
      Color(0xFFF7F4EE), // Crisp Light Sand Text
    ],
  );

  // Preset 4: Orange + Milk
  static const orangeAndMilk = AppThemePalette(
    id: ThemePaletteId.orangeAndMilk,
    name: 'Orange + Milk',
    description: 'High-energy athletic orange balanced with creamy milk porcelain surfaces',
    primaryColorName: 'Orange',
    backgroundColorName: 'Milk',
    primary: Color(0xFFEA580C),
    primaryHover: Color(0xFFC2410C),
    primaryLight: Color(0xFFFFEDD5),
    primaryDark: Color(0xFF7C2D12),
    lightBackground: Color(0xFFFAF7F2),
    darkBackground: Color(0xFF151413),
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
      Color(0xFF1C1917), // Charcoal
    ],
  );

  // Preset 5: Midnight Indigo + Vanilla
  static const midnightAndVanilla = AppThemePalette(
    id: ThemePaletteId.midnightAndVanilla,
    name: 'Midnight Indigo + Vanilla',
    description: 'Deep celestial midnight indigo contrasted with rich French vanilla',
    primaryColorName: 'Midnight Indigo',
    backgroundColorName: 'Vanilla',
    primary: Color(0xFF4F46E5),
    primaryHover: Color(0xFF4338CA),
    primaryLight: Color(0xFFEEF2FF),
    primaryDark: Color(0xFF312E81),
    lightBackground: Color(0xFFFDFBF7),
    darkBackground: Color(0xFF0F111A),
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
      Color(0xFF1E1B4B), // Deep Indigo
    ],
  );

  // Preset 6: Blaze Orange + Black
  static const blaze = AppThemePalette(
    id: ThemePaletteId.blaze,
    name: 'Blaze Orange + Black',
    description: 'Striking pure black motorsport stage with high-contrast electric blaze flame',
    primaryColorName: 'Blaze Orange',
    backgroundColorName: 'Black',
    primary: Color(0xFFFF5722),
    primaryHover: Color(0xFFE64A19),
    primaryLight: Color(0xFFFFCCBC),
    primaryDark: Color(0xFFBF360C),
    lightBackground: Color(0xFFF5F5F5),
    darkBackground: Color(0xFF0A0A0A),
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
      Color(0xFF171717), // Deep Gray
      Color(0xFFEDEDED), // Light Gray
    ],
  );

  static const List<AppThemePalette> allPalettes = [
    whiteMode,
    darkMode,
    wineAndSand,
    orangeAndMilk,
    midnightAndVanilla,
    blaze,
  ];

  static AppThemePalette fromId(String? rawId) {
    if (rawId == null) return darkMode;
    for (final p in allPalettes) {
      if (p.id.name.toLowerCase() == rawId.toLowerCase()) return p;
    }
    return darkMode;
  }
}

/// ---------------------------------------------------------------------------
/// 3. INDEPENDENT THEME SELECTION OPTION (6 Independent Themes)
/// ---------------------------------------------------------------------------
enum AppIndependentThemeId {
  whiteMode,
  darkMode,
  wineAndSand,
  orangeAndMilk,
  midnightAndVanilla,
  blaze,
  custom,
}

class AppIndependentTheme {
  final AppIndependentThemeId id;
  final bool isDark;
  final AppThemePalette palette;
  final String? _customName;
  final String? _customPrimaryColorName;
  final String? _customBackgroundColorName;
  final String? _customDescription;
  final List<Color>? _customPreviewSwatches;

  const AppIndependentTheme({
    required this.id,
    required this.isDark,
    required this.palette,
    String? name,
    String? primaryColorName,
    String? backgroundColorName,
    String? description,
    List<Color>? previewSwatches,
  })  : _customName = name,
        _customPrimaryColorName = primaryColorName,
        _customBackgroundColorName = backgroundColorName,
        _customDescription = description,
        _customPreviewSwatches = previewSwatches;

  String get name => _customName ?? palette.name;
  String get primaryColorName => _customPrimaryColorName ?? palette.primaryColorName;
  String get backgroundColorName => _customBackgroundColorName ?? palette.backgroundColorName;
  String get description => _customDescription ?? palette.description;
  List<Color> get previewSwatches => _customPreviewSwatches ?? palette.previewSwatches;

  // 1. White Mode (Classic Light)
  static const whiteMode = AppIndependentTheme(
    id: AppIndependentThemeId.whiteMode,
    isDark: false,
    palette: AppThemePalette.whiteMode,
  );

  // 2. Dark Mode (Classic Dark)
  static const darkMode = AppIndependentTheme(
    id: AppIndependentThemeId.darkMode,
    isDark: true,
    palette: AppThemePalette.darkMode,
  );

  // 3. Wine Red + Light Sand
  static const wineAndSand = AppIndependentTheme(
    id: AppIndependentThemeId.wineAndSand,
    isDark: true,
    palette: AppThemePalette.wineAndSand,
  );

  // 4. Orange + Milk
  static const orangeAndMilk = AppIndependentTheme(
    id: AppIndependentThemeId.orangeAndMilk,
    isDark: false,
    palette: AppThemePalette.orangeAndMilk,
  );

  // 5. Midnight Indigo + Vanilla
  static const midnightAndVanilla = AppIndependentTheme(
    id: AppIndependentThemeId.midnightAndVanilla,
    isDark: false,
    palette: AppThemePalette.midnightAndVanilla,
  );

  // 6. Blaze Orange + Black
  static const blaze = AppIndependentTheme(
    id: AppIndependentThemeId.blaze,
    isDark: true,
    palette: AppThemePalette.blaze,
  );

  static const List<AppIndependentTheme> allThemes = [
    whiteMode,
    darkMode,
    wineAndSand,
    orangeAndMilk,
    midnightAndVanilla,
    blaze,
  ];

  static AppIndependentTheme fromId(String? rawId) {
    if (rawId == null) return darkMode;
    for (final t in allThemes) {
      if (t.id.name.toLowerCase() == rawId.toLowerCase()) return t;
    }
    return darkMode;
  }
}

/// ---------------------------------------------------------------------------
/// 4. TYPOGRAPHY CUSTOMIZATION: COMBINATIONS & PAIRINGS (5 Options)
/// ---------------------------------------------------------------------------
enum FontCombinationId {
  syneAndDmMono,
  gothamAndInter,
  leagueSpartanAndInter,
  megionAndDmSans,
  nofexAndInter,
  custom,
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
    headingStyleBuilder: GoogleFonts.montserrat,
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
    headingStyleBuilder: GoogleFonts.cinzel,
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
    headingStyleBuilder: GoogleFonts.spaceGrotesk,
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

/// ---------------------------------------------------------------------------
/// 5. DYNAMIC REGISTRY FOR RUNTIME EXTENSIBILITY
/// ---------------------------------------------------------------------------
/// Allows dynamic registration of custom themes and typography pairings at
/// runtime (e.g. from an API, tenant branding plugin, or user configuration).
class DynamicThemeRegistry {
  static final List<AppIndependentTheme> _customThemes = [];
  static final List<AppFontCombination> _customFonts = [];

  /// Get all available themes (built-in presets + custom registered themes)
  static List<AppIndependentTheme> get themes => [
        ...AppIndependentTheme.allThemes,
        ..._customThemes,
      ];

  /// Get all available typography pairings (built-in presets + custom registered fonts)
  static List<AppFontCombination> get fonts => [
        ...AppFontCombination.allCombinations,
        ..._customFonts,
      ];

  /// Register a dynamic custom theme at runtime
  static void registerTheme(AppIndependentTheme theme) {
    if (!_customThemes.any((t) => t.id.name == theme.id.name)) {
      _customThemes.add(theme);
    }
  }

  /// Register a dynamic custom font combination at runtime
  static void registerFont(AppFontCombination fontCombo) {
    if (!_customFonts.any((f) => f.id.name == fontCombo.id.name)) {
      _customFonts.add(fontCombo);
    }
  }

  /// Resolve theme by ID from presets or registered custom themes
  static AppIndependentTheme findTheme(String? id) {
    if (id == null) return AppIndependentTheme.darkMode;
    for (final theme in themes) {
      if (theme.id.name.toLowerCase() == id.toLowerCase()) return theme;
    }
    return AppIndependentTheme.darkMode;
  }

  /// Resolve font combination by ID from presets or registered custom fonts
  static AppFontCombination findFont(String? id) {
    if (id == null) return AppFontCombination.leagueSpartanAndInter;
    for (final font in fonts) {
      if (font.id.name.toLowerCase() == id.toLowerCase()) return font;
    }
    return AppFontCombination.leagueSpartanAndInter;
  }
}
