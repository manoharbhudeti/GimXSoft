import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/design_tokens.dart';
import 'interactive_3d_card.dart';

class GlassCard extends StatefulWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final Color? backgroundColor;
  final Color? borderColor;
  final Color? glowColor;
  final VoidCallback? onTap;
  final bool enableHover;
  final bool enable3d;
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
    if (widget.enable3d) {
      return Interactive3DCard(
        width: widget.width,
        height: widget.height,
        margin: widget.margin,
        padding: widget.padding,
        borderRadius: widget.borderRadius,
        backgroundColor: widget.backgroundColor,
        borderColor: widget.borderColor,
        glowColor: widget.glowColor,
        onTap: widget.onTap,
        blur: widget.blur,
        child: widget.child,
      );
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final r = widget.borderRadius ?? DesignTokens.borderLg;

    final defaultBg = widget.backgroundColor ?? AppColors.glassSurface(isDark);
    final defaultBorder = widget.borderColor ?? AppColors.glassBorder(isDark);

    return Container(
      width: widget.width,
      height: widget.height,
      margin: widget.margin,
      child: MouseRegion(
        onEnter: widget.enableHover ? (_) => setState(() => _isHovered = true) : null,
        onExit: widget.enableHover ? (_) => setState(() => _isHovered = false) : null,
        cursor: widget.onTap != null ? SystemMouseCursors.click : MouseCursor.defer,
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: DesignTokens.durationFast,
            curve: Curves.easeOut,
            transform: _isHovered && widget.enableHover
                ? (Matrix4.identity()..translate(0.0, -3.0, 0.0))
                : Matrix4.identity(),
            decoration: BoxDecoration(
              borderRadius: r,
              boxShadow: _isHovered && widget.enableHover
                  ? DesignTokens.shadowLg(isDark)
                  : DesignTokens.shadowSm(isDark),
            ),
            child: ClipRRect(
              borderRadius: r,
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: widget.blur, sigmaY: widget.blur),
                child: Container(
                  padding: widget.padding ?? const EdgeInsets.all(DesignTokens.space20),
                  decoration: BoxDecoration(
                    color: _isHovered && widget.enableHover
                        ? (isDark ? const Color(0xE6162032) : const Color(0xF2FFFFFF))
                        : defaultBg,
                    borderRadius: r,
                    border: Border.all(
                      color: _isHovered && widget.enableHover
                          ? (widget.glowColor ?? AppColors.primary).withOpacity(0.5)
                          : defaultBorder,
                      width: 1.0,
                    ),
                  ),
                  child: widget.child,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
