import 'package:flutter/material.dart';
import 'package:unisphere/core/constants/app_colors.dart';

import 'package:unisphere/core/theme/app_animations.dart';

/// Custom Open Menu Button widget with uniform primary blue color and crisp menu icon.
class OpenMenuButton extends StatelessWidget {
  final VoidCallback onTap;
  final double height;

  const OpenMenuButton({
    super.key,
    required this.onTap,
    this.height = 46,
  });

  @override
  Widget build(BuildContext context) {
    return AppPressable(
      onTap: onTap,
      scaleFactor: 0.94,
      child: Container(
        height: height,
        padding: const EdgeInsets.fromLTRB(10, 0, 16, 0),
        decoration: const BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(16),
            bottomRight: Radius.circular(16),
          ),
        ),
        child: const Center(
          child: Icon(
            Icons.menu_rounded,
            color: Colors.white,
            size: 28,
          ),
        ),
      ),
    );
  }
}
