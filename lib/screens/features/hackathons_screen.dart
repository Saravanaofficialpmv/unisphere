import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';

import 'package:clg_application/controllers/hackathon_banner_controller.dart';
import 'package:clg_application/controllers/hackathon_banner_state.dart';

class HackathonsScreen extends ConsumerWidget {
  final VoidCallback? onBack;
  const HackathonsScreen({super.key, this.onBack});

  void _navigateBackToFeatureHub(BuildContext context) async {
    if (onBack != null) {
      onBack!();
      return;
    }
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    } else {
      context.go('/student');
    }
  }

  Future<void> _launchRegistrationLink(BuildContext context, String urlString) async {
    if (urlString.trim().isEmpty) return;
    final uri = Uri.parse(urlString);
    try {
      final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!launched) {
        await launchUrl(uri, mode: LaunchMode.platformDefault);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not launch registration link: $urlString'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(hackathonBannerControllerProvider);

    final scaffold = Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () => _navigateBackToFeatureHub(context),
        ),
        title: const Text(
          'Hackathon Registration',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(hackathonBannerControllerProvider.notifier).refresh();
        },
        color: const Color(0xFF7C3AED),
        child: _buildBodyContent(context, ref, state),
      ),
    );

    return PopScope(
      canPop: onBack == null,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (onBack != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            onBack!();
          });
        }
      },
      child: scaffold,
    );
  }

  Widget _buildBodyContent(BuildContext context, WidgetRef ref, HackathonBannerState state) {
    if (state.status == HackathonBannerStatus.loading) {
      return _buildShimmerLoading();
    }

    if (state.status == HackathonBannerStatus.error) {
      return _buildErrorState(context, ref, state.errorMessage ?? 'Unable to load hackathon poster');
    }

    if (state.status == HackathonBannerStatus.empty || state.banner == null || !state.banner!.isActive) {
      return _buildEmptyState(context, ref);
    }

    final banner = state.banner!;
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Banner Poster Card
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: AspectRatio(
              aspectRatio: 4 / 3,
              child: CachedNetworkImage(
                imageUrl: banner.posterImage,
                fit: BoxFit.cover,
                placeholder: (context, url) => Shimmer.fromColors(
                  baseColor: const Color(0xFFE2E8F0),
                  highlightColor: const Color(0xFFF1F5F9),
                  child: Container(color: Colors.white),
                ),
                errorWidget: (context, url, error) => Container(
                  color: const Color(0xFF1E293B),
                  child: const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.military_tech_rounded, size: 64, color: Colors.white38),
                        SizedBox(height: 8),
                        Text(
                          'Poster Image Unavailable',
                          style: TextStyle(color: Colors.white70, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Title
          Text(
            banner.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: Color(0xFF0F172A),
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 12),

          // Dates Badge Row
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today_rounded, size: 14, color: Color(0xFF64748B)),
                    const SizedBox(width: 6),
                    Text(
                      'Deadline: ${DateFormat('MMM dd, yyyy').format(banner.expiryDate)}',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF475569)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),

          // "Register Now" Button
          SizedBox(
            height: 54,
            child: ElevatedButton(
              onPressed: () => _launchRegistrationLink(context, banner.registrationLink),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7C3AED),
                foregroundColor: Colors.white,
                elevation: 4,
                shadowColor: const Color(0xFF7C3AED).withValues(alpha: 0.4),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Register Now',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(width: 8),
                  Icon(Icons.open_in_new_rounded, size: 18),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Shimmer.fromColors(
            baseColor: const Color(0xFFE2E8F0),
            highlightColor: const Color(0xFFF1F5F9),
            child: Container(
              height: 260,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Shimmer.fromColors(
            baseColor: const Color(0xFFE2E8F0),
            highlightColor: const Color(0xFFF1F5F9),
            child: Container(
              height: 28,
              width: 240,
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(6)),
            ),
          ),
          const SizedBox(height: 12),
          Shimmer.fromColors(
            baseColor: const Color(0xFFE2E8F0),
            highlightColor: const Color(0xFFF1F5F9),
            child: Container(
              height: 20,
              width: 160,
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
            ),
          ),
          const SizedBox(height: 32),
          Shimmer.fromColors(
            baseColor: const Color(0xFFE2E8F0),
            highlightColor: const Color(0xFFF1F5F9),
            child: Container(
              height: 54,
              width: double.infinity,
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.75,
        alignment: Alignment.center,
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Color(0xFFF3E8FF),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.campaign_outlined, size: 64, color: Color(0xFF7C3AED)),
            ),
            const SizedBox(height: 20),
            const Text(
              'No Hackathon Registration Available',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
            ),
            const SizedBox(height: 8),
            const Text(
              'There are currently no active hackathon registration posters uploaded.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Color(0xFF64748B)),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                ref.read(hackathonBannerControllerProvider.notifier).refresh();
              },
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Refresh'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7C3AED),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, WidgetRef ref, String message) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.75,
        alignment: Alignment.center,
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Color(0xFFFEE2E2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.error_outline_rounded, size: 64, color: Color(0xFFDC2626)),
            ),
            const SizedBox(height: 20),
            const Text(
              'Unable to load hackathon poster',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                ref.read(hackathonBannerControllerProvider.notifier).fetchBanner();
              },
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7C3AED),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
