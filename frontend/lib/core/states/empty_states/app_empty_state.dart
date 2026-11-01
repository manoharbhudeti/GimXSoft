import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/design_tokens.dart';
import '../../widgets/app_button.dart';
import '../../widgets/glass_card.dart';

class AppEmptyState extends StatelessWidget {
  final IconData icon;
  final Color? iconColor;
  final String title;
  final String description;
  final String? primaryActionLabel;
  final IconData? primaryActionIcon;
  final VoidCallback? onPrimaryAction;
  final String? secondaryActionLabel;
  final VoidCallback? onSecondaryAction;
  final double maxWidth;

  const AppEmptyState({
    super.key,
    required this.icon,
    this.iconColor,
    required this.title,
    required this.description,
    this.primaryActionLabel,
    this.primaryActionIcon,
    this.onPrimaryAction,
    this.secondaryActionLabel,
    this.onSecondaryAction,
    this.maxWidth = 440,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final effectiveIconColor = iconColor ?? AppColors.violet;

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
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 68,
                  height: 68,
                  decoration: BoxDecoration(
                    color: effectiveIconColor.withOpacity(0.12),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: effectiveIconColor.withOpacity(0.25),
                      width: 1.5,
                    ),
                  ),
                  child: Icon(
                    icon,
                    color: effectiveIconColor,
                    size: 32,
                  ),
                ),
                const SizedBox(height: DesignTokens.spacingLg),
                Text(
                  title,
                  style: TextStyle(
                    color: AppColors.textPrimary(isDark),
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: DesignTokens.spacingSm),
                Text(
                  description,
                  style: TextStyle(
                    color: AppColors.textSecondary(isDark),
                    fontSize: 13.5,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (onPrimaryAction != null || onSecondaryAction != null) ...[
                  const SizedBox(height: DesignTokens.spacingLg),
                  Wrap(
                    spacing: DesignTokens.spacingSm,
                    runSpacing: DesignTokens.spacingSm,
                    alignment: WrapAlignment.center,
                    children: [
                      if (onSecondaryAction != null && secondaryActionLabel != null)
                        AppButton(
                          label: secondaryActionLabel!,
                          onPressed: onSecondaryAction,
                          variant: AppButtonVariant.ghost,
                        ),
                      if (onPrimaryAction != null && primaryActionLabel != null)
                        AppButton(
                          label: primaryActionLabel!,
                          icon: primaryActionIcon,
                          onPressed: onPrimaryAction,
                          variant: AppButtonVariant.primary,
                        ),
                    ],
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
