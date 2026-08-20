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
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'All';

  List<FeatureItem> get _filteredFeatures {
    final query = _searchController.text.trim().toLowerCase();
    return FeatureRegistry.getAllFeatures().where((feature) {
      final matchesQuery = query.isEmpty ||
          feature.title.toLowerCase().contains(query) ||
          feature.subtitle.toLowerCase().contains(query) ||
          feature.category.toLowerCase().contains(query);

      final matchesCategory = _selectedCategory == 'All' || feature.category == _selectedCategory;

      return matchesQuery && matchesCategory;
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

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
    final categories = FeatureRegistry.getCategories();
    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount = screenWidth > 900 ? 3 : (screenWidth > 600 ? 2 : 2);

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
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Hero Hub Header Banner
                    _buildHeroHeader(),
                    const SizedBox(height: 20),

                    // Search Bar
                    TextField(
                      controller: _searchController,
                      onChanged: (_) => setState(() {}),
                      decoration: InputDecoration(
                        hintText: 'Search features, modules, tools...',
                        hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
                        prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF64748B)),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear_rounded, size: 18),
                                onPressed: () => setState(() => _searchController.clear()),
                              )
                            : null,
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(vertical: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Category Filter Pills Row
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: categories.map((cat) {
                          final isSelected = cat == _selectedCategory;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: ChoiceChip(
                              label: Text(cat),
                              selected: isSelected,
                              selectedColor: const Color(0xFF1E40AF),
                              backgroundColor: Colors.white,
                              labelStyle: TextStyle(
                                color: isSelected ? Colors.white : const Color(0xFF64748B),
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                fontSize: 12,
                              ),
                              side: BorderSide(
                                color: isSelected ? const Color(0xFF1E40AF) : const Color(0xFFE2E8F0),
                              ),
                              onSelected: (_) => setState(() => _selectedCategory = cat),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Grid of Features
                    if (_filteredFeatures.isEmpty)
                      _buildEmptyState()
                    else
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 0.95,
                        ),
                        itemCount: _filteredFeatures.length,
                        itemBuilder: (context, index) {
                          final feature = _filteredFeatures[index];
                          return _buildFeatureCard(feature);
                        },
                      ),
                  ],
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

  Widget _buildHeroHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF818CF8).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.auto_awesome_rounded, color: Color(0xFF818CF8), size: 14),
                    SizedBox(width: 4),
                    Text(
                      'UNISPHERE HUB',
                      style: TextStyle(color: Color(0xFF818CF8), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.8),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              const Text(
                'Modular & Scalable',
                style: TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Explore Campus Modules',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.white),
          ),
          const SizedBox(height: 6),
          const Text(
            'Access hackathons, professional certifications, gradebook tools, achievements, and events in one unified space.',
            style: TextStyle(fontSize: 12, color: Colors.white70, height: 1.3),
          ),
        ],
      ),
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

  Widget _buildEmptyState() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 40),
      child: Column(
        children: [
          Icon(Icons.search_off_rounded, size: 48, color: Color(0xFF94A3B8)),
          SizedBox(height: 12),
          Text('No Features Match Your Search', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
          SizedBox(height: 4),
          Text('Try clearing your search or category filters.', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
        ],
      ),
    );
  }
}
