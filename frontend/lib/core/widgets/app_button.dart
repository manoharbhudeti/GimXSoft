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
  final bool enable3d;

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
    this.enable3d = true,
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
    List<BoxShadow>? shadows;

    switch (widget.variant) {
      case ButtonVariant.primary:
        bgColor = _isHovered ? AppColors.primaryHover : AppColors.primary;
        textColor = Colors.white;
        if (!isDisabled && widget.enable3d) {
          final bevelColor = const Color(0xFF3730A3); // Darker indigo base
          shadows = [
            // 3D tactile ledge
            BoxShadow(
              color: bevelColor,
              offset: Offset(0, _isPressed ? 1.0 : (_isHovered ? 4.0 : 2.5)),
              blurRadius: 0,
            ),
            // Dynamic ambient shadow & neon glow
            BoxShadow(
              color: AppColors.primary.withOpacity(_isHovered ? 0.40 : 0.20),
              offset: Offset(0, _isHovered ? 8.0 : 4.0),
              blurRadius: _isHovered ? 16.0 : 8.0,
              spreadRadius: _isHovered ? 1.0 : 0.0,
            ),
          ];
        }
        break;
      case ButtonVariant.secondary:
        bgColor = isDark
            ? (_isHovered ? const Color(0xFF26334D) : AppColors.darkCard)
            : (_isHovered ? const Color(0xFFE2E8F0) : const Color(0xFFF1F5F9));
        textColor = AppColors.textPrimary(isDark);
        border = Border.all(
          color: _isHovered
              ? AppColors.primary.withOpacity(0.5)
              : AppColors.border(isDark),
        );
        if (!isDisabled && widget.enable3d) {
          shadows = [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.35 : 0.06),
              offset: Offset(0, _isPressed ? 1.0 : (_isHovered ? 4.0 : 2.0)),
              blurRadius: _isHovered ? 8.0 : 4.0,
            ),
          ];
        }
        break;
      case ButtonVariant.outline:
        bgColor = _isHovered
            ? (isDark ? const Color(0x1A6366F1) : const Color(0x0D4F46E5))
            : Colors.transparent;
        textColor = isDark ? AppColors.primaryLight : AppColors.primary;
        border = Border.all(
          color: _isHovered
              ? AppColors.primary
              : AppColors.primary.withOpacity(0.5),
          width: _isHovered ? 1.4 : 1.0,
        );
        if (!isDisabled && _isHovered && widget.enable3d) {
          shadows = [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.18),
              blurRadius: 12.0,
            ),
          ];
        }
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
        if (!isDisabled && widget.enable3d) {
          shadows = [
            BoxShadow(
              color: const Color(0xFF991B1B),
              offset: Offset(0, _isPressed ? 1.0 : (_isHovered ? 3.5 : 2.0)),
              blurRadius: 0,
            ),
            BoxShadow(
              color: AppColors.error.withOpacity(_isHovered ? 0.35 : 0.15),
              offset: Offset(0, _isHovered ? 6.0 : 3.0),
              blurRadius: _isHovered ? 12.0 : 6.0,
            ),
          ];
        }
        break;
    }

    if (isDisabled) {
      bgColor = isDark ? const Color(0xFF1E2638) : const Color(0xFFE2E8F0);
      textColor = isDark ? const Color(0xFF4B5563) : const Color(0xFF94A3B8);
      border = null;
      shadows = null;
    }

    // 3D tactile displacement calculation
    final double translateY = (!isDisabled && widget.enable3d)
        ? (_isPressed ? 2.0 : (_isHovered ? -1.5 : 0.0))
        : 0.0;

    return SizedBox(
      height: height,
      width: widget.isFullWidth ? double.infinity : null,
      child: MouseRegion(
        cursor: isDisabled ? SystemMouseCursors.forbidden : SystemMouseCursors.click,
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() {
          _isHovered = false;
          _isPressed = false;
        }),
        child: GestureDetector(
          onTapDown: isDisabled ? null : (_) => setState(() => _isPressed = true),
          onTapUp: isDisabled ? null : (_) => setState(() => _isPressed = false),
          onTapCancel: isDisabled ? null : () => setState(() => _isPressed = false),
          onTap: isDisabled ? null : widget.onPressed,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 110),
            curve: Curves.easeOutQuad,
            transform: Matrix4.translationValues(0.0, translateY, 0.0),
            padding: padding,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: DesignTokens.borderMd,
              border: border,
              boxShadow: shadows,
            ),
            child: Stack(
              children: [
                // Top-lit 3D specular highlight rim for primary and danger buttons
                if ((widget.variant == ButtonVariant.primary ||
                        widget.variant == ButtonVariant.danger) &&
                    !isDisabled)
                  Positioned(
                    top: 0,
                    left: 2,
                    right: 2,
                    height: 1.0,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.25),
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                      ),
                    ),
                  ),
                Row(
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
