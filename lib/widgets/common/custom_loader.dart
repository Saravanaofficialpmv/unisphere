import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:unisphere/core/constants/app_colors.dart';

/// Rebuild of the modern SVG/CSS loader in pure Flutter using CustomPainter & AnimationController.
/// Features three geometric shapes (Circle, Triangle, Square) side-by-side with animated stroke dashes
/// and tracing accent dots, matching the exact cubic-bezier timing curve.
class Loader extends StatefulWidget {
  final double size;
  final Color? pathColor;
  final Color? dotColor;
  final Duration duration;
  final String? label;
  final TextStyle? labelStyle;

  const Loader({
    super.key,
    this.size = 44.0,
    this.pathColor,
    this.dotColor,
    this.duration = const Duration(seconds: 3),
    this.label,
    this.labelStyle,
  });

  @override
  State<Loader> createState() => _LoaderState();
}

/// Alias for backwards compatibility
typedef CustomLoader = Loader;

class _LoaderState extends State<Loader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  static const Curve _cubicCurve = Cubic(0.785, 0.135, 0.15, 0.86);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectivePathColor = widget.pathColor ?? const Color(0xFF2F3545);
    final effectiveDotColor = widget.dotColor ??
        (theme.primaryColor != Colors.transparent && theme.primaryColor != Colors.black
            ? theme.primaryColor
            : const Color(0xFF5628EE));

    final double height = widget.size;
    final double circleWidth = widget.size;
    final double triangleWidth = widget.size * (48.0 / 44.0);
    final double rectWidth = widget.size;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final double t = _controller.value;

        return Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // 1. Circle Loader
                SizedBox(
                  width: circleWidth,
                  height: height,
                  child: CustomPaint(
                    painter: _CircleShapePainter(
                      progress: t,
                      cubicCurve: _cubicCurve,
                      pathColor: effectivePathColor,
                      dotColor: effectiveDotColor,
                    ),
                  ),
                ),
                SizedBox(width: widget.size * 0.35),

                // 2. Triangle Loader
                SizedBox(
                  width: triangleWidth,
                  height: height,
                  child: CustomPaint(
                    painter: _TriangleShapePainter(
                      progress: t,
                      cubicCurve: _cubicCurve,
                      pathColor: effectivePathColor,
                      dotColor: effectiveDotColor,
                    ),
                  ),
                ),
                SizedBox(width: widget.size * 0.35),

                // 3. Rectangle Loader
                SizedBox(
                  width: rectWidth,
                  height: height,
                  child: CustomPaint(
                    painter: _SquareShapePainter(
                      progress: t,
                      cubicCurve: _cubicCurve,
                      pathColor: effectivePathColor,
                      dotColor: effectiveDotColor,
                    ),
                  ),
                ),
              ],
            ),
            if (widget.label != null && widget.label!.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                widget.label!,
                style: widget.labelStyle ??
                    TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: theme.brightness == Brightness.dark
                          ? Colors.grey[300]
                          : AppColors.textSecondary,
                      letterSpacing: 0.3,
                    ),
              ),
            ],
          ],
        );
      },
    );
  }
}

/// Helper extension to draw dashed paths cleanly and safely
extension _PathDashExtension on Path {
  Path createDashedPath(double dashWidth, double dashGap, double dashOffset) {
    final Path dest = Path();
    final double period = dashWidth + dashGap;
    if (period <= 0) return this;

    for (final metric in computeMetrics()) {
      final double len = metric.length;
      if (len <= 0) continue;

      double offset = dashOffset % period;
      if (offset < 0) offset += period;

      double d = 0.0;
      while (d < len) {
        final double phase = (d + offset) % period;
        if (phase < dashWidth) {
          final double remainingDash = dashWidth - phase;
          final double drawEnd = math.min(d + remainingDash, len);
          if (drawEnd > d) {
            dest.addPath(metric.extractPath(d, drawEnd), Offset.zero);
          }
          d = drawEnd;
        } else {
          final double remainingGap = period - phase;
          d = math.min(d + remainingGap, len);
        }
      }
    }
    return dest;
  }
}

/// Circle Shape Painter
class _CircleShapePainter extends CustomPainter {
  final double progress;
  final Curve cubicCurve;
  final Color pathColor;
  final Color dotColor;

  _CircleShapePainter({
    required this.progress,
    required this.cubicCurve,
    required this.pathColor,
    required this.dotColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double scale = size.height / 44.0;
    final strokeWidth = 5.5 * scale;

    final double cx = size.width / 2;
    final double cy = size.height / 2;
    final double r = 32.0 * (size.height / 80.0);

    final Paint pathPaint = Paint()
      ..color = pathColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final Path circlePath = Path()
      ..addOval(Rect.fromCircle(center: Offset(cx, cy), radius: r));

    final double perimeter = 2 * math.pi * r;
    final double scaleRatio = perimeter / 400.0;
    final double dashWidth = 150 * scaleRatio;
    final double dashGap = 50 * scaleRatio;

    // Piecewise cubic-bezier dashoffset interpolation matching CSS keyframes @keyframes pathCircle
    // 0%: 75, 25%: 125, 50%: 175, 75%: 225, 100%: 275
    double rawOffset;
    if (progress < 0.25) {
      final t = cubicCurve.transform(progress / 0.25);
      rawOffset = 75.0 + 50.0 * t;
    } else if (progress < 0.50) {
      final t = cubicCurve.transform((progress - 0.25) / 0.25);
      rawOffset = 125.0 + 50.0 * t;
    } else if (progress < 0.75) {
      final t = cubicCurve.transform((progress - 0.50) / 0.25);
      rawOffset = 175.0 + 50.0 * t;
    } else {
      final t = cubicCurve.transform((progress - 0.75) / 0.25);
      rawOffset = 225.0 + 50.0 * t;
    }

    final Path dashedPath = circlePath.createDashedPath(dashWidth, dashGap, rawOffset * scaleRatio);
    canvas.drawPath(dashedPath, pathPaint);

    // Dot animation dotRect
    final Offset baseDotPos = Offset(19 * scale, 37 * scale);
    Offset dotTranslation;

    if (progress < 0.25) {
      final t = cubicCurve.transform(progress / 0.25);
      dotTranslation = Offset(-18 + 18 * t, -18 + 18 * t);
    } else if (progress < 0.50) {
      final t = cubicCurve.transform((progress - 0.25) / 0.25);
      dotTranslation = Offset(18 * t, -18 * t);
    } else if (progress < 0.75) {
      final t = cubicCurve.transform((progress - 0.50) / 0.25);
      dotTranslation = Offset(18 - 18 * t, -18 - 18 * t);
    } else {
      final t = cubicCurve.transform((progress - 0.75) / 0.25);
      dotTranslation = Offset(-18 * t, -36 + 18 * t);
    }

    final Offset finalDotCenter = baseDotPos + (dotTranslation * scale);
    final Paint dotPaint = Paint()
      ..color = dotColor
      ..style = PaintingStyle.fill;

    canvas.drawCircle(finalDotCenter, 3.0 * scale, dotPaint);
  }

  @override
  bool shouldRepaint(covariant _CircleShapePainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.pathColor != pathColor ||
      oldDelegate.dotColor != dotColor;
}

/// Triangle Shape Painter
class _TriangleShapePainter extends CustomPainter {
  final double progress;
  final Curve cubicCurve;
  final Color pathColor;
  final Color dotColor;

  _TriangleShapePainter({
    required this.progress,
    required this.cubicCurve,
    required this.pathColor,
    required this.dotColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double scale = size.height / 44.0;
    final strokeWidth = 5.5 * scale;

    final double sx = size.width / 86.0;
    final double sy = size.height / 80.0;

    final Offset p1 = Offset(43 * sx, 8 * sy);
    final Offset p2 = Offset(79 * sx, 72 * sy);
    final Offset p3 = Offset(7 * sx, 72 * sy);

    final Paint pathPaint = Paint()
      ..color = pathColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final Path trianglePath = Path()
      ..moveTo(p1.dx, p1.dy)
      ..lineTo(p2.dx, p2.dy)
      ..lineTo(p3.dx, p3.dy)
      ..close();

    final double side1 = (p2 - p1).distance;
    final double side2 = (p3 - p2).distance;
    final double side3 = (p1 - p3).distance;
    final double totalLen = side1 + side2 + side3;
    final double scaleRatio = totalLen / 442.0;

    final double dashWidth = 145 * scaleRatio;
    final double dashGap = 76 * scaleRatio;

    // Piecewise cubic-bezier interpolation matching CSS @keyframes pathTriangle
    // 33%: 74, 66%: 147, 100%: 221
    double rawOffset;
    if (progress < 0.333) {
      final t = cubicCurve.transform(progress / 0.333);
      rawOffset = 74.0 * t;
    } else if (progress < 0.666) {
      final t = cubicCurve.transform((progress - 0.333) / 0.333);
      rawOffset = 74.0 + 73.0 * t;
    } else {
      final t = cubicCurve.transform((progress - 0.666) / 0.334);
      rawOffset = 147.0 + 74.0 * t;
    }

    final Path dashedPath = trianglePath.createDashedPath(dashWidth, dashGap, rawOffset * scaleRatio);
    canvas.drawPath(dashedPath, pathPaint);

    // Dot animation dotTriangle
    // 0%: (-10, -18), 33%: (0, 0), 66%: (10, -18), 100%: (-10, -18)
    final Offset baseDotPos = Offset(21 * scale, 37 * scale);
    Offset dotTranslation;

    if (progress < 0.333) {
      final t = cubicCurve.transform(progress / 0.333);
      dotTranslation = Offset(-10 + 10 * t, -18 + 18 * t);
    } else if (progress < 0.666) {
      final t = cubicCurve.transform((progress - 0.333) / 0.333);
      dotTranslation = Offset(10 * t, -18 * t);
    } else {
      final t = cubicCurve.transform((progress - 0.666) / 0.334);
      dotTranslation = Offset(10 - 20 * t, -18);
    }

    final Offset finalDotCenter = baseDotPos + (dotTranslation * scale);
    final Paint dotPaint = Paint()
      ..color = dotColor
      ..style = PaintingStyle.fill;

    canvas.drawCircle(finalDotCenter, 3.0 * scale, dotPaint);
  }

  @override
  bool shouldRepaint(covariant _TriangleShapePainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.pathColor != pathColor ||
      oldDelegate.dotColor != dotColor;
}

/// Square / Rect Shape Painter
class _SquareShapePainter extends CustomPainter {
  final double progress;
  final Curve cubicCurve;
  final Color pathColor;
  final Color dotColor;

  _SquareShapePainter({
    required this.progress,
    required this.cubicCurve,
    required this.pathColor,
    required this.dotColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double scale = size.height / 44.0;
    final strokeWidth = 5.5 * scale;

    final double s = size.height / 80.0;
    final Rect rect = Rect.fromLTWH(8 * s, 8 * s, 64 * s, 64 * s);

    final Paint pathPaint = Paint()
      ..color = pathColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final Path rectPath = Path()..addRect(rect);

    final double totalLen = 256.0 * s;
    final double scaleRatio = totalLen / 512.0;
    final double dashWidth = 192 * scaleRatio;
    final double dashGap = 64 * scaleRatio;

    // Piecewise cubic-bezier interpolation matching CSS @keyframes pathRect
    // 25%: 64, 50%: 128, 75%: 192, 100%: 256
    double rawOffset;
    if (progress < 0.25) {
      final t = cubicCurve.transform(progress / 0.25);
      rawOffset = 64.0 * t;
    } else if (progress < 0.50) {
      final t = cubicCurve.transform((progress - 0.25) / 0.25);
      rawOffset = 64.0 + 64.0 * t;
    } else if (progress < 0.75) {
      final t = cubicCurve.transform((progress - 0.50) / 0.25);
      rawOffset = 128.0 + 64.0 * t;
    } else {
      final t = cubicCurve.transform((progress - 0.75) / 0.25);
      rawOffset = 192.0 + 64.0 * t;
    }

    final Path dashedPath = rectPath.createDashedPath(dashWidth, dashGap, rawOffset * scaleRatio);
    canvas.drawPath(dashedPath, pathPaint);

    // Dot animation dotRect
    final Offset baseDotPos = Offset(19 * scale, 37 * scale);
    Offset dotTranslation;

    if (progress < 0.25) {
      final t = cubicCurve.transform(progress / 0.25);
      dotTranslation = Offset(-18 + 18 * t, -18 + 18 * t);
    } else if (progress < 0.50) {
      final t = cubicCurve.transform((progress - 0.25) / 0.25);
      dotTranslation = Offset(18 * t, -18 * t);
    } else if (progress < 0.75) {
      final t = cubicCurve.transform((progress - 0.50) / 0.25);
      dotTranslation = Offset(18 - 18 * t, -18 - 18 * t);
    } else {
      final t = cubicCurve.transform((progress - 0.75) / 0.25);
      dotTranslation = Offset(-18 * t, -36 + 18 * t);
    }

    final Offset finalDotCenter = baseDotPos + (dotTranslation * scale);
    final Paint dotPaint = Paint()
      ..color = dotColor
      ..style = PaintingStyle.fill;

    canvas.drawCircle(finalDotCenter, 3.0 * scale, dotPaint);
  }

  @override
  bool shouldRepaint(covariant _SquareShapePainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.pathColor != pathColor ||
      oldDelegate.dotColor != dotColor;
}

/// Utility wrapper widget to show the Loader while fetching data
class DataLoaderView<T> extends StatelessWidget {
  final bool isLoading;
  final Widget child;
  final String label;
  final double loaderSize;

  const DataLoaderView({
    super.key,
    required this.isLoading,
    required this.child,
    this.label = 'Fetching data...',
    this.loaderSize = 44.0,
  });

  @override
  Widget build(BuildContext context) {
    if (!isLoading) return child;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Loader(
          size: loaderSize,
          label: label,
        ),
      ),
    );
  }
}
