import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/design_tokens.dart';
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

class AppSidebar extends ConsumerWidget {
  const AppSidebar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isCollapsed = ref.watch(sidebarCollapsedProvider);
    final authState = ref.watch(authProvider);
    final currentPath = GoRouterState.of(context).matchedLocation;

    final width = isCollapsed ? 74.0 : 250.0;

    return AnimatedContainer(
      duration: DesignTokens.durationNormal,
      curve: Curves.easeInOutCubic,
      width: width,
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        border: Border(
          right: BorderSide(color: AppColors.border(isDark), width: 1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Header with Logo & Brand
          Container(
            height: 64,
            padding: const EdgeInsets.symmetric(horizontal: DesignTokens.space16),
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
                  Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppColors.primary, AppColors.accentCyan],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: DesignTokens.borderMd,
                          boxShadow: DesignTokens.glowPrimary,
                        ),
                        child: const Center(
                          child: Icon(Icons.fitness_center_rounded, color: Colors.white, size: 18),
                        ),
                      ),
                      const SizedBox(width: DesignTokens.space10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'GIMXSOFT',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.8,
                              color: AppColors.textPrimary(isDark),
                            ),
                          ),
                          Text(
                            'ENTERPRISE CRM',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ] else ...[
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.primary, AppColors.accentCyan],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: DesignTokens.borderMd,
                    ),
                    child: const Center(
                      child: Icon(Icons.fitness_center_rounded, color: Colors.white, size: 18),
                    ),
                  ),
                ],
                if (!isCollapsed)
                  IconButton(
                    icon: Icon(
                      Icons.chevron_left_rounded,
                      size: 20,
                      color: AppColors.textMuted(isDark),
                    ),
                    splashRadius: 18,
                    onPressed: () => ref.read(sidebarCollapsedProvider.notifier).collapse(),
                  ),
              ],
            ),
          ),

          // 2. Navigation Items List
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(
                vertical: DesignTokens.space12,
                horizontal: DesignTokens.space10,
              ),
              itemCount: kNavigationItems.length,
              separatorBuilder: (_, __) => const SizedBox(height: 2),
              itemBuilder: (context, index) {
                final item = kNavigationItems[index];
                final isActive = currentPath == item.path ||
                    (item.path != '/dashboard' && currentPath.startsWith(item.path));

                return _SidebarTile(
                  item: item,
                  isActive: isActive,
                  isCollapsed: isCollapsed,
                  onTap: () => context.go(item.path),
                );
              },
            ),
          ),

          // 3. Bottom Footer / Tenant Info
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
                      icon: Icon(Icons.chevron_right_rounded, color: AppColors.textMuted(isDark), size: 20),
                      splashRadius: 18,
                      onPressed: () => ref.read(sidebarCollapsedProvider.notifier).expand(),
                    ),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 14,
                            backgroundColor: AppColors.primary.withOpacity(0.2),
                            child: Text(
                              authState.tenant?.name.isNotEmpty == true
                                  ? authState.tenant!.name[0].toUpperCase()
                                  : 'G',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                          const SizedBox(width: DesignTokens.space8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  authState.tenant?.name ?? 'Titan Fitness Club',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary(isDark),
                                  ),
                                ),
                                Text(
                                  authState.tenant?.subscriptionPlan ?? 'Enterprise Pro',
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.secondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: DesignTokens.space8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'v2.4.0 SaaS',
                            style: TextStyle(fontSize: 10, color: AppColors.textMuted(isDark)),
                          ),
                          InkWell(
                            onTap: () => ref.read(sidebarCollapsedProvider.notifier).collapse(),
                            borderRadius: DesignTokens.borderSm,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                              child: Row(
                                children: [
                                  Icon(Icons.keyboard_double_arrow_left_rounded, size: 14, color: AppColors.textMuted(isDark)),
                                  const SizedBox(width: 2),
                                  Text('Collapse', style: TextStyle(fontSize: 10, color: AppColors.textMuted(isDark))),
                                ],
                              ),
                            ),
                          ),
                        ],
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

    final bgColor = widget.isActive
        ? (isDark ? AppColors.primary.withOpacity(0.16) : AppColors.primary.withOpacity(0.10))
        : (_isHovered
            ? (isDark ? const Color(0x1AFFFFFF) : const Color(0x0A000000))
            : Colors.transparent);

    final iconColor = widget.isActive
        ? AppColors.primary
        : (_isHovered ? AppColors.textPrimary(isDark) : AppColors.textMuted(isDark));

    final textColor = widget.isActive
        ? (isDark ? Colors.white : AppColors.primary)
        : (_isHovered ? AppColors.textPrimary(isDark) : AppColors.textSecondary(isDark));

    Widget tile = MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: DesignTokens.durationFast,
          height: 40,
          padding: EdgeInsets.symmetric(
            horizontal: widget.isCollapsed ? 0 : DesignTokens.space12,
          ),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: DesignTokens.borderMd,
            border: widget.isActive
                ? Border.all(color: AppColors.primary.withOpacity(0.3), width: 1)
                : null,
          ),
          child: Row(
            mainAxisAlignment: widget.isCollapsed ? MainAxisAlignment.center : MainAxisAlignment.start,
            children: [
              Icon(widget.item.icon, size: 20, color: iconColor),
              if (!widget.isCollapsed) ...[
                const SizedBox(width: DesignTokens.space12),
                Expanded(
                  child: Text(
                    widget.item.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: widget.isActive ? FontWeight.w600 : FontWeight.w500,
                      color: textColor,
                    ),
                  ),
                ),
                if (widget.item.badgeCount != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: DesignTokens.borderFull,
                    ),
                    child: Text(
                      '${widget.item.badgeCount}',
                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
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
