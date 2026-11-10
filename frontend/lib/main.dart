import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const ProviderScope(
      child: GimXSoftApp(),
    ),
  );
}

class GimXSoftApp extends ConsumerWidget {
  const GimXSoftApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final selectedTheme = ref.watch(selectedThemeProvider);
    final fontCombo = ref.watch(fontCombinationProvider);

    return MaterialApp.router(
      title: 'GIMXSOFT - Smarter Fitness. Simpler Management.',
      debugShowCheckedModeBanner: false,
      themeMode: selectedTheme.isDark ? ThemeMode.dark : ThemeMode.light,
      theme: AppTheme.buildTheme(isDark: false, palette: selectedTheme.palette, fontCombo: fontCombo),
      darkTheme: AppTheme.buildTheme(isDark: true, palette: selectedTheme.palette, fontCombo: fontCombo),
      routerConfig: router,
    );
  }
}
