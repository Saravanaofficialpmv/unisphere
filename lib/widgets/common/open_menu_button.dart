import 'package:flutter/material.dart';

/// Custom Open Menu Button widget matching the exact blue side-tab with a large, prominent menu icon.
class OpenMenuButton extends StatelessWidget {
  final VoidCallback onTap;
  final double height;

  const OpenMenuButton({
    super.key,
    required this.onTap,
    this.height = 56,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: height,
        padding: const EdgeInsets.fromLTRB(14, 0, 22, 0),
        decoration: const BoxDecoration(
          color: Color(0xFF1D61E7),
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(16),
            bottomRight: Radius.circular(16),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              'assets/menu_icon_tab.png',
              height: height,
              fit: BoxFit.fitHeight,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(
                  Icons.menu_rounded,
                  color: Colors.white,
                  size: 34,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
