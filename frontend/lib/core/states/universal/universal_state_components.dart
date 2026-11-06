import 'dart:async';
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/design_tokens.dart';
import '../../widgets/app_button.dart';
import '../../widgets/glass_card.dart';

/// 1. STATE_RATE_LIMITED Cooldown Component with active countdown timer.
class RateLimitedCooldownView extends StatefulWidget {
  final int initialSeconds;
  final VoidCallback? onReset;

  const RateLimitedCooldownView({
    super.key,
    this.initialSeconds = 45,
    this.onReset,
  });

  @override
  State<RateLimitedCooldownView> createState() => _RateLimitedCooldownViewState();
}

class _RateLimitedCooldownViewState extends State<RateLimitedCooldownView> {
  late int _remaining;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _remaining = widget.initialSeconds;
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_remaining > 1) {
        setState(() => _remaining--);
      } else {
        timer.cancel();
        setState(() => _remaining = 0);
        widget.onReset?.call();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isReady = _remaining == 0;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: GlassCard(
          padding: const EdgeInsets.all(DesignTokens.space24),
          borderRadius: BorderRadius.circular(DesignTokens.radiusXl),
          borderColor: AppColors.warning.withValues(alpha: 0.3),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(DesignTokens.space12),
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.hourglass_top_rounded,
                  color: AppColors.warning,
                  size: 32,
                ),
              ),
              const SizedBox(height: DesignTokens.space16),
              Text(
                'Rate Limit Exceeded (HTTP 429)',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary(isDark),
                ),
              ),
              const SizedBox(height: DesignTokens.space8),
              Text(
                isReady
                    ? 'Quota reset. You may now retry your operation.'
                    : 'Too many requests dispatched in a short window. Please wait for cooldown.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary(isDark),
                ),
              ),
              const SizedBox(height: DesignTokens.space20),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: (isDark ? AppColors.darkCard : AppColors.lightBackground),
                  borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
                  border: Border.all(color: AppColors.border(isDark)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isReady ? Icons.check_circle_outline : Icons.timer_outlined,
                      size: 18,
                      color: isReady ? AppColors.success : AppColors.warning,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      isReady ? 'Ready to proceed' : 'Retry available in ${_remaining}s',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isReady ? AppColors.success : AppColors.warning,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: DesignTokens.space24),
              AppButton(
                text: isReady ? 'Retry Operation' : 'Cooldown Active ($_remaining s)',
                icon: Icons.refresh_rounded,
                variant: AppButtonVariant.primary,
                onPressed: isReady ? widget.onReset : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 2. STATE_PARTIAL_SUCCESS Component: Split status summary bar with selective retry.
class PartialSuccessView extends StatelessWidget {
  final int totalCount;
  final int succeededCount;
  final int failedCount;
  final List<String> failedItems;
  final VoidCallback? onRetryFailed;
  final VoidCallback? onDismiss;

  const PartialSuccessView({
    super.key,
    required this.totalCount,
    required this.succeededCount,
    required this.failedCount,
    this.failedItems = const [],
    this.onRetryFailed,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final successRate = totalCount > 0 ? (succeededCount / totalCount) : 0.0;

    return Container(
      padding: const EdgeInsets.all(DesignTokens.space16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
        border: Border.all(color: AppColors.warning.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.published_with_changes_rounded, size: 18, color: AppColors.warning),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Batch Execution Partial Success',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary(isDark),
                      ),
                    ),
                    Text(
                      '$succeededCount of $totalCount items completed successfully ($failedCount failed)',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary(isDark),
                      ),
                    ),
                  ],
                ),
              ),
              if (onDismiss != null)
                IconButton(
                  icon: const Icon(Icons.close_rounded, size: 18),
                  color: AppColors.textMuted(isDark),
                  onPressed: onDismiss,
                ),
            ],
          ),
          const SizedBox(height: DesignTokens.space12),
          // Split Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(DesignTokens.radiusFull),
            child: SizedBox(
              height: 6,
              child: Row(
                children: [
                  Expanded(
                    flex: (successRate * 100).toInt(),
                    child: Container(color: AppColors.success),
                  ),
                  Expanded(
                    flex: ((1.0 - successRate) * 100).toInt(),
                    child: Container(color: AppColors.error),
                  ),
                ],
              ),
            ),
          ),
          if (failedItems.isNotEmpty) ...[
            const SizedBox(height: DesignTokens.space12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
                border: Border.all(color: AppColors.error.withValues(alpha: 0.15)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Failed Items:',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.error,
                    ),
                  ),
                  const SizedBox(height: 4),
                  ...failedItems.take(3).map(
                        (item) => Text(
                          '• $item',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary(isDark),
                          ),
                        ),
                      ),
                  if (failedItems.length > 3)
                    Text(
                      'and ${failedItems.length - 3} more...',
                      style: TextStyle(
                        fontSize: 11,
                        fontStyle: FontStyle.italic,
                        color: AppColors.textMuted(isDark),
                      ),
                    ),
                ],
              ),
            ),
          ],
          const SizedBox(height: DesignTokens.space16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (onRetryFailed != null && failedCount > 0)
                AppButton(
                  text: 'Retry Failed ($failedCount)',
                  icon: Icons.refresh_rounded,
                  variant: AppButtonVariant.primary,
                  onPressed: onRetryFailed,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// 3. STATE_MAINTENANCE Takeover View
class MaintenanceTakeoverView extends StatelessWidget {
  final String? estimatedDowntime;
  final VoidCallback? onRefresh;

  const MaintenanceTakeoverView({
    super.key,
    this.estimatedDowntime = 'Estimated duration: 45 minutes',
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: GlassCard(
          padding: const EdgeInsets.all(DesignTokens.space32),
          borderRadius: BorderRadius.circular(DesignTokens.radiusXl),
          borderColor: AppColors.warning.withValues(alpha: 0.4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(DesignTokens.space16),
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.build_circle_outlined,
                  size: 48,
                  color: AppColors.warning,
                ),
              ),
              const SizedBox(height: DesignTokens.space20),
              Text(
                'Scheduled Platform Maintenance',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary(isDark),
                ),
              ),
              const SizedBox(height: DesignTokens.space12),
              Text(
                'GIMXSOFT is currently undergoing scheduled infrastructure upgrades. All data is securely preserved. Please check back shortly.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.5,
                  color: AppColors.textSecondary(isDark),
                ),
              ),
              if (estimatedDowntime != null) ...[
                const SizedBox(height: DesignTokens.space16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
                    border: Border.all(color: AppColors.warning.withValues(alpha: 0.2)),
                  ),
                  child: Text(
                    estimatedDowntime!,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.warning,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: DesignTokens.space32),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AppButton(
                    text: 'Refresh Status',
                    icon: Icons.refresh_rounded,
                    variant: AppButtonVariant.primary,
                    onPressed: onRefresh,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 4. STATE_SYSTEM_UPDATE_AVAILABLE Floating Pill Banner
class SystemUpdatePill extends StatelessWidget {
  final VoidCallback onReload;
  final VoidCallback? onDismiss;

  const SystemUpdatePill({
    super.key,
    required this.onReload,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Semantics(
      container: true,
      liveRegion: true,
      label: 'A new version of GIMXSOFT is available',
      child: Container(
        margin: const EdgeInsets.all(DesignTokens.space16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : AppColors.lightCard,
          borderRadius: BorderRadius.circular(DesignTokens.radiusFull),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.4)),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.18),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.arrow_upward_rounded, size: 14, color: Colors.white),
            ),
            const SizedBox(width: 10),
            Text(
              'A new version of GIMXSOFT is available.',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary(isDark),
              ),
            ),
            const SizedBox(width: 14),
            InkWell(
              onTap: onReload,
              borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
                ),
                child: const Text(
                  'Reload Now',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            if (onDismiss != null) ...[
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.close_rounded, size: 16),
                color: AppColors.textMuted(isDark),
                onPressed: onDismiss,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// 5. STATE_FEATURE_RESTRICTED Upgrade Modal/Card
class FeatureRestrictedView extends StatelessWidget {
  final String featureName;
  final String requiredTier;
  final VoidCallback? onUpgrade;

  const FeatureRestrictedView({
    super.key,
    required this.featureName,
    this.requiredTier = 'Enterprise Plan',
    this.onUpgrade,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440),
        child: GlassCard(
          padding: const EdgeInsets.all(DesignTokens.space32),
          borderRadius: BorderRadius.circular(DesignTokens.radiusXl),
          borderColor: AppColors.accentOrange.withValues(alpha: 0.35),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(DesignTokens.space12),
                decoration: BoxDecoration(
                  color: AppColors.accentOrange.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.workspace_premium_rounded,
                  color: AppColors.accentOrange,
                  size: 32,
                ),
              ),
              const SizedBox(height: DesignTokens.space16),
              Text(
                'Feature Gated: $featureName',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary(isDark),
                ),
              ),
              const SizedBox(height: DesignTokens.space8),
              Text(
                'This advanced capability requires the $requiredTier. Upgrade your subscription to unlock automated workflows and high-tier capabilities.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  height: 1.45,
                  color: AppColors.textSecondary(isDark),
                ),
              ),
              const SizedBox(height: DesignTokens.space24),
              AppButton(
                text: 'Upgrade to $requiredTier',
                icon: Icons.bolt_rounded,
                variant: AppButtonVariant.primary,
                onPressed: onUpgrade,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
