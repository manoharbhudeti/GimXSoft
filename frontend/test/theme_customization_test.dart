import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:frontend/core/theme/app_theme.dart';
import 'package:frontend/core/theme/theme_customization_models.dart';
import 'package:frontend/features/settings/widgets/theme_customization_section.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  group('Independent Theme Models & 6 Presets', () {
    test('All 6 Required Independent Themes Exist with Dedicated Palettes & Modes', () {
      expect(AppIndependentTheme.allThemes.length, equals(6));

      // 1. White Mode (existing light)
      final whiteMode = AppIndependentTheme.whiteMode;
      expect(whiteMode.name, equals('White Mode'));
      expect(whiteMode.primaryColorName, equals('Athletic Orange'));
      expect(whiteMode.backgroundColorName, equals('Porcelain White'));
      expect(whiteMode.isDark, isFalse);
      expect(whiteMode.palette.primary, equals(const Color(0xFFEA580C)));
      expect(whiteMode.palette.lightBackground, equals(const Color(0xFFFAF7F2)));

      // 2. Dark Mode (existing dark)
      final darkMode = AppIndependentTheme.darkMode;
      expect(darkMode.name, equals('Dark Mode'));
      expect(darkMode.primaryColorName, equals('Athletic Orange'));
      expect(darkMode.backgroundColorName, equals('Obsidian Void'));
      expect(darkMode.isDark, isTrue);
      expect(darkMode.palette.primary, equals(const Color(0xFFEA580C)));
      expect(darkMode.palette.darkBackground, equals(const Color(0xFF141415)));

      // 3. Wine Red + Light Sand
      final wine = AppIndependentTheme.wineAndSand;
      expect(wine.name, equals('Wine Red + Light Sand'));
      expect(wine.primaryColorName, equals('Wine Red'));
      expect(wine.backgroundColorName, equals('Light Sand'));
      expect(wine.isDark, isFalse);
      expect(wine.palette.primary, equals(const Color(0xFF881337)));
      expect(wine.palette.lightBackground, equals(const Color(0xFFF7F4EE)));

      // 4. Orange + Milk
      final orange = AppIndependentTheme.orangeAndMilk;
      expect(orange.name, equals('Orange + Milk'));
      expect(orange.primaryColorName, equals('Orange'));
      expect(orange.backgroundColorName, equals('Milk'));
      expect(orange.isDark, isFalse);
      expect(orange.palette.primary, equals(const Color(0xFFEA580C)));
      expect(orange.palette.lightBackground, equals(const Color(0xFFFAF7F2)));

      // 5. Midnight Indigo + Vanilla
      final midnight = AppIndependentTheme.midnightAndVanilla;
      expect(midnight.name, equals('Midnight Indigo + Vanilla'));
      expect(midnight.primaryColorName, equals('Midnight Indigo'));
      expect(midnight.backgroundColorName, equals('Vanilla'));
      expect(midnight.isDark, isFalse);
      expect(midnight.palette.primary, equals(const Color(0xFF4F46E5)));
      expect(midnight.palette.lightBackground, equals(const Color(0xFFFDFBF7)));

      // 6. Blaze Orange + Black
      final blaze = AppIndependentTheme.blaze;
      expect(blaze.name, equals('Blaze Orange + Black'));
      expect(blaze.primaryColorName, equals('Blaze Orange'));
      expect(blaze.backgroundColorName, equals('Black'));
      expect(blaze.isDark, isTrue);
      expect(blaze.palette.primary, equals(const Color(0xFFFF5722)));
      expect(blaze.palette.darkBackground, equals(const Color(0xFF0A0A0A)));
    });

    test('AppIndependentTheme fromId resolution and default fallback', () {
      expect(AppIndependentTheme.fromId('whiteMode').id, equals(AppIndependentThemeId.whiteMode));
      expect(AppIndependentTheme.fromId('darkMode').id, equals(AppIndependentThemeId.darkMode));
      expect(AppIndependentTheme.fromId('wineAndSand').id, equals(AppIndependentThemeId.wineAndSand));
      expect(AppIndependentTheme.fromId('orangeAndMilk').id, equals(AppIndependentThemeId.orangeAndMilk));
      expect(AppIndependentTheme.fromId('midnightAndVanilla').id, equals(AppIndependentThemeId.midnightAndVanilla));
      expect(AppIndependentTheme.fromId('blaze').id, equals(AppIndependentThemeId.blaze));
      expect(AppIndependentTheme.fromId('invalid_id').id, equals(AppIndependentThemeId.darkMode));
      expect(AppIndependentTheme.fromId(null).id, equals(AppIndependentThemeId.darkMode));
    });
  });

  group('Typography Combinations Models & 5 Presets', () {
    test('All 5 Required Typography Combinations Exist', () {
      expect(AppFontCombination.allCombinations.length, equals(5));

      final combos = AppFontCombination.allCombinations;
      expect(combos.any((c) => c.name == 'Syne + DM Mono'), isTrue);
      expect(combos.any((c) => c.name == 'Gotham + Inter'), isTrue);
      expect(combos.any((c) => c.name == 'League Spartan + Inter'), isTrue);
      expect(combos.any((c) => c.name == 'Megion + DM Sans'), isTrue);
      expect(combos.any((c) => c.name == 'Nofex + Inter'), isTrue);
    });

    test('AppFontCombination fromId resolution and fallback', () {
      expect(AppFontCombination.fromId('syneAndDmMono').id, equals(FontCombinationId.syneAndDmMono));
      expect(AppFontCombination.fromId('megionAndDmSans').id, equals(FontCombinationId.megionAndDmSans));
      expect(AppFontCombination.fromId('unknown').id, equals(FontCombinationId.leagueSpartanAndInter));
    });
  });

  group('Dynamic AppTheme Builder', () {
    test('AppTheme.buildTheme builds cohesive ThemeData for Dark & Light modes', () {
      final darkTheme = AppTheme.buildTheme(
        isDark: true,
        palette: AppThemePalette.wineAndSand,
        fontCombo: AppFontCombination.syneAndDmMono,
      );

      expect(darkTheme.brightness, equals(Brightness.dark));
      expect(darkTheme.primaryColor, equals(AppThemePalette.wineAndSand.primary));
      expect(darkTheme.scaffoldBackgroundColor, equals(AppThemePalette.wineAndSand.darkBackground));
      expect(darkTheme.colorScheme.primary, equals(AppThemePalette.wineAndSand.primary));

      final lightTheme = AppTheme.buildTheme(
        isDark: false,
        palette: AppThemePalette.midnightAndVanilla,
        fontCombo: AppFontCombination.gothamAndInter,
      );

      expect(lightTheme.brightness, equals(Brightness.light));
      expect(lightTheme.primaryColor, equals(AppThemePalette.midnightAndVanilla.primary));
      expect(lightTheme.scaffoldBackgroundColor, equals(AppThemePalette.midnightAndVanilla.lightBackground));
    });
  });

  group('ThemeCustomizationSection Widget Tests', () {
    testWidgets('Renders all 6 independent themes, 5 typography options, swatches, and controls', (tester) async {
      tester.view.physicalSize = const Size(1920, 2000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: ThemeCustomizationSection(isDark: true),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify Header
      expect(find.text('Theme & Typography Studio'), findsOneWidget);
      expect(find.text('Reset to Defaults'), findsOneWidget);

      // Verify All 6 Independent Themes in row-by-row layout
      expect(find.text('White Mode'), findsOneWidget);
      expect(find.text('Dark Mode'), findsOneWidget);
      expect(find.text('Wine Red + Light Sand'), findsOneWidget);
      expect(find.text('Orange + Milk'), findsOneWidget);
      expect(find.text('Midnight Indigo + Vanilla'), findsOneWidget);
      expect(find.text('Blaze Orange + Black'), findsOneWidget);

      // Verify Color Pairings Description text
      expect(find.text('Athletic Orange  •  Porcelain White'), findsOneWidget);
      expect(find.text('Athletic Orange  •  Obsidian Void'), findsOneWidget);
      expect(find.text('Wine Red  •  Light Sand'), findsOneWidget);
      expect(find.text('Orange  •  Milk'), findsOneWidget);
      expect(find.text('Midnight Indigo  •  Vanilla'), findsOneWidget);
      expect(find.text('Blaze Orange  •  Black'), findsOneWidget);

      // Verify 5 Typography Combinations
      expect(find.text('Syne + DM Mono'), findsOneWidget);
      expect(find.text('Gotham + Inter'), findsOneWidget);
      expect(find.text('League Spartan + Inter'), findsOneWidget);
      expect(find.text('Megion + DM Sans'), findsOneWidget);
      expect(find.text('Nofex + Inter'), findsOneWidget);

      // Verify Live Sandbox Preview
      expect(find.text('Live Component Sandbox Preview'), findsOneWidget);
      expect(find.text('Titan Performance Club'), findsOneWidget);
    });

    testWidgets('Tapping on an Independent Theme row updates selection and maintains font', (tester) async {
      tester.view.physicalSize = const Size(1920, 2000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: ThemeCustomizationSection(isDark: true),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Tap on Midnight Indigo + Vanilla row
      await tester.tap(find.text('Midnight Indigo + Vanilla'));
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pumpAndSettle(const Duration(seconds: 5));

      expect(find.text('Active: Midnight Indigo + Vanilla'), findsOneWidget);
      // Font combination should remain unchanged (League Spartan + Inter)
      expect(find.text('Active: League Spartan + Inter'), findsOneWidget);
    });

    testWidgets('Tapping on a Typography option updates selection and maintains theme', (tester) async {
      tester.view.physicalSize = const Size(1920, 2000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: ThemeCustomizationSection(isDark: true),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Tap on Syne + DM Mono card
      await tester.tap(find.text('Syne + DM Mono'));
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pumpAndSettle(const Duration(seconds: 5));

      expect(find.text('Active: Syne + DM Mono'), findsOneWidget);
      // Theme should remain unchanged (Dark Mode default)
      expect(find.text('Active: Dark Mode'), findsOneWidget);
    });

    testWidgets('Reset to Defaults restores Dark Mode and League Spartan + Inter', (tester) async {
      tester.view.physicalSize = const Size(1920, 2000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: ThemeCustomizationSection(isDark: true),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // First change theme to Blaze Orange + Black
      await tester.tap(find.text('Blaze Orange + Black'));
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pumpAndSettle(const Duration(seconds: 5));
      expect(find.text('Active: Blaze Orange + Black'), findsOneWidget);

      // Now click Reset to Defaults
      await tester.tap(find.text('Reset to Defaults'));
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pumpAndSettle(const Duration(seconds: 5));

      expect(find.text('Active: Dark Mode'), findsOneWidget);
      expect(find.text('Active: League Spartan + Inter'), findsOneWidget);
    });
  });
}
