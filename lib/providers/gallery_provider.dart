import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unisphere/models/gallery_photo_model.dart';
import 'package:unisphere/models/photo_album_model.dart';
import 'package:unisphere/services/gallery_service.dart';

/// Provider fetching top 6 recently published albums for Student & Parent dashboards
final recentPublishedAlbumsProvider = StreamProvider<List<PhotoAlbumModel>>((ref) {
  final galleryService = ref.watch(galleryServiceProvider);
  return galleryService.watchPublishedAlbums(limit: 6);
});

/// Provider fetching all published photo albums for the full Photo Gallery screen
final allPublishedAlbumsProvider = StreamProvider<List<PhotoAlbumModel>>((ref) {
  final galleryService = ref.watch(galleryServiceProvider);
  return galleryService.watchPublishedAlbums(limit: 100);
});

/// Provider fetching departmental albums for HOD (includes Drafts & Published)
final departmentAlbumsProvider = StreamProvider.family<List<PhotoAlbumModel>, String>((ref, departmentId) {
  final galleryService = ref.watch(galleryServiceProvider);
  return galleryService.watchDepartmentAlbums(departmentId);
});

/// Provider fetching all albums across all departments for Admin
final adminAlbumsProvider = StreamProvider<List<PhotoAlbumModel>>((ref) {
  final galleryService = ref.watch(galleryServiceProvider);
  return galleryService.watchAllAlbums();
});

/// Provider fetching photos within a specific album
final albumPhotosProvider = StreamProvider.family<List<GalleryPhotoModel>, String>((ref, albumId) {
  final galleryService = ref.watch(galleryServiceProvider);
  return galleryService.watchAlbumPhotos(albumId);
});
