import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/design_tokens.dart';

/// Unslopped Card Component:
/// - Crisp, quiet solid surface from the graphite neutral ramp
/// - Subtle hairline border (8% opacity)
/// - Subdued surface step on hover without bouncing, floating or glowing borders
class GlassCard extends StatefulWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final Color? backgroundColor;
  final Color? borderColor;
  final Color? glowColor; // Kept for API compatibility, rendered as quiet neutral
  final VoidCallback? onTap;
  final bool enableHover;
  final bool enable3d; // Deprecated by unslop, rendered with quiet surface steps
  final double blur;

  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.borderRadius,
    this.backgroundColor,
    this.borderColor,
    this.glowColor,
    this.onTap,
    this.enableHover = false,
    this.enable3d = false,
    this.blur = DesignTokens.blurStandard,
  });

  @override
  State<GlassCard> createState() => _GlassCardState();
}

class _GlassCardState extends State<GlassCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final r = widget.borderRadius ?? DesignTokens.borderLg;

    final defaultBg = widget.backgroundColor ?? AppColors.card(isDark);
    final defaultBorder = widget.borderColor ?? AppColors.border(isDark);

    // Unslopped hover: Subtle surface step without colored glow or vertical jump
    final surfaceColor = _isHovered && (widget.enableHover || widget.onTap != null)
        ? AppColors.raised(isDark)
        : defaultBg;

    final effectiveBorder = _isHovered && (widget.enableHover || widget.onTap != null)
        ? AppColors.border(isDark).withOpacity(0.18)
        : defaultBorder;

    return Container(
      width: widget.width,
      height: widget.height,
      margin: widget.margin,
      child: MouseRegion(
        onEnter: (widget.enableHover || widget.onTap != null) ? (_) => setState(() => _isHovered = true) : null,
        onExit: (widget.enableHover || widget.onTap != null) ? (_) => setState(() => _isHovered = false) : null,
        cursor: widget.onTap != null ? SystemMouseCursors.click : MouseCursor.defer,
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: DesignTokens.durationFast,
            curve: DesignTokens.easeOutStandard,
            decoration: BoxDecoration(
              color: surfaceColor,
              borderRadius: r,
              border: Border.all(color: effectiveBorder, width: 1.0),
              boxShadow: DesignTokens.shadowSm(isDark),
            ),
            child: Padding(
              padding: widget.padding ?? const EdgeInsets.all(DesignTokens.space20),
              child: widget.child,
            ),
          ),
        ),
      ),
    );
  }
}
