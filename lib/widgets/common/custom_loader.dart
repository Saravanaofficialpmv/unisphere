import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:unisphere/core/constants/app_colors.dart';

/// App-wide Loader widget that displays the official animated GIF asset (`assets/bloub-default-cycle-4.gif`).
/// Supports customizable dimensions, status labels, card styling, debounce, and full-screen modes.
class Loader extends StatelessWidget {
  /// Width and height of the loader animation.
  final double size;

  /// Optional primary text label to display below the loader.
  final String? label;

  /// Optional secondary subtitle text below the label.
  final String? subtitle;

  /// Custom text style for the status label.
  final TextStyle? labelStyle;

  /// Custom text style for the secondary subtitle.
  final TextStyle? subtitleStyle;

  /// Optional padding around the loader content.
  final EdgeInsetsGeometry? padding;

  /// Optional background color for the loader container.
  final Color? backgroundColor;

  /// Whether to display the loader inside an elevated, rounded card.
  final bool showCard;

  /// Vertical spacing between the loader animation and the label.
  final double spacing;

  /// Optional footer widget to show below the label.
  final Widget? footer;

  /// Backwards-compatibility properties (preserved so existing callers compile without issues)
  final Color? pathColor;
  final Color? dotColor;
  final Duration duration;

  const Loader({
    super.key,
    this.size = 64.0,
    this.label,
    this.subtitle,
    this.labelStyle,
    this.subtitleStyle,
    this.padding,
    this.backgroundColor,
    this.showCard = false,
    this.spacing = 12.0,
    this.footer,
    this.pathColor,
    this.dotColor,
    this.duration = const Duration(seconds: 3),
  });

  /// Factory constructor for a compact inline loader
  const Loader.inline({
    super.key,
    this.size = 32.0,
    this.label,
    this.subtitle,
    this.labelStyle,
    this.subtitleStyle,
    this.padding,
    this.backgroundColor,
    this.showCard = false,
    this.spacing = 8.0,
    this.footer,
    this.pathColor,
    this.dotColor,
    this.duration = const Duration(seconds: 3),
  });

  /// Factory constructor for micro button loaders
  const Loader.button({
    super.key,
    this.size = 20.0,
    this.label,
    this.subtitle,
    this.labelStyle,
    this.subtitleStyle,
    this.padding,
    this.backgroundColor,
    this.showCard = false,
    this.spacing = 6.0,
    this.footer,
    this.pathColor,
    this.dotColor,
    this.duration = const Duration(seconds: 3),
  });

  /// Factory constructor for a page-level loading state
  const Loader.page({
    super.key,
    this.size = 72.0,
    this.label = 'Loading content...',
    this.subtitle,
    this.labelStyle,
    this.subtitleStyle,
    this.padding = const EdgeInsets.all(32.0),
    this.backgroundColor,
    this.showCard = false,
    this.spacing = 14.0,
    this.footer,
    this.pathColor,
    this.dotColor,
    this.duration = const Duration(seconds: 3),
  });

  /// Factory constructor for a full-screen loading view
  static Widget fullscreen({
    Key? key,
    double size = 96.0,
    String? label = 'Loading UNISPHERE...',
    String? subtitle = 'Please wait while we prepare your campus data',
    TextStyle? labelStyle,
    TextStyle? subtitleStyle,
    Color backgroundColor = Colors.white,
    Widget? footer,
  }) {
    return Scaffold(
      key: key,
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 2),
              Loader(
                size: size,
                label: label,
                subtitle: subtitle,
                labelStyle: labelStyle,
                subtitleStyle: subtitleStyle,
                footer: footer,
                spacing: 16,
              ),
              const Spacer(flex: 2),
              Padding(
                padding: const EdgeInsets.only(bottom: 24.0),
                child: Text(
                  'UNISPHERE CAMPUS PORTAL',
                  style: TextStyle(
                    fontSize: 11,
                    letterSpacing: 2.0,
                    fontWeight: FontWeight.w700,
                    color: Colors.grey[400],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Factory constructor for a modal/card loading view
  const Loader.card({
    super.key,
    this.size = 56.0,
    this.label,
    this.subtitle,
    this.labelStyle,
    this.subtitleStyle,
    this.padding = const EdgeInsets.symmetric(horizontal: 24, vertical: 22),
    this.backgroundColor,
    this.showCard = true,
    this.spacing = 14.0,
    this.footer,
    this.pathColor,
    this.dotColor,
    this.duration = const Duration(seconds: 3),
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final Widget loaderImage = Image.asset(
      'assets/bloub-default-cycle-4.gif',
      width: size,
      height: size,
      fit: BoxFit.contain,
      gaplessPlayback: true,
      errorBuilder: (context, error, stackTrace) {
        return SizedBox(
          width: size,
          height: size,
          child: const Center(
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: AppColors.primary,
            ),
          ),
        );
      },
    );

    Widget content = Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        loaderImage,
        if (label != null && label!.isNotEmpty) ...[
          SizedBox(height: spacing),
          Text(
            label!,
            textAlign: TextAlign.center,
            style: labelStyle ??
                TextStyle(
                  fontSize: size <= 36 ? 12 : 13.5,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.grey[300] : AppColors.textSecondary,
                  letterSpacing: 0.2,
                ),
          ),
        ],
        if (subtitle != null && subtitle!.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            subtitle!,
            textAlign: TextAlign.center,
            style: subtitleStyle ??
                TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.normal,
                  color: isDark ? Colors.grey[500] : const Color(0xFF64748B),
                ),
          ),
        ],
        if (footer != null) ...[
          SizedBox(height: spacing * 0.75),
          footer!,
        ],
      ],
    );

    if (showCard) {
      content = Container(
        padding: padding ?? const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        decoration: BoxDecoration(
          color: backgroundColor ?? (isDark ? const Color(0xFF1E293B) : Colors.white),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.08)
                : const Color(0xFFE2E8F0),
          ),
        ),
        child: content,
      );
    } else if (padding != null || backgroundColor != null) {
      content = Container(
        padding: padding,
        color: backgroundColor,
        child: content,
      );
    }

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      builder: (context, opacity, childWidget) {
        return Opacity(
          opacity: opacity,
          child: childWidget,
        );
      },
      child: content,
    );
  }
}

/// Alias for backwards compatibility
typedef CustomLoader = Loader;

/// Universal Imperative Overlay Service for Modal & Blocking Operations
class AppLoadingOverlay {
  static OverlayEntry? _currentEntry;
  static Timer? _timeoutTimer;

  /// Shows a modal loading overlay with timeout protection
  static void show(
    BuildContext context, {
    String? message = 'Processing request...',
    String? subtitle,
    Duration timeout = const Duration(seconds: 20),
  }) {
    hide();

    final overlay = Overlay.of(context, rootOverlay: true);

    _currentEntry = OverlayEntry(
      builder: (context) => Material(
        color: Colors.black.withValues(alpha: 0.45),
        child: Center(
          child: Loader.card(
            size: 64,
            label: message,
            subtitle: subtitle,
          ),
        ),
      ),
    );

    overlay.insert(_currentEntry!);

    // Safety timeout: automatically dismiss overlay after timeout duration
    _timeoutTimer = Timer(timeout, () {
      hide();
    });
  }

  /// Hides the active loading overlay safely
  static void hide([BuildContext? context]) {
    _timeoutTimer?.cancel();
    _timeoutTimer = null;
    try {
      if (_currentEntry != null) {
        _currentEntry?.remove();
        _currentEntry = null;
      }
    } catch (_) {}
  }

  /// Executes an async task with automatic loading overlay and safe try/catch/finally dismissal
  static Future<T> runWithLoading<T>(
    BuildContext context,
    Future<T> Function() task, {
    String? message = 'Processing...',
    String? subtitle,
    Duration timeout = const Duration(seconds: 20),
  }) async {
    show(context, message: message, subtitle: subtitle, timeout: timeout);
    try {
      return await task().timeout(timeout);
    } finally {
      hide();
    }
  }
}

/// Utility wrapper widget to show the Loader while fetching data with anti-flash debounce & timeout safety
class DataLoaderView<T> extends StatefulWidget {
  final bool isLoading;
  final Widget child;
  final String label;
  final String? subtitle;
  final double loaderSize;
  final String? errorMessage;
  final VoidCallback? onRetry;
  final bool isEmpty;
  final Widget? emptyWidget;
  final Duration debounceDelay;
  final Duration timeoutDuration;

  const DataLoaderView({
    super.key,
    required this.isLoading,
    required this.child,
    this.label = 'Fetching data...',
    this.subtitle,
    this.loaderSize = 56.0,
    this.errorMessage,
    this.onRetry,
    this.isEmpty = false,
    this.emptyWidget,
    this.debounceDelay = const Duration(milliseconds: 150),
    this.timeoutDuration = const Duration(seconds: 15),
  });

  @override
  State<DataLoaderView<T>> createState() => _DataLoaderViewState<T>();
}

class _DataLoaderViewState<T> extends State<DataLoaderView<T>> {
  bool _showLoader = false;
  bool _hasTimedOut = false;
  Timer? _debounceTimer;
  Timer? _timeoutTimer;

  @override
  void initState() {
    super.initState();
    _handleLoadingStateChange(widget.isLoading);
  }

  @override
  void didUpdateWidget(covariant DataLoaderView<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isLoading != widget.isLoading) {
      _handleLoadingStateChange(widget.isLoading);
    }
  }

  void _handleLoadingStateChange(bool isLoading) {
    _debounceTimer?.cancel();
    _timeoutTimer?.cancel();

    if (isLoading) {
      _hasTimedOut = false;
      // Debounce: only show loader if operation takes longer than debounceDelay
      _debounceTimer = Timer(widget.debounceDelay, () {
        if (mounted) setState(() => _showLoader = true);
      });

      // Safety timeout
      _timeoutTimer = Timer(widget.timeoutDuration, () {
        if (mounted && widget.isLoading) {
          setState(() {
            _hasTimedOut = true;
            _showLoader = false;
          });
        }
      });
    } else {
      if (mounted) {
        setState(() {
          _showLoader = false;
          _hasTimedOut = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _timeoutTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.errorMessage != null || _hasTimedOut) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(28.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.cloud_off_rounded, size: 48, color: Color(0xFF94A3B8)),
              const SizedBox(height: 12),
              Text(
                _hasTimedOut ? 'Request timed out' : 'Unable to load content',
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
              ),
              const SizedBox(height: 6),
              Text(
                _hasTimedOut
                    ? 'The connection is taking longer than usual. Please check your internet connection.'
                    : (widget.errorMessage ?? 'An unexpected error occurred.'),
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
              ),
              if (widget.onRetry != null) ...[
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() => _hasTimedOut = false);
                    widget.onRetry!();
                  },
                  icon: const Icon(Icons.refresh_rounded, size: 16),
                  label: const Text('Try Again', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    }

    if (widget.isLoading && _showLoader) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Loader(
            size: widget.loaderSize,
            label: widget.label,
            subtitle: widget.subtitle,
          ),
        ),
      );
    }

    if (!widget.isLoading && widget.isEmpty && widget.emptyWidget != null) {
      return widget.emptyWidget!;
    }

    return widget.child;
  }
}

/// Dedicated Progress Card for File & Media Uploads/Downloads (Section 5)
class AppUploadProgressCard extends StatelessWidget {
  /// Progress value between 0.0 and 1.0 (null for indeterminate)
  final double? progress;

  /// Current step or action description (e.g. "Uploading Academic Schedule...")
  final String status;

  /// Optional secondary status (e.g. "Writing to Firebase Storage...")
  final String? subStatus;

  /// Optional file name being processed
  final String? fileName;

  /// Optional cancel callback
  final VoidCallback? onCancel;

  const AppUploadProgressCard({
    super.key,
    this.progress,
    required this.status,
    this.subStatus,
    this.fileName,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final int percent = progress != null ? (progress! * 100).clamp(0, 100).toInt() : 0;

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.08) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Loader.inline(size: 36),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      status,
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                      ),
                    ),
                    if (fileName != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        fileName!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                      ),
                    ],
                  ],
                ),
              ),
              if (progress != null)
                Text(
                  '$percent%',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
          if (subStatus != null || onCancel != null) ...[
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (subStatus != null)
                  Expanded(
                    child: Text(
                      subStatus!,
                      style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                    ),
                  ),
                if (onCancel != null)
                  TextButton(
                    onPressed: onCancel,
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text('Cancel', style: TextStyle(fontSize: 11, color: AppColors.error)),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// Shimmer Skeleton Helpers for List & Card Loading (Section 8)
class AppSkeletonLoader {
  static Widget list({
    int itemCount = 4,
    double itemHeight = 72,
    EdgeInsetsGeometry padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  }) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: padding,
      itemCount: itemCount,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, _) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Shimmer.fromColors(
          baseColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
          highlightColor: isDark ? const Color(0xFF334155) : const Color(0xFFF8FAFC),
          child: Container(
            height: itemHeight,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        );
      },
    );
  }

  static Widget card({
    double height = 130,
    EdgeInsetsGeometry margin = const EdgeInsets.all(16),
  }) {
    return Builder(builder: (context) {
      final isDark = Theme.of(context).brightness == Brightness.dark;
      return Shimmer.fromColors(
        baseColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
        highlightColor: isDark ? const Color(0xFF334155) : const Color(0xFFF8FAFC),
        child: Container(
          margin: margin,
          height: height,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      );
    });
  }
}
