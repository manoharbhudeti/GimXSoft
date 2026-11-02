import 'dart:ui';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/design_tokens.dart';

/// Scope that exposes current 3D tilt offsets to child widgets for multi-layer parallax effects.
class Interactive3DCardScope extends InheritedWidget {
  final Offset tiltOffset;
  final bool isHovered;

  const Interactive3DCardScope({
    super.key,
    required this.tiltOffset,
    required this.isHovered,
    required super.child,
  });

  static Interactive3DCardScope? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<Interactive3DCardScope>();
  }

  @override
  bool updateShouldNotify(Interactive3DCardScope oldWidget) {
    return oldWidget.tiltOffset != tiltOffset || oldWidget.isHovered != isHovered;
  }
}

/// A parallax layer widget that shifts its child slightly based on parent [Interactive3DCard] tilt.
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
    final scope = Interactive3DCardScope.of(context);
    final offset = scope?.tiltOffset ?? Offset.zero;

    return Transform.translate(
      offset: Offset(offset.dx * depth, offset.dy * depth),
      child: child,
    );
  }
}

/// A premium, hardware-accelerated 3D interactive card with perspective tilt,
/// dynamic specular light glare, layered depth shadows, and tactile press response.
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
    this.maxTiltAngle = 0.10, // ~5.7 degrees for a sleek, modern SaaS feel
    this.depthElevation = 1.025, // Slight z-axis lift on hover
    this.blur = DesignTokens.blurStandard,
    this.enableTilt = true,
    this.enableGlow = true,
    this.enableGlare = true,
    this.enableTactilePress = true,
  });

  @override
  State<Interactive3DCard> createState() => _Interactive3DCardState();
}

class _Interactive3DCardState extends State<Interactive3DCard>
    with SingleTickerProviderStateMixin {
  Offset _tiltOffset = Offset.zero;
  bool _isHovered = false;
  bool _isPressed = false;

  late final AnimationController _resetController;
  late Animation<Offset> _resetAnimation;

  @override
  void initState() {
    super.initState();
    _resetController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    )..addListener(() {
        setState(() {
          _tiltOffset = _resetAnimation.value;
        });
      });
  }

  @override
  void dispose() {
    _resetController.dispose();
    super.dispose();
  }

  void _onHover(PointerEvent event, Size size) {
    if (!widget.enableTilt || size.width == 0 || size.height == 0) return;

    if (_resetController.isAnimating) {
      _resetController.stop();
    }

    final dx = (event.localPosition.dx / size.width) * 2 - 1.0;
    final dy = (event.localPosition.dy / size.height) * 2 - 1.0;

    setState(() {
      _tiltOffset = Offset(
        dx.clamp(-1.0, 1.0),
        dy.clamp(-1.0, 1.0),
      );
    });
  }

  void _onEnter(PointerEnterEvent event) {
    setState(() {
      _isHovered = true;
    });
  }

  void _onExit(PointerExitEvent event) {
    setState(() {
      _isHovered = false;
      _isPressed = false;
    });

    if (widget.enableTilt) {
      _resetAnimation = Tween<Offset>(
        begin: _tiltOffset,
        end: Offset.zero,
      ).animate(
        CurvedAnimation(
          parent: _resetController,
          curve: Curves.easeOutCubic,
        ),
      );
      _resetController.forward(from: 0.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final r = widget.borderRadius ?? DesignTokens.borderLg;
    final glow = widget.glowColor ?? AppColors.primary;
    final defaultBg = widget.backgroundColor ?? AppColors.glassSurface(isDark);
    final defaultBorder = widget.borderColor ?? AppColors.glassBorder(isDark);

    return Container(
      width: widget.width,
      height: widget.height,
      margin: widget.margin,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final size = Size(
            constraints.maxWidth.isFinite ? constraints.maxWidth : 300,
            constraints.maxHeight.isFinite ? constraints.maxHeight : 200,
          );

          // Build 3D Transformation Matrix
          final matrix = Matrix4.identity();
          if (widget.enableTilt) {
            matrix.setEntry(3, 2, 0.0012); // Perspective foreshortening
            matrix.rotateX(-_tiltOffset.dy * widget.maxTiltAngle);
            matrix.rotateY(_tiltOffset.dx * widget.maxTiltAngle);
          }

          if (_isPressed && widget.enableTactilePress) {
            matrix.scale(0.98);
          } else if (_isHovered) {
            matrix.scale(widget.depthElevation);
          }

          // Layered Dynamic 3D Shadows
          final shadowOffsetX = -_tiltOffset.dx * 8.0;
          final shadowOffsetY = -_tiltOffset.dy * 8.0 + (_isHovered ? 14.0 : 4.0);

          final shadows = <BoxShadow>[
            // Ambient soft floor shadow
            BoxShadow(
              color: isDark
                  ? Colors.black.withOpacity(_isHovered ? 0.45 : 0.25)
                  : (widget.enableGlow ? glow : Colors.black).withOpacity(_isHovered ? 0.16 : 0.06),
              blurRadius: _isHovered ? 26.0 : 12.0,
              offset: Offset(shadowOffsetX, shadowOffsetY),
              spreadRadius: _isHovered ? 1.0 : 0.0,
            ),
            // Tactile 3D bottom bevel shadow
            if (_isHovered)
              BoxShadow(
                color: isDark ? Colors.black.withOpacity(0.55) : Colors.black.withOpacity(0.08),
                blurRadius: 10.0,
                offset: Offset(shadowOffsetX * 0.5, shadowOffsetY * 0.6),
              ),
            // Neon accent aura when glow enabled
            if (_isHovered && widget.enableGlow)
              BoxShadow(
                color: glow.withOpacity(isDark ? 0.22 : 0.12),
                blurRadius: 28.0,
                spreadRadius: -2.0,
              ),
          ];

          return MouseRegion(
            onEnter: _onEnter,
            onExit: _onExit,
            onHover: (e) => _onHover(e, size),
            cursor: widget.onTap != null ? SystemMouseCursors.click : MouseCursor.defer,
            child: GestureDetector(
              onTapDown: widget.enableTactilePress ? (_) => setState(() => _isPressed = true) : null,
              onTapUp: widget.enableTactilePress ? (_) => setState(() => _isPressed = false) : null,
              onTapCancel: widget.enableTactilePress ? () => setState(() => _isPressed = false) : null,
              onTap: widget.onTap,
              child: AnimatedContainer(
                duration: _resetController.isAnimating ? Duration.zero : const Duration(milliseconds: 90),
                curve: Curves.easeOut,
                transform: matrix,
                transformAlignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: r,
                  boxShadow: shadows,
                ),
                child: ClipRRect(
                  borderRadius: r,
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: widget.blur, sigmaY: widget.blur),
                    child: Container(
                      decoration: BoxDecoration(
                        color: _isHovered
                            ? (isDark ? const Color(0xE8182236) : const Color(0xF8FFFFFF))
                            : defaultBg,
                        borderRadius: r,
                        border: Border.all(
                          color: _isHovered
                              ? glow.withOpacity(isDark ? 0.65 : 0.45)
                              : defaultBorder,
                          width: _isHovered ? 1.4 : 1.0,
                        ),
                      ),
                      child: Stack(
                        children: [
                          // 1. Dynamic Specular Light Glare (Holographic Sheen)
                          if (widget.enableGlare && _isHovered)
                            Positioned.fill(
                              child: IgnorePointer(
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: r,
                                    gradient: RadialGradient(
                                      center: Alignment(
                                        _tiltOffset.dx * 0.85,
                                        _tiltOffset.dy * 0.85,
                                      ),
                                      radius: 0.95,
                                      colors: [
                                        (widget.specularColor ??
                                                (isDark ? Colors.white : glow))
                                            .withOpacity(isDark ? 0.14 : 0.08),
                                        (widget.specularColor ??
                                                (isDark ? Colors.white : glow))
                                            .withOpacity(0.0),
                                      ],
                                      stops: const [0.0, 1.0],
                                    ),
                                  ),
                                ),
                              ),
                            ),

                          // 2. Specular Top Edge Light Refraction
                          Positioned(
                            top: 0,
                            left: 0,
                            right: 0,
                            height: 1.5,
                            child: IgnorePointer(
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                    colors: [
                                      Colors.transparent,
                                      (isDark ? Colors.white : glow)
                                          .withOpacity(_isHovered ? 0.45 : 0.15),
                                      Colors.transparent,
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),

                          // 3. Child Content wrapped in Interactive3DCardScope for parallax
                          Interactive3DCardScope(
                            tiltOffset: _tiltOffset,
                            isHovered: _isHovered,
                            child: Padding(
                              padding: widget.padding ??
                                  const EdgeInsets.all(DesignTokens.space20),
                              child: widget.child,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
