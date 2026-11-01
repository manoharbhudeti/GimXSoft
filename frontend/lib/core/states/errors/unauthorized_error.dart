import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/design_tokens.dart';
import '../../widgets/app_button.dart';
import '../../widgets/glass_card.dart';

class UnauthorizedErrorView extends StatelessWidget {
  final bool isForbidden;
  final String? title;
  final String? message;
  final VoidCallback? onAction;

  const UnauthorizedErrorView({
    super.key,
    this.isForbidden = false,
    this.title,
    this.message,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final defaultTitle = isForbidden ? 'Access Restricted' : 'Session Expired';
    final defaultMessage = isForbidden
        ? 'Your current user role does not possess permissions to view or modify this module. Contact your gym administrator.'
        : 'Your security token has expired. Please sign in to resume your active session.';
    final actionLabel = isForbidden ? 'Return to Dashboard' : 'Sign In Again';

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
                    color: (isForbidden ? AppColors.amber : AppColors.violet).withOpacity(0.12),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: (isForbidden ? AppColors.amber : AppColors.violet).withOpacity(0.25),
                      width: 1.5,
                    ),
                  ),
                  child: Icon(
                    isForbidden ? Icons.gpp_maybe_rounded : Icons.lock_clock_rounded,
                    color: isForbidden ? AppColors.amber : AppColors.violet,
                    size: 34,
                  ),
                ),
                const SizedBox(height: DesignTokens.spacingLg),
                Text(
                  title ?? defaultTitle,
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
                  message ?? defaultMessage,
                  style: TextStyle(
                    color: AppColors.textSecondary(isDark),
                    fontSize: 14,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (onAction != null) ...[
                  const SizedBox(height: DesignTokens.spacingXl),
                  AppButton(
                    label: actionLabel,
                    icon: isForbidden ? Icons.home_rounded : Icons.login_rounded,
                    onPressed: onAction,
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
