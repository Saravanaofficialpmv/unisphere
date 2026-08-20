import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:unisphere/widgets/common/unisphere_header_card.dart';

import 'package:unisphere/core/features/feature_registry.dart';
import 'package:unisphere/core/features/feature_item.dart';
import 'package:unisphere/core/theme/app_animations.dart';

class FeatureHubScreen extends StatefulWidget {
  final VoidCallback? onBack;
  final Function(int index, {bool openCalculator})? onNavigateToTab;

  const FeatureHubScreen({
    super.key,
    this.onBack,
    this.onNavigateToTab,
  });

  @override
  State<FeatureHubScreen> createState() => _FeatureHubScreenState();
}

class _FeatureHubScreenState extends State<FeatureHubScreen> {
  void _openFeature(FeatureItem feature) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => feature.routeBuilder(context),
      ),
    );
  }

  void _handleBack() async {
    if (widget.onBack != null) {
      widget.onBack!();
    } else if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    } else {
      context.go('/student');
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount = screenWidth > 900 ? 3 : (screenWidth > 600 ? 2 : 2);
    final features = FeatureRegistry.getAllFeatures();

    final scaffold = Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            UnisphereHeaderCard(
              title: 'Feature Hub & Modules',
              subtitle: 'All Campus Tools, Portals & Resources',
              onBack: _handleBack,
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.95,
                  ),
                  itemCount: features.length,
                  itemBuilder: (context, index) {
                    final feature = features[index];
                    return _buildFeatureCard(feature);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );

    final bool canPopRoute = ModalRoute.of(context)?.canPop ?? false;
    return PopScope(
      canPop: canPopRoute,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop || !mounted) return;
        if (widget.onBack != null) {
          widget.onBack!();
        }
      },
      child: scaffold,
    );
  }

  Widget _buildFeatureCard(FeatureItem feature) {
    return AppCardPressable(
      onTap: () => _openFeature(feature),
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: const Color(0xFFE2E8F0)),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.03),
          blurRadius: 8,
          offset: const Offset(0, 3),
        ),
      ],
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 12.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Soft Pastel Icon Container (52x52px) with Image Asset or Icon
                Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      padding: const EdgeInsets.all(9),
                      decoration: BoxDecoration(
                        color: feature.pastelBg,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: feature.color.withValues(alpha: 0.2)),
                      ),
                      child: feature.imageAsset != null
                          ? Image.asset(
                              feature.imageAsset!,
                              fit: BoxFit.contain,
                              errorBuilder: (_, __, ___) =>
                                  Icon(feature.icon, size: 28, color: feature.color),
                            )
                          : Icon(feature.icon, size: 28, color: feature.color),
                    ),
                    if (feature.badge != null)
                      Positioned(
                        top: -5,
                        right: -5,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                          decoration: BoxDecoration(
                            color: feature.color,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: feature.color.withValues(alpha: 0.35),
                                blurRadius: 4,
                                offset: const Offset(0, 1.5),
                              ),
                            ],
                          ),
                          child: Text(
                            feature.badge!,
                            style: const TextStyle(
                              fontSize: 8.5,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),

                // Centered Feature Title
                Text(
                  feature.title,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 2),

                // Centered Subtitle
                Text(
                  feature.subtitle,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 10,
                    color: Color(0xFF64748B),
                    height: 1.15,
                  ),
                ),
              ],
            ),
    );
  }
}
