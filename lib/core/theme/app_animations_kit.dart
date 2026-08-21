import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:unisphere/core/theme/app_animations.dart';
export 'package:unisphere/widgets/common/app_liquid_pull_to_refresh.dart';

/// ─────────────────────────────────────────────────────────────────────────────
/// 1. APP COUNT UP TEXT
/// Animates numeric values smoothly (e.g. CGPA, Attendance %, Credits, Tasks)
/// ─────────────────────────────────────────────────────────────────────────────
class AppCountUpText extends StatelessWidget {
  final double end;
  final double begin;
  final int precision;
  final String prefix;
  final String suffix;
  final TextStyle? style;
  final Duration duration;
  final Curve curve;

  const AppCountUpText({
    super.key,
    required this.end,
    this.begin = 0.0,
    this.precision = 0,
    this.prefix = '',
    this.suffix = '',
    this.style,
    this.duration = const Duration(milliseconds: 900),
    this.curve = Curves.easeOutCubic,
  });

  @override
  Widget build(BuildContext context) {
    if (AppAnimations.isReducedMotion(context)) {
      final formatted = precision > 0 ? end.toStringAsFixed(precision) : end.round().toString();
      return Text('$prefix$formatted$suffix', style: style);
    }

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: begin, end: end),
      duration: duration,
      curve: curve,
      builder: (context, value, child) {
        final formatted = precision > 0 ? value.toStringAsFixed(precision) : value.round().toString();
        return Text('$prefix$formatted$suffix', style: style);
      },
    );
  }
}

/// ─────────────────────────────────────────────────────────────────────────────
/// 2. APP LIVE PULSE STATUS DOT
/// Displays an animated radiating pulse ring for ongoing classes & live statuses.
/// ─────────────────────────────────────────────────────────────────────────────
class AppLivePulseDot extends StatefulWidget {
  final Color color;
  final double size;
  final String? label;
  final TextStyle? labelStyle;

  const AppLivePulseDot({
    super.key,
    this.color = const Color(0xFF10B981), // Emerald Live
    this.size = 8.0,
    this.label,
    this.labelStyle,
  });

  @override
  State<AppLivePulseDot> createState() => _AppLivePulseDotState();
}

class _AppLivePulseDotState extends State<AppLivePulseDot> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _pulseAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();

    _pulseAnimation = Tween<double>(begin: 1.0, end: 2.3).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _opacityAnimation = Tween<double>(begin: 0.65, end: 0.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dot = SizedBox(
      width: widget.size * 2.4,
      height: widget.size * 2.4,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Radiating Wave Ring
          AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              return Transform.scale(
                scale: _pulseAnimation.value,
                child: Container(
                  width: widget.size,
                  height: widget.size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: widget.color.withValues(alpha: _opacityAnimation.value),
                  ),
                ),
              );
            },
          ),
          // Core Solid Dot
          Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: widget.color,
              boxShadow: [
                BoxShadow(
                  color: widget.color.withValues(alpha: 0.4),
                  blurRadius: 4,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
        ],
      ),
    );

    if (widget.label != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          dot,
          const SizedBox(width: 5),
          Text(
            widget.label!,
            style: widget.labelStyle ??
                TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: widget.color,
                  letterSpacing: 0.2,
                ),
          ),
        ],
      );
    }

    return dot;
  }
}

/// ─────────────────────────────────────────────────────────────────────────────
/// 3. APP PARALLAX TILT CARD
/// Smooth 3D perspective tilt container responding to touch pan with spring recovery.
/// ─────────────────────────────────────────────────────────────────────────────
class AppParallaxTiltCard extends StatefulWidget {
  final Widget child;
  final double maxTiltAngle;
  final BorderRadius? borderRadius;
  final VoidCallback? onTap;

  const AppParallaxTiltCard({
    super.key,
    required this.child,
    this.maxTiltAngle = 0.08,
    this.borderRadius,
    this.onTap,
  });

  @override
  State<AppParallaxTiltCard> createState() => _AppParallaxTiltCardState();
}

class _AppParallaxTiltCardState extends State<AppParallaxTiltCard> with SingleTickerProviderStateMixin {
  late AnimationController _springController;
  late Animation<Offset> _springAnimation;
  Offset _tiltOffset = Offset.zero;

  @override
  void initState() {
    super.initState();
    _springController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _springAnimation = Tween<Offset>(begin: Offset.zero, end: Offset.zero).animate(
      CurvedAnimation(parent: _springController, curve: Curves.elasticOut),
    );
  }

  @override
  void dispose() {
    _springController.dispose();
    super.dispose();
  }

  void _onPanUpdate(DragUpdateDetails details, Size size) {
    if (size.width == 0 || size.height == 0) return;
    final dx = (details.localPosition.dx / size.width) - 0.5;
    final dy = (details.localPosition.dy / size.height) - 0.5;
    setState(() {
      _tiltOffset = Offset(
        dx.clamp(-0.5, 0.5) * widget.maxTiltAngle,
        dy.clamp(-0.5, 0.5) * widget.maxTiltAngle,
      );
    });
  }

  void _onPanEnd(DragEndDetails _) {
    _springAnimation = Tween<Offset>(
      begin: _tiltOffset,
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _springController, curve: Curves.elasticOut));
    _springController.forward(from: 0.0).then((_) {
      if (mounted) setState(() => _tiltOffset = Offset.zero);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (AppAnimations.isReducedMotion(context)) {
      return GestureDetector(onTap: widget.onTap, child: widget.child);
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);
        final currentOffset = _springController.isAnimating ? _springAnimation.value : _tiltOffset;

        return GestureDetector(
          onTap: widget.onTap,
          onPanUpdate: (details) => _onPanUpdate(details, size),
          onPanEnd: _onPanEnd,
          onPanCancel: () => _onPanEnd(DragEndDetails()),
          child: Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001) // Perspective depth
              ..rotateX(-currentOffset.dy)
              ..rotateY(currentOffset.dx),
            child: widget.child,
          ),
        );
      },
    );
  }
}

/// ─────────────────────────────────────────────────────────────────────────────
/// 4. APP STREAK FLAME
/// Animated breathing flame icon with gentle flicker for streaks and active achievements.
/// ─────────────────────────────────────────────────────────────────────────────
class AppStreakFlame extends StatefulWidget {
  final int streakCount;
  final double size;
  final Color flameColor;

  const AppStreakFlame({
    super.key,
    required this.streakCount,
    this.size = 20.0,
    this.flameColor = const Color(0xFFF97316), // Vivid Orange Flame
  });

  @override
  State<AppStreakFlame> createState() => _AppStreakFlameState();
}

class _AppStreakFlameState extends State<AppStreakFlame> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 0.92, end: 1.08).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: child,
            );
          },
          child: Icon(
            Icons.local_fire_department_rounded,
            size: widget.size,
            color: widget.flameColor,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          '${widget.streakCount}',
          style: TextStyle(
            fontSize: widget.size * 0.7,
            fontWeight: FontWeight.w800,
            color: widget.flameColor,
          ),
        ),
      ],
    );
  }
}

/// ─────────────────────────────────────────────────────────────────────────────
/// 5. APP CONFETTI OVERLAY & PARTICLE CANNON
/// Zero-dependency lightweight particle burst for celebrations and milestones.
/// ─────────────────────────────────────────────────────────────────────────────
class AppConfetti {
  static void show(BuildContext context) {
    HapticFeedback.heavyImpact();
    final overlay = Overlay.maybeOf(context);
    if (overlay == null) return;

    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (ctx) => _ConfettiBurstWidget(
        onFinished: () {
          entry.remove();
        },
      ),
    );

    overlay.insert(entry);
  }
}

class _ConfettiBurstWidget extends StatefulWidget {
  final VoidCallback onFinished;

  const _ConfettiBurstWidget({required this.onFinished});

  @override
  State<_ConfettiBurstWidget> createState() => _ConfettiBurstWidgetState();
}

class _ConfettiBurstWidgetState extends State<_ConfettiBurstWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<_Particle> _particles = [];
  final math.Random _random = math.Random();

  final List<Color> _palette = const [
    Color(0xFF2563EB), // Royal Blue
    Color(0xFF3B82F6), // Light Blue
    Color(0xFF10B981), // Emerald
    Color(0xFFF59E0B), // Amber
    Color(0xFFEC4899), // Pink
    Color(0xFF8B5CF6), // Purple
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );

    // Generate 45 celebratory particles
    for (int i = 0; i < 45; i++) {
      final angle = (_random.nextDouble() * math.pi * 1.4) + (math.pi * 0.8);
      final speed = 250 + _random.nextDouble() * 350;
      _particles.add(
        _Particle(
          color: _palette[_random.nextInt(_palette.length)],
          vx: math.cos(angle) * speed,
          vy: math.sin(angle) * speed,
          size: 6.0 + _random.nextDouble() * 6.0,
          rotationSpeed: (_random.nextDouble() - 0.5) * 8.0,
          isCircle: _random.nextBool(),
        ),
      );
    }

    _controller.forward().then((_) => widget.onFinished());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final progress = _controller.value;
          return CustomPaint(
            size: MediaQuery.of(context).size,
            painter: _ConfettiPainter(
              particles: _particles,
              progress: progress,
            ),
          );
        },
      ),
    );
  }
}

class _Particle {
  final Color color;
  final double vx;
  final double vy;
  final double size;
  final double rotationSpeed;
  final bool isCircle;

  _Particle({
    required this.color,
    required this.vx,
    required this.vy,
    required this.size,
    required this.rotationSpeed,
    required this.isCircle,
  });
}

class _ConfettiPainter extends CustomPainter {
  final List<_Particle> particles;
  final double progress;

  _ConfettiPainter({required this.particles, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final originX = size.width / 2;
    final originY = size.height * 0.65;
    const gravity = 420.0;

    for (final p in particles) {
      final t = progress * 1.5;
      final x = originX + (p.vx * t);
      final y = originY + (p.vy * t) + (0.5 * gravity * t * t);
      final opacity = (1.0 - progress).clamp(0.0, 1.0);

      final paint = Paint()
        ..color = p.color.withValues(alpha: opacity)
        ..style = PaintingStyle.fill;

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(progress * p.rotationSpeed);

      if (p.isCircle) {
        canvas.drawCircle(Offset.zero, p.size / 2, paint);
      } else {
        canvas.drawRect(
          Rect.fromCenter(center: Offset.zero, width: p.size, height: p.size * 0.6),
          paint,
        );
      }
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter oldDelegate) => true;
}
