import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:unisphere/core/constants/app_colors.dart';
import 'package:unisphere/core/theme/app_animations.dart';

/// Custom Liquid Pull-to-Refresh with elastic snap-back and the Unisphere liquid GIF spinner.
class AppLiquidPullToRefresh extends StatefulWidget {
  final Widget child;
  final Future<void> Function() onRefresh;
  final String gifAsset;
  final double refreshTriggerPullDistance;
  final double refreshIndicatorExtent;
  final int animationCycleMs;

  const AppLiquidPullToRefresh({
    super.key,
    required this.child,
    required this.onRefresh,
    this.gifAsset = 'assets/tibsy-dp.gif',
    this.refreshTriggerPullDistance = 75.0,
    this.refreshIndicatorExtent = 64.0,
    this.animationCycleMs = 3100,
  });

  @override
  State<AppLiquidPullToRefresh> createState() => _AppLiquidPullToRefreshState();
}

class _AppLiquidPullToRefreshState extends State<AppLiquidPullToRefresh>
    with SingleTickerProviderStateMixin {
  double _pullDistance = 0.0;
  bool _isRefreshing = false;
  bool _hasHapticed = false;
  int _gifKeyId = 0;

  late AnimationController _springController;
  late Animation<double> _springAnimation;

  @override
  void initState() {
    super.initState();
    _gifKeyId = DateTime.now().millisecondsSinceEpoch;
    _springController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _springAnimation = Tween<double>(begin: 0.0, end: 0.0).animate(
      CurvedAnimation(parent: _springController, curve: Curves.easeOutBack),
    );
  }

  @override
  void dispose() {
    _springController.dispose();
    super.dispose();
  }

  void _onPullStart() {
    if (_pullDistance == 0.0) {
      // Clear image cache for the gif asset so it starts from frame 0
      AssetImage(widget.gifAsset).evict();
      _gifKeyId = DateTime.now().millisecondsSinceEpoch;
    }
  }

  bool _handleScrollNotification(ScrollNotification notification) {
    if (_isRefreshing) return false;

    if (notification is ScrollUpdateNotification) {
      // When at the top and pulling down
      if (notification.metrics.pixels <= 0 && (notification.scrollDelta ?? 0) < 0) {
        _onPullStart();
        final delta = (notification.scrollDelta ?? 0).abs();
        setState(() {
          _pullDistance = (_pullDistance + (delta * 0.45)).clamp(0.0, 110.0);
        });

        if (_pullDistance >= widget.refreshTriggerPullDistance && !_hasHapticed) {
          _hasHapticed = true;
          HapticFeedback.mediumImpact();
        }
      }
    } else if (notification is OverscrollNotification) {
      if (notification.overscroll < 0) {
        _onPullStart();
        final delta = notification.overscroll.abs();
        setState(() {
          _pullDistance = (_pullDistance + (delta * 0.45)).clamp(0.0, 110.0);
        });

        if (_pullDistance >= widget.refreshTriggerPullDistance && !_hasHapticed) {
          _hasHapticed = true;
          HapticFeedback.mediumImpact();
        }
      }
    } else if (notification is ScrollEndNotification) {
      _hasHapticed = false;
      if (_pullDistance >= widget.refreshTriggerPullDistance) {
        _triggerRefresh();
      } else if (_pullDistance > 0) {
        _snapBackToZero();
      }
    }
    return false;
  }

  void _triggerRefresh() async {
    // Reset key and evict cache so the GIF plays cleanly from frame 0
    AssetImage(widget.gifAsset).evict();
    final startTime = DateTime.now();
    setState(() {
      _isRefreshing = true;
      _gifKeyId = startTime.millisecondsSinceEpoch;
    });

    _springAnimation = Tween<double>(
      begin: _pullDistance,
      end: widget.refreshIndicatorExtent,
    ).animate(CurvedAnimation(parent: _springController, curve: Curves.easeOutBack));

    _springController.forward(from: 0.0);

    try {
      await widget.onRefresh();
    } catch (_) {
      // Ignore errors in refresh callback
    } finally {
      // Ensure the GIF completes full animation cycles (exact 3100ms per full loop of tibsy-dp.gif)
      final int cycleMs = widget.animationCycleMs;
      final int elapsed = DateTime.now().difference(startTime).inMilliseconds;
      final int remainder = elapsed % cycleMs;
      final int waitMs = remainder == 0 ? 0 : (cycleMs - remainder);

      if (waitMs > 0) {
        await Future.delayed(Duration(milliseconds: waitMs));
      }

      if (mounted) {
        HapticFeedback.lightImpact();
        setState(() {
          _isRefreshing = false;
        });
        _snapBackToZero();
      }
    }
  }

  void _snapBackToZero() {
    _springAnimation = Tween<double>(
      begin: _pullDistance,
      end: 0.0,
    ).animate(CurvedAnimation(parent: _springController, curve: Curves.easeOutCubic));

    _springController.forward(from: 0.0).then((_) {
      if (mounted) {
        setState(() {
          _pullDistance = 0.0;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (AppAnimations.isReducedMotion(context)) {
      return RefreshIndicator(
        onRefresh: widget.onRefresh,
        color: AppColors.primary,
        child: widget.child,
      );
    }

    return AnimatedBuilder(
      animation: _springController,
      builder: (context, child) {
        final double currentExtent =
            _springController.isAnimating ? _springAnimation.value : _pullDistance;
        final double progress = (currentExtent / widget.refreshTriggerPullDistance).clamp(0.0, 1.0);
        final double bubbleScale = (0.5 + (progress * 0.55)).clamp(0.0, 1.15);

        return Stack(
          children: [
            // Main content shifted down slightly with liquid damping
            Transform.translate(
              offset: Offset(0, currentExtent * 0.85),
              child: NotificationListener<ScrollNotification>(
                onNotification: _handleScrollNotification,
                child: widget.child,
              ),
            ),

            // Top Liquid Bubble Indicator
            if (currentExtent > 2)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    height: currentExtent,
                    alignment: Alignment.center,
                    child: Transform.scale(
                      scale: bubbleScale,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.94),
                          borderRadius: BorderRadius.circular(32),
                          border: Border.all(
                            color: AppColors.primary.withValues(alpha: 0.25),
                            width: 1.2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.16),
                              blurRadius: 16,
                              offset: const Offset(0, 4),
                            ),
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.06),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Liquid Spinner GIF Asset
                            ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Image.asset(
                                widget.gifAsset,
                                key: ValueKey('liquid_gif_$_gifKeyId'),
                                width: 32,
                                height: 32,
                                fit: BoxFit.cover,
                                gaplessPlayback: true,
                                errorBuilder: (ctx, _, __) => const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                                  ),
                                ),
                              ),
                            ),
                            if (_isRefreshing || progress >= 0.85) ...[
                              const SizedBox(width: 10),
                              Text(
                                _isRefreshing ? 'Refreshing...' : 'Release to Refresh',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primary,
                                  letterSpacing: -0.2,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
