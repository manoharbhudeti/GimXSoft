import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/design_tokens.dart';
import 'sidebar.dart';
import 'top_nav_bar.dart';

class AppShell extends ConsumerStatefulWidget {
  final Widget child;

  const AppShell({super.key, required this.child});

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < DesignTokens.breakpointTablet;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.background(isDark),
      drawer: isMobile ? const Drawer(child: AppSidebar()) : null,
      body: Row(
        children: [
          // Sidebar on Desktop / Tablet
          if (!isMobile) const AppSidebar(),

          // Main View Area
          Expanded(
            child: Column(
              children: [
                TopNavBar(
                  onOpenDrawer: () => _scaffoldKey.currentState?.openDrawer(),
                ),
                Expanded(
                  child: widget.child,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

