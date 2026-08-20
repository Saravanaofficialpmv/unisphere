import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:unisphere/core/constants/app_colors.dart';
import 'package:unisphere/models/photo_album_model.dart';
import 'package:unisphere/providers/gallery_provider.dart';
import 'package:unisphere/screens/gallery/album_details_screen.dart';
import 'package:unisphere/screens/gallery/full_photo_gallery_screen.dart';
import 'package:unisphere/widgets/common/stacked_deck_photo_gallery.dart';
import 'package:unisphere/widgets/common/custom_loader.dart';

class RecentPhotosSection extends ConsumerStatefulWidget {
  final VoidCallback? onViewAllPressed;
  final bool isDarkMode;

  const RecentPhotosSection({
    super.key,
    this.onViewAllPressed,
    this.isDarkMode = false,
  });

  @override
  ConsumerState<RecentPhotosSection> createState() => _RecentPhotosSectionState();
}

class _RecentPhotosSectionState extends ConsumerState<RecentPhotosSection> {
  bool _useStackedDeckView = true;

  @override
  Widget build(BuildContext context) {
    final recentAlbumsAsync = ref.watch(recentPublishedAlbumsProvider);
    final dateFormat = DateFormat('MMM dd, yyyy');

    return recentAlbumsAsync.when(
      data: (albums) {
        if (albums.isEmpty) return const SizedBox.shrink();

        final displayAlbums = albums.take(6).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section Header with View Toggle & View All Button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primarySubtle,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.collections_outlined, color: AppColors.primary, size: 20),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Campus Memories',
                      style: TextStyle(
                        color: widget.isDarkMode ? Colors.white : AppColors.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.surfaceSecondary,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          InkWell(
                            onTap: () {
                              if (!_useStackedDeckView) {
                                setState(() => _useStackedDeckView = true);
                              }
                            },
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: _useStackedDeckView ? AppColors.primary : Colors.transparent,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Icon(
                                Icons.view_carousel_rounded,
                                size: 16,
                                color: _useStackedDeckView ? Colors.white : AppColors.textSecondary,
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              if (_useStackedDeckView) {
                                setState(() => _useStackedDeckView = false);
                              }
                            },
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: !_useStackedDeckView ? AppColors.primary : Colors.transparent,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Icon(
                                Icons.grid_view_rounded,
                                size: 16,
                                color: !_useStackedDeckView ? Colors.white : AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    TextButton.icon(
                      onPressed: widget.onViewAllPressed ??
                          () {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const FullPhotoGalleryScreen()),
                            );
                          },
                      icon: const Icon(Icons.arrow_forward_rounded, size: 16, color: AppColors.primary),
                      label: const Text(
                        'View All',
                        style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Content Body: 3D Stacked Deck or Horizontal Cards
            if (_useStackedDeckView)
              StackedDeckPhotoGallery(
                albums: displayAlbums,
                isDarkMode: widget.isDarkMode,
              )
            else
              SizedBox(
                height: 230,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: displayAlbums.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 14),
                  itemBuilder: (context, index) {
                    final album = displayAlbums[index];
                    return _buildRecentAlbumCard(context, album, dateFormat);
                  },
                ),
              ),
          ],
        );
      },
      loading: () => const SizedBox(
        height: 180,
        child: Center(child: Loader(size: 44, label: 'Loading recent photos...')),
      ),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildRecentAlbumCard(BuildContext context, PhotoAlbumModel album, DateFormat dateFormat) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => AlbumDetailsScreen(album: album)),
        );
      },
      child: Container(
        width: 240,
        decoration: BoxDecoration(
          color: widget.isDarkMode ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: widget.isDarkMode ? Colors.white.withValues(alpha: 0.1) : AppColors.border),
          boxShadow: [
            BoxShadow(
              color: AppColors.textPrimary.withValues(alpha: 0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail Image & Photo Count Badge
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
                            child: const Icon(Icons.collections_outlined, color: AppColors.textSecondary, size: 40),
                          ),
                        )
                      : Container(
                          color: AppColors.surfaceSecondary,
                          child: const Icon(Icons.collections_outlined, color: AppColors.textSecondary, size: 40),
                        ),
                  Positioned(
                    top: 8,
                    right: 8,
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

            // Details Container
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
                  const SizedBox(height: 5),
                  Text(
                    album.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: widget.isDarkMode ? Colors.white : AppColors.textPrimary,
                      fontSize: 13.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
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
