import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/design_tokens.dart';
import '../../widgets/app_button.dart';
import '../../widgets/glass_card.dart';
import 'universal_state.dart';

/// Descriptor for an operation requiring explicit safety confirmation.
class PermissionRequirement {
  final String actionTitle;
  final String description;
  final String consequenceText;
  final MutationSeverity severity;
  final bool requiresTypedConfirmation;
  final String? expectedConfirmationPhrase;
  final String confirmLabel;
  final String cancelLabel;

  const PermissionRequirement({
    required this.actionTitle,
    required this.description,
    required this.consequenceText,
    this.severity = MutationSeverity.medium,
    this.requiresTypedConfirmation = false,
    this.expectedConfirmationPhrase,
    this.confirmLabel = 'Grant Permission',
    this.cancelLabel = 'Cancel',
  });

  /// Factory preset for destructive deletions (e.g. deleting members, subscriptions, database stores).
  factory PermissionRequirement.destructiveDelete({
    required String resourceName,
    String? resourceIdentifier,
  }) {
    final phrase = resourceIdentifier ?? 'DELETE';
    return PermissionRequirement(
      actionTitle: 'Confirm Permanent Deletion',
      description: 'You are about to permanently delete "$resourceName". This action cannot be undone.',
      consequenceText: 'All related audit logs, historical measurements, and scheduled routines will be severed.',
      severity: MutationSeverity.high,
      requiresTypedConfirmation: true,
      expectedConfirmationPhrase: phrase,
      confirmLabel: 'Permanently Delete',
      cancelLabel: 'Keep Resource',
    );
  }

  /// Factory preset for state-machine overrides or elevated workflow steps.
  factory PermissionRequirement.elevatedAction({
    required String actionTitle,
    required String description,
    required String consequenceText,
  }) {
    return PermissionRequirement(
      actionTitle: actionTitle,
      description: description,
      consequenceText: consequenceText,
      severity: MutationSeverity.medium,
      requiresTypedConfirmation: false,
      confirmLabel: 'Authorize & Proceed',
      cancelLabel: 'Abort',
    );
  }
}

/// Accessible modal dialog enforcing explicit confirmation interlocks.
class PermissionInterlockDialog extends StatefulWidget {
  final PermissionRequirement requirement;

  const PermissionInterlockDialog({
    super.key,
    required this.requirement,
  });

  static Future<bool> request({
    required BuildContext context,
    required PermissionRequirement requirement,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => PermissionInterlockDialog(requirement: requirement),
    );
    return result ?? false;
  }

  @override
  State<PermissionInterlockDialog> createState() => _PermissionInterlockDialogState();
}

class _PermissionInterlockDialogState extends State<PermissionInterlockDialog> {
  final TextEditingController _typedController = TextEditingController();
  bool _isMatch = false;

  @override
  void initState() {
    super.initState();
    if (!widget.requirement.requiresTypedConfirmation) {
      _isMatch = true;
    }
  }

  @override
  void dispose() {
    _typedController.dispose();
    super.dispose();
  }

  void _onTextChanged(String val) {
    if (widget.requirement.requiresTypedConfirmation) {
      final expected = widget.requirement.expectedConfirmationPhrase ?? '';
      setState(() {
        _isMatch = val.trim() == expected;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final req = widget.requirement;
    final isHighSeverity = req.severity == MutationSeverity.high;
    final accent = isHighSeverity ? AppColors.error : AppColors.warning;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Semantics(
          namesRoute: true,
          scopesRoute: true,
          explicitChildNodes: true,
          liveRegion: true,
          label: req.actionTitle,
          child: GlassCard(
            padding: const EdgeInsets.all(DesignTokens.space24),
            borderRadius: BorderRadius.circular(DesignTokens.radiusXl),
            borderColor: accent.withValues(alpha: 0.35),
            child: Material(
              color: Colors.transparent,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(DesignTokens.space10),
                        decoration: BoxDecoration(
                          color: accent.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isHighSeverity ? Icons.warning_amber_rounded : Icons.shield_outlined,
                          color: accent,
                          size: 26,
                        ),
                      ),
                      const SizedBox(width: DesignTokens.space12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              req.actionTitle,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary(isDark),
                              ),
                            ),
                            Text(
                              isHighSeverity ? 'High-Risk Destructive Action' : 'Permission Required',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: accent,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: DesignTokens.space16),
                  Text(
                    req.description,
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.45,
                      color: AppColors.textSecondary(isDark),
                    ),
                  ),
                  const SizedBox(height: DesignTokens.space12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(DesignTokens.space12),
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
                      border: Border.all(color: accent.withValues(alpha: 0.2)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.info_outline_rounded, size: 16, color: accent),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            req.consequenceText,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textPrimary(isDark),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (req.requiresTypedConfirmation) ...[
                    const SizedBox(height: DesignTokens.space16),
                    Text(
                      'Type "${req.expectedConfirmationPhrase}" to confirm:',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary(isDark),
                      ),
                    ),
                    const SizedBox(height: DesignTokens.space8),
                    TextField(
                      controller: _typedController,
                      onChanged: _onTextChanged,
                      autofocus: true,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textPrimary(isDark),
                      ),
                      decoration: InputDecoration(
                        hintText: req.expectedConfirmationPhrase,
                        hintStyle: TextStyle(
                          color: AppColors.textMuted(isDark),
                        ),
                        filled: true,
                        fillColor: isDark ? AppColors.darkCard : AppColors.lightBackground,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
                          borderSide: BorderSide(color: AppColors.border(isDark)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
                          borderSide: BorderSide(color: accent, width: 1.5),
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: DesignTokens.space24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      AppButton(
                        text: req.cancelLabel,
                        variant: AppButtonVariant.outline,
                        onPressed: () => Navigator.of(context).pop(false),
                      ),
                      const SizedBox(width: DesignTokens.space12),
                      AppButton(
                        text: req.confirmLabel,
                        variant: isHighSeverity ? AppButtonVariant.danger : AppButtonVariant.primary,
                        onPressed: _isMatch ? () => Navigator.of(context).pop(true) : null,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
