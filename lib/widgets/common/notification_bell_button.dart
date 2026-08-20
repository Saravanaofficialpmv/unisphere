import 'package:flutter/material.dart';
import 'package:unisphere/core/theme/app_animations.dart';

/// Notification Bell action button using the user-provided bell-ring.png asset.
class NotificationBellButton extends StatelessWidget {
  final VoidCallback onTap;
  final int unreadCount;
  final double size;

  const NotificationBellButton({
    super.key,
    required this.onTap,
    this.unreadCount = 0,
    this.size = 24,
  });

  @override
  Widget build(BuildContext context) {
    return AppPressable(
      onTap: onTap,
      scaleFactor: 0.92,
      child: SizedBox(
        width: size + 18,
        height: size + 18,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Image.asset(
                'assets/bell_ring_2.png',
                width: size,
                height: size,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Image.asset(
                    'assets/bell_ring.png',
                    width: size,
                    height: size,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(
                        Icons.notifications_none_rounded,
                        size: size,
                        color: const Color(0xFF2D3142),
                      );
                    },
                  );
                },
              ),
            ),
            if (unreadCount > 0)
              Positioned(
                right: 6,
                top: 6,
                child: Container(
                  width: 9,
                  height: 9,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEF4444),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 1.5),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
