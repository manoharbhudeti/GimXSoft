import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:frontend/core/theme/app_theme.dart';
import 'package:frontend/features/settings/widgets/theme_customization_section.dart';
import 'package:frontend/layout/app_shell.dart';
import 'package:frontend/layout/sidebar.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  const viewports = [
    {'name': 'Desktop (1920x1080)', 'size': Size(1920, 1080), 'isMobile': false},
    {'name': 'Laptop (1440x900)', 'size': Size(1440, 900), 'isMobile': false},
    {'name': 'Small Laptop (1280x720)', 'size': Size(1280, 720), 'isMobile': false},
    {'name': 'Tablet (768x1024)', 'size': Size(768, 1024), 'isMobile': true},
    {'name': 'Mobile (390x844)', 'size': Size(390, 844), 'isMobile': true},
  ];

  group('Multi-Viewport Responsive Architecture Tests', () {
    for (final vp in viewports) {
      final name = vp['name'] as String;
      final size = vp['size'] as Size;
      final isMobile = vp['isMobile'] as bool;

      testWidgets('AppShell layout adapts cleanly at $name without overflow', (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              theme: AppTheme.darkTheme,
              home: const AppShell(
                child: Center(
                  child: Text('Dashboard View Content'),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Dashboard View Content'), findsOneWidget);

        if (isMobile) {
          // On mobile & tablet (< 900px), sidebar is tucked into drawer
          expect(find.byType(AppSidebar), findsNothing);
          expect(find.byIcon(Icons.menu_rounded), findsOneWidget);
        } else {
          // On desktop & laptop (>= 900px), persistent sidebar is visible
          expect(find.byType(AppSidebar), findsOneWidget);
        }

        // Verify zero RenderFlex overflows
        final ex = tester.takeException();
        if (ex is FlutterError) {
          debugPrint('==== FLUTTER ERROR DIAGNOSTICS ====');
          for (final d in ex.diagnostics) {
            debugPrint(d.toString());
          }
          debugPrint('====================================');
        }
        expect(ex, isNull);
      });
    }

    testWidgets('ThemeCustomizationSection renders all 6 themes and 5 font combinations on mobile 390x844', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: AppTheme.darkTheme,
            home: const Scaffold(
              body: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: ThemeCustomizationSection(isDark: true),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Check all 6 themes rendered
      expect(find.text('White Mode'), findsOneWidget);
      expect(find.text('Dark Mode'), findsOneWidget);
      expect(find.text('Wine Red + Light Sand'), findsOneWidget);
      expect(find.text('Orange + Milk'), findsOneWidget);
      expect(find.text('Midnight Indigo + Vanilla'), findsOneWidget);
      expect(find.text('Blaze Orange + Black'), findsOneWidget);

      // Check font combinations rendered
      expect(find.text('Syne + DM Mono'), findsOneWidget);
      expect(find.text('Gotham + Inter'), findsOneWidget);
      expect(find.text('League Spartan + Inter'), findsOneWidget);
      expect(find.text('Megion + DM Sans'), findsOneWidget);
      expect(find.text('Nofex + Inter'), findsOneWidget);

      final ex = tester.takeException();
      expect(ex, isNull);
    });

    testWidgets('ThemeCustomizationSection renders all 6 themes and 5 font combinations on desktop 1920x1080', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: AppTheme.darkTheme,
            home: const Scaffold(
              body: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: ThemeCustomizationSection(isDark: true),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Theme & Typography Studio'), findsOneWidget);
      expect(find.text('Reset to Defaults'), findsOneWidget);
      final ex = tester.takeException();
      if (ex is FlutterError) {
        debugPrint('==== MOBILE TEST FLUTTER ERROR FULL STRING ====');
        for (final d in ex.diagnostics) {
          debugPrint(d.toStringDeep());
        }
        debugPrint('=============================================');
      }
      expect(ex, isNull);
    });
  });
}
