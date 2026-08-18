import 'package:cloud_firestore/cloud_firestore.dart';

class GalleryPhotoModel {
  final String photoId;
  final String albumId;
  final String photoUrl;
  final String storagePath;
  final String caption;
  final String uploadedBy;
  final DateTime uploadedAt;
  final int displayOrder;

  GalleryPhotoModel({
    required this.photoId,
    required this.albumId,
    required this.photoUrl,
    this.storagePath = '',
    this.caption = '',
    required this.uploadedBy,
    required this.uploadedAt,
    this.displayOrder = 0,
  });

  factory GalleryPhotoModel.fromMap(Map<String, dynamic> map, String id) {
    DateTime parseDate(dynamic val, DateTime fallback) {
      if (val == null) return fallback;
      if (val is Timestamp) return val.toDate();
      if (val is DateTime) return val;
      return DateTime.tryParse(val.toString()) ?? fallback;
    }

    final now = DateTime.now();

    return GalleryPhotoModel(
      photoId: id.isNotEmpty ? id : map['photoId']?.toString() ?? 'PHOTO-${now.millisecondsSinceEpoch}',
      albumId: map['albumId']?.toString() ?? map['album_id']?.toString() ?? '',
      photoUrl: map['photoUrl']?.toString() ?? map['photo_url']?.toString() ?? map['url']?.toString() ?? '',
      storagePath: map['storagePath']?.toString() ?? map['storage_path']?.toString() ?? '',
      caption: map['caption']?.toString() ?? '',
      uploadedBy: map['uploadedBy']?.toString() ?? map['uploaded_by']?.toString() ?? '',
      uploadedAt: parseDate(map['uploadedAt'] ?? map['uploaded_at'], now),
      displayOrder: (map['displayOrder'] ?? map['display_order'] ?? 0) as int,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'photoId': photoId,
      'id': photoId,
      'albumId': albumId,
      'album_id': albumId,
      'photoUrl': photoUrl,
      'photo_url': photoUrl,
      'storagePath': storagePath,
      'storage_path': storagePath,
      'caption': caption,
      'uploadedBy': uploadedBy,
      'uploaded_by': uploadedBy,
      'uploadedAt': uploadedAt.toIso8601String(),
      'uploaded_at': uploadedAt.toIso8601String(),
      'displayOrder': displayOrder,
      'display_order': displayOrder,
    };
  }

  GalleryPhotoModel copyWith({
    String? photoId,
    String? albumId,
    String? photoUrl,
    String? storagePath,
    String? caption,
    String? uploadedBy,
    DateTime? uploadedAt,
    int? displayOrder,
  }) {
    return GalleryPhotoModel(
      photoId: photoId ?? this.photoId,
      albumId: albumId ?? this.albumId,
      photoUrl: photoUrl ?? this.photoUrl,
      storagePath: storagePath ?? this.storagePath,
      caption: caption ?? this.caption,
      uploadedBy: uploadedBy ?? this.uploadedBy,
      uploadedAt: uploadedAt ?? this.uploadedAt,
      displayOrder: displayOrder ?? this.displayOrder,
    );
  }
}
