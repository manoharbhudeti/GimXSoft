import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_theme.dart';
import 'package:frontend/core/theme/theme_customization_models.dart';
import 'package:frontend/core/theme/theme_provider.dart';
import 'package:frontend/features/settings/widgets/theme_customization_section.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  group('Dynamic Theme Palette Models & Presets', () {
    test('All 4 Required Themes Exist with Distinct Color Palettes', () {
      expect(AppThemePalette.allPalettes.length, equals(4));

      // 1. Wine & Sand
      final wine = AppThemePalette.wineAndSand;
      expect(wine.name, equals('Wine & Sand'));
      expect(wine.primaryColorName, equals('Wine Red'));
      expect(wine.backgroundColorName, equals('Light Sand'));
      expect(wine.primary, equals(const Color(0xFF881337)));
      expect(wine.lightBackground, equals(const Color(0xFFF7F4EE)));

      // 2. Orange & Milk
      final orange = AppThemePalette.orangeAndMilk;
      expect(orange.name, equals('Orange & Milk'));
      expect(orange.primaryColorName, equals('Orange'));
      expect(orange.backgroundColorName, equals('Milk'));
      expect(orange.primary, equals(const Color(0xFFEA580C)));
      expect(orange.lightBackground, equals(const Color(0xFFFAF7F2)));

      // 3. Midnight & Vanilla
      final midnight = AppThemePalette.midnightAndVanilla;
      expect(midnight.name, equals('Midnight & Vanilla'));
      expect(midnight.primaryColorName, equals('Midnight Indigo'));
      expect(midnight.backgroundColorName, equals('Vanilla'));
      expect(midnight.primary, equals(const Color(0xFF4F46E5)));
      expect(midnight.lightBackground, equals(const Color(0xFFFDFBF7)));

      // 4. Blaze
      final blaze = AppThemePalette.blaze;
      expect(blaze.name, equals('Blaze'));
      expect(blaze.primaryColorName, equals('Blaze Orange'));
      expect(blaze.backgroundColorName, equals('Black'));
      expect(blaze.primary, equals(const Color(0xFFFF5722)));
      expect(blaze.darkBackground, equals(const Color(0xFF0A0A0A)));
    });

    test('AppThemePalette fromId resolution and default fallback', () {
      expect(AppThemePalette.fromId('wineAndSand').id, equals(ThemePaletteId.wineAndSand));
      expect(AppThemePalette.fromId('blaze').id, equals(ThemePaletteId.blaze));
      expect(AppThemePalette.fromId('invalid_id').id, equals(ThemePaletteId.orangeAndMilk));
      expect(AppThemePalette.fromId(null).id, equals(ThemePaletteId.orangeAndMilk));
    });
  });

  group('Typography Combinations Models & Presets', () {
    test('All 5 Required Typography Combinations Exist', () {
      expect(AppFontCombination.allCombinations.length, equals(5));

      final combos = AppFontCombination.allCombinations;
      expect(combos.any((c) => c.name.contains('Syne') && c.name.contains('DM Mono')), isTrue);
      expect(combos.any((c) => c.name.contains('Gotham') && c.name.contains('Inter')), isTrue);
      expect(combos.any((c) => c.name.contains('League Spartan') && c.name.contains('Inter')), isTrue);
      expect(combos.any((c) => c.name.contains('Megion') && c.name.contains('DM Sans')), isTrue);
      expect(combos.any((c) => c.name.contains('Nofex') && c.name.contains('Inter')), isTrue);
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
    testWidgets('Renders all 4 themes, 5 typography options, and interactive controls', (tester) async {
      tester.view.physicalSize = const Size(1920, 1400);
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

      // Verify 4 Theme Palettes
      expect(find.text('Wine & Sand'), findsOneWidget);
      expect(find.text('Orange & Milk'), findsOneWidget);
      expect(find.text('Midnight & Vanilla'), findsOneWidget);
      expect(find.text('Blaze'), findsOneWidget);

      // Verify Color Pairings Description text
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

    testWidgets('Tapping on a Theme Palette updates selection', (tester) async {
      tester.view.physicalSize = const Size(1920, 1400);
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

      // Tap on Midnight & Vanilla card
      await tester.tap(find.text('Midnight & Vanilla'));
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pumpAndSettle(const Duration(seconds: 5));

      expect(find.text('Active: Midnight & Vanilla'), findsOneWidget);
    });

    testWidgets('Tapping on a Typography option updates selection', (tester) async {
      tester.view.physicalSize = const Size(1920, 1400);
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
    });
  });
}
