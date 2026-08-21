import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unisphere/services/auth_service.dart';
import 'package:unisphere/widgets/common/custom_loader.dart';

/// Displays the custom modal bottom sheet for sign-out confirmation matching the exact reference UI.
void showSignOutConfirmationSheet(BuildContext context, WidgetRef ref) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    barrierColor: Colors.black.withValues(alpha: 0.5),
    builder: (context) => SignOutConfirmationSheet(ref: ref),
  );
}

class SignOutConfirmationSheet extends StatelessWidget {
  final WidgetRef ref;

  const SignOutConfirmationSheet({super.key, required this.ref});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.15),
            blurRadius: 24,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        child: Stack(
          children: [
            // Decorative background waves at the bottom (compact & subtle)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: 150,
              child: CustomPaint(
                painter: _LogoutWavePainter(isDark: isDark),
              ),
            ),

            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Top Drag Indicator Pill
                    Center(
                      child: Container(
                        width: 38,
                        height: 4,
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Top Illustration: Tibsy Character + Floating Logout Badge + Sparkles (Compact)
                    _buildCharacterIllustration(isDark),
                    const SizedBox(height: 8),

                    // Title
                    Text(
                      'Sign Out?',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                        letterSpacing: -0.4,
                      ),
                    ),
                    const SizedBox(height: 4),

                    // Subtitle
                    Text(
                      'Are you sure you want to log out of your account?',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Security Reassurance Card (Compact & Sleek)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: const Color(0xFF2563EB).withValues(alpha: isDark ? 0.2 : 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.verified_user_rounded,
                              color: Color(0xFF2563EB),
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Your account will be secure',
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w700,
                                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                                  ),
                                ),
                                const SizedBox(height: 1),
                                Text(
                                  'You can sign in again anytime to access your account.',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w400,
                                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Action Buttons (Sign Out - Primary Blue Pill)
                    SizedBox(
                      width: double.infinity,
                      height: 46,
                      child: ElevatedButton(
                        onPressed: () async {
                          final navigator = Navigator.of(context);
                          navigator.pop();
                          AppLoadingOverlay.show(
                            context,
                            message: 'Signing out safely...',
                            subtitle: 'Clearing session cache',
                          );
                          try {
                            await ref.read(authServiceProvider).signOut();
                          } finally {
                            AppLoadingOverlay.hide();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2563EB),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.exit_to_app_rounded, size: 18, color: Colors.white),
                            SizedBox(width: 8),
                            Text(
                              'Sign Out',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Stay Button (Light Pill)
                    SizedBox(
                      width: double.infinity,
                      height: 46,
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                          foregroundColor: isDark ? Colors.white : const Color(0xFF0F172A),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: Text(
                          'Stay',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: isDark ? Colors.white : const Color(0xFF0F172A),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Top Right Close '✕' Button
            Positioned(
              top: 10,
              right: 12,
              child: Material(
                color: Colors.transparent,
                child: IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  splashRadius: 18,
                  icon: Icon(
                    Icons.close_rounded,
                    size: 20,
                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCharacterIllustration(bool isDark) {
    final starColor = isDark
        ? const Color(0xFF60A5FA).withValues(alpha: 0.75)
        : const Color(0xFF2563EB).withValues(alpha: 0.65);

    return SizedBox(
      height: 104,
      width: 140,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          // Centered Tibsy Animated Character (96x96)
          _buildTibsyGif(),

          // Exact mathematical sparkles overlay touching the head
          Positioned.fill(
            child: CustomPaint(
              painter: _HeadSparklesOverlayPainter(color: starColor),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTibsyGif() {
    const String assetPath = 'assets/tibsy-cercle-excite-2563eb.gif';
    const String fallbackAsset = 'assets/tibsy-dp.gif';
    const String localFilePath = 'tibsy-cercle-excite-2563eb.gif';

    return Image.asset(
      assetPath,
      width: 96,
      height: 96,
      fit: BoxFit.contain,
      errorBuilder: (_, __, ___) {
        final localFile = File(localFilePath);
        if (localFile.existsSync()) {
          return Image.file(
            localFile,
            width: 96,
            height: 96,
            fit: BoxFit.contain,
          );
        }
        return Image.asset(
          fallbackAsset,
          width: 96,
          height: 96,
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => Container(
            width: 90,
            height: 90,
            decoration: const BoxDecoration(
              color: Color(0xFF2563EB),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.sentiment_very_satisfied_rounded, size: 48, color: Colors.white),
          ),
        );
      },
    );
  }
}

/// Custom Painter for Delicate Floating Sparkle Stars & Soft Twinkle Dots
class _HeadSparklesOverlayPainter extends CustomPainter {
  final Color color;

  _HeadSparklesOverlayPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    final fillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // --- Main 4-Point Sparkle Star (Top-Right) ---
    _drawFourPointStar(canvas, Offset(cx + 44, cy - 34), 13, fillPaint);

    // --- Soft Twinkle Dot (Upper-Right) ---
    canvas.drawCircle(
      Offset(cx + 52, cy - 14),
      2.4,
      fillPaint..color = color.withValues(alpha: 0.65),
    );

    // --- Mini Sparkle Star (Top-Left) ---
    _drawFourPointStar(
      canvas,
      Offset(cx - 42, cy - 28),
      9,
      fillPaint..color = color.withValues(alpha: 0.5),
    );

    // --- Mini Twinkle Dot (Bottom-Left) ---
    canvas.drawCircle(
      Offset(cx - 46, cy + 16),
      1.8,
      fillPaint..color = color.withValues(alpha: 0.4),
    );
  }

  void _drawFourPointStar(Canvas canvas, Offset center, double size, Paint paint) {
    final h = size / 2;
    final path = Path()
      ..moveTo(center.dx, center.dy - h)
      ..quadraticBezierTo(center.dx, center.dy, center.dx + h, center.dy)
      ..quadraticBezierTo(center.dx, center.dy, center.dx, center.dy + h)
      ..quadraticBezierTo(center.dx, center.dy, center.dx - h, center.dy)
      ..quadraticBezierTo(center.dx, center.dy, center.dx, center.dy - h)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Custom Painter for Decorative Organic Bottom Wave Curves with Sparkles
class _LogoutWavePainter extends CustomPainter {
  final bool isDark;

  _LogoutWavePainter({required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // First background wave (lighter)
    final backWavePaint = Paint()
      ..color = const Color(0xFF2563EB).withValues(alpha: isDark ? 0.10 : 0.12)
      ..style = PaintingStyle.fill;

    final backWavePath = Path()
      ..moveTo(0, h * 0.45)
      ..quadraticBezierTo(w * 0.28, h * 0.30, w * 0.62, h * 0.55)
      ..quadraticBezierTo(w * 0.85, h * 0.70, w, h * 0.35)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(backWavePath, backWavePaint);

    // Second foreground wave (richer)
    final frontWavePaint = Paint()
      ..color = const Color(0xFF2563EB).withValues(alpha: isDark ? 0.18 : 0.22)
      ..style = PaintingStyle.fill;

    final frontWavePath = Path()
      ..moveTo(0, h * 0.65)
      ..quadraticBezierTo(w * 0.25, h * 0.50, w * 0.55, h * 0.72)
      ..quadraticBezierTo(w * 0.80, h * 0.88, w, h * 0.68)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(frontWavePath, frontWavePaint);

    // Decorative floating dots and crosses on waves
    final dotPaint = Paint()
      ..color = const Color(0xFF2563EB).withValues(alpha: isDark ? 0.30 : 0.38)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(w * 0.12, h * 0.52), 3.5, dotPaint);
    canvas.drawCircle(Offset(w * 0.88, h * 0.75), 2.8, dotPaint);
    canvas.drawCircle(Offset(w * 0.08, h * 0.80), 2.5, dotPaint);

    final crossPaint = Paint()
      ..color = const Color(0xFF2563EB).withValues(alpha: isDark ? 0.30 : 0.38)
      ..strokeWidth = 1.4
      ..strokeCap = StrokeCap.round;

    final c1 = Offset(w * 0.88, h * 0.48);
    canvas.drawLine(c1 + const Offset(-2.5, -2.5), c1 + const Offset(2.5, 2.5), crossPaint);
    canvas.drawLine(c1 + const Offset(-2.5, 2.5), c1 + const Offset(2.5, -2.5), crossPaint);

    final c2 = Offset(w * 0.10, h * 0.90);
    canvas.drawLine(c2 + const Offset(-2.5, -2.5), c2 + const Offset(2.5, 2.5), crossPaint);
    canvas.drawLine(c2 + const Offset(-2.5, 2.5), c2 + const Offset(2.5, -2.5), crossPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}


