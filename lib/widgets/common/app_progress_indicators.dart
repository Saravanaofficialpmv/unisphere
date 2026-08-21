import 'package:flutter/material.dart';

/// Native, rock-solid Flutter Circular Gauge Widget.
/// Eliminates all third-party percent_indicator semantics and layout assertions.
class AppCircularGauge extends StatelessWidget {
  final double radius;
  final double lineWidth;
  final double percent;
  final Widget center;
  final Color progressColor;
  final Color backgroundColor;

  const AppCircularGauge({
    super.key,
    required this.radius,
    required this.lineWidth,
    required this.percent,
    required this.center,
    required this.progressColor,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final size = radius * 2;
    final clampedPercent = percent.clamp(0.0, 1.0);

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              value: clampedPercent,
              strokeWidth: lineWidth,
              strokeAlign: CircularProgressIndicator.strokeAlignInside,
              color: progressColor,
              backgroundColor: backgroundColor,
              strokeCap: StrokeCap.round,
            ),
          ),
          Center(child: center),
        ],
      ),
    );
  }
}

/// Native, rock-solid Flutter Linear Progress Bar Widget.
/// Uses LayoutBuilder + Container layout bounds to guarantee zero RenderBox layout assertions.
class AppLinearProgressBar extends StatelessWidget {
  final double lineHeight;
  final double percent;
  final Color progressColor;
  final Color backgroundColor;
  final double borderRadius;

  const AppLinearProgressBar({
    super.key,
    required this.lineHeight,
    required this.percent,
    required this.progressColor,
    required this.backgroundColor,
    this.borderRadius = 4.0,
  });

  @override
  Widget build(BuildContext context) {
    final clampedPercent = percent.clamp(0.0, 1.0);

    return LayoutBuilder(
      builder: (context, constraints) {
        final parentWidth = constraints.maxWidth.isFinite ? constraints.maxWidth : 100.0;
        return Container(
          width: parentWidth,
          height: lineHeight,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          child: Align(
            alignment: Alignment.centerLeft,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: parentWidth * clampedPercent,
              height: lineHeight,
              decoration: BoxDecoration(
                color: progressColor,
                borderRadius: BorderRadius.circular(borderRadius),
              ),
            ),
          ),
        );
      },
    );
  }
}
