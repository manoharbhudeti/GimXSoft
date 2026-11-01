import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/app_colors.dart';
import '../../theme/design_tokens.dart';
import '../../widgets/app_button.dart';
import '../../widgets/glass_card.dart';

class ServerErrorView extends StatelessWidget {
  final String? title;
  final String? message;
  final String? correlationId;
  final VoidCallback? onRetry;
  final bool isRetrying;

  const ServerErrorView({
    super.key,
    this.title,
    this.message,
    this.correlationId,
    this.onRetry,
    this.isRetrying = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(DesignTokens.spacingLg),
        child: GlassCard(
          borderRadius: DesignTokens.borderLg,
          padding: const EdgeInsets.symmetric(
            horizontal: DesignTokens.spacingXl,
            vertical: DesignTokens.spacingXl * 1.2,
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: AppColors.amber.withOpacity(0.12),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.amber.withOpacity(0.25),
                      width: 1.5,
                    ),
                  ),
                  child: Icon(
                    Icons.cloud_off_rounded,
                    color: AppColors.amber,
                    size: 34,
                  ),
                ),
                const SizedBox(height: DesignTokens.spacingLg),
                Text(
                  title ?? 'Server Temporarily Unavailable',
                  style: TextStyle(
                    color: AppColors.textPrimary(isDark),
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.4,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: DesignTokens.spacingSm),
                Text(
                  message ??
                      'An unexpected system condition occurred on our server cluster. No sensitive data was exposed. Please retry in a few moments.',
                  style: TextStyle(
                    color: AppColors.textSecondary(isDark),
                    fontSize: 14,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (correlationId != null && correlationId!.isNotEmpty) ...[
                  const SizedBox(height: DesignTokens.spacingMd),
                  InkWell(
                    borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
                    onTap: () {
                      Clipboard.setData(ClipboardData(text: correlationId!));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Correlation ID copied to clipboard'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white.withOpacity(0.04) : Colors.black.withOpacity(0.04),
                        borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
                        border: Border.all(
                          color: isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.08),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.tag_rounded,
                            size: 14,
                            color: AppColors.textMuted(isDark),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Ref: $correlationId',
                            style: TextStyle(
                              fontSize: 12,
                              fontFamily: 'monospace',
                              color: AppColors.textSecondary(isDark),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Icon(
                            Icons.copy_rounded,
                            size: 12,
                            color: AppColors.textMuted(isDark),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
                if (onRetry != null) ...[
                  const SizedBox(height: DesignTokens.spacingXl),
                  AppButton(
                    label: 'Retry Request',
                    icon: Icons.refresh_rounded,
                    isLoading: isRetrying,
                    onPressed: onRetry,
                    variant: AppButtonVariant.primary,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
