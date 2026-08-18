import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unisphere/models/gallery_photo_model.dart';
import 'package:unisphere/models/photo_album_model.dart';
import 'package:unisphere/services/activity_log_service.dart';
import 'package:unisphere/services/storage_service.dart';

final galleryServiceProvider = Provider<GalleryService>((ref) {
  final storageService = ref.watch(storageServiceProvider);
  final activityLogService = ref.watch(activityLogServiceProvider);
  return GalleryService(
    storageService: storageService,
    activityLogService: activityLogService,
  );
});

class GalleryService {
  final FirebaseFirestore? _firestore;
  final StorageService _storageService;
  final ActivityLogService _activityLogService;

  GalleryService({
    FirebaseFirestore? firestore,
    required StorageService storageService,
    required ActivityLogService activityLogService,
  })  : _firestore = firestore ?? _tryGetFirestore(),
        _storageService = storageService,
        _activityLogService = activityLogService;

  static FirebaseFirestore? _tryGetFirestore() {
    try {
      return FirebaseFirestore.instance;
    } catch (_) {
      return null;
    }
  }

  /// Create a new photo album (Draft or Published)
  Future<String?> createAlbum({
    required PhotoAlbumModel album,
    required String userId,
    required String userName,
    required String userRole,
    File? coverPhotoFile,
  }) async {
    final firestore = _firestore;
    if (firestore == null) return null;

    try {
      String coverUrl = album.coverPhotoUrl;

      // Upload cover photo file if provided
      if (coverPhotoFile != null) {
        final storagePath = 'gallery-photos/${album.albumId}/cover_${DateTime.now().millisecondsSinceEpoch}.jpg';
        final uploaded = await _storageService.uploadFile(storagePath: storagePath, file: coverPhotoFile);
        if (uploaded != null) {
          coverUrl = uploaded;
        }
      }

      final newAlbum = album.copyWith(
        coverPhotoUrl: coverUrl,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        publishedAt: album.isPublished ? DateTime.now() : album.publishedAt,
      );

      await firestore.collection('photo_albums').doc(album.albumId).set(newAlbum.toMap(), SetOptions(merge: true));

      // Log activity
      await _activityLogService.logActivity(
        userId: userId,
        action: album.isPublished ? 'PUBLISH_ALBUM' : 'CREATE_ALBUM_DRAFT',
        module: 'GALLERY',
        entityId: album.albumId,
        description: 'Created photo album "${album.title}" (${album.statusString}) for department ${album.departmentName}',
        metadata: {
          'userName': userName,
          'userRole': userRole,
          'departmentId': album.departmentId,
          'status': album.statusString,
        },
      );

      return album.albumId;
    } catch (e) {
      debugPrint('GalleryService createAlbum error: $e');
      return null;
    }
  }

  /// Update existing album details
  Future<bool> updateAlbum({
    required PhotoAlbumModel album,
    required String userId,
    required String userName,
    required String userRole,
    File? newCoverPhotoFile,
  }) async {
    final firestore = _firestore;
    if (firestore == null) return false;

    try {
      String coverUrl = album.coverPhotoUrl;

      if (newCoverPhotoFile != null) {
        final storagePath = 'gallery-photos/${album.albumId}/cover_${DateTime.now().millisecondsSinceEpoch}.jpg';
        final uploaded = await _storageService.uploadFile(storagePath: storagePath, file: newCoverPhotoFile);
        if (uploaded != null) {
          coverUrl = uploaded;
        }
      }

      final updatedAlbum = album.copyWith(
        coverPhotoUrl: coverUrl,
        updatedAt: DateTime.now(),
      );

      await firestore.collection('photo_albums').doc(album.albumId).set(updatedAlbum.toMap(), SetOptions(merge: true));

      await _activityLogService.logActivity(
        userId: userId,
        action: 'UPDATE_ALBUM',
        module: 'GALLERY',
        entityId: album.albumId,
        description: 'Updated photo album "${album.title}"',
        metadata: {'userName': userName, 'userRole': userRole},
      );

      return true;
    } catch (e) {
      debugPrint('GalleryService updateAlbum error: $e');
      return false;
    }
  }

  /// Publish a draft album
  Future<bool> publishAlbum({
    required String albumId,
    required String userId,
    required String userName,
    required String userRole,
  }) async {
    final firestore = _firestore;
    if (firestore == null) return false;

    try {
      final now = DateTime.now();
      await firestore.collection('photo_albums').doc(albumId).update({
        'status': 'published',
        'publishedAt': now.toIso8601String(),
        'published_at': now.toIso8601String(),
        'updatedAt': now.toIso8601String(),
        'updated_at': now.toIso8601String(),
      });

      await _activityLogService.logActivity(
        userId: userId,
        action: 'PUBLISH_ALBUM',
        module: 'GALLERY',
        entityId: albumId,
        description: 'Published photo album $albumId to campus gallery',
        metadata: {'userName': userName, 'userRole': userRole},
      );

      return true;
    } catch (e) {
      debugPrint('GalleryService publishAlbum error: $e');
      return false;
    }
  }

  /// Hide an album
  Future<bool> hideAlbum({
    required String albumId,
    required String userId,
    required String userName,
    required String userRole,
  }) async {
    final firestore = _firestore;
    if (firestore == null) return false;

    try {
      await firestore.collection('photo_albums').doc(albumId).update({
        'status': 'hidden',
        'updatedAt': DateTime.now().toIso8601String(),
      });

      await _activityLogService.logActivity(
        userId: userId,
        action: 'HIDE_ALBUM',
        module: 'GALLERY',
        entityId: albumId,
        description: 'Hid photo album $albumId from gallery view',
        metadata: {'userName': userName, 'userRole': userRole},
      );

      return true;
    } catch (e) {
      debugPrint('GalleryService hideAlbum error: $e');
      return false;
    }
  }

  /// Delete album
  Future<bool> deleteAlbum({
    required String albumId,
    required String userId,
    required String userName,
    required String userRole,
  }) async {
    final firestore = _firestore;
    if (firestore == null) return false;

    try {
      // 1. Delete photo subcollection docs
      final photoDocs = await firestore.collection('photo_albums').doc(albumId).collection('photos').get();
      final batch = firestore.batch();
      for (final doc in photoDocs.docs) {
        batch.delete(doc.reference);
      }
      // 2. Delete main album doc
      batch.delete(firestore.collection('photo_albums').doc(albumId));
      await batch.commit();

      await _activityLogService.logActivity(
        userId: userId,
        action: 'DELETE_ALBUM',
        module: 'GALLERY',
        entityId: albumId,
        description: 'Deleted photo album $albumId and associated photos',
        metadata: {'userName': userName, 'userRole': userRole},
      );

      return true;
    } catch (e) {
      debugPrint('GalleryService deleteAlbum error: $e');
      return false;
    }
  }

  /// Upload multiple photos to album
  Future<List<GalleryPhotoModel>> uploadPhotosToAlbum({
    required String albumId,
    required List<File> files,
    required String uploadedBy,
    required String userName,
    required String userRole,
    List<String>? captions,
  }) async {
    final firestore = _firestore;
    if (firestore == null || files.isEmpty) return [];

    final List<GalleryPhotoModel> uploadedPhotos = [];

    try {
      final albumRef = firestore.collection('photo_albums').doc(albumId);
      final albumDoc = await albumRef.get();
      int currentCount = albumDoc.data()?['photoCount'] as int? ?? 0;
      String currentCover = albumDoc.data()?['coverPhotoUrl']?.toString() ?? '';

      for (int i = 0; i < files.length; i++) {
        final file = files[i];
        final photoId = 'PHOTO-${DateTime.now().millisecondsSinceEpoch}-$i';
        final storagePath = 'gallery-photos/$albumId/$photoId.jpg';

        final photoUrl = await _storageService.uploadFile(storagePath: storagePath, file: file);
        if (photoUrl != null) {
          final photoModel = GalleryPhotoModel(
            photoId: photoId,
            albumId: albumId,
            photoUrl: photoUrl,
            storagePath: storagePath,
            caption: captions != null && i < captions.length ? captions[i] : '',
            uploadedBy: uploadedBy,
            uploadedAt: DateTime.now(),
            displayOrder: currentCount + i,
          );

          await albumRef.collection('photos').doc(photoId).set(photoModel.toMap());
          uploadedPhotos.add(photoModel);

          // Set as cover photo if album currently has no cover photo
          if (currentCover.isEmpty && i == 0) {
            currentCover = photoUrl;
          }
        }
      }

      final newTotalCount = currentCount + uploadedPhotos.length;
      await albumRef.update({
        'photoCount': newTotalCount,
        'photo_count': newTotalCount,
        'coverPhotoUrl': currentCover,
        'cover_photo_url': currentCover,
        'updatedAt': DateTime.now().toIso8601String(),
      });

      await _activityLogService.logActivity(
        userId: uploadedBy,
        action: 'UPLOAD_PHOTOS',
        module: 'GALLERY',
        entityId: albumId,
        description: 'Uploaded ${uploadedPhotos.length} photos to album $albumId',
        metadata: {'userName': userName, 'userRole': userRole, 'photoCount': uploadedPhotos.length},
      );
    } catch (e) {
      debugPrint('GalleryService uploadPhotosToAlbum error: $e');
    }

    return uploadedPhotos;
  }

  /// Watch latest published albums for Students & Parents (Sorted newest publishedAt first)
  Stream<List<PhotoAlbumModel>> watchPublishedAlbums({int limit = 20}) {
    final firestore = _firestore;
    if (firestore == null) return Stream.value([]);

    try {
      return firestore
          .collection('photo_albums')
          .where('status', isEqualTo: 'published')
          .snapshots()
          .map((snap) {
        final albums = snap.docs.map((doc) => PhotoAlbumModel.fromMap(doc.data(), doc.id)).toList();
        albums.sort((a, b) => (b.publishedAt ?? b.createdAt).compareTo(a.publishedAt ?? a.createdAt));
        return albums.take(limit).toList();
      }).handleError((e) {
        debugPrint('GalleryService watchPublishedAlbums error: $e');
        return <PhotoAlbumModel>[];
      });
    } catch (e) {
      debugPrint('GalleryService watchPublishedAlbums exception: $e');
      return Stream.value([]);
    }
  }

  /// Watch departmental albums for HOD (includes Drafts & Published)
  Stream<List<PhotoAlbumModel>> watchDepartmentAlbums(String departmentId) {
    final firestore = _firestore;
    if (firestore == null || departmentId.isEmpty) return Stream.value([]);

    try {
      return firestore.collection('photo_albums').snapshots().map((snap) {
        final albums = snap.docs
            .map((doc) => PhotoAlbumModel.fromMap(doc.data(), doc.id))
            .where((album) => album.departmentId == departmentId || departmentId == 'All')
            .toList();
        albums.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
        return albums;
      }).handleError((e) {
        debugPrint('GalleryService watchDepartmentAlbums error: $e');
        return <PhotoAlbumModel>[];
      });
    } catch (e) {
      debugPrint('GalleryService watchDepartmentAlbums exception: $e');
      return Stream.value([]);
    }
  }

  /// Watch all albums for Admin
  Stream<List<PhotoAlbumModel>> watchAllAlbums() {
    final firestore = _firestore;
    if (firestore == null) return Stream.value([]);

    try {
      return firestore.collection('photo_albums').snapshots().map((snap) {
        final albums = snap.docs.map((doc) => PhotoAlbumModel.fromMap(doc.data(), doc.id)).toList();
        albums.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
        return albums;
      }).handleError((e) {
        debugPrint('GalleryService watchAllAlbums error: $e');
        return <PhotoAlbumModel>[];
      });
    } catch (e) {
      debugPrint('GalleryService watchAllAlbums exception: $e');
      return Stream.value([]);
    }
  }

  /// Watch photos of a specific album
  Stream<List<GalleryPhotoModel>> watchAlbumPhotos(String albumId) {
    final firestore = _firestore;
    if (firestore == null || albumId.isEmpty) return Stream.value([]);

    try {
      return firestore
          .collection('photo_albums')
          .doc(albumId)
          .collection('photos')
          .snapshots()
          .map((snap) {
        final photos = snap.docs.map((doc) => GalleryPhotoModel.fromMap(doc.data(), doc.id)).toList();
        photos.sort((a, b) => a.displayOrder.compareTo(b.displayOrder));
        return photos;
      }).handleError((e) {
        debugPrint('GalleryService watchAlbumPhotos error: $e');
        return <GalleryPhotoModel>[];
      });
    } catch (e) {
      debugPrint('GalleryService watchAlbumPhotos exception: $e');
      return Stream.value([]);
    }
  }
}
