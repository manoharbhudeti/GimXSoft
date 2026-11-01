import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/design_tokens.dart';
import '../../widgets/app_button.dart';
import '../../widgets/glass_card.dart';

class NotFoundErrorView extends StatelessWidget {
  final String? title;
  final String? message;
  final VoidCallback? onBack;

  const NotFoundErrorView({
    super.key,
    this.title,
    this.message,
    this.onBack,
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
                    color: AppColors.cyan.withOpacity(0.12),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.cyan.withOpacity(0.25),
                      width: 1.5,
                    ),
                  ),
                  child: Icon(
                    Icons.search_off_rounded,
                    color: AppColors.cyan,
                    size: 34,
                  ),
                ),
                const SizedBox(height: DesignTokens.spacingLg),
                Text(
                  title ?? 'Resource Not Found (404)',
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
                      'The item or page you are attempting to access does not exist, was archived, or was moved.',
                  style: TextStyle(
                    color: AppColors.textSecondary(isDark),
                    fontSize: 14,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (onBack != null) ...[
                  const SizedBox(height: DesignTokens.spacingXl),
                  AppButton(
                    label: 'Go Back',
                    icon: Icons.arrow_back_rounded,
                    onPressed: onBack,
                    variant: AppButtonVariant.secondary,
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
