import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/design_tokens.dart';
import '../theme/theme_customization_models.dart';

enum ButtonVariant { primary, secondary, outline, ghost, danger }
typedef AppButtonVariant = ButtonVariant;

enum ButtonSize { sm, md, lg }
typedef AppButtonSize = ButtonSize;

/// Unslopped Button Component adhering to heydamir/unslop:
/// - Dark: Off-white primary with dark text or clean athletic accent fill
/// - Light: Solid dark graphite fill with white text or clean athletic accent fill
/// - Secondary: Raised surface with hairline border
/// - Tactile feel: Subtle 0.98 press scale and top highlight without bouncy springs or fake 3D bevels
class AppButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final ButtonVariant variant;
  final ButtonSize size;
  final IconData? icon;
  final IconData? trailingIcon;
  final bool isLoading;
  final bool isFullWidth;
  final bool enable3d; // Maintained for backwards API compatibility

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
    this.enable3d = false,
  }) : text = text ?? label ?? '';

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton> {
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isDisabled = widget.onPressed == null || widget.isLoading;

    // Height & padding on 4px grid
    final double height = switch (widget.size) {
      ButtonSize.sm => 32.0,
      ButtonSize.md => 36.0,
      ButtonSize.lg => 44.0,
    };

    final double fontSize = switch (widget.size) {
      ButtonSize.sm => 12.0,
      ButtonSize.md => 13.0,
      ButtonSize.lg => 14.0,
    };

    final EdgeInsets padding = switch (widget.size) {
      ButtonSize.sm => const EdgeInsets.symmetric(horizontal: 12),
      ButtonSize.md => const EdgeInsets.symmetric(horizontal: 16),
      ButtonSize.lg => const EdgeInsets.symmetric(horizontal: 20),
    };

    Color bgColor;
    Color textColor;
    Border? border;

    switch (widget.variant) {
      case ButtonVariant.primary:
        if (AppColors.activePalette.id == ThemePaletteId.wineAndSand) {
          bgColor = _isHovered ? const Color(0xFFFAF7F2) : const Color(0xFFF7F4EE);
          textColor = const Color(0xFF380811);
        } else if (isDark) {
          // Off-white from the ramp with dark text (heydamir/unslop recommendation for dark themes)
          bgColor = _isHovered ? const Color(0xFFFFFFFF) : const Color(0xFFEDEDED);
          textColor = const Color(0xFF141415);
        } else {
          // Solid graphite with white text
          bgColor = _isHovered ? const Color(0xFF262626) : const Color(0xFF171717);
          textColor = Colors.white;
        }
        break;

      case ButtonVariant.secondary:
        bgColor = _isHovered ? AppColors.raised(isDark).withOpacity(0.9) : AppColors.raised(isDark);
        textColor = AppColors.textPrimary(isDark);
        border = Border.all(color: AppColors.border(isDark), width: 1);
        break;

      case ButtonVariant.outline:
        bgColor = _isHovered ? AppColors.raised(isDark) : Colors.transparent;
        textColor = AppColors.textPrimary(isDark);
        border = Border.all(color: AppColors.border(isDark), width: 1);
        break;

      case ButtonVariant.ghost:
        bgColor = _isHovered ? AppColors.raised(isDark) : Colors.transparent;
        textColor = _isHovered ? AppColors.textPrimary(isDark) : AppColors.textSecondary(isDark);
        break;

      case ButtonVariant.danger:
        bgColor = _isHovered ? const Color(0xFFF0565B) : AppColors.error;
        textColor = Colors.white;
        break;
    }

    if (isDisabled) {
      bgColor = isDark ? const Color(0xFF1F1F22) : const Color(0xFFE5E7EB);
      textColor = AppColors.textMuted(isDark);
      border = null;
    }

    Widget content = Row(
      mainAxisSize: widget.isFullWidth ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (widget.isLoading) ...[
          SizedBox(
            width: 14,
            height: 14,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(textColor),
            ),
          ),
          const SizedBox(width: 8),
        ] else if (widget.icon != null) ...[
          Icon(widget.icon, size: 16, color: textColor),
          const SizedBox(width: 8),
        ],
        Text(
          widget.text,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w500, // Two weights: 400 and 500
            letterSpacing: 0,
            color: textColor,
          ),
        ),
        if (widget.trailingIcon != null && !widget.isLoading) ...[
          const SizedBox(width: 8),
          Icon(widget.trailingIcon, size: 16, color: textColor),
        ],
      ],
    );

    return MouseRegion(
      cursor: isDisabled ? SystemMouseCursors.forbidden : SystemMouseCursors.click,
      onEnter: (_) {
        if (!isDisabled) setState(() => _isHovered = true);
      },
      onExit: (_) {
        if (!isDisabled) {
          setState(() {
            _isHovered = false;
            _isPressed = false;
          });
        }
      },
      child: GestureDetector(
        onTapDown: (_) {
          if (!isDisabled) setState(() => _isPressed = true);
        },
        onTapUp: (_) {
          if (!isDisabled) setState(() => _isPressed = false);
        },
        onTapCancel: () {
          if (!isDisabled) setState(() => _isPressed = false);
        },
        onTap: isDisabled ? null : widget.onPressed,
        child: AnimatedScale(
          scale: _isPressed ? 0.98 : 1.0,
          duration: DesignTokens.durationFast,
          curve: DesignTokens.easeOutStandard,
          child: AnimatedContainer(
            duration: DesignTokens.durationFast,
            curve: DesignTokens.easeOutStandard,
            height: height,
            padding: padding,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
              border: border,
              boxShadow: (widget.variant == ButtonVariant.primary && !isDisabled)
                  ? DesignTokens.shadowSm(isDark)
                  : null,
            ),
            child: Center(
              widthFactor: widget.isFullWidth ? null : 1.0,
              child: content,
            ),
          ),
        ),
      ),
    );
  }
}
