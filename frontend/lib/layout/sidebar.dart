import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/design_tokens.dart';
import '../core/theme/theme_customization_models.dart';
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
        color: isDark ? AppColors.darkDeepest : AppColors.lightCard,
        border: Border(
          right: BorderSide(color: AppColors.border(isDark), width: 1),
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
                bottom: BorderSide(color: AppColors.border(isDark), width: 1),
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
                            color: AppColors.activePalette.id == ThemePaletteId.wineAndSand
                                ? const Color(0xFFF7F4EE)
                                : AppColors.primary,
                            borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
                          ),
                          child: Center(
                            child: Icon(
                              Icons.fitness_center_rounded,
                              color: AppColors.activePalette.id == ThemePaletteId.wineAndSand
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
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: -0.2,
                                  color: AppColors.textPrimary(isDark),
                                ),
                              ),
                              Text(
                                'Gym Operations',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w400,
                                  color: AppColors.textMuted(isDark),
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
                      color: AppColors.textMuted(isDark),
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
                        color: AppColors.activePalette.id == ThemePaletteId.wineAndSand
                            ? const Color(0xFFF7F4EE)
                            : AppColors.primary,
                        borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.fitness_center_rounded,
                          color: AppColors.activePalette.id == ThemePaletteId.wineAndSand
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
                top: BorderSide(color: AppColors.border(isDark), width: 1),
              ),
            ),
            child: isCollapsed
                ? Center(
                    child: IconButton(
                      icon: Icon(Icons.chevron_right_rounded, color: AppColors.textMuted(isDark), size: 18),
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
                          color: AppColors.raised(isDark),
                          borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
                          border: Border.all(color: AppColors.border(isDark)),
                        ),
                        child: Center(
                          child: Text(
                            authState.tenant?.name.isNotEmpty == true
                                ? authState.tenant!.name[0].toUpperCase()
                                : 'T',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textPrimary(isDark),
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
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textPrimary(isDark),
                              ),
                            ),
                            Text(
                              authState.selectedBranch?.name ?? 'Downtown Flagship',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 11,
                                color: AppColors.textMuted(isDark),
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

  const _SidebarTile({
    required this.item,
    required this.isActive,
    required this.isCollapsed,
    required this.onTap,
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
        ? AppColors.raised(isDark)
        : (_isHovered
            ? (isDark ? const Color(0x1F232325) : const Color(0xFFF4F4F5))
            : Colors.transparent);

    final iconColor = widget.isActive
        ? AppColors.textPrimary(isDark)
        : (_isHovered ? AppColors.textPrimary(isDark) : AppColors.textMuted(isDark));

    final textColor = widget.isActive
        ? AppColors.textPrimary(isDark)
        : (_isHovered ? AppColors.textPrimary(isDark) : AppColors.textSecondary(isDark));

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
                ? Border.all(color: AppColors.border(isDark).withOpacity(0.18), width: 1)
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
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: widget.isActive ? FontWeight.w500 : FontWeight.w400,
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
