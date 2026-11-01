import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/states/errors/error_boundary.dart';
import '../core/states/loading/app_loading.dart';
import '../core/states/loading/full_screen_loader.dart';
import '../core/states/network/connectivity_service.dart';
import '../core/states/success/app_toast.dart';
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
  bool _wasOffline = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < DesignTokens.breakpointTablet;

    final connectivity = ref.watch(connectivityProvider);
    final globalLoading = ref.watch(globalLoadingProvider);

    // Trigger toast when returning online from offline
    if (_wasOffline && connectivity.isConnected) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(toastProvider.notifier).success(
              'Back Online',
              message: 'Connection restored. Data syncing has resumed.',
            );
      });
      _wasOffline = false;
    } else if (!connectivity.isConnected) {
      _wasOffline = true;
    }

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.background(isDark),
      drawer: isMobile ? const Drawer(child: AppSidebar()) : null,
      body: Stack(
        children: [
          // Main Application Shell
          Row(
            children: [
              // Sidebar on Desktop / Tablet
              if (!isMobile) const AppSidebar(),

              // Main View Area
              Expanded(
                child: Column(
                  children: [
                    // Offline Notification Banner
                    if (!connectivity.isConnected)
                      _OfflineBanner(
                        isChecking: connectivity.isChecking,
                        onRetry: () => ref.read(connectivityProvider.notifier).checkConnectivity(),
                      ),

                    TopNavBar(
                      onOpenDrawer: () => _scaffoldKey.currentState?.openDrawer(),
                    ),
                    Expanded(
                      child: ErrorBoundary(
                        child: widget.child,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Global Full-Screen Loader Overlay (when triggered)
          if (globalLoading.isLoading && globalLoading.type == LoadingType.fullScreen)
            FullScreenLoader(
              message: globalLoading.message,
              progress: globalLoading.progress,
            ),

          // Global Floating Toast Overlay
          const ToastOverlay(),
        ],
      ),
    );
  }
}

class _OfflineBanner extends StatelessWidget {
  final bool isChecking;
  final VoidCallback onRetry;

  const _OfflineBanner({
    required this.isChecking,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: const Color(0xFFDC2626), // Strong danger red for high visibility
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.wifi_off_rounded,
            color: Colors.white,
            size: 16,
          ),
          const SizedBox(width: 8),
          const Text(
            'You are offline. Live synchronization is paused.',
            style: TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 16),
          InkWell(
            onTap: isChecking ? null : onRetry,
            borderRadius: BorderRadius.circular(4),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isChecking)
                    const SizedBox(
                      width: 12,
                      height: 12,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  else
                    const Icon(Icons.refresh_rounded, size: 14, color: Colors.white),
                  const SizedBox(width: 4),
                  const Text(
                    'Check Again',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
