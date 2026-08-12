import 'package:flutter/material.dart';

/// Custom Open Menu Button widget matching the open-menu.png design tab.
class OpenMenuButton extends StatelessWidget {
  final VoidCallback onTap;
  final double height;

  const OpenMenuButton({
    super.key,
    required this.onTap,
    this.height = 42,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1D4ED8).withValues(alpha: 0.35),
              blurRadius: 12,
              offset: const Offset(3, 3),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.horizontal(right: Radius.circular(22)),
          child: Image.asset(
            'assets/open_menu.png',
            height: height,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              // Vector fallback matching exact design
              return Container(
                height: height,
                padding: const EdgeInsets.fromLTRB(10, 0, 14, 0),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF1D4ED8), Color(0xFF2563EB)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.horizontal(right: Radius.circular(22)),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.chevron_right_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                    SizedBox(width: 4),
                    Icon(
                      Icons.menu_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
