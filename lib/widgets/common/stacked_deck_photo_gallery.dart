import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:unisphere/core/constants/app_colors.dart';
import 'package:unisphere/models/photo_album_model.dart';
import 'package:unisphere/providers/gallery_provider.dart';
import 'package:unisphere/screens/gallery/album_details_screen.dart';
import 'package:unisphere/screens/gallery/full_photo_gallery_screen.dart';
import 'package:unisphere/screens/hod/modules/hod_album_management_screen.dart';
import 'package:unisphere/services/auth_service.dart';

class StackedDeckPhotoGallery extends ConsumerStatefulWidget {
  final List<PhotoAlbumModel>? albums;
  final bool isDarkMode;

  const StackedDeckPhotoGallery({
    super.key,
    this.albums,
    this.isDarkMode = false,
  });

  @override
  ConsumerState<StackedDeckPhotoGallery> createState() => _StackedDeckPhotoGalleryState();
}

class _StackedDeckPhotoGalleryState extends ConsumerState<StackedDeckPhotoGallery> {
  late PageController _pageController;
  double _currentPage = 0.0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      viewportFraction: 0.65,
      initialPage: 0,
    )..addListener(() {
        setState(() {
          _currentPage = _pageController.page ?? 0;
        });
      });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final recentAsync = ref.watch(recentPublishedAlbumsProvider);
    final user = ref.watch(authServiceProvider).currentUser;
    final isHodOrAdmin = user != null && (user.role.name == 'hod' || user.role.name == 'admin');

    final albumsList = widget.albums ?? recentAsync.asData?.value ?? [];

    if (albumsList.isEmpty) {
      return const SizedBox.shrink();
    }

    final dateFormat = DateFormat('MMMM yyyy');

    return Column(
      children: [
        // Styled Title with Unisphere Primary Accent Underline
        Column(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Text(
                  'Campus Memories',
                  style: TextStyle(
                    color: widget.isDarkMode ? Colors.white : AppColors.textPrimary,
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                  ),
                ),
                Positioned(
                  bottom: -4,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 3.5,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Swipe up & down to explore latest event albums',
              style: TextStyle(
                color: widget.isDarkMode ? Colors.white.withValues(alpha: 0.6) : AppColors.textSecondary,
                fontSize: 12.5,
              ),
            ),
          ],
        ),

        const SizedBox(height: 18),

        // Vertical Stacked 3D Card Deck View
        SizedBox(
          height: 420,
          child: PageView.builder(
            controller: _pageController,
            scrollDirection: Axis.vertical,
            itemCount: albumsList.length,
            itemBuilder: (context, index) {
              final album = albumsList[index];
              final delta = index - _currentPage;

              // 3D Card Depth Transformations
              final scale = (1 - (delta.abs() * 0.12)).clamp(0.75, 1.0);
              final opacity = (1 - (delta.abs() * 0.4)).clamp(0.2, 1.0);
              final translateY = delta * -15;

              final isNew = index == 0 || (album.publishedAt != null && DateTime.now().difference(album.publishedAt!).inDays <= 7);

              return Transform.translate(
                offset: Offset(0, translateY),
                child: Transform.scale(
                  scale: scale,
                  child: Opacity(
                    opacity: opacity,
                    child: _buildStackedCard(context, album, dateFormat, isNew),
                  ),
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 16),

        // Floating Action Pill Button using Unisphere Theme Colors
        Center(
          child: isHodOrAdmin
              ? FloatingPillButton(
                  icon: Icons.add_photo_alternate_rounded,
                  label: 'Add New Album',
                  useGradient: true,
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (context) => const CreateOrEditAlbumSheet(),
                    );
                  },
                )
              : FloatingPillButton(
                  icon: Icons.grid_view_rounded,
                  label: 'Explore All Albums',
                  useGradient: true,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const FullPhotoGalleryScreen()),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildStackedCard(
    BuildContext context,
    PhotoAlbumModel album,
    DateFormat dateFormat,
    bool isNew,
  ) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => AlbumDetailsScreen(album: album)),
        );
      },
      child: Center(
        child: Container(
          width: 330,
          height: 285,
          margin: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.borderSubtle),
            boxShadow: [
              BoxShadow(
                color: AppColors.textPrimary.withValues(alpha: 0.16),
                blurRadius: 18,
                spreadRadius: 1,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Cover Image
                album.coverPhotoUrl.isNotEmpty
                    ? Image.network(
                        album.coverPhotoUrl,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, progress) {
                          if (progress == null) return child;
                          return Container(
                            color: AppColors.surfaceSecondary,
                            child: const Center(
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.primaryLight,
                              ),
                            ),
                          );
                        },
                        errorBuilder: (_, __, ___) => Container(
                          color: AppColors.surfaceSecondary,
                          child: const Icon(Icons.collections_outlined, color: AppColors.textTertiary, size: 56),
                        ),
                      )
                    : Container(
                        color: AppColors.surfaceSecondary,
                        child: const Icon(Icons.collections_outlined, color: AppColors.textTertiary, size: 56),
                      ),

                // Top Gradient Overlay
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: 80,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.45),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),

                // Top Badges Row
                Positioned(
                  top: 14,
                  left: 14,
                  right: 14,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.55),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.2), width: 0.8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.photo_library_rounded, color: Colors.white, size: 11),
                            const SizedBox(width: 4),
                            Text(
                              '${album.photoCount} Photos',
                              style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                      if (isNew)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF10B981), Color(0xFF059669)],
                            ),
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF10B981).withValues(alpha: 0.4),
                                blurRadius: 6,
                              ),
                            ],
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.auto_awesome, color: Colors.white, size: 10),
                              SizedBox(width: 3),
                              Text(
                                'NEW',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 10.5,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),

                // Bottom Floating White Title Card Pill (Unisphere Theme Styled)
                Positioned(
                  bottom: 14,
                  left: 14,
                  right: 14,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.borderSubtle),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.textPrimary.withValues(alpha: 0.12),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                album.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.2,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
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
                                        fontSize: 10.5,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    dateFormat.format(album.eventDate),
                                    style: const TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          width: 32,
                          height: 32,
                          decoration: const BoxDecoration(
                            color: AppColors.primarySubtle,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.arrow_forward_rounded,
                            color: AppColors.primary,
                            size: 18,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class FloatingPillButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool useGradient;
  final Color backgroundColor;
  final Color textColor;
  final VoidCallback onTap;

  const FloatingPillButton({
    super.key,
    required this.icon,
    required this.label,
    this.useGradient = false,
    this.backgroundColor = Colors.white,
    this.textColor = Colors.white,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: useGradient ? AppColors.primaryGradient : null,
        color: useGradient ? null : backgroundColor,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: (useGradient ? AppColors.primary : Colors.black).withValues(alpha: 0.25),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(30),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 18, color: textColor),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 13.5,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
