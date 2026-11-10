import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_colors.dart';
import 'theme_customization_models.dart';

/// ---------------------------------------------------------------------------
/// THEME MODE NOTIFIER (Dark / Light)
/// ---------------------------------------------------------------------------
class ThemeModeNotifier extends Notifier<ThemeMode> {
  static const _prefKey = 'app_theme_mode';

  @override
  ThemeMode build() {
    _loadFromPrefs();
    return ThemeMode.dark;
  }

  Future<void> _loadFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final mode = prefs.getString(_prefKey);
      if (mode == 'light') {
        state = ThemeMode.light;
      } else {
        state = ThemeMode.dark;
      }
    } catch (_) {}
  }

  Future<void> toggle() async {
    final next = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    await setMode(next);
  }

  Future<void> setMode(ThemeMode mode) async {
    state = mode;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefKey, mode == ThemeMode.dark ? 'dark' : 'light');
    } catch (_) {}
  }

  bool get isDark => state == ThemeMode.dark;
}

final themeModeProvider = NotifierProvider<ThemeModeNotifier, ThemeMode>(ThemeModeNotifier.new);

/// ---------------------------------------------------------------------------
/// THEME PALETTE NOTIFIER (Wine & Sand, Orange & Milk, Midnight & Vanilla, Blaze)
/// ---------------------------------------------------------------------------
class ThemePaletteNotifier extends Notifier<AppThemePalette> {
  static const _prefKey = 'app_theme_palette_id';

  @override
  AppThemePalette build() {
    _loadFromPrefs();
    // Default palette
    final defaultPalette = AppThemePalette.orangeAndMilk;
    AppColors.setPalette(defaultPalette);
    return defaultPalette;
  }

  Future<void> _loadFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final rawId = prefs.getString(_prefKey);
      final palette = AppThemePalette.fromId(rawId);
      AppColors.setPalette(palette);
      state = palette;
    } catch (_) {}
  }

  Future<void> setPalette(AppThemePalette palette) async {
    AppColors.setPalette(palette);
    state = palette;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefKey, palette.id.name);
    } catch (_) {}
  }
}

final themePaletteProvider = NotifierProvider<ThemePaletteNotifier, AppThemePalette>(ThemePaletteNotifier.new);

/// ---------------------------------------------------------------------------
/// FONT COMBINATION NOTIFIER (Syne+DM Mono, Gotham+Inter, League Spartan+Inter, Megion+DM Sans, Nofex+Inter)
/// ---------------------------------------------------------------------------
class FontCombinationNotifier extends Notifier<AppFontCombination> {
  static const _prefKey = 'app_font_combination_id';

  @override
  AppFontCombination build() {
    _loadFromPrefs();
    return AppFontCombination.leagueSpartanAndInter;
  }

  Future<void> _loadFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final rawId = prefs.getString(_prefKey);
      final fontCombo = AppFontCombination.fromId(rawId);
      state = fontCombo;
    } catch (_) {}
  }

  Future<void> setFontCombination(AppFontCombination fontCombo) async {
    state = fontCombo;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefKey, fontCombo.id.name);
    } catch (_) {}
  }
}

final fontCombinationProvider = NotifierProvider<FontCombinationNotifier, AppFontCombination>(FontCombinationNotifier.new);

/// ---------------------------------------------------------------------------
/// RESET HELPER
/// ---------------------------------------------------------------------------
extension ThemeResetExtension on WidgetRef {
  Future<void> resetAllCustomizations() async {
    await read(themePaletteProvider.notifier).setPalette(AppThemePalette.orangeAndMilk);
    await read(fontCombinationProvider.notifier).setFontCombination(AppFontCombination.leagueSpartanAndInter);
    await read(themeModeProvider.notifier).setMode(ThemeMode.dark);
  }
}
