import 'package:flutter/material.dart';
import 'package:unisphere/core/constants/app_colors.dart';
import 'package:unisphere/models/gallery_photo_model.dart';

class MasonryPhotoGrid extends StatelessWidget {
  final List<GalleryPhotoModel> photos;
  final Function(int index) onPhotoTap;
  final VoidCallback? onAddTap;
  final List<String>? contributorAvatars;
  final bool showHeaderAvatars;

  const MasonryPhotoGrid({
    super.key,
    required this.photos,
    required this.onPhotoTap,
    this.onAddTap,
    this.contributorAvatars,
    this.showHeaderAvatars = true,
  });

  @override
  Widget build(BuildContext context) {
    if (photos.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
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
                child: const Icon(
                  Icons.photo_library_outlined,
                  size: 36,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'No Photos Yet',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Photos added to this event album will appear here.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                ),
              ),
              if (onAddTap != null) ...[
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: onAddTap,
                  icon: const Icon(Icons.add_a_photo, size: 16, color: Colors.white),
                  label: const Text('Add First Photo'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    }

    // Split photos into 2 columns for staggered Masonry effect
    final leftColumnPhotos = <Map<String, dynamic>>[];
    final rightColumnPhotos = <Map<String, dynamic>>[];

    // Varying height aspect ratios to create Pinterest / Apple Memories staggered layout
    final aspectRatios = [0.85, 1.2, 0.95, 1.3, 0.75, 1.1];

    for (int i = 0; i < photos.length; i++) {
      final photo = photos[i];
      final aspectRatio = aspectRatios[i % aspectRatios.length];
      final item = {
        'photo': photo,
        'index': i,
        'aspectRatio': aspectRatio,
        'likeCount': (i * 3 + 2) % 9 + 1,
      };

      if (i % 2 == 0) {
        leftColumnPhotos.add(item);
      } else {
        rightColumnPhotos.add(item);
      }
    }

    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 90),
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Top Contributor Avatars Pill Bar
              if (showHeaderAvatars) ...[
                Center(
                  child: _buildAvatarStack(context),
                ),
                const SizedBox(height: 14),
              ],

              // 2. Staggered 2-Column Masonry Grid
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left Column
                  Expanded(
                    child: Column(
                      children: leftColumnPhotos.map((data) {
                        return _buildMasonryTile(
                          context,
                          data['photo'] as GalleryPhotoModel,
                          data['index'] as int,
                          data['aspectRatio'] as double,
                          data['likeCount'] as int,
                        );
                      }).toList(),
                    ),
                  ),

                  const SizedBox(width: 12),

                  // Right Column
                  Expanded(
                    child: Column(
                      children: rightColumnPhotos.map((data) {
                        return _buildMasonryTile(
                          context,
                          data['photo'] as GalleryPhotoModel,
                          data['index'] as int,
                          data['aspectRatio'] as double,
                          data['likeCount'] as int,
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // 3. Floating Center Action Button with Unisphere Primary Gradient
        if (onAddTap != null)
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.35),
                      blurRadius: 14,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: onAddTap,
                    borderRadius: BorderRadius.circular(30),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.add_photo_alternate_rounded, color: Colors.white, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Add Photos',
                            style: TextStyle(
                              color: Colors.white,
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
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildAvatarStack(BuildContext context) {
    final sampleAvatars = contributorAvatars ??
        [
          'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=150&q=80',
          'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=150&q=80',
          'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=150&q=80',
        ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimary.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 28,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: sampleAvatars.length,
              itemBuilder: (context, idx) {
                return Align(
                  widthFactor: 0.72,
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 3,
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      backgroundImage: NetworkImage(sampleAvatars[idx]),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(width: 8),
          const Text(
            'Contributors',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.primarySubtle,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '${sampleAvatars.length}',
              style: const TextStyle(
                color: AppColors.primary,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMasonryTile(
    BuildContext context,
    GalleryPhotoModel photo,
    int index,
    double aspectRatio,
    int likeCount,
  ) {
    return GestureDetector(
      onTap: () => onPhotoTap(index),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.borderSubtle),
          boxShadow: [
            BoxShadow(
              color: AppColors.textPrimary.withValues(alpha: 0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Stack(
            children: [
              // Photo Image
              AspectRatio(
                aspectRatio: aspectRatio,
                child: photo.photoUrl.isNotEmpty
                    ? Image.network(
                        photo.photoUrl,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, progress) {
                          if (progress == null) return child;
                          return Container(
                            color: AppColors.surfaceSecondary,
                            child: const Center(
                              child: SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.primaryLight,
                                ),
                              ),
                            ),
                          );
                        },
                        errorBuilder: (_, __, ___) => Container(
                          color: AppColors.surfaceSecondary,
                          child: const Center(
                            child: Icon(Icons.broken_image_rounded, color: AppColors.textTertiary, size: 32),
                          ),
                        ),
                      )
                    : Container(
                        color: AppColors.surfaceSecondary,
                        child: const Center(
                          child: Icon(Icons.image_outlined, color: AppColors.textTertiary, size: 32),
                        ),
                      ),
              ),

              // Bottom Overlay Gradient
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                height: 56,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.65),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),

              // Bottom Left Photo Index Pill
              Positioned(
                bottom: 8,
                left: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.15), width: 0.8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.photo_camera_outlined, color: Colors.white, size: 10),
                      const SizedBox(width: 3),
                      Text(
                        '#${index + 1}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Bottom Right Reaction / Like Count Pill
              Positioned(
                bottom: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.15), width: 0.8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.favorite_rounded, color: Color(0xFFEF4444), size: 11),
                      const SizedBox(width: 3),
                      Text(
                        '$likeCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
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
    );
  }
}
