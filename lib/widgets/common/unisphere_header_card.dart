import 'package:flutter/material.dart';

/// Reusable Unisphere Section Header Card Widget matching the exact royal blue
/// gradient, rounded corners, back button, typography, and optional tab/action controls.
/// Responsive and overflow-safe across all screen widths.
class UnisphereHeaderCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final VoidCallback? onBack;
  final VoidCallback? onInfoPressed;
  final String? infoTooltip;
  final List<Widget>? rightActions;
  final Widget? bottomWidget;
  final EdgeInsetsGeometry margin;
  final EdgeInsetsGeometry padding;
  final List<Color>? gradientColors;

  const UnisphereHeaderCard({
    super.key,
    required this.title,
    this.subtitle,
    this.onBack,
    this.onInfoPressed,
    this.infoTooltip,
    this.rightActions,
    this.bottomWidget,
    this.margin = const EdgeInsets.fromLTRB(12, 4, 12, 6),
    this.padding = const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    this.gradientColors,
  });

  @override
  Widget build(BuildContext context) {
    final colors = gradientColors ?? const [Color(0xFF1E40AF), Color(0xFF2563EB)];

    final bool showBackButton = onBack != null || Navigator.canPop(context);

    return Container(
      margin: margin,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: colors.last.withValues(alpha: 0.25),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: padding,
            child: Row(
              children: [
                if (showBackButton)
                  IconButton(
                    constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                    padding: EdgeInsets.zero,
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                    onPressed: () {
                      if (onBack != null) {
                        onBack!();
                      } else if (context.mounted && Navigator.canPop(context)) {
                        Navigator.pop(context);
                      } else if (context.mounted && Navigator.of(context, rootNavigator: true).canPop()) {
                        Navigator.of(context, rootNavigator: true).pop();
                      }
                    },
                  )
                else
                  const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        title,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 16.5,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 0.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (subtitle != null && subtitle!.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          subtitle!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFFBFDBFE),
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (rightActions != null) ...rightActions!,
                    if (onInfoPressed != null)
                      Tooltip(
                        message: infoTooltip ?? 'Section Information',
                        child: IconButton(
                          constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                          padding: EdgeInsets.zero,
                          icon: const Icon(
                            Icons.info_outline_rounded,
                            color: Colors.white70,
                            size: 22,
                          ),
                          onPressed: onInfoPressed,
                        ),
                      )
                    else if (rightActions == null && showBackButton)
                      const SizedBox(width: 36),
                  ],
                ),
              ],
            ),
          ),
          if (bottomWidget != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
              child: bottomWidget!,
            ),
        ],
      ),
    );
  }
}
