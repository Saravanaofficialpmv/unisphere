class AnnouncementModel {
  final String id;
  final String title;
  final String content;
  final String authorName;
  final DateTime createdAt;
  final String? category; // 'General', 'Academic', 'Examination', 'Department', 'Placement', 'Internship', 'Event', 'Holiday', 'Emergency', 'Fee / Administration'
  final String priority; // 'Normal', 'Important', 'Urgent'
  final String? imageUrl;
  final String? attachmentUrl;
  final List<String>? relatedLinks;
  final List<String>? targetedRoles;
  final List<String>? targetedClasses;
  final List<String> readByUsers;
  final bool isNew;

  AnnouncementModel({
    required this.id,
    required this.title,
    required this.content,
    required this.authorName,
    required this.createdAt,
    this.category = 'General',
    this.priority = 'Normal',
    this.imageUrl,
    this.attachmentUrl,
    this.relatedLinks,
    this.targetedRoles,
    this.targetedClasses,
    this.readByUsers = const [],
    this.isNew = true,
  });

  bool isReadBy(String userId) => readByUsers.contains(userId);

  AnnouncementModel markReadFor(String userId) {
    if (readByUsers.contains(userId)) return this;
    final updatedList = List<String>.from(readByUsers)..add(userId);
    return copyWith(readByUsers: updatedList, isNew: false);
  }

  AnnouncementModel copyWith({
    List<String>? readByUsers,
    bool? isNew,
  }) {
    return AnnouncementModel(
      id: id,
      title: title,
      content: content,
      authorName: authorName,
      createdAt: createdAt,
      category: category,
      priority: priority,
      imageUrl: imageUrl,
      attachmentUrl: attachmentUrl,
      relatedLinks: relatedLinks,
      targetedRoles: targetedRoles,
      targetedClasses: targetedClasses,
      readByUsers: readByUsers ?? this.readByUsers,
      isNew: isNew ?? this.isNew,
    );
  }

  factory AnnouncementModel.fromMap(Map<String, dynamic> map) {
    return AnnouncementModel(
      id: map['id'].toString(),
      title: map['title'] ?? '',
      content: map['content'] ?? '',
      authorName: map['author_name'] ?? 'Admin',
      createdAt: DateTime.parse(map['created_at'] ?? DateTime.now().toIso8601String()),
      category: map['category'] ?? 'General',
      priority: map['priority'] ?? 'Normal',
      imageUrl: map['image_url'],
      attachmentUrl: map['attachment_url'],
      relatedLinks: List<String>.from(map['related_links'] ?? []),
      targetedRoles: List<String>.from(map['targeted_roles'] ?? []),
      targetedClasses: List<String>.from(map['targeted_classes'] ?? []),
      readByUsers: List<String>.from(map['read_by_users'] ?? []),
      isNew: map['is_new'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'author_name': authorName,
      'created_at': createdAt.toIso8601String(),
      'category': category,
      'priority': priority,
      'image_url': imageUrl,
      'attachment_url': attachmentUrl,
      'related_links': relatedLinks,
      'targeted_roles': targetedRoles,
      'targeted_classes': targetedClasses,
      'read_by_users': readByUsers,
      'is_new': isNew,
    };
  }
}
