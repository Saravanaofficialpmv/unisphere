import 'package:flutter/material.dart';
import 'package:clg_application/core/features/feature_registry.dart';
import 'package:clg_application/core/features/feature_item.dart';

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
    if (feature.id == 'gradebook' && widget.onNavigateToTab != null) {
      // If it's gradebook, switch to tab index 4
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
      widget.onNavigateToTab!(4, openCalculator: false);
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => feature.routeBuilder(context),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final categories = FeatureRegistry.getCategories();
    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount = screenWidth > 900 ? 3 : (screenWidth > 600 ? 2 : 2);

    final scaffold = Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () {
            if (widget.onBack != null) {
              widget.onBack!();
            } else {
              Navigator.of(context).pop();
            }
          },
        ),
        title: const Row(
          children: [
            Icon(Icons.grid_view_rounded, color: Color(0xFF818CF8), size: 22),
            SizedBox(width: 8),
            Text(
              'Feature Hub',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
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
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: Color(0xFF4F46E5), width: 1.5),
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Category Choice Chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: categories.map((cat) {
                  final isSelected = _selectedCategory == cat;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ChoiceChip(
                      label: Text(cat),
                      selected: isSelected,
                      onSelected: (val) {
                        if (val) setState(() => _selectedCategory = cat);
                      },
                      selectedColor: const Color(0xFF4F46E5),
                      backgroundColor: Colors.white,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : const Color(0xFF475569),
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: BorderSide(color: isSelected ? const Color(0xFF4F46E5) : const Color(0xFFE2E8F0)),
                      ),
                      showCheckmark: false,
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 20),

            // Responsive Feature Grid
            if (_filteredFeatures.isEmpty)
              _buildEmptyState()
            else
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                  childAspectRatio: 0.82,
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
    );

    if (widget.onBack != null) {
      return PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) {
          if (didPop) return;
          widget.onBack!();
        },
        child: scaffold,
      );
    }

    return scaffold;
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
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      color: Colors.white,
      child: InkWell(
        onTap: () => _openFeature(feature),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(14.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: feature.color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(feature.icon, color: feature.color, size: 24),
                  ),
                  if (feature.badge != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: feature.color.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        feature.badge!,
                        style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: feature.color),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                feature.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF0F172A), height: 1.2),
              ),
              const SizedBox(height: 4),
              Text(
                feature.subtitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 10, color: Color(0xFF64748B), height: 1.2),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text(
                    'Open Module',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: feature.color),
                  ),
                  const SizedBox(width: 4),
                  Icon(Icons.arrow_forward_rounded, size: 12, color: feature.color),
                ],
              ),
            ],
          ),
        ),
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
