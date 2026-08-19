import 'package:flutter/material.dart';

/// Native, rock-solid Flutter Circular Gauge Widget.
/// Eliminates all third-party percent_indicator semantics dirty parent data assertions.
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
              color: progressColor,
              backgroundColor: backgroundColor,
              strokeCap: StrokeCap.round,
            ),
          ),
          center,
        ],
      ),
    );
  }
}

/// Native, rock-solid Flutter Linear Progress Bar Widget.
/// Eliminates all third-party percent_indicator semantics dirty parent data assertions.
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

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: SizedBox(
        height: lineHeight,
        child: LinearProgressIndicator(
          value: clampedPercent,
          color: progressColor,
          backgroundColor: backgroundColor,
        ),
      ),
    );
  }
}
