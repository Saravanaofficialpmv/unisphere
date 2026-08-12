import 'package:flutter/material.dart';

/// Custom Open Menu Button widget using the user provided icon asset.
class OpenMenuButton extends StatelessWidget {
  final VoidCallback onTap;
  final double height;

  const OpenMenuButton({
    super.key,
    required this.onTap,
    this.height = 48,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: height,
        color: Colors.transparent,
        child: Image.asset(
          'assets/menu_icon_tab.png',
          height: height,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return Image.asset(
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
                      padding: const EdgeInsets.fromLTRB(10, 0, 16, 0),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2563EB),
                        borderRadius: BorderRadius.horizontal(right: Radius.circular(height / 2)),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.chevron_right_rounded,
                            color: Colors.white,
                            size: 22,
                          ),
                          SizedBox(width: 4),
                          Icon(
                            Icons.menu_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}
