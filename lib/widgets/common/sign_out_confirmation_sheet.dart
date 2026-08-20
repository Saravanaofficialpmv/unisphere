import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unisphere/core/constants/app_colors.dart';
import 'package:unisphere/services/auth_service.dart';
import 'package:unisphere/widgets/common/custom_loader.dart';

/// Displays a full-width custom modal bottom sheet covering the bottom edge for sign-out confirmation.
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
        color: isDark ? const Color(0xFF1E293B) : AppColors.cardBackground,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.15),
            blurRadius: 24,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Top Drag Indicator Pill
                  Center(
                    child: Container(
                      width: 44,
                      height: 5,
                      decoration: BoxDecoration(
                        color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Circular Illustration Badge (Soft Blue Tint)
                  Container(
                    width: 84,
                    height: 84,
                    decoration: BoxDecoration(
                      color: isDark 
                          ? AppColors.primary.withValues(alpha: 0.2) 
                          : const Color(0xFFE0F2FE),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: isDark 
                              ? AppColors.primary.withValues(alpha: 0.3)
                              : const Color(0xFFBAE6FD),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.exit_to_app_rounded,
                          color: AppColors.primary,
                          size: 28,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Title
                  Text(
                    'Sign Out?',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                      color: isDark ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Subtitle
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'Are you sure you want to log out of your account?',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: isDark ? Colors.grey.shade400 : AppColors.textSecondary,
                        fontSize: 14,
                        height: 1.45,
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Action Buttons Row (Sign Out | Stay)
                  Row(
                    children: [
                      // Sign Out Button (Left - Soft Neutral Pill)
                      Expanded(
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
                            backgroundColor: isDark 
                                ? const Color(0xFF334155) 
                                : AppColors.surfaceSecondary,
                            foregroundColor: isDark ? Colors.white : AppColors.textPrimary,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                          ),
                          child: const Text(
                            'Sign Out',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      // Stay Button (Right - Primary Brand Pill)
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                          ),
                          child: const Text(
                            'Stay',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Top Right '✕' Close Button
            Positioned(
              top: 16,
              right: 16,
              child: Material(
                color: Colors.transparent,
                child: IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  splashRadius: 20,
                  icon: Icon(
                    Icons.close_rounded,
                    size: 20,
                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
