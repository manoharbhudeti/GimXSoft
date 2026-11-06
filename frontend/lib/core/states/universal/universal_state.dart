import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

/// The 30 Universal Core States defined by the AI Agent UI & State Management Specification.
enum UniversalState {
  /// 1. Entity container has zero items and no user-generated input.
  empty,

  /// 2. Initial asynchronous data retrieval before DOM/UI paints content.
  loading,

  /// 3. Re-fetching or polling data when active content already exists on screen.
  refreshing,

  /// 4. Explicit completion of an action, mutation, or workflow step.
  success,

  /// 5. Unhandled exception, mutation failure, or fatal transaction error.
  error,

  /// 6. Non-fatal issue, boundary threshold exceeded, or sub-optimal system parameter.
  warning,

  /// 7. Multi-step backend transaction, AI generation task, or async background job.
  processing,

  /// 8. Query or filter criteria yielded zero records while parent collection is non-empty.
  noResults,

  /// 9. Window offline event triggered; device network interface is down.
  noInternet,

  /// 10. Request duration exceeds threshold (>3000ms) or slow connection.
  slowNetwork,

  /// 11. User toggles offline functionality or system falls back to cached storage.
  offlineMode,

  /// 12. Unauthorized guest/anonymous user accesses a protected route.
  loginRequired,

  /// 13. Auth token expiration (HTTP 401) during active usage.
  sessionExpired,

  /// 14. Authenticated user lacks sufficient role/claims (HTTP 403).
  permissionDenied,

  /// 15. Client-side field validation failure on blur or submission.
  formValidation,

  /// 16. Dirty form state detected when navigating away or closing window.
  unsavedChanges,

  /// 17. File payload transmission to external storage or context window.
  uploading,

  /// 18. Export, report generation, or artifact extraction initiated.
  downloading,

  /// 19. User metadata flag onboarding_completed: false.
  firstTimeUser,

  /// 20. Target URI, model reference, or document ID does not exist.
  notFound404,

  /// 21. System maintenance window active (HTTP 503).
  maintenance,

  /// 22. Email, phone, or identity verification required.
  accountVerification,

  /// 23. Feature gated by paywall, beta-flag, tier level, or hardware constraint.
  featureRestricted,

  /// 24. User initiates deletion of persistent entities, models, or data stores.
  deleteConfirmation,

  /// 25. API response HTTP 429 Too Many Requests.
  rateLimited,

  /// 26. Upstream backend failure (HTTP 502, 504, connection reset).
  serverUnavailable,

  /// 27. Batch operation or multi-agent execution where a subset succeeded and some failed.
  partialSuccess,

  /// 28. Search bar input active or focused with suggestions.
  searchState,

  /// 29. Unread message, asynchronous task finish, or priority system message.
  notificationState,

  /// 30. New application version or Service Worker update detected.
  systemUpdateAvailable,
}

/// Categorical priority tiers for deterministic state resolution:
/// Critical Errors > Network Outage > Auth > Transient Progress > Data Views
enum StatePriorityTier {
  criticalError(100),
  networkOutage(80),
  auth(60),
  transientProgress(40),
  dataViews(20);

  final int rank;
  const StatePriorityTier(this.rank);
}

/// Mutation severity rating for permission interlocks.
enum MutationSeverity {
  none,
  low,
  medium,
  high,
}

/// Metadata and behavioral characteristics for each of the 30 Universal States.
class UniversalStateDescriptor {
  final UniversalState state;
  final String stateCode;
  final StatePriorityTier priorityTier;
  final MutationSeverity mutationSeverity;
  final String accessibilityRole;
  final String ariaLive;
  final IconData defaultIcon;
  final Color Function(bool isDark) accentColor;

  const UniversalStateDescriptor({
    required this.state,
    required this.stateCode,
    required this.priorityTier,
    required this.mutationSeverity,
    required this.accessibilityRole,
    required this.ariaLive,
    required this.defaultIcon,
    required this.accentColor,
  });

  static UniversalStateDescriptor of(UniversalState state) {
    return _descriptors[state]!;
  }

  static final Map<UniversalState, UniversalStateDescriptor> _descriptors = {
    UniversalState.empty: UniversalStateDescriptor(
      state: UniversalState.empty,
      stateCode: 'STATE_EMPTY',
      priorityTier: StatePriorityTier.dataViews,
      mutationSeverity: MutationSeverity.none,
      accessibilityRole: 'status',
      ariaLive: 'polite',
      defaultIcon: Icons.inbox_outlined,
      accentColor: (isDark) => AppColors.textMuted(isDark),
    ),
    UniversalState.loading: UniversalStateDescriptor(
      state: UniversalState.loading,
      stateCode: 'STATE_LOADING',
      priorityTier: StatePriorityTier.transientProgress,
      mutationSeverity: MutationSeverity.none,
      accessibilityRole: 'progressbar',
      ariaLive: 'polite',
      defaultIcon: Icons.hourglass_empty_rounded,
      accentColor: (isDark) => AppColors.primary,
    ),
    UniversalState.refreshing: UniversalStateDescriptor(
      state: UniversalState.refreshing,
      stateCode: 'STATE_REFRESHING',
      priorityTier: StatePriorityTier.transientProgress,
      mutationSeverity: MutationSeverity.none,
      accessibilityRole: 'status',
      ariaLive: 'off',
      defaultIcon: Icons.sync_rounded,
      accentColor: (isDark) => AppColors.accentCyan,
    ),
    UniversalState.success: UniversalStateDescriptor(
      state: UniversalState.success,
      stateCode: 'STATE_SUCCESS',
      priorityTier: StatePriorityTier.transientProgress,
      mutationSeverity: MutationSeverity.none,
      accessibilityRole: 'status',
      ariaLive: 'polite',
      defaultIcon: Icons.check_circle_outline_rounded,
      accentColor: (isDark) => AppColors.success,
    ),
    UniversalState.error: UniversalStateDescriptor(
      state: UniversalState.error,
      stateCode: 'STATE_ERROR',
      priorityTier: StatePriorityTier.criticalError,
      mutationSeverity: MutationSeverity.none,
      accessibilityRole: 'alert',
      ariaLive: 'assertive',
      defaultIcon: Icons.error_outline_rounded,
      accentColor: (isDark) => AppColors.error,
    ),
    UniversalState.warning: UniversalStateDescriptor(
      state: UniversalState.warning,
      stateCode: 'STATE_WARNING',
      priorityTier: StatePriorityTier.transientProgress,
      mutationSeverity: MutationSeverity.none,
      accessibilityRole: 'alert',
      ariaLive: 'polite',
      defaultIcon: Icons.warning_amber_rounded,
      accentColor: (isDark) => AppColors.warning,
    ),
    UniversalState.processing: UniversalStateDescriptor(
      state: UniversalState.processing,
      stateCode: 'STATE_PROCESSING',
      priorityTier: StatePriorityTier.transientProgress,
      mutationSeverity: MutationSeverity.none,
      accessibilityRole: 'progressbar',
      ariaLive: 'polite',
      defaultIcon: Icons.auto_mode_rounded,
      accentColor: (isDark) => AppColors.primary,
    ),
    UniversalState.noResults: UniversalStateDescriptor(
      state: UniversalState.noResults,
      stateCode: 'STATE_NO_RESULTS',
      priorityTier: StatePriorityTier.dataViews,
      mutationSeverity: MutationSeverity.none,
      accessibilityRole: 'status',
      ariaLive: 'polite',
      defaultIcon: Icons.search_off_rounded,
      accentColor: (isDark) => AppColors.textMuted(isDark),
    ),
    UniversalState.noInternet: UniversalStateDescriptor(
      state: UniversalState.noInternet,
      stateCode: 'STATE_NO_INTERNET',
      priorityTier: StatePriorityTier.networkOutage,
      mutationSeverity: MutationSeverity.none,
      accessibilityRole: 'alert',
      ariaLive: 'assertive',
      defaultIcon: Icons.wifi_off_rounded,
      accentColor: (isDark) => AppColors.error,
    ),
    UniversalState.slowNetwork: UniversalStateDescriptor(
      state: UniversalState.slowNetwork,
      stateCode: 'STATE_SLOW_NETWORK',
      priorityTier: StatePriorityTier.networkOutage,
      mutationSeverity: MutationSeverity.none,
      accessibilityRole: 'status',
      ariaLive: 'polite',
      defaultIcon: Icons.network_check_rounded,
      accentColor: (isDark) => AppColors.warning,
    ),
    UniversalState.offlineMode: UniversalStateDescriptor(
      state: UniversalState.offlineMode,
      stateCode: 'STATE_OFFLINE_MODE',
      priorityTier: StatePriorityTier.networkOutage,
      mutationSeverity: MutationSeverity.none,
      accessibilityRole: 'status',
      ariaLive: 'polite',
      defaultIcon: Icons.cloud_off_rounded,
      accentColor: (isDark) => AppColors.accentCyan,
    ),
    UniversalState.loginRequired: UniversalStateDescriptor(
      state: UniversalState.loginRequired,
      stateCode: 'STATE_LOGIN_REQUIRED',
      priorityTier: StatePriorityTier.auth,
      mutationSeverity: MutationSeverity.medium,
      accessibilityRole: 'alertdialog',
      ariaLive: 'assertive',
      defaultIcon: Icons.lock_outline_rounded,
      accentColor: (isDark) => AppColors.primary,
    ),
    UniversalState.sessionExpired: UniversalStateDescriptor(
      state: UniversalState.sessionExpired,
      stateCode: 'STATE_SESSION_EXPIRED',
      priorityTier: StatePriorityTier.auth,
      mutationSeverity: MutationSeverity.medium,
      accessibilityRole: 'alertdialog',
      ariaLive: 'assertive',
      defaultIcon: Icons.timer_outlined,
      accentColor: (isDark) => AppColors.warning,
    ),
    UniversalState.permissionDenied: UniversalStateDescriptor(
      state: UniversalState.permissionDenied,
      stateCode: 'STATE_PERMISSION_DENIED',
      priorityTier: StatePriorityTier.auth,
      mutationSeverity: MutationSeverity.none,
      accessibilityRole: 'alert',
      ariaLive: 'assertive',
      defaultIcon: Icons.gpp_bad_outlined,
      accentColor: (isDark) => AppColors.error,
    ),
    UniversalState.formValidation: UniversalStateDescriptor(
      state: UniversalState.formValidation,
      stateCode: 'STATE_FORM_VALIDATION',
      priorityTier: StatePriorityTier.transientProgress,
      mutationSeverity: MutationSeverity.none,
      accessibilityRole: 'alert',
      ariaLive: 'assertive',
      defaultIcon: Icons.announcement_outlined,
      accentColor: (isDark) => AppColors.error,
    ),
    UniversalState.unsavedChanges: UniversalStateDescriptor(
      state: UniversalState.unsavedChanges,
      stateCode: 'STATE_UNSAVED_CHANGES',
      priorityTier: StatePriorityTier.transientProgress,
      mutationSeverity: MutationSeverity.medium,
      accessibilityRole: 'alertdialog',
      ariaLive: 'assertive',
      defaultIcon: Icons.edit_note_rounded,
      accentColor: (isDark) => AppColors.warning,
    ),
    UniversalState.uploading: UniversalStateDescriptor(
      state: UniversalState.uploading,
      stateCode: 'STATE_UPLOADING',
      priorityTier: StatePriorityTier.transientProgress,
      mutationSeverity: MutationSeverity.none,
      accessibilityRole: 'progressbar',
      ariaLive: 'polite',
      defaultIcon: Icons.cloud_upload_outlined,
      accentColor: (isDark) => AppColors.primary,
    ),
    UniversalState.downloading: UniversalStateDescriptor(
      state: UniversalState.downloading,
      stateCode: 'STATE_DOWNLOADING',
      priorityTier: StatePriorityTier.transientProgress,
      mutationSeverity: MutationSeverity.none,
      accessibilityRole: 'progressbar',
      ariaLive: 'polite',
      defaultIcon: Icons.cloud_download_outlined,
      accentColor: (isDark) => AppColors.accentCyan,
    ),
    UniversalState.firstTimeUser: UniversalStateDescriptor(
      state: UniversalState.firstTimeUser,
      stateCode: 'STATE_FIRST_TIME_USER',
      priorityTier: StatePriorityTier.dataViews,
      mutationSeverity: MutationSeverity.none,
      accessibilityRole: 'region',
      ariaLive: 'polite',
      defaultIcon: Icons.auto_awesome_rounded,
      accentColor: (isDark) => AppColors.accentPurple,
    ),
    UniversalState.notFound404: UniversalStateDescriptor(
      state: UniversalState.notFound404,
      stateCode: 'STATE_404_NOT_FOUND',
      priorityTier: StatePriorityTier.dataViews,
      mutationSeverity: MutationSeverity.none,
      accessibilityRole: 'region',
      ariaLive: 'polite',
      defaultIcon: Icons.search_off_rounded,
      accentColor: (isDark) => AppColors.textMuted(isDark),
    ),
    UniversalState.maintenance: UniversalStateDescriptor(
      state: UniversalState.maintenance,
      stateCode: 'STATE_MAINTENANCE',
      priorityTier: StatePriorityTier.criticalError,
      mutationSeverity: MutationSeverity.none,
      accessibilityRole: 'alert',
      ariaLive: 'assertive',
      defaultIcon: Icons.build_circle_outlined,
      accentColor: (isDark) => AppColors.warning,
    ),
    UniversalState.accountVerification: UniversalStateDescriptor(
      state: UniversalState.accountVerification,
      stateCode: 'STATE_ACCOUNT_VERIFICATION',
      priorityTier: StatePriorityTier.auth,
      mutationSeverity: MutationSeverity.low,
      accessibilityRole: 'status',
      ariaLive: 'polite',
      defaultIcon: Icons.mark_email_unread_outlined,
      accentColor: (isDark) => AppColors.primary,
    ),
    UniversalState.featureRestricted: UniversalStateDescriptor(
      state: UniversalState.featureRestricted,
      stateCode: 'STATE_FEATURE_RESTRICTED',
      priorityTier: StatePriorityTier.dataViews,
      mutationSeverity: MutationSeverity.low,
      accessibilityRole: 'region',
      ariaLive: 'polite',
      defaultIcon: Icons.workspace_premium_outlined,
      accentColor: (isDark) => AppColors.accentOrange,
    ),
    UniversalState.deleteConfirmation: UniversalStateDescriptor(
      state: UniversalState.deleteConfirmation,
      stateCode: 'STATE_DELETE_CONFIRMATION',
      priorityTier: StatePriorityTier.criticalError,
      mutationSeverity: MutationSeverity.high,
      accessibilityRole: 'alertdialog',
      ariaLive: 'assertive',
      defaultIcon: Icons.delete_forever_rounded,
      accentColor: (isDark) => AppColors.error,
    ),
    UniversalState.rateLimited: UniversalStateDescriptor(
      state: UniversalState.rateLimited,
      stateCode: 'STATE_RATE_LIMITED',
      priorityTier: StatePriorityTier.networkOutage,
      mutationSeverity: MutationSeverity.none,
      accessibilityRole: 'alert',
      ariaLive: 'assertive',
      defaultIcon: Icons.hourglass_top_rounded,
      accentColor: (isDark) => AppColors.warning,
    ),
    UniversalState.serverUnavailable: UniversalStateDescriptor(
      state: UniversalState.serverUnavailable,
      stateCode: 'STATE_SERVER_UNAVAILABLE',
      priorityTier: StatePriorityTier.criticalError,
      mutationSeverity: MutationSeverity.none,
      accessibilityRole: 'alert',
      ariaLive: 'assertive',
      defaultIcon: Icons.dns_outlined,
      accentColor: (isDark) => AppColors.error,
    ),
    UniversalState.partialSuccess: UniversalStateDescriptor(
      state: UniversalState.partialSuccess,
      stateCode: 'STATE_PARTIAL_SUCCESS',
      priorityTier: StatePriorityTier.transientProgress,
      mutationSeverity: MutationSeverity.low,
      accessibilityRole: 'status',
      ariaLive: 'polite',
      defaultIcon: Icons.published_with_changes_rounded,
      accentColor: (isDark) => AppColors.warning,
    ),
    UniversalState.searchState: UniversalStateDescriptor(
      state: UniversalState.searchState,
      stateCode: 'STATE_SEARCH_STATE',
      priorityTier: StatePriorityTier.dataViews,
      mutationSeverity: MutationSeverity.none,
      accessibilityRole: 'search',
      ariaLive: 'polite',
      defaultIcon: Icons.search_rounded,
      accentColor: (isDark) => AppColors.primary,
    ),
    UniversalState.notificationState: UniversalStateDescriptor(
      state: UniversalState.notificationState,
      stateCode: 'STATE_NOTIFICATION_STATE',
      priorityTier: StatePriorityTier.dataViews,
      mutationSeverity: MutationSeverity.none,
      accessibilityRole: 'region',
      ariaLive: 'polite',
      defaultIcon: Icons.notifications_active_outlined,
      accentColor: (isDark) => AppColors.accentCyan,
    ),
    UniversalState.systemUpdateAvailable: UniversalStateDescriptor(
      state: UniversalState.systemUpdateAvailable,
      stateCode: 'STATE_SYSTEM_UPDATE_AVAILABLE',
      priorityTier: StatePriorityTier.dataViews,
      mutationSeverity: MutationSeverity.none,
      accessibilityRole: 'status',
      ariaLive: 'polite',
      defaultIcon: Icons.system_update_rounded,
      accentColor: (isDark) => AppColors.primary,
    ),
  };
}

