import 'package:cloud_firestore/cloud_firestore.dart';

enum AlbumStatus {
  draft,
  published,
  hidden,
}

class PhotoAlbumModel {
  final String albumId;
  final String title;
  final String description;
  final DateTime eventDate;
  final String departmentId;
  final String departmentName;
  final String coverPhotoUrl;
  final AlbumStatus status;
  final String createdBy;
  final String? createdByName;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? publishedAt;
  final int photoCount;

  PhotoAlbumModel({
    required this.albumId,
    required this.title,
    this.description = '',
    required this.eventDate,
    required this.departmentId,
    required this.departmentName,
    this.coverPhotoUrl = '',
    this.status = AlbumStatus.draft,
    required this.createdBy,
    this.createdByName,
    required this.createdAt,
    required this.updatedAt,
    this.publishedAt,
    this.photoCount = 0,
  });

  bool get isPublished => status == AlbumStatus.published;
  bool get isDraft => status == AlbumStatus.draft;
  bool get isHidden => status == AlbumStatus.hidden;

  String get statusString {
    switch (status) {
      case AlbumStatus.published:
        return 'published';
      case AlbumStatus.hidden:
        return 'hidden';
      case AlbumStatus.draft:
        return 'draft';
    }
  }

  static AlbumStatus parseStatus(String? val) {
    if (val == null) return AlbumStatus.draft;
    switch (val.toLowerCase().trim()) {
      case 'published':
        return AlbumStatus.published;
      case 'hidden':
        return AlbumStatus.hidden;
      case 'draft':
      default:
        return AlbumStatus.draft;
    }
  }

  factory PhotoAlbumModel.fromMap(Map<String, dynamic> map, String id) {
    DateTime parseDate(dynamic val, DateTime fallback) {
      if (val == null) return fallback;
      if (val is Timestamp) return val.toDate();
      if (val is DateTime) return val;
      return DateTime.tryParse(val.toString()) ?? fallback;
    }

    final now = DateTime.now();

    return PhotoAlbumModel(
      albumId: id.isNotEmpty ? id : map['albumId']?.toString() ?? 'ALBUM-${now.millisecondsSinceEpoch}',
      title: map['title']?.toString() ?? 'Event Album',
      description: map['description']?.toString() ?? '',
      eventDate: parseDate(map['eventDate'] ?? map['event_date'], now),
      departmentId: map['departmentId']?.toString() ?? map['department_id']?.toString() ?? 'DEP-CSE',
      departmentName: map['departmentName']?.toString() ?? map['department_name']?.toString() ?? 'Computer Science & Engineering',
      coverPhotoUrl: map['coverPhotoUrl']?.toString() ?? map['cover_photo_url']?.toString() ?? '',
      status: parseStatus(map['status']?.toString()),
      createdBy: map['createdBy']?.toString() ?? map['created_by']?.toString() ?? '',
      createdByName: map['createdByName']?.toString() ?? map['created_by_name']?.toString(),
      createdAt: parseDate(map['createdAt'] ?? map['created_at'], now),
      updatedAt: parseDate(map['updatedAt'] ?? map['updated_at'], now),
      publishedAt: map['publishedAt'] != null ? parseDate(map['publishedAt'] ?? map['published_at'], now) : null,
      photoCount: (map['photoCount'] ?? map['photo_count'] ?? 0) as int,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'albumId': albumId,
      'id': albumId,
      'title': title,
      'description': description,
      'eventDate': eventDate.toIso8601String(),
      'event_date': eventDate.toIso8601String(),
      'departmentId': departmentId,
      'department_id': departmentId,
      'departmentName': departmentName,
      'department_name': departmentName,
      'coverPhotoUrl': coverPhotoUrl,
      'cover_photo_url': coverPhotoUrl,
      'status': statusString,
      'createdBy': createdBy,
      'created_by': createdBy,
      'createdByName': createdByName,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'publishedAt': publishedAt?.toIso8601String(),
      'photoCount': photoCount,
      'photo_count': photoCount,
    };
  }

  PhotoAlbumModel copyWith({
    String? albumId,
    String? title,
    String? description,
    DateTime? eventDate,
    String? departmentId,
    String? departmentName,
    String? coverPhotoUrl,
    AlbumStatus? status,
    String? createdBy,
    String? createdByName,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? publishedAt,
    int? photoCount,
  }) {
    return PhotoAlbumModel(
      albumId: albumId ?? this.albumId,
      title: title ?? this.title,
      description: description ?? this.description,
      eventDate: eventDate ?? this.eventDate,
      departmentId: departmentId ?? this.departmentId,
      departmentName: departmentName ?? this.departmentName,
      coverPhotoUrl: coverPhotoUrl ?? this.coverPhotoUrl,
      status: status ?? this.status,
      createdBy: createdBy ?? this.createdBy,
      createdByName: createdByName ?? this.createdByName,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      publishedAt: publishedAt ?? this.publishedAt,
      photoCount: photoCount ?? this.photoCount,
    );
  }
}
