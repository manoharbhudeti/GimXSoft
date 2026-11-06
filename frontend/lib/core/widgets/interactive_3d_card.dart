import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/design_tokens.dart';

/// Scope exposing card hover status to child widgets.
class Interactive3DCardScope extends InheritedWidget {
  final Offset tiltOffset;
  final bool isHovered;

  const Interactive3DCardScope({
    super.key,
    this.tiltOffset = Offset.zero,
    required this.isHovered,
    required super.child,
  });

  static Interactive3DCardScope? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<Interactive3DCardScope>();
  }

  @override
  bool updateShouldNotify(Interactive3DCardScope oldWidget) {
    return oldWidget.isHovered != isHovered;
  }
}

/// Unslopped Parallax Layer:
/// Renders its child cleanly and stably without disorienting tilt jitter.
class ParallaxLayer extends StatelessWidget {
  final Widget child;
  final double depth;

  const ParallaxLayer({
    super.key,
    required this.child,
    this.depth = 10.0,
  });

  @override
  Widget build(BuildContext context) {
    return child;
  }
}

/// Unslopped Interactive Card adhering to heydamir/unslop:
/// - Replaces disorienting 3D Matrix4 perspective tilt, colored neon glows, and fake holographic glares
/// - Clean graphite neutral surface with quiet hairline border
/// - Subtle 140ms surface step on hover without layout shifting or bouncy springs
class Interactive3DCard extends StatefulWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final Color? backgroundColor;
  final Color? borderColor;
  final Color? glowColor;
  final Color? specularColor;
  final VoidCallback? onTap;
  final double maxTiltAngle;
  final double depthElevation;
  final double blur;
  final bool enableTilt;
  final bool enableGlow;
  final bool enableGlare;
  final bool enableTactilePress;

  const Interactive3DCard({
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
    this.specularColor,
    this.onTap,
    this.maxTiltAngle = 0.0,
    this.depthElevation = 1.0,
    this.blur = DesignTokens.blurStandard,
    this.enableTilt = false,
    this.enableGlow = false,
    this.enableGlare = false,
    this.enableTactilePress = false,
  });

  @override
  State<Interactive3DCard> createState() => _Interactive3DCardState();
}

class _Interactive3DCardState extends State<Interactive3DCard> {
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final r = widget.borderRadius ?? BorderRadius.circular(DesignTokens.radiusLg);

    final defaultBg = widget.backgroundColor ?? AppColors.card(isDark);
    final defaultBorder = widget.borderColor ?? AppColors.border(isDark);

    final surfaceColor = _isHovered && widget.onTap != null
        ? AppColors.raised(isDark)
        : defaultBg;

    final border = Border.all(
      color: _isHovered && widget.onTap != null
          ? AppColors.border(isDark).withOpacity(0.2)
          : defaultBorder,
      width: 1.0,
    );

    return Container(
      width: widget.width,
      height: widget.height,
      margin: widget.margin,
      child: MouseRegion(
        cursor: widget.onTap != null ? SystemMouseCursors.click : MouseCursor.defer,
        onEnter: (_) {
          if (widget.onTap != null) setState(() => _isHovered = true);
        },
        onExit: (_) {
          if (widget.onTap != null) {
            setState(() {
              _isHovered = false;
              _isPressed = false;
            });
          }
        },
        child: GestureDetector(
          onTapDown: (_) {
            if (widget.onTap != null) setState(() => _isPressed = true);
          },
          onTapUp: (_) {
            if (widget.onTap != null) setState(() => _isPressed = false);
          },
          onTapCancel: () {
            if (widget.onTap != null) setState(() => _isPressed = false);
          },
          onTap: widget.onTap,
          child: AnimatedScale(
            scale: _isPressed && widget.onTap != null ? 0.99 : 1.0,
            duration: DesignTokens.durationFast,
            curve: DesignTokens.easeOutStandard,
            child: AnimatedContainer(
              duration: DesignTokens.durationFast,
              curve: DesignTokens.easeOutStandard,
              padding: widget.padding ?? const EdgeInsets.all(DesignTokens.space20),
              decoration: BoxDecoration(
                color: surfaceColor,
                borderRadius: r,
                border: border,
                boxShadow: DesignTokens.shadowSm(isDark),
              ),
              child: Interactive3DCardScope(
                isHovered: _isHovered,
                child: widget.child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
