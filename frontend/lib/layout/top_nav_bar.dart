import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/design_tokens.dart';
import '../core/theme/theme_customization_models.dart';
import '../core/theme/theme_provider.dart';
import '../core/widgets/status_badge.dart';
import '../features/auth/auth_models.dart';
import '../features/auth/auth_provider.dart';

/// Unslopped Top Navigation Bar:
/// - 56px height on 4px grid
/// - Quiet single breadcrumb title in primary graphite
/// - Restrained athletic controls and hairline borders
class TopNavBar extends ConsumerWidget implements PreferredSizeWidget {
  final VoidCallback? onOpenDrawer;

  const TopNavBar({super.key, this.onOpenDrawer});

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedTheme = ref.watch(selectedThemeProvider);
    final fontCombo = ref.watch(fontCombinationProvider);
    final palette = selectedTheme.palette;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final themeNotifier = ref.watch(themeModeProvider.notifier);
    final authState = ref.watch(authProvider);
    String currentPath = '/dashboard';
    try {
      currentPath = GoRouterState.of(context).matchedLocation;
    } catch (_) {}

    // Breadcrumb page title
    String pageTitle = 'Dashboard';
    if (currentPath.contains('memberships')) {
      pageTitle = 'Membership Plans';
    } else if (currentPath.contains('members')) {
      pageTitle = 'Members';
    } else if (currentPath.contains('whatsapp')) {
      pageTitle = 'WhatsApp Hub';
    } else if (currentPath.contains('attendance')) {
      pageTitle = 'Attendance Terminal';
    } else if (currentPath.contains('payments')) {
      pageTitle = 'Payments & Invoices';
    } else if (currentPath.contains('trainers')) {
      pageTitle = 'Coaches';
    } else if (currentPath.contains('workouts')) {
      pageTitle = 'Workouts';
    } else if (currentPath.contains('fitness-progress')) {
      pageTitle = 'Fitness Progress';
    } else if (currentPath.contains('staff')) {
      pageTitle = 'Staff & Roles';
    } else if (currentPath.contains('reports')) {
      pageTitle = 'Reports & Intelligence';
    } else if (currentPath.contains('branches')) {
      pageTitle = 'Branches';
    } else if (currentPath.contains('settings')) {
      pageTitle = 'Settings';
    }

    final isMobile = MediaQuery.of(context).size.width < DesignTokens.breakpointTablet;

    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: DesignTokens.space16),
      decoration: BoxDecoration(
        color: palette.surface(isDark),
        border: Border(
          bottom: BorderSide(color: palette.border(isDark), width: 1),
        ),
      ),
      child: Row(
        children: [
          if (isMobile)
            IconButton(
              icon: Icon(Icons.menu_rounded, color: palette.textPrimary(isDark), size: 20),
              onPressed: onOpenDrawer,
            ),

          // Quiet Breadcrumb / Page Title
          Flexible(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!isMobile) ...[
                  Text(
                    'GimXSoft',
                    style: fontCombo.bodyStyleBuilder(
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: palette.textMuted(isDark),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Icon(Icons.chevron_right_rounded, size: 14, color: palette.textMuted(isDark)),
                  const SizedBox(width: 6),
                ],
                Flexible(
                  child: Text(
                    pageTitle,
                    style: fontCombo.headingStyleBuilder(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: palette.textPrimary(isDark),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),

          const Spacer(),

          // Branch Switcher (quiet raised surface with hairline)
          if (!isMobile && authState.branches.isNotEmpty) ...[
            Container(
              height: 32,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: palette.raised(isDark),
                borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
                border: Border.all(color: palette.border(isDark)),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<BranchModel>(
                  value: authState.selectedBranch ?? authState.branches.first,
                  isDense: true,
                  icon: Icon(Icons.unfold_more_rounded, size: 14, color: palette.textMuted(isDark)),
                  dropdownColor: palette.card(isDark),
                  style: fontCombo.bodyStyleBuilder(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: palette.textPrimary(isDark),
                  ),
                  items: authState.branches.map((branch) {
                    return DropdownMenuItem<BranchModel>(
                      value: branch,
                      child: Text(branch.name),
                    );
                  }).toList(),
                  onChanged: (newBranch) {
                    if (newBranch != null) {
                      ref.read(authProvider.notifier).switchBranch(newBranch);
                    }
                  },
                ),
              ),
            ),
            const SizedBox(width: DesignTokens.space8),
          ],

          // Theme Toggle
          IconButton(
            tooltip: isDark ? 'Switch to Light Mode' : 'Switch to Dark Mode',
            icon: Icon(
              isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
              size: 18,
              color: palette.textSecondary(isDark),
            ),
            splashRadius: 16,
            onPressed: () => themeNotifier.toggle(),
          ),

          const SizedBox(width: DesignTokens.space4),

          // User Profile Trigger
          PopupMenuButton<String>(
            offset: const Offset(0, 44),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
              side: BorderSide(color: palette.border(isDark)),
            ),
            color: palette.card(isDark),
            onSelected: (value) {
              if (value == 'logout') {
                ref.read(authProvider.notifier).logout();
                context.go('/login');
              } else if (value == 'settings') {
                context.go('/settings');
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                enabled: false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      authState.user?.fullName ?? 'Alexander Morgan',
                      style: fontCombo.headingStyleBuilder(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: palette.textPrimary(isDark),
                      ),
                    ),
                    Text(
                      authState.user?.email ?? 'admin@titanfit.com',
                      style: fontCombo.bodyStyleBuilder(fontSize: 11, color: palette.textMuted(isDark)),
                    ),
                    const SizedBox(height: 6),
                    StatusBadge(status: authState.user?.role ?? 'GymOwner'),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              PopupMenuItem(
                value: 'settings',
                child: Row(
                  children: [
                    Icon(Icons.settings_outlined, size: 16, color: palette.textSecondary(isDark)),
                    const SizedBox(width: 8),
                    Text('Settings', style: fontCombo.bodyStyleBuilder(fontSize: 13, color: palette.textPrimary(isDark))),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    const Icon(Icons.logout_rounded, size: 16, color: AppColors.error),
                    const SizedBox(width: 8),
                    Text('Sign out', style: fontCombo.bodyStyleBuilder(fontSize: 13, color: AppColors.error)),
                  ],
                ),
              ),
            ],
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: palette.raised(isDark),
                borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
                border: Border.all(color: palette.border(isDark)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color: palette.id == ThemePaletteId.wineAndSand
                          ? const Color(0xFFF7F4EE)
                          : palette.primary,
                      borderRadius: BorderRadius.circular(DesignTokens.radiusXs),
                    ),
                    child: Center(
                      child: Text(
                        authState.user?.fullName.isNotEmpty == true
                            ? authState.user!.fullName[0].toUpperCase()
                            : 'A',
                        style: fontCombo.headingStyleBuilder(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: palette.id == ThemePaletteId.wineAndSand
                              ? const Color(0xFF380811)
                              : Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    authState.user?.fullName.split(' ').first ?? 'Staff',
                    style: fontCombo.bodyStyleBuilder(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: palette.textPrimary(isDark),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: palette.textMuted(isDark)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
