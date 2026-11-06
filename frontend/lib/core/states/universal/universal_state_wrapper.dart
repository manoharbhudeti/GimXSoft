import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/design_tokens.dart';
import '../empty_states/app_empty_state.dart';
import '../empty_states/search_empty_state.dart';
import '../errors/network_error.dart';
import '../errors/not_found_error.dart';
import '../errors/server_error.dart';
import '../errors/unauthorized_error.dart';
import '../loading/inline_loader.dart';
import 'universal_state.dart';
import 'universal_state_components.dart';

/// Universal non-destructive slot/wrapper component adhering to the Zero-Regression Policy.
/// Wraps any existing core UI component and dynamically projects the corresponding
/// accessible state without altering child event listeners or business logic.
class UniversalStateWrapper extends StatelessWidget {
  final UniversalState state;
  final Widget child;

  // Optional custom slots / overrides
  final Widget? customLoadingWidget;
  final Widget? customEmptyWidget;
  final String? emptyTitle;
  final String? emptyMessage;
  final VoidCallback? onEmptyAction;
  final String? emptyActionLabel;

  final String? errorMessage;
  final String? correlationId;
  final VoidCallback? onRetry;

  final VoidCallback? onRefresh;
  final VoidCallback? onClearSearch;
  final VoidCallback? onUpgrade;

  final int? rateLimitSeconds;
  final int? partialTotal;
  final int? partialSucceeded;
  final int? partialFailed;
  final List<String>? partialFailedItems;
  final VoidCallback? onRetryPartialFailed;

  const UniversalStateWrapper({
    super.key,
    required this.state,
    required this.child,
    this.customLoadingWidget,
    this.customEmptyWidget,
    this.emptyTitle,
    this.emptyMessage,
    this.onEmptyAction,
    this.emptyActionLabel,
    this.errorMessage,
    this.correlationId,
    this.onRetry,
    this.onRefresh,
    this.onClearSearch,
    this.onUpgrade,
    this.rateLimitSeconds,
    this.partialTotal,
    this.partialSucceeded,
    this.partialFailed,
    this.partialFailedItems,
    this.onRetryPartialFailed,
  });

  @override
  Widget build(BuildContext context) {
    final descriptor = UniversalStateDescriptor.of(state);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Wrap the resolved state widget with accessible semantics conforming to WCAG 2.1 AA
    return Semantics(
      label: descriptor.stateCode,
      liveRegion: descriptor.ariaLive != 'off',
      child: _buildStateContent(context, descriptor, isDark),
    );
  }

  Widget _buildStateContent(BuildContext context, UniversalStateDescriptor descriptor, bool isDark) {
    switch (state) {
      // 1. STATE_EMPTY
      case UniversalState.empty:
        return customEmptyWidget ??
            AppEmptyState(
              icon: descriptor.defaultIcon,
              title: emptyTitle ?? 'No Records Found',
              description: emptyMessage ?? 'Get started by creating your first entry.',
              primaryActionLabel: emptyActionLabel,
              onPrimaryAction: onEmptyAction,
            );

      // 2. STATE_LOADING
      case UniversalState.loading:
        return customLoadingWidget ??
            const Center(
              child: Padding(
                padding: EdgeInsets.all(DesignTokens.space32),
                child: InlineLoader(size: 36),
              ),
            );

      // 3. STATE_REFRESHING
      case UniversalState.refreshing:
        return Stack(
          children: [
            child,
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: LinearProgressIndicator(
                minHeight: 2.5,
                backgroundColor: Colors.transparent,
                color: AppColors.accentCyan,
              ),
            ),
          ],
        );

      // 4. STATE_SUCCESS
      case UniversalState.success:
        return child;

      // 5. STATE_ERROR
      case UniversalState.error:
        return ServerErrorView(
          title: 'System Error Encountered',
          message: errorMessage ?? 'A system error occurred while processing your request. Please try again.',
          correlationId: correlationId,
          onRetry: onRetry,
        );

      // 6. STATE_WARNING
      case UniversalState.warning:
        return Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              color: AppColors.warning.withValues(alpha: 0.12),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber_rounded, size: 18, color: AppColors.warning),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      errorMessage ?? 'System warning: A threshold or constraint was exceeded.',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.warning),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(child: child),
          ],
        );

      // 7. STATE_PROCESSING
      case UniversalState.processing:
        return Stack(
          children: [
            child,
            Container(
              color: (isDark ? Colors.black : Colors.white).withValues(alpha: 0.7),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const InlineLoader(size: 40),
                    const SizedBox(height: 16),
                    Text(
                      'Processing workflow…',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary(isDark),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );

      // 8. STATE_NO_RESULTS
      case UniversalState.noResults:
        return SearchEmptyState(
          searchQuery: '',
          onClear: onClearSearch ?? () {},
        );

      // 9. STATE_NO_INTERNET
      case UniversalState.noInternet:
        return NetworkErrorView(
          title: 'Network Disconnected',
          message: 'Unable to reach the server. Please check your internet connection.',
          onRetry: onRetry,
        );

      // 10. STATE_SLOW_NETWORK
      case UniversalState.slowNetwork:
        return Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: AppColors.warning.withValues(alpha: 0.15),
              child: Row(
                children: const [
                  Icon(Icons.network_check_rounded, size: 16, color: AppColors.warning),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Connection is slow. Taking longer than usual...',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.warning),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(child: child),
          ],
        );

      // 11. STATE_OFFLINE_MODE
      case UniversalState.offlineMode:
        return Stack(
          children: [
            child,
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.accentCyan.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(DesignTokens.radiusFull),
                  border: Border.all(color: AppColors.accentCyan),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.cloud_off_rounded, size: 14, color: AppColors.accentCyan),
                    SizedBox(width: 6),
                    Text(
                      'Working Offline',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.accentCyan),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );

      // 12. STATE_LOGIN_REQUIRED
      case UniversalState.loginRequired:
        return UnauthorizedErrorView(
          isForbidden: false,
          title: 'Authentication Required',
          message: 'Please sign in to access this workspace and your data.',
          onAction: onRetry,
        );

      // 13. STATE_SESSION_EXPIRED
      case UniversalState.sessionExpired:
        return UnauthorizedErrorView(
          isForbidden: false,
          title: 'Session Expired',
          message: 'Your authentication token has expired. Please sign in again to continue.',
          onAction: onRetry,
        );

      // 14. STATE_PERMISSION_DENIED
      case UniversalState.permissionDenied:
        return const UnauthorizedErrorView(
          isForbidden: true,
          title: 'Permission Denied',
          message: 'You do not have the required role or administrative claims to view this module.',
        );

      // 15. STATE_FORM_VALIDATION
      case UniversalState.formValidation:
        return child;

      // 16. STATE_UNSAVED_CHANGES
      case UniversalState.unsavedChanges:
        return child;

      // 17. STATE_UPLOADING
      case UniversalState.uploading:
        return Stack(
          children: [
            child,
            Positioned(
              bottom: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkCard : AppColors.lightCard,
                  borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
                  border: Border.all(color: AppColors.primary),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
                    SizedBox(width: 10),
                    Text('Uploading payload…', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ),
          ],
        );

      // 18. STATE_DOWNLOADING
      case UniversalState.downloading:
        return Stack(
          children: [
            child,
            Positioned(
              bottom: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkCard : AppColors.lightCard,
                  borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
                  border: Border.all(color: AppColors.accentCyan),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.downloading_rounded, size: 18, color: AppColors.accentCyan),
                    SizedBox(width: 10),
                    Text('Downloading file…', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ),
          ],
        );

      // 19. STATE_FIRST_TIME_USER
      case UniversalState.firstTimeUser:
        return child;

      // 20. STATE_404_NOT_FOUND
      case UniversalState.notFound404:
        return NotFoundErrorView(
          title: 'Resource Not Found (404)',
          message: errorMessage ?? 'The requested entity or page does not exist or has been removed.',
          onBack: onRetry,
        );

      // 21. STATE_MAINTENANCE
      case UniversalState.maintenance:
        return MaintenanceTakeoverView(onRefresh: onRefresh);

      // 22. STATE_ACCOUNT_VERIFICATION
      case UniversalState.accountVerification:
        return Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: AppColors.primary.withValues(alpha: 0.12),
              child: Row(
                children: const [
                  Icon(Icons.mark_email_unread_outlined, size: 16, color: AppColors.primary),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Account verification required. Please verify your email to unlock all features.',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.primary),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(child: child),
          ],
        );

      // 23. STATE_FEATURE_RESTRICTED
      case UniversalState.featureRestricted:
        return FeatureRestrictedView(
          featureName: emptyTitle ?? 'Advanced Automation',
          onUpgrade: onUpgrade,
        );

      // 24. STATE_DELETE_CONFIRMATION
      case UniversalState.deleteConfirmation:
        return child;

      // 25. STATE_RATE_LIMITED
      case UniversalState.rateLimited:
        return RateLimitedCooldownView(
          initialSeconds: rateLimitSeconds ?? 45,
          onReset: onRetry,
        );

      // 26. STATE_SERVER_UNAVAILABLE
      case UniversalState.serverUnavailable:
        return ServerErrorView(
          title: 'Service Temporarily Unavailable (503/502)',
          message: errorMessage ?? 'The upstream server is restarting or overloaded. Auto-retrying...',
          correlationId: correlationId,
          onRetry: onRetry,
        );

      // 27. STATE_PARTIAL_SUCCESS
      case UniversalState.partialSuccess:
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(DesignTokens.space12),
              child: PartialSuccessView(
                totalCount: partialTotal ?? 10,
                succeededCount: partialSucceeded ?? 8,
                failedCount: partialFailed ?? 2,
                failedItems: partialFailedItems ?? const [],
                onRetryFailed: onRetryPartialFailed,
              ),
            ),
            Expanded(child: child),
          ],
        );

      // 28. STATE_SEARCH_STATE
      case UniversalState.searchState:
        return child;

      // 29. STATE_NOTIFICATION_STATE
      case UniversalState.notificationState:
        return child;

      // 30. STATE_SYSTEM_UPDATE_AVAILABLE
      case UniversalState.systemUpdateAvailable:
        return Stack(
          children: [
            child,
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Center(
                child: SystemUpdatePill(onReload: onRefresh ?? () {}),
              ),
            ),
          ],
        );
    }
  }
}
