import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/design_tokens.dart';

enum ButtonVariant { primary, secondary, outline, ghost, danger }
typedef AppButtonVariant = ButtonVariant;

enum ButtonSize { sm, md, lg }
typedef AppButtonSize = ButtonSize;

class AppButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final ButtonVariant variant;
  final ButtonSize size;
  final IconData? icon;
  final IconData? trailingIcon;
  final bool isLoading;
  final bool isFullWidth;

  const AppButton({
    super.key,
    String? text,
    String? label,
    this.onPressed,
    this.variant = ButtonVariant.primary,
    this.size = ButtonSize.md,
    this.icon,
    this.trailingIcon,
    this.isLoading = false,
    this.isFullWidth = false,
  }) : text = text ?? label ?? '';

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isDisabled = widget.onPressed == null || widget.isLoading;

    // Size parameters
    final double height = switch (widget.size) {
      ButtonSize.sm => 34.0,
      ButtonSize.md => 42.0,
      ButtonSize.lg => 48.0,
    };

    final double fontSize = switch (widget.size) {
      ButtonSize.sm => 13.0,
      ButtonSize.md => 14.0,
      ButtonSize.lg => 15.0,
    };

    final EdgeInsets padding = switch (widget.size) {
      ButtonSize.sm => const EdgeInsets.symmetric(horizontal: 12),
      ButtonSize.md => const EdgeInsets.symmetric(horizontal: 18),
      ButtonSize.lg => const EdgeInsets.symmetric(horizontal: 24),
    };

    // Variant colors
    Color bgColor;
    Color textColor;
    Border? border;

    switch (widget.variant) {
      case ButtonVariant.primary:
        bgColor = _isHovered ? AppColors.primaryHover : AppColors.primary;
        textColor = Colors.white;
        break;
      case ButtonVariant.secondary:
        bgColor = isDark
            ? (_isHovered ? const Color(0xFF26334D) : AppColors.darkCard)
            : (_isHovered ? const Color(0xFFE2E8F0) : const Color(0xFFF1F5F9));
        textColor = AppColors.textPrimary(isDark);
        border = Border.all(color: AppColors.border(isDark));
        break;
      case ButtonVariant.outline:
        bgColor = _isHovered
            ? (isDark ? const Color(0x1A6366F1) : const Color(0x0D4F46E5))
            : Colors.transparent;
        textColor = isDark ? AppColors.primaryLight : AppColors.primary;
        border = Border.all(color: AppColors.primary.withOpacity(0.5));
        break;
      case ButtonVariant.ghost:
        bgColor = _isHovered
            ? (isDark ? const Color(0x14FFFFFF) : const Color(0x0A000000))
            : Colors.transparent;
        textColor = AppColors.textPrimary(isDark);
        break;
      case ButtonVariant.danger:
        bgColor = _isHovered ? const Color(0xFFDC2626) : AppColors.error;
        textColor = Colors.white;
        break;
    }

    if (isDisabled) {
      bgColor = isDark ? const Color(0xFF1E2638) : const Color(0xFFE2E8F0);
      textColor = isDark ? const Color(0xFF4B5563) : const Color(0xFF94A3B8);
      border = null;
    }

    return SizedBox(
      height: height,
      width: widget.isFullWidth ? double.infinity : null,
      child: MouseRegion(
        cursor: isDisabled ? SystemMouseCursors.forbidden : SystemMouseCursors.click,
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: GestureDetector(
          onTap: isDisabled ? null : widget.onPressed,
          child: AnimatedContainer(
            duration: DesignTokens.durationFast,
            padding: padding,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: DesignTokens.borderMd,
              border: border,
              boxShadow: widget.variant == ButtonVariant.primary && !isDisabled && _isHovered
                  ? DesignTokens.glowPrimary
                  : null,
            ),
            child: Row(
              mainAxisSize: widget.isFullWidth ? MainAxisSize.max : MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (widget.isLoading) ...[
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(textColor),
                    ),
                  ),
                  const SizedBox(width: DesignTokens.space8),
                ] else if (widget.icon != null) ...[
                  Icon(widget.icon, size: fontSize + 2, color: textColor),
                  const SizedBox(width: DesignTokens.space8),
                ],
                Text(
                  widget.text,
                  style: TextStyle(
                    fontSize: fontSize,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                    letterSpacing: -0.2,
                  ),
                ),
                if (widget.trailingIcon != null && !widget.isLoading) ...[
                  const SizedBox(width: DesignTokens.space8),
                  Icon(widget.trailingIcon, size: fontSize + 2, color: textColor),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
