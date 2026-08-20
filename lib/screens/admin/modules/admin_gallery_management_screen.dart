import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:unisphere/core/constants/app_colors.dart';
import 'package:unisphere/models/photo_album_model.dart';
import 'package:unisphere/providers/gallery_provider.dart';
import 'package:unisphere/screens/gallery/album_details_screen.dart';
import 'package:unisphere/screens/hod/modules/hod_album_management_screen.dart';
import 'package:unisphere/services/auth_service.dart';
import 'package:unisphere/services/gallery_service.dart';
import 'package:unisphere/widgets/common/unisphere_header_card.dart';
import 'package:unisphere/widgets/common/custom_loader.dart';

class AdminGalleryManagementScreen extends ConsumerStatefulWidget {
  final VoidCallback? onBack;

  const AdminGalleryManagementScreen({
    super.key,
    this.onBack,
  });

  @override
  ConsumerState<AdminGalleryManagementScreen> createState() => _AdminGalleryManagementScreenState();
}

class _AdminGalleryManagementScreenState extends ConsumerState<AdminGalleryManagementScreen> {
  String _selectedStatus = 'All';

  @override
  Widget build(BuildContext context) {
    final allAlbumsAsync = ref.watch(adminAlbumsProvider);
    final dateFormat = DateFormat('MMM dd, yyyy');

    return Scaffold(
      backgroundColor: AppColors.backgroundSubtle,
      body: SafeArea(
        child: Column(
          children: [
            // Unisphere Signature Header Card
            UnisphereHeaderCard(
              title: 'Photo Gallery Governance',
              subtitle: 'Manage, Approve & Publish Campus Albums',
              onBack: widget.onBack ?? (Navigator.canPop(context) ? () => Navigator.of(context).pop() : null),
            ),

            // Status Filter Bar
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 6, 16, 8),
              child: Row(
                children: [
                  const Text('Filter:', style: TextStyle(color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.bold)),
                  const SizedBox(width: 10),
                  Wrap(
                    spacing: 8,
                    children: ['All', 'Published', 'Draft', 'Hidden'].map((status) {
                      final isSelected = _selectedStatus == status;
                      Color activeColor = AppColors.primary;
                      if (status == 'Published') activeColor = AppColors.success;
                      if (status == 'Draft') activeColor = AppColors.warning;
                      if (status == 'Hidden') activeColor = AppColors.error;

                      return ChoiceChip(
                        showCheckmark: false,
                        label: Text(
                          status,
                          style: TextStyle(
                            color: isSelected ? Colors.white : AppColors.textSecondary,
                            fontSize: 12,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                          ),
                        ),
                        selected: isSelected,
                        selectedColor: activeColor,
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(color: isSelected ? activeColor : AppColors.border),
                        ),
                        onSelected: (selected) {
                          if (selected) setState(() => _selectedStatus = status);
                        },
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),

            // Main Album List
            Expanded(
              child: allAlbumsAsync.when(
                data: (albums) {
                  final filtered = albums.where((a) {
                    if (_selectedStatus == 'Published') return a.isPublished;
                    if (_selectedStatus == 'Draft') return a.isDraft;
                    if (_selectedStatus == 'Hidden') return a.isHidden;
                    return true;
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
                              child: const Icon(Icons.collections_outlined, size: 36, color: AppColors.primary),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No albums matching filter "$_selectedStatus"',
                              style: const TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'Event albums created by departments will appear here for governance.',
                              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 90),
                    physics: const BouncingScrollPhysics(),
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final album = filtered[index];
                      return _buildAdminAlbumCard(context, album, dateFormat);
                    },
                  );
                },
                loading: () => const Center(child: Loader(label: 'Loading campus albums...')),
                error: (err, _) => Center(child: Text('Error loading albums: $err', style: const TextStyle(color: AppColors.textSecondary))),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        elevation: 4,
        icon: const Icon(Icons.add_photo_alternate_rounded, color: Colors.white),
        label: const Text('Add Campus Album', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13.5)),
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) => const CreateOrEditAlbumSheet(),
          );
        },
      ),
    );
  }

  Widget _buildAdminAlbumCard(BuildContext context, PhotoAlbumModel album, DateFormat dateFormat) {
    final user = ref.read(authServiceProvider).currentUser;

    Color badgeColor = AppColors.warning;
    if (album.isPublished) badgeColor = AppColors.success;
    if (album.isHidden) badgeColor = AppColors.error;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimary.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: SizedBox(
            width: 68,
            height: 68,
            child: album.coverPhotoUrl.isNotEmpty
                ? Image.network(
                    album.coverPhotoUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: AppColors.surfaceSecondary,
                      child: const Icon(Icons.collections_outlined, color: AppColors.textTertiary),
                    ),
                  )
                : Container(
                    color: AppColors.surfaceSecondary,
                    child: const Icon(Icons.collections_outlined, color: AppColors.textTertiary),
                  ),
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                album.title,
                style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 14),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: badgeColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                album.statusString.toUpperCase(),
                style: TextStyle(color: badgeColor, fontSize: 10, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${album.departmentName} • ${album.photoCount} Photos',
                style: const TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 3),
              Row(
                children: [
                  const Icon(Icons.calendar_today_rounded, size: 11, color: AppColors.textSecondary),
                  const SizedBox(width: 4),
                  Text('Event: ${dateFormat.format(album.eventDate)}', style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
                ],
              ),
            ],
          ),
        ),
        trailing: PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert_rounded, color: AppColors.textSecondary),
          color: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: AppColors.border)),
          onSelected: (action) async {
            if (user == null) return;
            final service = ref.read(galleryServiceProvider);
            if (action == 'view') {
              Navigator.of(context).push(MaterialPageRoute(builder: (_) => AlbumDetailsScreen(album: album)));
            } else if (action == 'publish') {
              await service.publishAlbum(albumId: album.albumId, userId: user.uid, userName: user.fullName, userRole: user.role.name);
            } else if (action == 'hide') {
              await service.hideAlbum(albumId: album.albumId, userId: user.uid, userName: user.fullName, userRole: user.role.name);
            } else if (action == 'delete') {
              await service.deleteAlbum(albumId: album.albumId, userId: user.uid, userName: user.fullName, userRole: user.role.name);
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'view',
              child: Row(
                children: [
                  Icon(Icons.visibility_outlined, size: 16, color: AppColors.textPrimary),
                  SizedBox(width: 8),
                  Text('View Details', style: TextStyle(color: AppColors.textPrimary, fontSize: 13)),
                ],
              ),
            ),
            if (!album.isPublished)
              const PopupMenuItem(
                value: 'publish',
                child: Row(
                  children: [
                    Icon(Icons.publish_rounded, size: 16, color: AppColors.success),
                    SizedBox(width: 8),
                    Text('Publish Album', style: TextStyle(color: AppColors.success, fontSize: 13, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            if (album.isPublished)
              const PopupMenuItem(
                value: 'hide',
                child: Row(
                  children: [
                    Icon(Icons.visibility_off_outlined, size: 16, color: AppColors.warning),
                    SizedBox(width: 8),
                    Text('Hide Album', style: TextStyle(color: AppColors.warning, fontSize: 13)),
                  ],
                ),
              ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete_outline_rounded, size: 16, color: AppColors.error),
                  SizedBox(width: 8),
                  Text('Delete Album', style: TextStyle(color: AppColors.error, fontSize: 13)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
