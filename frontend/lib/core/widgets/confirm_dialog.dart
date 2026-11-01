import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/design_tokens.dart';
import 'app_button.dart';
import 'glass_card.dart';

class ConfirmDialog extends StatelessWidget {
  final String title;
  final String message;
  final String confirmText;
  final String cancelText;
  final bool isDestructive;
  final VoidCallback onConfirm;

  const ConfirmDialog({
    super.key,
    required this.title,
    required this.message,
    this.confirmText = 'Confirm',
    this.cancelText = 'Cancel',
    this.isDestructive = false,
    required this.onConfirm,
  });

  static Future<bool?> show(
    BuildContext context, {
    required String title,
    required String message,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
    bool isDestructive = false,
    required VoidCallback onConfirm,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => ConfirmDialog(
        title: title,
        message: message,
        confirmText: confirmText,
        cancelText: cancelText,
        isDestructive: isDestructive,
        onConfirm: () {
          onConfirm();
          Navigator.of(context).pop(true);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(DesignTokens.space24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: GlassCard(
          padding: const EdgeInsets.all(DesignTokens.space24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(DesignTokens.space8),
                    decoration: BoxDecoration(
                      color: (isDestructive ? AppColors.error : AppColors.primary).withOpacity(0.12),
                      borderRadius: DesignTokens.borderMd,
                    ),
                    child: Icon(
                      isDestructive ? Icons.warning_amber_rounded : Icons.info_outline,
                      color: isDestructive ? AppColors.error : AppColors.primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: DesignTokens.space12),
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary(isDark),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: DesignTokens.space16),
              Text(
                message,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary(isDark),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: DesignTokens.space24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  AppButton(
                    text: cancelText,
                    variant: ButtonVariant.ghost,
                    onPressed: () => Navigator.of(context).pop(false),
                  ),
                  const SizedBox(width: DesignTokens.space12),
                  AppButton(
                    text: confirmText,
                    variant: isDestructive ? ButtonVariant.danger : ButtonVariant.primary,
                    onPressed: onConfirm,
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

