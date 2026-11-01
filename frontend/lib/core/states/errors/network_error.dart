import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/design_tokens.dart';
import '../../widgets/app_button.dart';
import '../../widgets/glass_card.dart';

class NetworkErrorView extends StatelessWidget {
  final String? title;
  final String? message;
  final VoidCallback? onRetry;
  final bool isRetrying;

  const NetworkErrorView({
    super.key,
    this.title,
    this.message,
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
            constraints: const BoxConstraints(maxWidth: 460),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: AppColors.rose.withOpacity(0.12),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.rose.withOpacity(0.25),
                      width: 1.5,
                    ),
                  ),
                  child: Icon(
                    Icons.wifi_off_rounded,
                    color: AppColors.rose,
                    size: 34,
                  ),
                ),
                const SizedBox(height: DesignTokens.spacingLg),
                Text(
                  title ?? 'Connection Unavailable',
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
                      'We could not establish a connection to the GIMXSOFT cloud. Please check your Wi-Fi or cellular network and try again.',
                  style: TextStyle(
                    color: AppColors.textSecondary(isDark),
                    fontSize: 14,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (onRetry != null) ...[
                  const SizedBox(height: DesignTokens.spacingXl),
                  AppButton(
                    label: 'Retry Connection',
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
