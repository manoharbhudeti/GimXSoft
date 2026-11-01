import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/design_tokens.dart';
import '../../widgets/app_button.dart';
import '../../widgets/glass_card.dart';

class SuccessDialog extends StatelessWidget {
  final String title;
  final String message;
  final String? primaryActionLabel;
  final VoidCallback? onPrimaryAction;
  final String? secondaryActionLabel;
  final VoidCallback? onSecondaryAction;
  final Widget? content;

  const SuccessDialog({
    super.key,
    required this.title,
    required this.message,
    this.primaryActionLabel = 'Done',
    this.onPrimaryAction,
    this.secondaryActionLabel,
    this.onSecondaryAction,
    this.content,
  });

  static Future<T?> show<T>({
    required BuildContext context,
    required String title,
    required String message,
    String? primaryActionLabel = 'Done',
    VoidCallback? onPrimaryAction,
    String? secondaryActionLabel,
    VoidCallback? onSecondaryAction,
    Widget? content,
  }) {
    return showDialog<T>(
      context: context,
      barrierDismissible: true,
      builder: (context) => SuccessDialog(
        title: title,
        message: message,
        primaryActionLabel: primaryActionLabel,
        onPrimaryAction: onPrimaryAction ?? () => Navigator.of(context).pop(),
        secondaryActionLabel: secondaryActionLabel,
        onSecondaryAction: onSecondaryAction,
        content: content,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(DesignTokens.spacingLg),
      child: GlassCard(
        borderRadius: DesignTokens.borderLg,
        padding: const EdgeInsets.all(DesignTokens.spacingXl),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.emerald.withOpacity(0.12),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.emerald.withOpacity(0.25),
                    width: 1.5,
                  ),
                ),
                child: Icon(
                  Icons.check_circle_outline_rounded,
                  color: AppColors.emerald,
                  size: 34,
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
                message,
                style: TextStyle(
                  color: AppColors.textSecondary(isDark),
                  fontSize: 14,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              if (content != null) ...[
                const SizedBox(height: DesignTokens.spacingMd),
                content!,
              ],
              const SizedBox(height: DesignTokens.spacingXl),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (secondaryActionLabel != null && onSecondaryAction != null) ...[
                    AppButton(
                      label: secondaryActionLabel!,
                      onPressed: onSecondaryAction,
                      variant: AppButtonVariant.ghost,
                    ),
                    const SizedBox(width: DesignTokens.spacingSm),
                  ],
                  if (primaryActionLabel != null && onPrimaryAction != null)
                    AppButton(
                      label: primaryActionLabel!,
                      onPressed: onPrimaryAction,
                      variant: AppButtonVariant.primary,
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
