class AnnouncementModel {
  final String id;
  final String title;
  final String content;
  final String authorName;
  final DateTime createdAt;
  final String? category;
  final String? imageUrl;
  final List<String>? targetedRoles;
  final List<String>? targetedClasses;

  AnnouncementModel({
    required this.id,
    required this.title,
    required this.content,
    required this.authorName,
    required this.createdAt,
    this.category,
    this.imageUrl,
    this.targetedRoles,
    this.targetedClasses,
  });

  factory AnnouncementModel.fromMap(Map<String, dynamic> map) {
    return AnnouncementModel(
      id: map['id'].toString(),
      title: map['title'] ?? '',
      content: map['content'] ?? '',
      authorName: map['author_name'] ?? 'Admin',
      createdAt: DateTime.parse(map['created_at'] ?? DateTime.now().toIso8601String()),
      category: map['category'],
      imageUrl: map['image_url'],
      targetedRoles: List<String>.from(map['targeted_roles'] ?? []),
      targetedClasses: List<String>.from(map['targeted_classes'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'content': content,
      'author_name': authorName,
      'created_at': createdAt.toIso8601String(),
      'category': category,
      'image_url': imageUrl,
      'targeted_roles': targetedRoles,
      'targeted_classes': targetedClasses,
    };
  }
}
