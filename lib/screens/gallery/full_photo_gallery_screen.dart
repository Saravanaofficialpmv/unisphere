import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:unisphere/core/constants/app_colors.dart';
import 'package:unisphere/models/photo_album_model.dart';
import 'package:unisphere/providers/gallery_provider.dart';
import 'package:unisphere/screens/gallery/album_details_screen.dart';
import 'package:unisphere/widgets/common/stacked_deck_photo_gallery.dart';
import 'package:unisphere/widgets/common/unisphere_header_card.dart';
import 'package:unisphere/widgets/common/custom_loader.dart';

class FullPhotoGalleryScreen extends ConsumerStatefulWidget {
  final VoidCallback? onBack;

  const FullPhotoGalleryScreen({
    super.key,
    this.onBack,
  });

  @override
  ConsumerState<FullPhotoGalleryScreen> createState() => _FullPhotoGalleryScreenState();
}

class _FullPhotoGalleryScreenState extends ConsumerState<FullPhotoGalleryScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedDeptFilter = 'All';
  bool _useStackedDeckView = false;

  final List<String> _departments = [
    'All',
    'Computer Science & Engineering',
    'Electronics & Communication',
    'Information Technology',
    'Mechanical Engineering',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final publishedAlbumsAsync = ref.watch(allPublishedAlbumsProvider);
    final dateFormat = DateFormat('MMM dd, yyyy');

    return Scaffold(
      backgroundColor: AppColors.backgroundSubtle,
      body: SafeArea(
        child: Column(
          children: [
            // Unisphere Signature Header Card
            UnisphereHeaderCard(
              title: 'Campus Photo Gallery',
              subtitle: 'Memories, Events, Hackathons & Cultural Fests',
              onBack: widget.onBack ?? (Navigator.canPop(context) ? () => Navigator.of(context).pop() : null),
              rightActions: [
                IconButton(
                  icon: Icon(
                    _useStackedDeckView ? Icons.grid_view_rounded : Icons.view_carousel_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                  tooltip: _useStackedDeckView ? 'Switch to Grid View' : 'Switch to 3D Deck View',
                  onPressed: () {
                    setState(() {
                      _useStackedDeckView = !_useStackedDeckView;
                    });
                  },
                ),
              ],
            ),

            // Search Bar & Filter Chips Header
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 8, 14, 10),
              child: Column(
                children: [
                  // Search TextField Card
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.border),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.textPrimary.withValues(alpha: 0.04),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (val) => setState(() => _searchQuery = val.trim().toLowerCase()),
                      style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
                      decoration: InputDecoration(
                        hintText: 'Search albums by event or title...',
                        hintStyle: const TextStyle(color: AppColors.textTertiary, fontSize: 13.5),
                        prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primary, size: 20),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear_rounded, color: AppColors.textTertiary, size: 18),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() => _searchQuery = '');
                                },
                              )
                            : null,
                        filled: true,
                        fillColor: Colors.transparent,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Department Filter Horizontal Chips
                  SizedBox(
                    height: 36,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      itemCount: _departments.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        final dept = _departments[index];
                        final isSelected = _selectedDeptFilter == dept;
                        return ChoiceChip(
                          showCheckmark: false,
                          label: Text(
                            dept,
                            style: TextStyle(
                              color: isSelected ? Colors.white : AppColors.textSecondary,
                              fontSize: 12,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                            ),
                          ),
                          selected: isSelected,
                          selectedColor: AppColors.primary,
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(
                              color: isSelected ? AppColors.primary : AppColors.border,
                            ),
                          ),
                          onSelected: (selected) {
                            if (selected) {
                              setState(() => _selectedDeptFilter = dept);
                            }
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            // Main Gallery Content Body
            Expanded(
              child: publishedAlbumsAsync.when(
                data: (albums) {
                  // Apply search & dept filters
                  final filtered = albums.where((album) {
                    final matchesSearch = _searchQuery.isEmpty ||
                        album.title.toLowerCase().contains(_searchQuery) ||
                        album.description.toLowerCase().contains(_searchQuery);
                    final matchesDept = _selectedDeptFilter == 'All' || album.departmentName == _selectedDeptFilter;
                    return matchesSearch && matchesDept;
                  }).toList();

                  if (filtered.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 72,
                              height: 72,
                              decoration: BoxDecoration(
                                color: AppColors.primarySubtle,
                                shape: BoxShape.circle,
                                border: Border.all(color: AppColors.primary.withValues(alpha: 0.15), width: 2),
                              ),
                              child: const Icon(Icons.photo_library_outlined, size: 36, color: AppColors.primary),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'No Event Albums Found',
                              style: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'Try modifying your search query or department filter.',
                              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  if (_useStackedDeckView) {
                    return SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: StackedDeckPhotoGallery(albums: filtered),
                    );
                  }

                  return GridView.builder(
                    padding: const EdgeInsets.fromLTRB(14, 4, 14, 24),
                    physics: const BouncingScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 340,
                      mainAxisSpacing: 14,
                      crossAxisSpacing: 14,
                      childAspectRatio: 0.85,
                    ),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final album = filtered[index];
                      return _buildAlbumCard(context, album, dateFormat);
                    },
                  );
                },
                loading: () => const Center(
                  child: Loader(label: 'Loading photo gallery...'),
                ),
                error: (err, _) => Center(
                  child: Text('Error loading photo gallery: $err', style: const TextStyle(color: AppColors.textSecondary)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlbumCard(BuildContext context, PhotoAlbumModel album, DateFormat dateFormat) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => AlbumDetailsScreen(album: album)),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: AppColors.textPrimary.withValues(alpha: 0.06),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cover Image with Badge Overlay
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  album.coverPhotoUrl.isNotEmpty
                      ? Image.network(
                          album.coverPhotoUrl,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, progress) {
                            if (progress == null) return child;
                            return Container(
                              color: AppColors.surfaceSecondary,
                              child: const Center(
                                child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primaryLight),
                              ),
                            );
                          },
                          errorBuilder: (_, __, ___) => Container(
                            color: AppColors.surfaceSecondary,
                            child: const Icon(Icons.collections_outlined, color: AppColors.textTertiary, size: 44),
                          ),
                        )
                      : Container(
                          color: AppColors.surfaceSecondary,
                          child: const Icon(Icons.collections_outlined, color: AppColors.textTertiary, size: 44),
                        ),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.65),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.2), width: 0.8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.photo_library_rounded, color: Colors.white, size: 11),
                          const SizedBox(width: 4),
                          Text(
                            '${album.photoCount}',
                            style: const TextStyle(color: Colors.white, fontSize: 10.5, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Card Body Details
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.primarySubtle,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      album.departmentName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    album.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today_rounded, size: 11, color: AppColors.textSecondary),
                      const SizedBox(width: 4),
                      Text(
                        dateFormat.format(album.eventDate),
                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
