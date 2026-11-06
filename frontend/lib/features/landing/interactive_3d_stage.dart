import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// 2D Muscular Zeus Stage with Dynamic Procedural Thunder & Lightning Animations.
/// Replaces legacy 3D ring with mythological athletic power matching the application vibe.
class Interactive3DStage extends StatefulWidget {
  final int liveOccupancy;
  final VoidCallback? onSimulateScan;

  const Interactive3DStage({
    super.key,
    this.liveOccupancy = 42,
    this.onSimulateScan,
  });

  @override
  State<Interactive3DStage> createState() => _Interactive3DStageState();
}

typedef ZeusThunderStage = Interactive3DStage;

class _LightningSegment {
  final Offset start;
  final Offset end;
  final double width;
  final bool isBranch;

  _LightningSegment(this.start, this.end, this.width, this.isBranch);
}

class _LightningBolt {
  final List<_LightningSegment> segments;
  double alpha = 1.0;
  final double decay;
  final Color color = const Color(0xFFF59E0B);

  _LightningBolt({
    required this.segments,
    this.decay = 0.055,
  });
}

class _LightningSpark {
  Offset position;
  Offset velocity;
  double alpha = 1.0;
  final double decay;
  final double size;
  final Color color;

  _LightningSpark({
    required this.position,
    required this.velocity,
    required this.decay,
    required this.size,
    required this.color,
  });
}

class _Interactive3DStageState extends State<Interactive3DStage>
    with TickerProviderStateMixin {
  late final AnimationController _breatheController;
  late final AnimationController _ticker;

  final List<_LightningBolt> _bolts = [];
  final List<_LightningSpark> _sparks = [];
  final math.Random _random = math.Random();
  Timer? _burstTimer1;
  Timer? _burstTimer2;

  Offset _pointerOffset = Offset.zero;
  double _flashOpacity = 0.0;

  DateTime _lastAmbient = DateTime.now();

  @override
  void initState() {
    super.initState();

    // 1. Zeus Breathing & Muscle Flexing Animation (4.2s subtle cycle)
    _breatheController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4200),
    )..repeat(reverse: true);

    // 2. 60 FPS Lightning Simulation Loop
    _ticker = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..addListener(_onTick);
    _ticker.repeat();

    // 3. Initial power-up storm on load!
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _triggerThunderStorm();
    });
  }

  void _onTick() {
    final now = DateTime.now();

    // Trigger ambient lightning every 2.0 to 3.2 seconds
    if (now.difference(_lastAmbient).inMilliseconds > 2400) {
      _lastAmbient = now;
      if (_random.nextDouble() > 0.2) {
        _strikeThunder(const Size(440, 420));
      }
    }

    // Fade flash
    if (_flashOpacity > 0.0) {
      setState(() {
        _flashOpacity = math.max(0.0, _flashOpacity - 0.12);
      });
    }

    // Update bolts
    bool needsRepaint = false;
    for (int i = _bolts.length - 1; i >= 0; i--) {
      _bolts[i].alpha -= _bolts[i].decay;
      if (_bolts[i].alpha <= 0.0) {
        _bolts.removeAt(i);
      }
      needsRepaint = true;
    }

    // Update sparks
    for (int i = _sparks.length - 1; i >= 0; i--) {
      final s = _sparks[i];
      s.position += s.velocity;
      s.velocity = Offset(s.velocity.dx * 0.94, (s.velocity.dy * 0.94) + 0.12);
      s.alpha -= s.decay;
      if (s.alpha <= 0.0) {
        _sparks.removeAt(i);
      }
      needsRepaint = true;
    }

    if (needsRepaint && mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _burstTimer1?.cancel();
    _burstTimer2?.cancel();
    _breatheController.dispose();
    _ticker.dispose();
    super.dispose();
  }

  Offset _getZeusFistCoords(Size size) {
    // Zeus raised flexed left fist position
    return Offset(size.width * 0.72, size.height * 0.18);
  }

  void _generateBolt(
    Offset start,
    Offset end,
    int depth,
    double width,
    List<_LightningSegment> outSegments,
  ) {
    final dx = end.dx - start.dx;
    final dy = end.dy - start.dy;
    final dist = math.sqrt(dx * dx + dy * dy);

    if (dist < 18.0 || depth > 5) {
      outSegments.add(_LightningSegment(start, end, width, depth > 0));
      return;
    }

    final midX = (start.dx + end.dx) / 2.0;
    final midY = (start.dy + end.dy) / 2.0;
    final normalX = -dy / dist;
    final normalY = dx / dist;

    final jitter = (_random.nextDouble() - 0.5) * dist * 0.44;
    final displaced = Offset(midX + normalX * jitter, midY + normalY * jitter);

    _generateBolt(start, displaced, depth + 1, width * 0.95, outSegments);
    _generateBolt(displaced, end, depth + 1, width * 0.92, outSegments);

    // Branching fork
    if (depth < 3 && _random.nextDouble() < 0.45) {
      final branchAngle = (_random.nextDouble() - 0.5) * 1.1;
      final branchLength = dist * (0.35 + _random.nextDouble() * 0.35);
      final cos = math.cos(branchAngle);
      final sin = math.sin(branchAngle);
      final dirX = (dx * cos - dy * sin) / dist;
      final dirY = (dx * sin + dy * cos) / dist;

      final branchTarget = Offset(
        displaced.dx + dirX * branchLength,
        displaced.dy + dirY * branchLength,
      );

      _generateBolt(displaced, branchTarget, depth + 1, width * 0.65, outSegments);
    }
  }

  void _strikeThunder(Size size, [Offset? target, bool isUserClick = false]) {
    final fist = _getZeusFistCoords(size);

    final actualTarget = target ??
        Offset(
          size.width * (0.15 + _random.nextDouble() * 0.75),
          size.height * (0.40 + _random.nextDouble() * 0.55),
        );

    final segments = <_LightningSegment>[];
    _generateBolt(fist, actualTarget, 0, isUserClick ? 4.0 : 3.0, segments);

    _bolts.add(_LightningBolt(
      segments: segments,
      decay: isUserClick ? 0.045 : 0.065,
    ));

    // Spawn crackling sparks
    final sparkCount = 14 + _random.nextInt(14);
    for (int i = 0; i < sparkCount; i++) {
      final t = _random.nextDouble();
      final p = Offset(
        fist.dx + (actualTarget.dx - fist.dx) * t + (_random.nextDouble() - 0.5) * 20,
        fist.dy + (actualTarget.dy - fist.dy) * t + (_random.nextDouble() - 0.5) * 20,
      );
      final angle = _random.nextDouble() * math.pi * 2;
      final speed = 1.5 + _random.nextDouble() * 4.0;
      _sparks.add(_LightningSpark(
        position: p,
        velocity: Offset(math.cos(angle) * speed, math.sin(angle) * speed),
        decay: 0.035 + _random.nextDouble() * 0.04,
        size: 1.5 + _random.nextDouble() * 2.0,
        color: _random.nextDouble() > 0.4 ? const Color(0xFFF59E0B) : Colors.white,
      ));
    }

    _flashOpacity = isUserClick ? 0.45 : 0.22;
  }

  void _triggerThunderStorm() {
    const size = Size(440, 420);
    _strikeThunder(size, Offset(size.width * 0.18, size.height * 0.70), true);
    _burstTimer1?.cancel();
    _burstTimer2?.cancel();
    _burstTimer1 = Timer(const Duration(milliseconds: 70), () {
      if (mounted) _strikeThunder(size, Offset(size.width * 0.10, size.height * 0.25), true);
    });
    _burstTimer2 = Timer(const Duration(milliseconds: 140), () {
      if (mounted) _strikeThunder(size, Offset(size.width * 0.85, size.height * 0.80), true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return MouseRegion(
      onExit: (_) => setState(() {
        _pointerOffset = Offset.zero;
      }),
      onHover: (event) {
        final box = context.findRenderObject() as RenderBox?;
        if (box != null) {
          final local = event.localPosition;
          final w = box.size.width;
          final h = box.size.height;
          setState(() {
            _pointerOffset = Offset(
              ((local.dx / w) * 2.0) - 1.0,
              ((local.dy / h) * 2.0) - 1.0,
            );
          });
        }
      },
      child: GestureDetector(
        onTapDown: (details) {
          _strikeThunder(const Size(440, 420), details.localPosition, true);
        },
        child: SizedBox(
          width: 440,
          height: 420,
          child: Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              // 1. Subtle Radial Backlight Aura that blends directly into the UI
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: const Alignment(0.35, -0.30),
                      radius: 0.85,
                      colors: [
                        AppColors.primary.withOpacity(isDark ? 0.28 : 0.16),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),

              // 2. Animated Muscular Zeus Character with Breathing & Flex
              AnimatedBuilder(
                animation: _breatheController,
                builder: (context, child) {
                  final scale = 1.0 + (_breatheController.value * 0.032);
                  final floatY = math.sin(_breatheController.value * math.pi) * -6.0;

                  return Transform.translate(
                    offset: Offset(
                      _pointerOffset.dx * 6.0,
                      floatY + (_pointerOffset.dy * 6.0),
                    ),
                    child: Transform.scale(
                      scale: scale,
                      child: child,
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Image.asset(
                    isDark
                        ? 'assets/images/zeus_white.png'
                        : 'assets/images/zeus_black.png',
                    fit: BoxFit.contain,
                    filterQuality: FilterQuality.high,
                    errorBuilder: (context, error, stackTrace) {
                      return const Center(
                        child: Icon(
                          Icons.bolt_rounded,
                          size: 140,
                          color: AppColors.primary,
                        ),
                      );
                    },
                  ),
                ),
              ),

              // 3. 2D Procedural Thunderbolts & Crackling Sparks Canvas
              Positioned.fill(
                child: CustomPaint(
                  size: const Size(440, 420),
                  painter: _ZeusThunderPainter(
                    bolts: _bolts,
                    sparks: _sparks,
                  ),
                ),
              ),

              // 4. Atmospheric Lightning Flash Overlay
              if (_flashOpacity > 0.0)
                Positioned.fill(
                  child: IgnorePointer(
                    child: Container(
                      color: const Color(0xFFFEF3C7).withOpacity(_flashOpacity),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ZeusThunderPainter extends CustomPainter {
  final List<_LightningBolt> bolts;
  final List<_LightningSpark> sparks;

  _ZeusThunderPainter({
    required this.bolts,
    required this.sparks,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Draw lightning bolts
    for (final bolt in bolts) {
      if (bolt.alpha <= 0.0) continue;

      // Outer Corona (Warm Amber Glow)
      final coronaPaint = Paint()
        ..color = const Color(0xFFF59E0B).withOpacity(math.min(1.0, bolt.alpha * 0.85))
        ..strokeWidth = 6.0
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8.0);

      // Inner Core (Pure White Strike)
      final corePaint = Paint()
        ..color = Colors.white.withOpacity(math.min(1.0, bolt.alpha))
        ..strokeWidth = 2.2
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke;

      final path = Path();
      for (int i = 0; i < bolt.segments.length; i++) {
        final s = bolt.segments[i];
        if (i == 0 || s.isBranch) {
          path.moveTo(s.start.dx, s.start.dy);
        }
        path.lineTo(s.end.dx, s.end.dy);
      }

      canvas.drawPath(path, coronaPaint);
      canvas.drawPath(path, corePaint);
    }

    // 2. Draw crackling sparks
    final sparkPaint = Paint()..style = PaintingStyle.fill;
    for (final spark in sparks) {
      if (spark.alpha <= 0.0) continue;
      sparkPaint.color = spark.color.withOpacity(math.min(1.0, spark.alpha));
      canvas.drawCircle(spark.position, spark.size, sparkPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _ZeusThunderPainter oldDelegate) => true;
}
