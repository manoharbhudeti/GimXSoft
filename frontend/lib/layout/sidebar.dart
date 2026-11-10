import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../core/theme/design_tokens.dart';
import '../core/theme/theme_customization_models.dart';
import '../core/theme/theme_provider.dart';
import '../features/auth/auth_provider.dart';
import 'navigation_items.dart';

class SidebarCollapsedNotifier extends Notifier<bool> {
  @override
  bool build() => false;
  void toggle() => state = !state;
  void collapse() => state = true;
  void expand() => state = false;
}

final sidebarCollapsedProvider = NotifierProvider<SidebarCollapsedNotifier, bool>(SidebarCollapsedNotifier.new);

/// Unslopped Sidebar Component:
/// - 256px desktop width
/// - Quiet flat logo mark (no neon glow or purple gradients)
/// - Navigation rows 36px tall, 2px gap, 20px above sections
/// - Active item uses subtle surface step and hairline rather than glowing violet
class AppSidebar extends ConsumerWidget {
  const AppSidebar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedTheme = ref.watch(selectedThemeProvider);
    final fontCombo = ref.watch(fontCombinationProvider);
    final palette = selectedTheme.palette;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isCollapsed = ref.watch(sidebarCollapsedProvider);
    final authState = ref.watch(authProvider);
    String currentPath = '/dashboard';
    try {
      currentPath = GoRouterState.of(context).matchedLocation;
    } catch (_) {}

    final width = isCollapsed ? 64.0 : 256.0;

    return AnimatedContainer(
      duration: DesignTokens.durationNormal,
      curve: DesignTokens.easeOutStandard,
      width: width,
      decoration: BoxDecoration(
        color: palette.surface(isDark),
        border: Border(
          right: BorderSide(color: palette.border(isDark), width: 1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Header with Flat Clean Brand
          Container(
            height: 56,
            padding: EdgeInsets.symmetric(horizontal: isCollapsed ? 14 : DesignTokens.space16),
            alignment: Alignment.centerLeft,
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: palette.border(isDark), width: 1),
              ),
            ),
            child: Row(
              mainAxisAlignment: isCollapsed ? MainAxisAlignment.center : MainAxisAlignment.spaceBetween,
              children: [
                if (!isCollapsed) ...[
                  Expanded(
                    child: Row(
                      children: [
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: palette.id == ThemePaletteId.wineAndSand
                                ? const Color(0xFFF7F4EE)
                                : palette.primary,
                            borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
                          ),
                          child: Center(
                            child: Icon(
                              Icons.fitness_center_rounded,
                              color: palette.id == ThemePaletteId.wineAndSand
                                  ? const Color(0xFF380811)
                                  : Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                        const SizedBox(width: DesignTokens.space10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'GimXSoft',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: fontCombo.headingStyleBuilder(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: -0.2,
                                  color: palette.textPrimary(isDark),
                                ),
                              ),
                              Text(
                                'Gym Operations',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: fontCombo.bodyStyleBuilder(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w400,
                                  color: palette.textMuted(isDark),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.chevron_left_rounded,
                      size: 18,
                      color: palette.textMuted(isDark),
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                    splashRadius: 16,
                    onPressed: () => ref.read(sidebarCollapsedProvider.notifier).collapse(),
                  ),
                ] else ...[
                  InkWell(
                    onTap: () => ref.read(sidebarCollapsedProvider.notifier).expand(),
                    borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: palette.id == ThemePaletteId.wineAndSand
                            ? const Color(0xFFF7F4EE)
                            : palette.primary,
                        borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.fitness_center_rounded,
                          color: palette.id == ThemePaletteId.wineAndSand
                              ? const Color(0xFF380811)
                              : Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),

          // 2. Navigation Items List (Dense, 36px rows, 2px gap)
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(
                vertical: DesignTokens.space8,
                horizontal: DesignTokens.space8,
              ),
              itemCount: kNavigationItems.length,
              separatorBuilder: (context, index) => const SizedBox(height: 2),
              itemBuilder: (context, index) {
                final item = kNavigationItems[index];
                final isActive = currentPath == item.path ||
                    (item.path != '/' && currentPath.startsWith(item.path));

                return _SidebarTile(
                  item: item,
                  isActive: isActive,
                  isCollapsed: isCollapsed,
                  palette: palette,
                  fontCombo: fontCombo,
                  onTap: () => context.go(item.path),
                );
              },
            ),
          ),

          // 3. Bottom Footer / Context Info
          Container(
            padding: const EdgeInsets.all(DesignTokens.space12),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: palette.border(isDark), width: 1),
              ),
            ),
            child: isCollapsed
                ? Center(
                    child: IconButton(
                      icon: Icon(Icons.chevron_right_rounded, color: palette.textMuted(isDark), size: 18),
                      splashRadius: 16,
                      onPressed: () => ref.read(sidebarCollapsedProvider.notifier).expand(),
                    ),
                  )
                : Row(
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: palette.raised(isDark),
                          borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
                          border: Border.all(color: palette.border(isDark)),
                        ),
                        child: Center(
                          child: Text(
                            authState.tenant?.name.isNotEmpty == true
                                ? authState.tenant!.name[0].toUpperCase()
                                : 'T',
                            style: fontCombo.headingStyleBuilder(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: palette.textPrimary(isDark),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: DesignTokens.space8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              authState.tenant?.name ?? 'Titan Performance',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: fontCombo.bodyStyleBuilder(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: palette.textPrimary(isDark),
                              ),
                            ),
                            Text(
                              authState.selectedBranch?.name ?? 'Downtown Flagship',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: fontCombo.bodyStyleBuilder(
                                fontSize: 11,
                                color: palette.textMuted(isDark),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class _SidebarTile extends StatefulWidget {
  final NavigationItem item;
  final bool isActive;
  final bool isCollapsed;
  final VoidCallback onTap;
  final AppThemePalette palette;
  final AppFontCombination fontCombo;

  const _SidebarTile({
    required this.item,
    required this.isActive,
    required this.isCollapsed,
    required this.onTap,
    required this.palette,
    required this.fontCombo,
  });

  @override
  State<_SidebarTile> createState() => _SidebarTileState();
}

class _SidebarTileState extends State<_SidebarTile> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Active item uses small surface step and hairline; inactive hover uses light raised
    final bgColor = widget.isActive
        ? widget.palette.raised(isDark)
        : (_isHovered
            ? (isDark
                ? widget.palette.raised(isDark).withOpacity(0.5)
                : widget.palette.raised(isDark).withOpacity(0.7))
            : Colors.transparent);

    final iconColor = widget.isActive
        ? (widget.palette.id == ThemePaletteId.wineAndSand
            ? const Color(0xFFF7F4EE)
            : widget.palette.primary)
        : (_isHovered ? widget.palette.textPrimary(isDark) : widget.palette.textMuted(isDark));

    final textColor = widget.isActive
        ? widget.palette.textPrimary(isDark)
        : (_isHovered ? widget.palette.textPrimary(isDark) : widget.palette.textSecondary(isDark));

    Widget tile = MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: DesignTokens.durationFast,
          curve: DesignTokens.easeOutStandard,
          height: 36, // Exact 36px token height
          padding: EdgeInsets.symmetric(
            horizontal: widget.isCollapsed ? 0 : DesignTokens.space10,
          ),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
            border: widget.isActive
                ? Border.all(color: widget.palette.border(isDark).withOpacity(0.35), width: 1)
                : null,
          ),
          child: Row(
            mainAxisAlignment: widget.isCollapsed ? MainAxisAlignment.center : MainAxisAlignment.start,
            children: [
              Icon(widget.item.icon, size: 16, color: iconColor),
              if (!widget.isCollapsed) ...[
                const SizedBox(width: DesignTokens.space10),
                Expanded(
                  child: Text(
                    widget.item.title,
                    style: widget.fontCombo.bodyStyleBuilder(
                      fontSize: 13,
                      fontWeight: widget.isActive ? FontWeight.w600 : FontWeight.w400,
                      color: textColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );

    if (widget.isCollapsed) {
      return Tooltip(
        message: widget.item.title,
        waitDuration: const Duration(milliseconds: 300),
        child: tile,
      );
    }

    return tile;
  }
}
