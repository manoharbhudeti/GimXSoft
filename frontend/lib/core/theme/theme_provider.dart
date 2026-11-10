import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_colors.dart';
import 'theme_customization_models.dart';

/// ---------------------------------------------------------------------------
/// INDEPENDENT THEME SELECTION NOTIFIER (6 Independent Themes)
/// ---------------------------------------------------------------------------
class SelectedThemeNotifier extends Notifier<AppIndependentTheme> {
  static const _prefKey = 'app_selected_theme_id';

  @override
  AppIndependentTheme build() {
    _loadFromPrefs();
    final defaultTheme = AppIndependentTheme.darkMode;
    AppColors.setPalette(defaultTheme.palette);
    return defaultTheme;
  }

  Future<void> _loadFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final rawId = prefs.getString(_prefKey);
      if (rawId != null) {
        final theme = AppIndependentTheme.fromId(rawId);
        AppColors.setPalette(theme.palette);
        state = theme;
        // Keep themeModeProvider aligned
        ref.read(themeModeProvider.notifier).setModeSilently(theme.isDark ? ThemeMode.dark : ThemeMode.light);
      }
    } catch (_) {}
  }

  Future<void> setTheme(AppIndependentTheme theme) async {
    AppColors.setPalette(theme.palette);
    state = theme;
    // Align theme mode with the theme's intrinsic brightness
    ref.read(themeModeProvider.notifier).setModeSilently(theme.isDark ? ThemeMode.dark : ThemeMode.light);

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefKey, theme.id.name);
      await prefs.setString('app_theme_mode', theme.isDark ? 'dark' : 'light');
    } catch (_) {}
  }
}

final selectedThemeProvider = NotifierProvider<SelectedThemeNotifier, AppIndependentTheme>(SelectedThemeNotifier.new);

/// ---------------------------------------------------------------------------
/// THEME MODE NOTIFIER (Backwards compatibility & Top-Nav quick toggling)
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
      state = mode == 'light' ? ThemeMode.light : ThemeMode.dark;
    } catch (_) {}
  }

  void setModeSilently(ThemeMode mode) {
    state = mode;
  }

  Future<void> toggle() async {
    final nextMode = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    if (nextMode == ThemeMode.light) {
      await ref.read(selectedThemeProvider.notifier).setTheme(AppIndependentTheme.whiteMode);
    } else {
      await ref.read(selectedThemeProvider.notifier).setTheme(AppIndependentTheme.darkMode);
    }
  }

  Future<void> setMode(ThemeMode mode) async {
    state = mode;
    if (mode == ThemeMode.light) {
      await ref.read(selectedThemeProvider.notifier).setTheme(AppIndependentTheme.whiteMode);
    } else {
      await ref.read(selectedThemeProvider.notifier).setTheme(AppIndependentTheme.darkMode);
    }
  }

  bool get isDark => state == ThemeMode.dark;
}

final themeModeProvider = NotifierProvider<ThemeModeNotifier, ThemeMode>(ThemeModeNotifier.new);

/// ---------------------------------------------------------------------------
/// PALETTE PROVIDER (Backwards compatibility for existing code)
/// ---------------------------------------------------------------------------
final themePaletteProvider = Provider<AppThemePalette>((ref) {
  return ref.watch(selectedThemeProvider).palette;
});

/// ---------------------------------------------------------------------------
/// FONT COMBINATION NOTIFIER (5 Independent Typography Combinations)
/// ---------------------------------------------------------------------------
class FontCombinationNotifier extends Notifier<AppFontCombination> {
  static const _prefKey = 'app_selected_font_id';

  @override
  AppFontCombination build() {
    _loadFromPrefs();
    return AppFontCombination.leagueSpartanAndInter;
  }

  Future<void> _loadFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final rawId = prefs.getString(_prefKey);
      if (rawId != null) {
        state = AppFontCombination.fromId(rawId);
      }
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
/// RESET HELPER (Restores default Dark Mode & League Spartan + Inter)
/// ---------------------------------------------------------------------------
extension ThemeResetExtension on WidgetRef {
  Future<void> resetAllCustomizations() async {
    await read(selectedThemeProvider.notifier).setTheme(AppIndependentTheme.darkMode);
    await read(fontCombinationProvider.notifier).setFontCombination(AppFontCombination.leagueSpartanAndInter);
  }
}
