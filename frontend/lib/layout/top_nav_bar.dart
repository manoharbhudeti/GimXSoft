import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/design_tokens.dart';
import '../core/theme/theme_provider.dart';
import '../core/widgets/status_badge.dart';
import '../features/auth/auth_models.dart';
import '../features/auth/auth_provider.dart';

class TopNavBar extends ConsumerWidget implements PreferredSizeWidget {
  final VoidCallback? onOpenDrawer;

  const TopNavBar({super.key, this.onOpenDrawer});

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final themeNotifier = ref.watch(themeModeProvider.notifier);
    final authState = ref.watch(authProvider);
    final currentPath = GoRouterState.of(context).matchedLocation;

    // Breadcrumb page title
    String pageTitle = 'Dashboard';
    if (currentPath.contains('memberships')) {
      pageTitle = 'Membership Plans & Subscriptions';
    } else if (currentPath.contains('members')) {
      pageTitle = 'Member Management';
    } else if (currentPath.contains('leads')) {
      pageTitle = 'Leads & CRM Pipeline';
    } else if (currentPath.contains('attendance')) {
      pageTitle = 'Attendance Terminal';
    } else if (currentPath.contains('payments')) {
      pageTitle = 'Payments & Billing Ledger';
    } else if (currentPath.contains('trainers')) {
      pageTitle = 'Trainer Roster & Sessions';
    } else if (currentPath.contains('workouts')) {
      pageTitle = 'Workout Plan Builder';
    } else if (currentPath.contains('staff')) {
      pageTitle = 'Staff & Role Permissions';
    } else if (currentPath.contains('reports')) {
      pageTitle = 'Business Intelligence & Reports';
    } else if (currentPath.contains('branches')) {
      pageTitle = 'Multi-Branch Management';
    } else if (currentPath.contains('settings')) {
      pageTitle = 'System & Tenant Settings';
    }

    final isMobile = MediaQuery.of(context).size.width < DesignTokens.breakpointTablet;

    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: DesignTokens.space20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        border: Border(
          bottom: BorderSide(color: AppColors.border(isDark), width: 1),
        ),
      ),
      child: Row(
        children: [
          // Mobile Menu Button
          if (isMobile)
            IconButton(
              icon: Icon(Icons.menu_rounded, color: AppColors.textPrimary(isDark)),
              onPressed: onOpenDrawer,
            ),

          // Breadcrumbs
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                children: [
                  Text(
                    'GimXSoft',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textMuted(isDark),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(Icons.chevron_right, size: 14, color: AppColors.textMuted(isDark)),
                  const SizedBox(width: 4),
                  Text(
                    pageTitle,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                pageTitle,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary(isDark),
                ),
              ),
            ],
          ),

          const Spacer(),

          // Branch Switcher Dropdown
          if (!isMobile && authState.branches.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard : const Color(0xFFF1F5F9),
                borderRadius: DesignTokens.borderMd,
                border: Border.all(color: AppColors.border(isDark)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.storefront_rounded, size: 16, color: AppColors.primary),
                  const SizedBox(width: 8),
                  DropdownButtonHideUnderline(
                    child: DropdownButton<BranchModel>(
                      value: authState.selectedBranch ?? authState.branches.first,
                      isDense: true,
                      dropdownColor: isDark ? AppColors.darkCard : Colors.white,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary(isDark),
                      ),
                      items: authState.branches.map((branch) {
                        return DropdownMenuItem<BranchModel>(
                          value: branch,
                          child: Text('${branch.name} (${branch.code})'),
                        );
                      }).toList(),
                      onChanged: (newBranch) {
                        if (newBranch != null) {
                          ref.read(authProvider.notifier).switchBranch(newBranch);
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: DesignTokens.space12),
          ],

          // Theme Toggle Button
          IconButton(
            tooltip: isDark ? 'Switch to Light Mode' : 'Switch to Dark Mode',
            icon: Icon(
              isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
              size: 20,
              color: AppColors.textSecondary(isDark),
            ),
            splashRadius: 20,
            onPressed: () => themeNotifier.toggle(),
          ),

          const SizedBox(width: DesignTokens.space8),

          // Notification Bell
          Stack(
            children: [
              IconButton(
                tooltip: 'Notifications',
                icon: Icon(
                  Icons.notifications_none_rounded,
                  size: 20,
                  color: AppColors.textSecondary(isDark),
                ),
                splashRadius: 20,
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('All systems operational. No unread alerts.'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
              ),
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  width: 7,
                  height: 7,
                  decoration: const BoxDecoration(
                    color: AppColors.error,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(width: DesignTokens.space12),

          // User Profile Menu
          PopupMenuButton<String>(
            offset: const Offset(0, 52),
            shape: RoundedRectangleBorder(
              borderRadius: DesignTokens.borderLg,
              side: BorderSide(color: AppColors.border(isDark)),
            ),
            color: isDark ? AppColors.darkCard : Colors.white,
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
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary(isDark),
                      ),
                    ),
                    Text(
                      authState.user?.email ?? 'admin@titanfit.com',
                      style: TextStyle(fontSize: 12, color: AppColors.textMuted(isDark)),
                    ),
                    const SizedBox(height: 6),
                    StatusBadge(status: authState.user?.role ?? 'GymOwner'),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: 'settings',
                child: Row(
                  children: [
                    Icon(Icons.tune_rounded, size: 16),
                    SizedBox(width: 8),
                    Text('Organization Settings'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout_rounded, size: 16, color: AppColors.error),
                    SizedBox(width: 8),
                    Text('Sign Out', style: TextStyle(color: AppColors.error)),
                  ],
                ),
              ),
            ],
            child: Row(
              children: [
                CircleAvatar(
                  radius: 17,
                  backgroundImage: authState.user?.avatarUrl != null
                      ? NetworkImage(authState.user!.avatarUrl!)
                      : null,
                  backgroundColor: AppColors.primaryHover,
                  child: authState.user?.avatarUrl == null
                      ? Text(
                          authState.user?.fullName.isNotEmpty == true
                              ? authState.user!.fullName[0]
                              : 'A',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                        )
                      : null,
                ),
                if (!isMobile) ...[
                  const SizedBox(width: DesignTokens.space8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        authState.user?.fullName ?? 'Alex Morgan',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary(isDark),
                        ),
                      ),
                      Text(
                        authState.user?.role ?? 'Gym Owner',
                        style: TextStyle(fontSize: 11, color: AppColors.textMuted(isDark)),
                      ),
                    ],
                  ),
                  const SizedBox(width: 4),
                  Icon(Icons.arrow_drop_down, color: AppColors.textMuted(isDark), size: 18),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
