import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/design_tokens.dart';
import '../../widgets/app_button.dart';
import '../../widgets/glass_card.dart';

class SystemConfirmationDialog extends StatefulWidget {
  final String title;
  final String message;
  final String confirmLabel;
  final String cancelLabel;
  final bool isDestructive;
  final Future<void> Function()? onConfirm;
  final VoidCallback? onCancel;

  const SystemConfirmationDialog({
    super.key,
    required this.title,
    required this.message,
    this.confirmLabel = 'Confirm',
    this.cancelLabel = 'Cancel',
    this.isDestructive = false,
    this.onConfirm,
    this.onCancel,
  });

  static Future<bool?> show({
    required BuildContext context,
    required String title,
    required String message,
    String confirmLabel = 'Confirm',
    String cancelLabel = 'Cancel',
    bool isDestructive = false,
    Future<void> Function()? onConfirm,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => SystemConfirmationDialog(
        title: title,
        message: message,
        confirmLabel: confirmLabel,
        cancelLabel: cancelLabel,
        isDestructive: isDestructive,
        onConfirm: onConfirm,
      ),
    );
  }

  @override
  State<SystemConfirmationDialog> createState() => _SystemConfirmationDialogState();
}

class _SystemConfirmationDialogState extends State<SystemConfirmationDialog> {
  bool _isLoading = false;

  Future<void> _handleConfirm() async {
    if (widget.onConfirm == null) {
      Navigator.of(context).pop(true);
      return;
    }

    setState(() => _isLoading = true);
    try {
      await widget.onConfirm!();
      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accentColor = widget.isDestructive ? AppColors.rose : AppColors.violet;

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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: accentColor.withOpacity(0.12),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: accentColor.withOpacity(0.25),
                        width: 1.5,
                      ),
                    ),
                    child: Icon(
                      widget.isDestructive ? Icons.warning_amber_rounded : Icons.help_outline_rounded,
                      color: accentColor,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: DesignTokens.spacingMd),
                  Expanded(
                    child: Text(
                      widget.title,
                      style: TextStyle(
                        color: AppColors.textPrimary(isDark),
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: DesignTokens.spacingMd),
              Text(
                widget.message,
                style: TextStyle(
                  color: AppColors.textSecondary(isDark),
                  fontSize: 13.5,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: DesignTokens.spacingXl),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  AppButton(
                    label: widget.cancelLabel,
                    onPressed: _isLoading
                        ? null
                        : (widget.onCancel ?? () => Navigator.of(context).pop(false)),
                    variant: AppButtonVariant.ghost,
                  ),
                  const SizedBox(width: DesignTokens.spacingSm),
                  AppButton(
                    label: widget.confirmLabel,
                    isLoading: _isLoading,
                    onPressed: _isLoading ? null : _handleConfirm,
                    variant: widget.isDestructive
                        ? AppButtonVariant.danger
                        : AppButtonVariant.primary,
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
