import 'universal_state.dart';

/// Context inputs for deterministic state resolution.
class StateResolutionContext {
  final int? httpStatusCode;
  final bool isOffline;
  final bool isSlowNetwork;
  final bool isSessionExpired;
  final bool isTokenMissing;
  final bool isForbidden;
  final bool isMaintenance;
  final bool isRateLimited;
  final int? rateLimitResetSeconds;
  final bool isLoading;
  final bool isRefreshing;
  final bool isProcessing;
  final bool isUploading;
  final bool isDownloading;
  final bool hasUnsavedChanges;
  final bool isFirstTimeUser;
  final bool isSearchFocused;
  final bool hasSystemUpdate;
  final bool hasNotification;
  final bool hasFormValidationErrors;
  final bool isPartialSuccess;
  final bool isEmpty;
  final bool hasNoResults;
  final bool isSuccess;

  const StateResolutionContext({
    this.httpStatusCode,
    this.isOffline = false,
    this.isSlowNetwork = false,
    this.isSessionExpired = false,
    this.isTokenMissing = false,
    this.isForbidden = false,
    this.isMaintenance = false,
    this.isRateLimited = false,
    this.rateLimitResetSeconds,
    this.isLoading = false,
    this.isRefreshing = false,
    this.isProcessing = false,
    this.isUploading = false,
    this.isDownloading = false,
    this.hasUnsavedChanges = false,
    this.isFirstTimeUser = false,
    this.isSearchFocused = false,
    this.hasSystemUpdate = false,
    this.hasNotification = false,
    this.hasFormValidationErrors = false,
    this.isPartialSuccess = false,
    this.isEmpty = false,
    this.hasNoResults = false,
    this.isSuccess = false,
  });
}

/// Evaluator that resolves multiple concurrent conditions into a single deterministic state
/// strictly following the priority order:
/// Critical Errors > Network Outage > Auth > Transient Progress > Data Views
class UniversalStatePriorityResolver {
  static UniversalState resolve(StateResolutionContext ctx) {
    // 1. Tier 1: Critical Errors (Rank 100)
    if (ctx.isMaintenance || ctx.httpStatusCode == 503) {
      return UniversalState.maintenance;
    }
    if (ctx.httpStatusCode == 500 || ctx.httpStatusCode == 502 || ctx.httpStatusCode == 504) {
      return UniversalState.serverUnavailable;
    }

    // 2. Tier 2: Network Outage & Throttling (Rank 80)
    if (ctx.isOffline) {
      return UniversalState.noInternet;
    }
    if (ctx.isRateLimited || ctx.httpStatusCode == 429) {
      return UniversalState.rateLimited;
    }
    if (ctx.isSlowNetwork || ctx.httpStatusCode == 408) {
      return UniversalState.slowNetwork;
    }

    // 3. Tier 3: Authentication & Permissions (Rank 60)
    if (ctx.isSessionExpired || ctx.httpStatusCode == 401) {
      return UniversalState.sessionExpired;
    }
    if (ctx.isForbidden || ctx.httpStatusCode == 403) {
      return UniversalState.permissionDenied;
    }
    if (ctx.isTokenMissing) {
      return UniversalState.loginRequired;
    }

    // 4. Tier 4: Transient Progress & Active Mutations (Rank 40)
    if (ctx.hasFormValidationErrors || ctx.httpStatusCode == 422) {
      return UniversalState.formValidation;
    }
    if (ctx.hasUnsavedChanges) {
      return UniversalState.unsavedChanges;
    }
    if (ctx.isUploading) {
      return UniversalState.uploading;
    }
    if (ctx.isDownloading) {
      return UniversalState.downloading;
    }
    if (ctx.isProcessing) {
      return UniversalState.processing;
    }
    if (ctx.isLoading) {
      return UniversalState.loading;
    }
    if (ctx.isRefreshing) {
      return UniversalState.refreshing;
    }
    if (ctx.isPartialSuccess) {
      return UniversalState.partialSuccess;
    }
    if (ctx.isSuccess) {
      return UniversalState.success;
    }

    // 5. Tier 5: Data Views & Operational Overlays (Rank 20)
    if (ctx.httpStatusCode == 404) {
      return UniversalState.notFound404;
    }
    if (ctx.isFirstTimeUser) {
      return UniversalState.firstTimeUser;
    }
    if (ctx.hasSystemUpdate) {
      return UniversalState.systemUpdateAvailable;
    }
    if (ctx.hasNoResults) {
      return UniversalState.noResults;
    }
    if (ctx.isEmpty) {
      return UniversalState.empty;
    }
    if (ctx.isSearchFocused) {
      return UniversalState.searchState;
    }
    if (ctx.hasNotification) {
      return UniversalState.notificationState;
    }

    // Default neutral state
    return UniversalState.empty;
  }
}

