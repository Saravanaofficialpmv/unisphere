import 'package:flutter/material.dart';

/// Custom Open Menu Button widget matching the sidebar icon & open-menu design tab.
class OpenMenuButton extends StatelessWidget {
  final VoidCallback onTap;
  final double height;

  const OpenMenuButton({
    super.key,
    required this.onTap,
    this.height = 58,
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
              color: const Color(0xFF1D4ED8).withValues(alpha: 0.45),
              blurRadius: 16,
              offset: const Offset(4, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.horizontal(right: Radius.circular(height / 2)),
          child: Image.asset(
            'assets/sidebar_icon.png',
            height: height,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return Image.asset(
                'assets/open_menu.png',
                height: height,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: height,
                    padding: const EdgeInsets.fromLTRB(12, 0, 18, 0),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF1D4ED8), Color(0xFF2563EB)],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.horizontal(right: Radius.circular(height / 2)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.chevron_right_rounded,
                          color: Colors.white,
                          size: 26,
                        ),
                        SizedBox(width: 4),
                        Icon(
                          Icons.menu_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
